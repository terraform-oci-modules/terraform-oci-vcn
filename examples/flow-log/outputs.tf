################################################################################
# VCN
################################################################################

output "vcn_id" {
  description = "The OCID of the VCN"
  value       = module.vcn.vcn_id
}

output "vcn_cidr_block" {
  description = "The primary CIDR block of the VCN"
  value       = module.vcn.vcn_cidr_block
}

################################################################################
# Subnets
################################################################################

output "public_subnets" {
  description = "List of OCIDs of public subnets"
  value       = module.vcn.public_subnets
}

output "private_subnets" {
  description = "List of OCIDs of private subnets"
  value       = module.vcn.private_subnets
}

################################################################################
# Flow Logs — public subnet (dedicated log group)
################################################################################

output "flow_log_public_id" {
  description = "The OCID of the flow log for the public subnet"
  value       = module.flow_log_public.id
}

output "flow_log_public_log_group_id" {
  description = "The OCID of the log group created for the public subnet flow log"
  value       = module.flow_log_public.log_group_id
}

################################################################################
# Flow Logs — private subnet (shared log group)
################################################################################

output "flow_log_private_id" {
  description = "The OCID of the flow log for the private subnet"
  value       = module.flow_log_private.id
}
