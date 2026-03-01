################################################################################
# Per-tier Dedicated Security Lists
#
# OCI security lists are stateful, subnet-level firewall rules — the direct
# equivalent of AWS Network ACLs (NACLs). Each tier has an opt-in flag:
#   <tier>_dedicated_security_list = true
#
# When enabled, a dedicated oci_core_security_list is created for that tier and
# attached to every subnet in that tier. The VCN default security list continues
# to be attached alongside it (OCI supports multiple security lists per subnet).
#
# Rule shape (OCI-native, differs from AWS NACL):
#   - No rule_number (OCI evaluates all matching rules, not in priority order)
#   - protocol: "all", "6" (TCP), "17" (UDP), "1" (ICMP)
#   - source_type / destination_type: "CIDR_BLOCK" or "SERVICE_CIDR_BLOCK"
#   - Optional tcp_options / udp_options / icmp_options sub-blocks
################################################################################

locals {
  create_public_security_list   = local.create_vcn && var.public_dedicated_security_list && length(var.public_subnets) > 0
  create_private_security_list  = local.create_vcn && var.private_dedicated_security_list && length(var.private_subnets) > 0
  create_database_security_list = local.create_vcn && var.database_dedicated_security_list && length(var.database_subnets) > 0
  create_intra_security_list    = local.create_vcn && var.intra_dedicated_security_list && length(var.intra_subnets) > 0
}

################################################################################
# Public Security List
################################################################################

resource "oci_core_security_list" "public" {
  count = local.create_public_security_list ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-${var.public_subnet_suffix}-sl"

  dynamic "ingress_security_rules" {
    for_each = var.public_inbound_security_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      description = ingress_security_rules.value.description
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.public_outbound_security_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      description      = egress_security_rules.value.description
      stateless        = egress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.tcp_options != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.udp_options != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp_options != null ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  freeform_tags = merge({ "Name" = "${var.name}-${var.public_subnet_suffix}-sl" }, var.tags, var.public_acl_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Private Security List
################################################################################

resource "oci_core_security_list" "private" {
  count = local.create_private_security_list ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-${var.private_subnet_suffix}-sl"

  dynamic "ingress_security_rules" {
    for_each = var.private_inbound_security_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      description = ingress_security_rules.value.description
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.private_outbound_security_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      description      = egress_security_rules.value.description
      stateless        = egress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.tcp_options != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.udp_options != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp_options != null ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  freeform_tags = merge({ "Name" = "${var.name}-${var.private_subnet_suffix}-sl" }, var.tags, var.private_acl_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Database Security List
################################################################################

resource "oci_core_security_list" "database" {
  count = local.create_database_security_list ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-${var.database_subnet_suffix}-sl"

  dynamic "ingress_security_rules" {
    for_each = var.database_inbound_security_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      description = ingress_security_rules.value.description
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.database_outbound_security_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      description      = egress_security_rules.value.description
      stateless        = egress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.tcp_options != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.udp_options != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp_options != null ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  freeform_tags = merge({ "Name" = "${var.name}-${var.database_subnet_suffix}-sl" }, var.tags, var.database_acl_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Intra Security List
################################################################################

resource "oci_core_security_list" "intra" {
  count = local.create_intra_security_list ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.name}-${var.intra_subnet_suffix}-sl"

  dynamic "ingress_security_rules" {
    for_each = var.intra_inbound_security_rules
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      description = ingress_security_rules.value.description
      stateless   = ingress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = ingress_security_rules.value.tcp_options != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = ingress_security_rules.value.udp_options != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = ingress_security_rules.value.icmp_options != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = var.intra_outbound_security_rules
    content {
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = egress_security_rules.value.destination_type
      description      = egress_security_rules.value.description
      stateless        = egress_security_rules.value.stateless

      dynamic "tcp_options" {
        for_each = egress_security_rules.value.tcp_options != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = egress_security_rules.value.udp_options != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = egress_security_rules.value.icmp_options != null ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = icmp_options.value.code
        }
      }
    }
  }

  freeform_tags = merge({ "Name" = "${var.name}-${var.intra_subnet_suffix}-sl" }, var.tags, var.intra_acl_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
