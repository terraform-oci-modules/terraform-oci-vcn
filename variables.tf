variable "create_vcn" {
  description = "Controls if VCN should be created (it affects almost all resources)"
  type        = bool
  default     = true
}

variable "compartment_id" {
  description = "The OCID of the compartment where the VCN and all resources will be created"
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.(compartment|tenancy)\\.oc1\\.", var.compartment_id))
    error_message = "compartment_id must be a valid OCI compartment or tenancy OCID (e.g. ocid1.compartment.oc1... or ocid1.tenancy.oc1...)."
  }
}

variable "tenancy_id" {
  description = <<-EOT
    The OCID of the tenancy, used to resolve availability domain names.

    Optional — when null (default), the module uses var.compartment_id to query ADs,
    which works for any compartment in the tenancy. Set this explicitly only when your
    compartment lacks IAM permission to list ADs, which is rare.
  EOT
  type        = string
  default     = null

  validation {
    condition     = var.tenancy_id == null ? true : can(regex("^ocid1\\.tenancy\\.oc1\\.", var.tenancy_id))
    error_message = "tenancy_id must be a valid OCI tenancy OCID (e.g. ocid1.tenancy.oc1...) or null."
  }
}

variable "tags" {
  description = "A map of freeform tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "A map of defined tags (namespace.key = value) to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# VCN
################################################################################

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "cidr" {
  description = "The primary IPv4 CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "secondary_cidr_blocks" {
  description = "List of secondary IPv4 CIDR blocks to associate with the VCN"
  type        = list(string)
  default     = []
}

variable "ads" {
  description = <<-EOT
    List of availability domain numbers (e.g. [1, 2, 3]) to pin subnets to specific ADs.

    OCI supports two subnet placement modes:
      - Regional (default, recommended): leave ads = [] — subnets span all ADs in the
        region automatically. This is the simplest and most resilient choice for most workloads.
      - AD-specific: set ads = [1, 2, 3] — each subnet is pinned to one AD. Use this only
        when you need workload-level AD affinity (e.g. bare metal, local NVMe, AD-local services).

    When ads is set, subnets are distributed round-robin across the listed ADs so you can
    create more subnets than ADs (e.g. 6 subnets across 3 ADs gives two subnets per AD).
  EOT
  type        = list(number)
  default     = []

  validation {
    condition     = alltrue([for n in var.ads : n >= 1])
    error_message = "All ads values must be >= 1 (AD numbers are 1-indexed)."
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VCN (sets vcn_dns_label)"
  type        = bool
  default     = true
}

variable "vcn_dns_label" {
  description = "A DNS label for the VCN. When null and enable_dns_hostnames is true, derived from var.name. Set to empty string to disable DNS"
  type        = string
  default     = null

  validation {
    condition     = var.vcn_dns_label == null ? true : length(var.vcn_dns_label) == 0 ? true : length(regexall("^[a-zA-Z][a-zA-Z0-9]{0,14}$", var.vcn_dns_label)) > 0
    error_message = "vcn_dns_label must be null (auto-derive), empty string (disable), or an alphanumeric string of 1-15 chars beginning with a letter."
  }
}

variable "enable_ipv6" {
  description = "Requests an Oracle-provided IPv6 CIDR block for the VCN. Subnets must be assigned explicit IPv6 CIDR blocks via <tier>_subnet_ipv6_cidrs"
  type        = bool
  default     = false
}

variable "vcn_tags" {
  description = "Additional freeform tags for the VCN"
  type        = map(string)
  default     = {}
}

################################################################################
# Public Subnets
################################################################################

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks inside the VCN"
  type        = list(string)
  default     = []
}

variable "public_subnet_names" {
  description = "Explicit display names for public subnets. If empty, names are generated"
  type        = list(string)
  default     = []
}

variable "public_subnet_suffix" {
  description = "Suffix to append to public subnet names"
  type        = string
  default     = "public"
}

variable "public_subnet_tags" {
  description = "Additional freeform tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags_per_ad" {
  description = "Additional freeform tags for the public subnets where the primary key is the AD name (e.g. \"NATD:US-ASHBURN-AD-1\")"
  type        = map(map(string))
  default     = {}
}

variable "public_subnet_defined_tags" {
  description = "Additional defined tags for the public subnets, merged with var.defined_tags"
  type        = map(string)
  default     = {}
}

variable "public_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for public subnets. Length must match public_subnets. Requires enable_ipv6 = true"
  type        = list(string)
  default     = []
}

variable "public_route_table_tags" {
  description = "Additional freeform tags for the public route table"
  type        = map(string)
  default     = {}
}

variable "create_multiple_public_route_tables" {
  description = "When true, creates a dedicated route table for each public subnet. When false, all public subnets share a single route table"
  type        = bool
  default     = false
}

################################################################################
# Private Subnets
################################################################################

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks inside the VCN"
  type        = list(string)
  default     = []
}

