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

output "vcn_cidr_blocks" {
  description = "All CIDR blocks (primary + secondary) of the VCN"
  value       = module.vcn.vcn_cidr_blocks
}

output "vcn_dns_label" {
  description = "The DNS label of the VCN"
  value       = module.vcn.vcn_dns_label
}

output "default_security_list_id" {
  description = "The OCID of the VCN default security list"
  value       = module.vcn.default_security_list_id
}

output "default_route_table_id" {
  description = "The OCID of the VCN default route table"
  value       = module.vcn.default_route_table_id
}

output "default_dhcp_options_id" {
  description = "The OCID of the VCN default DHCP options"
  value       = module.vcn.default_dhcp_options_id
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

output "intra_subnets" {
  description = "List of OCIDs of intra subnets"
  value       = module.vcn.intra_subnets
}

output "intra_subnets_cidr_blocks" {
  description = "List of CIDR blocks of intra subnets"
  value       = module.vcn.intra_subnets_cidr_blocks
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

output "intra_route_table_id" {
  description = "The OCID of the intra (isolated) route table"
  value       = module.vcn.intra_route_table_id
}

################################################################################
# Flow Logs
################################################################################

output "flow_log_group_ids" {
  description = "Map of subnet type to flow log group OCID"
  value       = module.vcn.flow_log_group_ids
}

output "flow_log_ids" {
  description = "Map of subnet key to flow log OCID"
  value       = module.vcn.flow_log_ids
}

################################################################################
# Availability Domains
################################################################################

output "ads" {
  description = "AD numbers specified as input"
  value       = module.vcn.ads
}

output "ad_names" {
  description = "Resolved availability domain names"
  value       = module.vcn.ad_names
}
