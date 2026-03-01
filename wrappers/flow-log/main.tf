module "wrapper" {
  source = "../../modules/flow-log"

  for_each = var.items

  compartment_id        = try(each.value.compartment_id, var.defaults.compartment_id)
  create                = try(each.value.create, var.defaults.create, true)
  create_log_group      = try(each.value.create_log_group, var.defaults.create_log_group, true)
  defined_tags          = try(each.value.defined_tags, var.defaults.defined_tags, {})
  flow_log_tags         = try(each.value.flow_log_tags, var.defaults.flow_log_tags, {})
  is_enabled            = try(each.value.is_enabled, var.defaults.is_enabled, true)
  log_group_description = try(each.value.log_group_description, var.defaults.log_group_description, null)
  log_group_id          = try(each.value.log_group_id, var.defaults.log_group_id, null)
  log_group_tags        = try(each.value.log_group_tags, var.defaults.log_group_tags, {})
  name                  = try(each.value.name, var.defaults.name, "")
  retention_duration    = try(each.value.retention_duration, var.defaults.retention_duration, 30)
  subnet_id             = try(each.value.subnet_id, var.defaults.subnet_id, null)
  tags                  = try(each.value.tags, var.defaults.tags, {})
  vcn_id                = try(each.value.vcn_id, var.defaults.vcn_id, null)
}