variable "private_subnet_names" {
  description = "Explicit display names for private subnets. If empty, names are generated"
  type        = list(string)
  default     = []
}

variable "private_subnet_suffix" {
  description = "Suffix to append to private subnet names"
  type        = string
  default     = "private"
}

variable "private_subnet_tags" {
  description = "Additional freeform tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags_per_ad" {
  description = "Additional freeform tags for the private subnets where the primary key is the AD name (e.g. \"NATD:US-ASHBURN-AD-1\")"
  type        = map(map(string))
  default     = {}
}

variable "private_subnet_defined_tags" {
  description = "Additional defined tags for the private subnets, merged with var.defined_tags"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for private subnets. Length must match private_subnets. Requires enable_ipv6 = true"
  type        = list(string)
  default     = []
}

variable "private_route_table_tags" {
  description = "Additional freeform tags for the private route tables"
  type        = map(string)
  default     = {}
}

################################################################################
# Database Subnets
################################################################################

variable "database_subnets" {
  description = "A list of database subnet CIDR blocks inside the VCN (private + service gateway route)"
  type        = list(string)
  default     = []
}

variable "database_subnet_names" {
  description = "Explicit display names for database subnets. If empty, names are generated"
  type        = list(string)
  default     = []
}

variable "database_subnet_suffix" {
  description = "Suffix to append to database subnet names"
  type        = string
  default     = "db"
}

variable "database_subnet_tags" {
  description = "Additional freeform tags for the database subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags_per_ad" {
  description = "Additional freeform tags for the database subnets where the primary key is the AD name (e.g. \"NATD:US-ASHBURN-AD-1\")"
  type        = map(map(string))
  default     = {}
}

variable "database_subnet_defined_tags" {
  description = "Additional defined tags for the database subnets, merged with var.defined_tags"
  type        = map(string)
  default     = {}
}

variable "database_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for database subnets. Length must match database_subnets. Requires enable_ipv6 = true"
  type        = list(string)
  default     = []
}

variable "create_database_subnet_route_table" {
  description = "Controls if a dedicated route table for database subnets should be created. When false, database subnets use the private route table"
  type        = bool
  default     = false
}

variable "create_database_internet_gateway_route" {
  description = "Controls if an Internet Gateway route is added to the database route table. Requires create_database_subnet_route_table = true and create_igw = true. Use with caution — database subnets are normally private"
  type        = bool
  default     = false
}

variable "database_route_table_tags" {
  description = "Additional freeform tags for the database route tables"
  type        = map(string)
  default     = {}
}

################################################################################
# Intra Subnets
################################################################################

variable "intra_subnets" {
  description = "A list of intra subnet CIDR blocks inside the VCN (fully isolated, no outbound route)"
  type        = list(string)
  default     = []
}

variable "intra_subnet_names" {
  description = "Explicit display names for intra subnets. If empty, names are generated"
  type        = list(string)
  default     = []
}

variable "intra_subnet_suffix" {
  description = "Suffix to append to intra subnet names"
  type        = string
  default     = "intra"
}

variable "intra_subnet_tags" {
  description = "Additional freeform tags for the intra subnets"
  type        = map(string)
  default     = {}
}

variable "intra_subnet_tags_per_ad" {
  description = "Additional freeform tags for the intra subnets where the primary key is the AD name (e.g. \"NATD:US-ASHBURN-AD-1\")"
  type        = map(map(string))
  default     = {}
}

variable "intra_subnet_defined_tags" {
  description = "Additional defined tags for the intra subnets, merged with var.defined_tags"
  type        = map(string)
  default     = {}
}

variable "intra_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for intra subnets. Length must match intra_subnets. Requires enable_ipv6 = true"
  type        = list(string)
  default     = []
}

