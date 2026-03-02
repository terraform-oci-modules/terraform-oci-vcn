locals {
  # Master kill switch
  create_vcn = var.create_vcn

  # Resolve availability domain numbers to tenancy-specific AD names.
  # var.ads accepts a list of integers like [1, 2, 3].
  # data.oci_identity_availability_domains returns ADs sorted by name (AD-1, AD-2, AD-3).
  # We map each number to the zero-indexed entry in that sorted list.
  availability_domains = data.oci_identity_availability_domains.ads.availability_domains
  ad_names = [
    for n in var.ads : local.availability_domains[n - 1].name
  ]

  # VCN CIDR blocks — primary + any secondary CIDRs
  vcn_cidr_blocks = concat([var.cidr], var.secondary_cidr_blocks)

  # DNS label: when enable_dns_hostnames=true and no explicit label given, derive from name.
  # OCI DNS labels: alphanumeric, max 15 chars, must start with a letter.
  vcn_dns_label = (
    var.vcn_dns_label != null
    ? var.vcn_dns_label
    : (
      var.enable_dns_hostnames
      ? substr(lower(replace(replace(var.name, "/[^a-zA-Z0-9]/", ""), "/^[0-9]+/", "a")), 0, 15)
      : null
    )
  )

  # ----------------------------------------------------------------------------
  # Subnet count logic
  # ----------------------------------------------------------------------------

  # NAT Gateway count logic:
  #   single_nat_gateway=true   → 1
  #   one_nat_gateway_per_ad    → one per AD when ads is set; falls back to one per
  #                               private subnet when ads=[] (regional mode has no ADs to pin to)
  #   otherwise                 → one per private subnet
  nat_gateway_count = (
    var.enable_nat_gateway == false
    ? 0
    : var.single_nat_gateway
    ? 1
    : var.one_nat_gateway_per_ad
    ? (length(var.ads) > 0 ? length(var.ads) : length(var.private_subnets))
    : length(var.private_subnets)
  )

  num_public_route_tables = var.create_multiple_public_route_tables ? length(var.public_subnets) : 1
  num_intra_route_tables  = var.create_multiple_intra_route_tables ? length(var.intra_subnets) : 1

  # ----------------------------------------------------------------------------
  # Tagging helpers
  # ----------------------------------------------------------------------------
  # Merge global tags with per-resource tags, OCI freeform_tags style.
  # Pattern: merge({"Name" = <display_name>}, var.tags, var.<resource>_tags)
  # For OCI we merge into freeform_tags; the "Name" key holds the display_name.

  anywhere = "0.0.0.0/0"
}

# Data source: resolve AD numbers → AD names.
# Uses tenancy_id when provided, otherwise falls back to compartment_id —
# the OCI ADs API works with any compartment in the tenancy.
data "oci_identity_availability_domains" "ads" {
  compartment_id = coalesce(var.tenancy_id, var.compartment_id)
}

################################################################################
# VCN
################################################################################

resource "oci_core_vcn" "this" {
  count = local.create_vcn ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = var.name
  cidr_blocks    = local.vcn_cidr_blocks
  dns_label      = local.vcn_dns_label
  is_ipv6enabled = var.enable_ipv6 ? true : null

  freeform_tags = merge({ "Name" = var.name }, var.tags, var.vcn_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, dns_label, freeform_tags]
  }
}

################################################################################
# DHCP Options
################################################################################

