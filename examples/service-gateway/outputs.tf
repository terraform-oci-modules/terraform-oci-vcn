output "vcn_id" {
  description = "The OCID of the VCN"
  value       = module.vcn.vcn_id
}

output "vcn_cidr_block" {
  description = "The primary CIDR block of the VCN"
  value       = module.vcn.vcn_cidr_block
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

output "database_route_table_id" {
  description = "The OCID of the dedicated database subnet route table"
  value       = module.vcn.database_route_table_id
}

output "service_gateway_id" {
  description = "The OCID of the Service Gateway"
  value       = module.vcn.service_gateway_id
}
