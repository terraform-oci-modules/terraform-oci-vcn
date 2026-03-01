################################################################################
# Hub VCN outputs
################################################################################

output "hub_vcn_id" {
  description = "The OCID of the hub VCN"
  value       = module.vcn_hub.vcn_id
}

output "hub_vcn_cidr_block" {
  description = "The primary CIDR block of the hub VCN"
  value       = module.vcn_hub.vcn_cidr_block
}

output "hub_public_subnets" {
  description = "List of OCIDs of hub public subnets"
  value       = module.vcn_hub.public_subnets
}

output "hub_private_subnets" {
  description = "List of OCIDs of hub private subnets"
  value       = module.vcn_hub.private_subnets
}

output "hub_internet_gateway_id" {
  description = "The OCID of the hub Internet Gateway"
  value       = module.vcn_hub.internet_gateway_id
}

output "hub_nat_ids" {
  description = "List of OCIDs of hub NAT Gateways"
  value       = module.vcn_hub.nat_ids
}

output "hub_service_gateway_id" {
  description = "The OCID of the hub Service Gateway"
  value       = module.vcn_hub.service_gateway_id
}

output "hub_lpg_ids" {
  description = "Map of LPG name to OCID for hub Local Peering Gateways"
  value       = module.vcn_hub.lpg_ids
}

################################################################################
# Spoke VCN outputs
################################################################################

output "spoke_vcn_id" {
  description = "The OCID of the spoke VCN"
  value       = module.vcn_spoke.vcn_id
}

output "spoke_vcn_cidr_block" {
  description = "The primary CIDR block of the spoke VCN"
  value       = module.vcn_spoke.vcn_cidr_block
}

output "spoke_private_subnets" {
  description = "List of OCIDs of spoke private subnets"
  value       = module.vcn_spoke.private_subnets
}

output "spoke_lpg_ids" {
  description = "Map of LPG name to OCID for spoke Local Peering Gateways"
  value       = module.vcn_spoke.lpg_ids
}
