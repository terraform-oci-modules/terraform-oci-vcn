output "vcn_id" {
  description = "The OCID of the VCN"
  value       = module.vcn.vcn_id
}

output "vcn_cidr_block" {
  description = "The primary IPv4 CIDR block of the VCN"
  value       = module.vcn.vcn_cidr_block
}

output "vcn_ipv6_cidr_blocks" {
  description = "The Oracle-assigned IPv6 /56 CIDR block(s) of the VCN"
  value       = module.vcn.vcn_ipv6_cidr_blocks
}

output "public_subnets" {
  description = "List of OCIDs of public subnets"
  value       = module.vcn.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of IPv4 CIDR blocks of public subnets"
  value       = module.vcn.public_subnets_cidr_blocks
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 /64 CIDR blocks of public subnets (auto-derived from the VCN /56)"
  value       = module.vcn.public_subnets_ipv6_cidr_blocks
}

output "private_subnets" {
  description = "List of OCIDs of private subnets"
  value       = module.vcn.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of IPv4 CIDR blocks of private subnets"
  value       = module.vcn.private_subnets_cidr_blocks
}
