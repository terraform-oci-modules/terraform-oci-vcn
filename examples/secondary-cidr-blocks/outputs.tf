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
