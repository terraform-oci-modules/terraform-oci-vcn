################################################################################
# VCN Flow Logs (OCI Logging service)
#
# When enable_flow_log=true, creates:
#   - one log group per subnet type that has subnets
#   - one flow log per subnet
################################################################################

locals {
  # Build a flat map of all subnets that need flow logs.
  # Key format: "<type>-<index>" (e.g., "public-0", "private-1")
  flow_log_subnets = var.enable_flow_log && local.create_vcn ? merge(
    { for idx, s in oci_core_subnet.public : "public-${idx}" => { subnet_id = s.id, type = "public" } },
    { for idx, s in oci_core_subnet.private : "private-${idx}" => { subnet_id = s.id, type = "private" } },
    { for idx, s in oci_core_subnet.database : "database-${idx}" => { subnet_id = s.id, type = "database" } },
    { for idx, s in oci_core_subnet.intra : "intra-${idx}" => { subnet_id = s.id, type = "intra" } },
  ) : {}

  # Unique subnet types that have at least one subnet (for log groups)
  flow_log_types = distinct([for k, v in local.flow_log_subnets : v.type])
}

# One log group per subnet type
resource "oci_logging_log_group" "vcn_flow_logs" {
  for_each = toset(local.flow_log_types)

  compartment_id = var.compartment_id
  display_name   = "${var.name}-${each.key}-flow-log-group"
  description    = "VCN flow log group for ${each.key} subnets"

  freeform_tags = merge({ "Name" = "${var.name}-${each.key}-flow-log-group" }, var.tags, var.flow_log_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

# One flow log per subnet
resource "oci_logging_log" "vcn_flow_logs" {
  for_each = local.flow_log_subnets

  display_name = "${var.name}-${each.key}-flow-log"
  log_group_id = oci_logging_log_group.vcn_flow_logs[each.value.type].id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = each.value.subnet_id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }

  retention_duration = var.flow_log_retention_duration
  is_enabled         = true

  freeform_tags = merge({ "Name" = "${var.name}-${each.key}-flow-log" }, var.tags, var.flow_log_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