variable "intra_route_table_tags" {
  description = "Additional freeform tags for the intra route table"
  type        = map(string)
  default     = {}
}

variable "create_multiple_intra_route_tables" {
  description = "When true, creates a dedicated route table for each intra subnet. When false, all intra subnets share a single route table"
  type        = bool
  default     = false
}

################################################################################
# Internet Gateway
################################################################################

variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets"
  type        = bool
  default     = true
}

variable "igw_tags" {
  description = "Additional freeform tags for the Internet Gateway"
  type        = map(string)
  default     = {}
}

variable "internet_gateway_route_rules" {
  description = "Additional route rules to add to the Internet Gateway route table. Use symbolic network_entity_id values: 'drg', 'internet_gateway', 'lpg@<key>'"
  type        = list(map(string))
  default     = null
}

################################################################################
# NAT Gateway
################################################################################

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_ad" {
  description = "Should be true if you want one NAT Gateway per availability domain. Has no effect when ads = [] (regional subnets) — in that case a single NAT Gateway is sufficient since regional subnets already span all ADs. Requires var.ads to be set and var.single_nat_gateway to be false"
  type        = bool
  default     = false
}

variable "nat_gateway_tags" {
  description = "Additional freeform tags for the NAT Gateways"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_route_rules" {
  description = "Additional route rules to add to the NAT Gateway route table(s). Use symbolic network_entity_id values: 'drg', 'nat_gateway', 'lpg@<key>'"
  type        = list(map(string))
  default     = null
}

variable "nat_gateway_destination_cidr_block" {
  description = "Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "nat_gateway_public_ip_id" {
  description = <<-EOT
    Controls the public IP attached to the first (or only) NAT Gateway:
      - null (default): OCI assigns an ephemeral public IP automatically.
      - "RESERVED": the module creates a new reserved public IP and attaches it.
        Use this to get a stable, predictable outbound IP (e.g. for firewall allowlisting).
      - "<ocid>": attach an existing reserved public IP by OCID.
    Has no effect when enable_nat_gateway = false.
    When multiple NAT gateways are created, only the first one gets this IP.
  EOT
  type        = string
  default     = null
}

################################################################################
# Service Gateway (OCI-specific)
################################################################################

variable "create_service_gateway" {
  description = "Controls if an OCI Service Gateway is created (routes traffic to Oracle Services Network without going to the internet)"
  type        = bool
  default     = false
}

variable "service_gateway_tags" {
  description = "Additional freeform tags for the Service Gateway"
  type        = map(string)
  default     = {}
}

################################################################################
# Local Peering Gateways (OCI-specific)
################################################################################

variable "attached_drg_id" {
  description = "OCID of a DRG already attached to the VCN. Used for symbolic 'drg' route rules"
  type        = string
  default     = null
}

variable "local_peering_gateways" {
  description = "Map of Local Peering Gateways to attach to the VCN. Key is the LPG name, value is an object with optional peer_id and route_table_id"
  type        = map(any)
  default     = null
}

################################################################################
# DHCP Options
################################################################################

variable "enable_dhcp_options" {
  description = "Controls if a custom DHCP options set is created and associated with all subnets. When false, subnets use the VCN default DHCP options (VcnLocalPlusInternet resolver)"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "A domain name to append to DNS search for instances in the VCN. Only used when enable_dhcp_options = true"
  type        = string
  default     = ""
}

variable "dhcp_options_server_type" {
  description = "DNS server type for the DHCP options set. 'VcnLocalPlusInternet' uses the OCI VCN resolver (equivalent to AmazonProvidedDNS). 'CustomDnsServer' uses the IPs in dhcp_options_domain_name_servers. Only used when enable_dhcp_options = true"
  type        = string
  default     = "VcnLocalPlusInternet"
  validation {
    condition     = contains(["VcnLocalPlusInternet", "CustomDnsServer"], var.dhcp_options_server_type)
    error_message = "dhcp_options_server_type must be 'VcnLocalPlusInternet' or 'CustomDnsServer'."
  }
}

