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

output "database_subnets" {
  description = "List of OCIDs of database subnets"
  value       = module.vcn.database_subnets
}

output "intra_subnets" {
  description = "List of OCIDs of intra subnets"
  value       = module.vcn.intra_subnets
}

################################################################################
# Security Lists
################################################################################

output "public_security_list_id" {
  description = "The OCID of the dedicated public security list"
  value       = module.vcn.public_security_list_id
}

output "private_security_list_id" {
  description = "The OCID of the dedicated private security list"
  value       = module.vcn.private_security_list_id
}

output "database_security_list_id" {
  description = "The OCID of the dedicated database security list"
  value       = module.vcn.database_security_list_id
}

output "intra_security_list_id" {
  description = "The OCID of the dedicated intra security list"
  value       = module.vcn.intra_security_list_id
}

################################################################################
# Gateways
################################################################################

output "internet_gateway_id" {
  description = "The OCID of the Internet Gateway"
  value       = module.vcn.internet_gateway_id
}

output "nat_ids" {
  description = "List of OCIDs of NAT Gateways"
  value       = module.vcn.nat_ids
}

output "service_gateway_id" {
  description = "The OCID of the Service Gateway"
  value       = module.vcn.service_gateway_id
}
