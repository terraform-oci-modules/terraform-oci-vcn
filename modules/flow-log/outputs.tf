################################################################################
# Log Group
################################################################################

output "log_group_id" {
  description = "The OCID of the log group"
  value       = try(oci_logging_log_group.this[0].id, null)
}

output "log_group_display_name" {
  description = "The display name of the log group"
  value       = try(oci_logging_log_group.this[0].display_name, null)
}

################################################################################
# Flow Log
################################################################################

output "id" {
  description = "The OCID of the flow log"
  value       = try(oci_logging_log.this[0].id, null)
}

output "display_name" {
  description = "The display name of the flow log"
  value       = try(oci_logging_log.this[0].display_name, null)
}
