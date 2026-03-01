locals {
  create = var.create

  # Determine the resource OCID and type for the flow log source.
  # Exactly one of subnet_id or vcn_id should be set.
  resource_id   = coalesce(var.subnet_id, var.vcn_id, "")
  resource_type = var.subnet_id != null ? "subnet" : "vcn"

  # Derive a default name from the resource being logged when name is not set.
  log_name       = var.name != "" ? var.name : "${local.resource_type}-flow-log"
  log_group_name = var.name != "" ? "${var.name}-group" : "${local.resource_type}-flow-log-group"

  # Use caller-supplied log group or the one we create.
  log_group_id = var.create_log_group ? try(oci_logging_log_group.this[0].id, null) : var.log_group_id
}

################################################################################
# Log Group
################################################################################

resource "oci_logging_log_group" "this" {
  count = local.create && var.create_log_group ? 1 : 0

  compartment_id = var.compartment_id
  display_name   = local.log_group_name
  description    = var.log_group_description

  freeform_tags = merge({ "Name" = local.log_group_name }, var.tags, var.log_group_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}

################################################################################
# Flow Log
################################################################################

resource "oci_logging_log" "this" {
  count = local.create ? 1 : 0

  display_name = local.log_name
  log_group_id = local.log_group_id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = local.resource_id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }

  retention_duration = var.retention_duration
  is_enabled         = var.is_enabled

  freeform_tags = merge({ "Name" = local.log_name }, var.tags, var.flow_log_tags)
  defined_tags  = var.defined_tags

  lifecycle {
    ignore_changes = [defined_tags, freeform_tags]
  }
}