variable "dhcp_options_domain_name_servers" {
  description = "List of custom DNS server IP addresses. Required when dhcp_options_server_type = 'CustomDnsServer'. Only used when enable_dhcp_options = true"
  type        = list(string)
  default     = []
}

variable "dhcp_options_tags" {
  description = "Additional freeform tags for the DHCP options set. Only used when enable_dhcp_options = true"
  type        = map(string)
  default     = {}
}

################################################################################
# Default Security List
################################################################################

variable "lockdown_default_seclist" {
  description = "Whether to remove all default security rules from the VCN Default Security List. Recommended true for security best practice"
  type        = bool
  default     = true
}

################################################################################
# Public Security List
################################################################################

variable "public_dedicated_security_list" {
  description = "Whether to create a dedicated security list for public subnets and attach it (instead of relying solely on the VCN default security list)"
  type        = bool
  default     = false
}

variable "public_inbound_security_rules" {
  description = "Inbound (ingress) security rules for the public dedicated security list"
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, null)
    stateless   = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ]
}

variable "public_outbound_security_rules" {
  description = "Outbound (egress) security rules for the public dedicated security list"
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, null)
    stateless        = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ]
}

variable "public_acl_tags" {
  description = "Additional freeform tags for the public dedicated security list"
  type        = map(string)
  default     = {}
}

################################################################################
# Private Security List
################################################################################

variable "private_dedicated_security_list" {
  description = "Whether to create a dedicated security list for private subnets and attach it"
  type        = bool
  default     = false
}

variable "private_inbound_security_rules" {
  description = "Inbound (ingress) security rules for the private dedicated security list"
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, null)
    stateless   = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ]
}

variable "private_outbound_security_rules" {
  description = "Outbound (egress) security rules for the private dedicated security list"
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, null)
    stateless        = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ]
}

variable "private_acl_tags" {
  description = "Additional freeform tags for the private dedicated security list"
  type        = map(string)
  default     = {}
}

################################################################################
# Database Security List
################################################################################

variable "database_dedicated_security_list" {
  description = "Whether to create a dedicated security list for database subnets and attach it"
  type        = bool
  default     = false
}

variable "database_inbound_security_rules" {
  description = "Inbound (ingress) security rules for the database dedicated security list"
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, null)
    stateless   = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ]
}

variable "database_outbound_security_rules" {
  description = "Outbound (egress) security rules for the database dedicated security list"
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, null)
    stateless        = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ]
}

variable "database_acl_tags" {
  description = "Additional freeform tags for the database dedicated security list"
  type        = map(string)
  default     = {}
}

################################################################################
# Intra Security List
################################################################################

variable "intra_dedicated_security_list" {
  description = "Whether to create a dedicated security list for intra subnets and attach it"
  type        = bool
  default     = false
}

variable "intra_inbound_security_rules" {
  description = "Inbound (ingress) security rules for the intra dedicated security list"
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, null)
    stateless   = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ]
}

variable "intra_outbound_security_rules" {
  description = "Outbound (egress) security rules for the intra dedicated security list"
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, null)
    stateless        = optional(bool, false)
    tcp_options = optional(object({
      min = number
      max = number
    }), null)
    udp_options = optional(object({
      min = number
      max = number
    }), null)
    icmp_options = optional(object({
      type = number
      code = optional(number, null)
    }), null)
  }))
  default = [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ]
}

variable "intra_acl_tags" {
  description = "Additional freeform tags for the intra dedicated security list"
  type        = map(string)
  default     = {}
}

################################################################################
# Flow Logs
################################################################################

variable "enable_flow_log" {
  description = "Whether or not to enable VCN Flow Logs (OCI Logging service)"
  type        = bool
  default     = false
}

variable "flow_log_retention_duration" {
  description = "Log retention duration in days for VCN flow logs. Allowed values: 30, 60, 90, 180, 365"
  type        = number
  default     = 30

  validation {
    condition     = contains([30, 60, 90, 180, 365], var.flow_log_retention_duration)
    error_message = "flow_log_retention_duration must be one of: 30, 60, 90, 180, 365."
  }
}

variable "flow_log_tags" {
  description = "Additional freeform tags for the flow log resources"
  type        = map(string)
  default     = {}
}