resource "oci_core_dhcp_options" "this" {
  count = local.create_vcn && var.enable_dhcp_options ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-dhcp-options"

  # DNS option — always required
  options {
    type        = "DomainNameServer"
    server_type = var.dhcp_options_server_type
    # custom_dns_servers only valid when server_type = "CustomDnsServer"
    custom_dns_servers = var.dhcp_options_server_type == "CustomDnsServer" ? var.dhcp_options_domain_name_servers : []
  }

  # Search domain option — only included when a value is provided
  dynamic "options" {
    for_each = var.dhcp_options_domain_name != "" ? [var.dhcp_options_domain_name] : []
    content {
      type                = "SearchDomain"
      search_domain_names = [options.value]
    }
  }

  freeform_tags = merge({ "Name" = "${var.name}-dhcp-options" }, var.tags, var.dhcp_options_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Public Subnets
################################################################################

locals {
  # Build a flat list of public subnet objects with computed names and ADs.
  # Index wraps around ADs when there are fewer ADs than subnets.
  public_subnet_objects = [
    for idx, cidr in var.public_subnets : {
      index        = idx
      cidr         = cidr
      display_name = length(var.public_subnet_names) > idx ? var.public_subnet_names[idx] : "${var.name}-${var.public_subnet_suffix}-${idx + 1}"
      ad           = length(local.ad_names) > 0 ? local.ad_names[idx % length(local.ad_names)] : null
    }
  ]
}

resource "oci_core_subnet" "public" {
  count = local.create_vcn ? length(var.public_subnets) : 0

  compartment_id      = var.compartment_id
  vcn_id              = oci_core_vcn.this[0].id
  cidr_block          = local.public_subnet_objects[count.index].cidr
  display_name        = local.public_subnet_objects[count.index].display_name
  availability_domain = local.public_subnet_objects[count.index].ad
  # Public subnets: prohibit_public_ip = false so instances can get public IPs
  prohibit_public_ip_on_vnic = false
  ipv6cidr_block             = var.enable_ipv6 && length(var.public_subnet_ipv6_cidrs) > count.index ? var.public_subnet_ipv6_cidrs[count.index] : null
  dhcp_options_id            = var.enable_dhcp_options ? oci_core_dhcp_options.this[0].id : null
  route_table_id             = var.create_igw ? element(oci_core_route_table.ig[*].id, var.create_multiple_public_route_tables ? count.index : 0) : null
  security_list_ids          = local.create_public_security_list ? [oci_core_security_list.public[0].id] : null

  freeform_tags = merge(
    { "Name" = local.public_subnet_objects[count.index].display_name },
    var.tags,
    var.public_subnet_tags,
    lookup(var.public_subnet_tags_per_ad, local.public_subnet_objects[count.index].ad != null ? local.public_subnet_objects[count.index].ad : "", {}),
  )
  defined_tags = merge(var.defined_tags, var.public_subnet_defined_tags)

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Private Subnets
################################################################################

locals {
  private_subnet_objects = [
    for idx, cidr in var.private_subnets : {
      index        = idx
      cidr         = cidr
      display_name = length(var.private_subnet_names) > idx ? var.private_subnet_names[idx] : "${var.name}-${var.private_subnet_suffix}-${idx + 1}"
      ad           = length(local.ad_names) > 0 ? local.ad_names[idx % length(local.ad_names)] : null
      # Which NAT GW route table does this subnet use?
      # single → index 0; one_per_ad → index = (idx % ad count); else → index = idx
      nat_rt_index = (
        var.single_nat_gateway
        ? 0
        : var.one_nat_gateway_per_ad
        ? (length(local.ad_names) > 0 ? idx % length(local.ad_names) : 0)
        : idx
      )
    }
  ]
}

resource "oci_core_subnet" "private" {
  count = local.create_vcn ? length(var.private_subnets) : 0

  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = local.private_subnet_objects[count.index].cidr
  display_name               = local.private_subnet_objects[count.index].display_name
  availability_domain        = local.private_subnet_objects[count.index].ad
  prohibit_public_ip_on_vnic = true
  ipv6cidr_block             = var.enable_ipv6 && length(var.private_subnet_ipv6_cidrs) > count.index ? var.private_subnet_ipv6_cidrs[count.index] : null
  dhcp_options_id            = var.enable_dhcp_options ? oci_core_dhcp_options.this[0].id : null
  route_table_id = (
    var.enable_nat_gateway
    ? oci_core_route_table.nat[local.private_subnet_objects[count.index].nat_rt_index].id
    : null
  )
  security_list_ids = local.create_private_security_list ? [oci_core_security_list.private[0].id] : null

  freeform_tags = merge(
    { "Name" = local.private_subnet_objects[count.index].display_name },
    var.tags,
    var.private_subnet_tags,
    lookup(var.private_subnet_tags_per_ad, local.private_subnet_objects[count.index].ad != null ? local.private_subnet_objects[count.index].ad : "", {}),
  )
  defined_tags = merge(var.defined_tags, var.private_subnet_defined_tags)

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Database Subnets
################################################################################

locals {
  database_subnet_objects = [
    for idx, cidr in var.database_subnets : {
      index        = idx
      cidr         = cidr
      display_name = length(var.database_subnet_names) > idx ? var.database_subnet_names[idx] : "${var.name}-${var.database_subnet_suffix}-${idx + 1}"
      ad           = length(local.ad_names) > 0 ? local.ad_names[idx % length(local.ad_names)] : null
    }
  ]
}

resource "oci_core_subnet" "database" {
  count = local.create_vcn ? length(var.database_subnets) : 0

  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = local.database_subnet_objects[count.index].cidr
  display_name               = local.database_subnet_objects[count.index].display_name
  availability_domain        = local.database_subnet_objects[count.index].ad
  prohibit_public_ip_on_vnic = true
  ipv6cidr_block             = var.enable_ipv6 && length(var.database_subnet_ipv6_cidrs) > count.index ? var.database_subnet_ipv6_cidrs[count.index] : null
  dhcp_options_id            = var.enable_dhcp_options ? oci_core_dhcp_options.this[0].id : null
  route_table_id = (
    var.create_database_subnet_route_table
    ? oci_core_route_table.database[0].id
    : (
      var.enable_nat_gateway
      ? oci_core_route_table.nat[0].id
      : null
    )
  )
  security_list_ids = local.create_database_security_list ? [oci_core_security_list.database[0].id] : null

  freeform_tags = merge(
    { "Name" = local.database_subnet_objects[count.index].display_name },
    var.tags,
    var.database_subnet_tags,
    lookup(var.database_subnet_tags_per_ad, local.database_subnet_objects[count.index].ad != null ? local.database_subnet_objects[count.index].ad : "", {}),
  )
  defined_tags = merge(var.defined_tags, var.database_subnet_defined_tags)

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

# Dedicated database route table (optional — service gateway route for DB traffic)
resource "oci_core_route_table" "database" {
  count = local.create_vcn && var.create_database_subnet_route_table && length(var.database_subnets) > 0 ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-${var.database_subnet_suffix}-rt"

  # Route to service gateway when available
  dynamic "route_rules" {
    for_each = var.create_service_gateway ? [1] : []
    content {
      destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this[0].id
      description       = "Auto-generated: All OCI Services via Service Gateway"
    }
  }

  # Route to NAT gateway when available
  dynamic "route_rules" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      destination       = local.anywhere
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.this[0].id
      description       = "Auto-generated: NAT Gateway as default gateway"
    }
  }

  # Optional direct Internet Gateway route for database subnets (use with caution)
  dynamic "route_rules" {
    for_each = var.create_database_internet_gateway_route && var.create_igw ? [1] : []
    content {
      destination       = local.anywhere
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.this[0].id
      description       = "Auto-generated: Internet Gateway route (create_database_internet_gateway_route=true)"
    }
  }

  freeform_tags = merge({ "Name" = "${var.name}-${var.database_subnet_suffix}-rt" }, var.tags, var.database_route_table_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Intra Subnets (fully isolated — no outbound route)
################################################################################

locals {
  intra_subnet_objects = [
    for idx, cidr in var.intra_subnets : {
      index        = idx
      cidr         = cidr
      display_name = length(var.intra_subnet_names) > idx ? var.intra_subnet_names[idx] : "${var.name}-${var.intra_subnet_suffix}-${idx + 1}"
      ad           = length(local.ad_names) > 0 ? local.ad_names[idx % length(local.ad_names)] : null
    }
  ]
}

resource "oci_core_subnet" "intra" {
  count = local.create_vcn ? length(var.intra_subnets) : 0

  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = local.intra_subnet_objects[count.index].cidr
  display_name               = local.intra_subnet_objects[count.index].display_name
  availability_domain        = local.intra_subnet_objects[count.index].ad
  prohibit_public_ip_on_vnic = true
  ipv6cidr_block             = var.enable_ipv6 && length(var.intra_subnet_ipv6_cidrs) > count.index ? var.intra_subnet_ipv6_cidrs[count.index] : null
  dhcp_options_id            = var.enable_dhcp_options ? oci_core_dhcp_options.this[0].id : null
  # No route table — intra subnets are fully isolated (use VCN default/empty RT)
  route_table_id    = element(oci_core_route_table.intra[*].id, var.create_multiple_intra_route_tables ? count.index : 0)
  security_list_ids = local.create_intra_security_list ? [oci_core_security_list.intra[0].id] : null

  freeform_tags = merge(
    { "Name" = local.intra_subnet_objects[count.index].display_name },
    var.tags,
    var.intra_subnet_tags,
    lookup(var.intra_subnet_tags_per_ad, local.intra_subnet_objects[count.index].ad != null ? local.intra_subnet_objects[count.index].ad : "", {}),
  )
  defined_tags = merge(var.defined_tags, var.intra_subnet_defined_tags)

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

# Empty route table for intra subnets (no rules = fully isolated)
resource "oci_core_route_table" "intra" {
  count = local.create_vcn && length(var.intra_subnets) > 0 ? local.num_intra_route_tables : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = local.num_intra_route_tables > 1 ? "${var.name}-${var.intra_subnet_suffix}-rt-${count.index + 1}" : "${var.name}-${var.intra_subnet_suffix}-rt"

  # No route_rules — intentionally empty for full isolation

  freeform_tags = merge({ "Name" = local.num_intra_route_tables > 1 ? "${var.name}-${var.intra_subnet_suffix}-rt-${count.index + 1}" : "${var.name}-${var.intra_subnet_suffix}-rt" }, var.tags, var.intra_route_table_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Internet Gateway (IGW)
################################################################################

resource "oci_core_internet_gateway" "this" {
  count = local.create_vcn && var.create_igw ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-igw"

  freeform_tags = merge({ "Name" = "${var.name}-igw" }, var.tags, var.igw_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

resource "oci_core_route_table" "ig" {
  count = local.create_vcn && var.create_igw && length(var.public_subnets) > 0 ? local.num_public_route_tables : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = local.num_public_route_tables > 1 ? "${var.name}-${var.public_subnet_suffix}-rt-${count.index + 1}" : "${var.name}-igw-rt"

  # Default route → Internet Gateway
  route_rules {
    destination       = local.anywhere
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this[0].id
    description       = "Auto-generated: Internet Gateway as default gateway"
  }

  # IPv6 default route → Internet Gateway (when IPv6 is enabled)
  dynamic "route_rules" {
    for_each = var.enable_ipv6 ? [1] : []
    content {
      destination       = "::/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_internet_gateway.this[0].id
      description       = "Auto-generated: Internet Gateway as IPv6 default gateway"
    }
  }

  # Additional user-supplied rules — symbolic dispatch
  dynamic "route_rules" {
    for_each = var.internet_gateway_route_rules != null ? {
      for k, v in var.internet_gateway_route_rules : k => v
      if v.network_entity_id == "drg" && var.attached_drg_id != null
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = var.attached_drg_id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  dynamic "route_rules" {
    for_each = var.internet_gateway_route_rules != null ? {
      for k, v in var.internet_gateway_route_rules : k => v
      if v.network_entity_id == "internet_gateway"
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = oci_core_internet_gateway.this[0].id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  dynamic "route_rules" {
    for_each = var.internet_gateway_route_rules != null ? {
      for k, v in var.internet_gateway_route_rules : k => v
      if startswith(v.network_entity_id, "lpg@") && var.local_peering_gateways != null
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = oci_core_local_peering_gateway.this[split("@", route_rules.value.network_entity_id)[1]].id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  dynamic "route_rules" {
    for_each = var.internet_gateway_route_rules != null ? {
      for k, v in var.internet_gateway_route_rules : k => v
      if !contains(["drg", "internet_gateway"], v.network_entity_id) && !startswith(v.network_entity_id, "lpg@")
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = route_rules.value.network_entity_id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  freeform_tags = merge({ "Name" = local.num_public_route_tables > 1 ? "${var.name}-${var.public_subnet_suffix}-rt-${count.index + 1}" : "${var.name}-igw-rt" }, var.tags, var.public_route_table_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# NAT Gateway (NGW)
################################################################################

# Reserved public IP for the first NAT gateway — created only when nat_gateway_public_ip_id = "RESERVED"
resource "oci_core_public_ip" "nat" {
  count = local.create_vcn && var.enable_nat_gateway && var.nat_gateway_public_ip_id == "RESERVED" ? 1 : 0

  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "${var.name}-nat-ip"

  freeform_tags = merge({ "Name" = "${var.name}-nat-ip" }, var.tags, var.nat_gateway_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

locals {
  # Resolve the public_ip_id for the first NAT gateway:
  #   null       → OCI auto-assigns (no explicit IP)
  #   "RESERVED" → use the reserved IP created above
  #   "<ocid>"   → use an existing reserved IP
  nat_public_ip_id = (
    var.nat_gateway_public_ip_id == null ? null
    : var.nat_gateway_public_ip_id == "RESERVED" ? oci_core_public_ip.nat[0].id
    : var.nat_gateway_public_ip_id
  )
}

resource "oci_core_nat_gateway" "this" {
  # One NAT GW per local.nat_gateway_count
  count = local.create_vcn && var.enable_nat_gateway ? local.nat_gateway_count : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = local.nat_gateway_count == 1 ? "${var.name}-nat" : "${var.name}-nat-${count.index + 1}"
  # Reserved/existing public IP only applied to the first NAT gateway
  public_ip_id = count.index == 0 ? local.nat_public_ip_id : null

  freeform_tags = merge(
    { "Name" = local.nat_gateway_count == 1 ? "${var.name}-nat" : "${var.name}-nat-${count.index + 1}" },
    var.tags,
    var.nat_gateway_tags,
  )
  defined_tags = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

# One route table per NAT GW (private subnets reference these by index)
resource "oci_core_route_table" "nat" {
  count = local.create_vcn && var.enable_nat_gateway ? local.nat_gateway_count : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = local.nat_gateway_count == 1 ? "${var.name}-nat-rt" : "${var.name}-nat-rt-${count.index + 1}"

  # Default route → this NAT GW
  route_rules {
    destination       = var.nat_gateway_destination_cidr_block
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this[count.index].id
    description       = "Auto-generated: NAT Gateway as default gateway"
  }

  # Also route OCI Services traffic through Service Gateway when present
  dynamic "route_rules" {
    for_each = var.create_service_gateway ? [1] : []
    content {
      destination       = lookup(data.oci_core_services.all_oci_services[0].services[0], "cidr_block")
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this[0].id
      description       = "Auto-generated: All OCI Services via Service Gateway"
    }
  }

  # Additional user-supplied rules — symbolic dispatch
  dynamic "route_rules" {
    for_each = var.nat_gateway_route_rules != null ? {
      for k, v in var.nat_gateway_route_rules : k => v
      if v.network_entity_id == "drg" && var.attached_drg_id != null
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = var.attached_drg_id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  dynamic "route_rules" {
    for_each = var.nat_gateway_route_rules != null ? {
      for k, v in var.nat_gateway_route_rules : k => v
      if v.network_entity_id == "nat_gateway"
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = oci_core_nat_gateway.this[count.index].id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  dynamic "route_rules" {
    for_each = var.nat_gateway_route_rules != null ? {
      for k, v in var.nat_gateway_route_rules : k => v
      if startswith(v.network_entity_id, "lpg@") && var.local_peering_gateways != null
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = oci_core_local_peering_gateway.this[split("@", route_rules.value.network_entity_id)[1]].id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  dynamic "route_rules" {
    for_each = var.nat_gateway_route_rules != null ? {
      for k, v in var.nat_gateway_route_rules : k => v
      if !contains(["drg", "nat_gateway"], v.network_entity_id) && !startswith(v.network_entity_id, "lpg@")
    } : {}
    content {
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      network_entity_id = route_rules.value.network_entity_id
      description       = lookup(route_rules.value, "description", null)
    }
  }

  freeform_tags = merge(
    { "Name" = local.nat_gateway_count == 1 ? "${var.name}-nat-rt" : "${var.name}-nat-rt-${count.index + 1}" },
    var.tags,
    var.private_route_table_tags,
  )
  defined_tags = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Service Gateway (SGW) — OCI-specific
################################################################################

data "oci_core_services" "all_oci_services" {
  count = local.create_vcn && var.create_service_gateway ? 1 : 0

  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "this" {
  count = local.create_vcn && var.create_service_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-sgw"

  services {
    service_id = lookup(data.oci_core_services.all_oci_services[0].services[0], "id")
  }

  freeform_tags = merge({ "Name" = "${var.name}-sgw" }, var.tags, var.service_gateway_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Local Peering Gateway (LPG) — OCI-specific
################################################################################

resource "oci_core_local_peering_gateway" "this" {
  for_each = local.create_vcn ? (var.local_peering_gateways != null ? var.local_peering_gateways : {}) : {}

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-${each.key}"

  peer_id        = can(each.value.peer_id) ? each.value.peer_id : null
  route_table_id = can(each.value.route_table_id) ? each.value.route_table_id : null

  freeform_tags = merge({ "Name" = "${var.name}-${each.key}" }, var.tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# VCN Default Security List — lockdown or restore
#
# OCI creates a default security list on every VCN. Best practice is to lock it
# down (remove all rules) and manage security explicitly on subnets.
# Setting lockdown_default_seclist=false restores the OCI-default rules instead.
################################################################################

# Lockdown: replace all rules with an empty set
resource "oci_core_default_security_list" "lockdown" {
  count = local.create_vcn && var.lockdown_default_seclist ? 1 : 0

  manage_default_resource_id = oci_core_vcn.this[0].default_security_list_id

  # No ingress_security_rules / egress_security_rules blocks — removes all rules

  lifecycle {
    ignore_changes = [egress_security_rules, ingress_security_rules, defined_tags]
  }
}

# Restore: re-apply OCI's factory default rules
resource "oci_core_default_security_list" "restore_default" {
  count = local.create_vcn && !var.lockdown_default_seclist ? 1 : 0

  manage_default_resource_id = oci_core_vcn.this[0].default_security_list_id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all egress traffic"
  }

  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "Allow SSH from anywhere"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    description = "Allow ICMP type 3 code 4 from anywhere"
    icmp_options {
      type = "3"
      code = "4"
    }
  }

  dynamic "ingress_security_rules" {
    for_each = oci_core_vcn.this[0].cidr_blocks
    iterator = vcn_cidr
    content {
      protocol    = "1" # ICMP
      source      = vcn_cidr.value
      description = "Allow ICMP type 3 from VCN CIDR ${vcn_cidr.value}"
      icmp_options {
        type = "3"
      }
    }
  }

  lifecycle {
    ignore_changes = [egress_security_rules, ingress_security_rules, defined_tags]
  }
}
