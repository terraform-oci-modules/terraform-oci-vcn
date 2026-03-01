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

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = module.vcn.public_subnets_cidr_blocks
}

output "private_subnets" {
  description = "List of OCIDs of private subnets"
  value       = module.vcn.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = module.vcn.private_subnets_cidr_blocks
}

output "database_subnets" {
  description = "List of OCIDs of database subnets"
  value       = module.vcn.database_subnets
}

output "database_subnets_cidr_blocks" {
  description = "List of CIDR blocks of database subnets"
  value       = module.vcn.database_subnets_cidr_blocks
}

################################################################################
# Route Tables
################################################################################

output "public_route_table_id" {
  description = "The OCID of the Internet Gateway route table"
  value       = module.vcn.public_route_table_id
}

output "private_route_table_ids" {
  description = "List of OCIDs of NAT Gateway route tables"
  value       = module.vcn.private_route_table_ids
}

output "database_route_table_id" {
  description = "The OCID of the dedicated database route table"
  value       = module.vcn.database_route_table_id
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

output "nat_public_ips" {
  description = "List of public IP addresses of NAT Gateways"
  value       = module.vcn.nat_public_ips
}

output "service_gateway_id" {
  description = "The OCID of the Service Gateway"
  value       = module.vcn.service_gateway_id
}
