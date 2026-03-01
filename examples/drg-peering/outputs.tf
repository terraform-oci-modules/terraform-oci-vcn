################################################################################
# Ashburn VCN outputs
################################################################################

output "ashburn_vcn_id" {
  description = "The OCID of the Ashburn VCN"
  value       = module.vcn_ashburn.vcn_id
}

output "ashburn_vcn_cidr_block" {
  description = "The primary CIDR block of the Ashburn VCN"
  value       = module.vcn_ashburn.vcn_cidr_block
}

output "ashburn_public_subnets" {
  description = "List of OCIDs of Ashburn public subnets"
  value       = module.vcn_ashburn.public_subnets
}

output "ashburn_private_subnets" {
  description = "List of OCIDs of Ashburn private subnets"
  value       = module.vcn_ashburn.private_subnets
}

output "ashburn_internet_gateway_id" {
  description = "The OCID of the Ashburn Internet Gateway"
  value       = module.vcn_ashburn.internet_gateway_id
}

output "ashburn_nat_ids" {
  description = "List of OCIDs of Ashburn NAT Gateways"
  value       = module.vcn_ashburn.nat_ids
}

output "ashburn_service_gateway_id" {
  description = "The OCID of the Ashburn Service Gateway"
  value       = module.vcn_ashburn.service_gateway_id
}

output "ashburn_drg_id" {
  description = "The OCID of the Ashburn Dynamic Routing Gateway"
  value       = oci_core_drg.ashburn.id
}

output "ashburn_rpc_id" {
  description = "The OCID of the Ashburn Remote Peering Connection (requestor)"
  value       = oci_core_remote_peering_connection.ashburn.id
}

output "ashburn_rpc_peering_status" {
  description = "The peering status of the Ashburn RPC"
  value       = oci_core_remote_peering_connection.ashburn.peering_status
}

################################################################################
# Chicago VCN outputs
################################################################################

output "chicago_vcn_id" {
  description = "The OCID of the Chicago VCN"
  value       = module.vcn_chicago.vcn_id
}

output "chicago_vcn_cidr_block" {
  description = "The primary CIDR block of the Chicago VCN"
  value       = module.vcn_chicago.vcn_cidr_block
}

output "chicago_private_subnets" {
  description = "List of OCIDs of Chicago private subnets"
  value       = module.vcn_chicago.private_subnets
}

output "chicago_service_gateway_id" {
  description = "The OCID of the Chicago Service Gateway"
  value       = module.vcn_chicago.service_gateway_id
}

output "chicago_drg_id" {
  description = "The OCID of the Chicago Dynamic Routing Gateway"
  value       = oci_core_drg.chicago.id
}

output "chicago_rpc_id" {
  description = "The OCID of the Chicago Remote Peering Connection (acceptor)"
  value       = oci_core_remote_peering_connection.chicago.id
}

output "chicago_rpc_peering_status" {
  description = "The peering status of the Chicago RPC"
  value       = oci_core_remote_peering_connection.chicago.peering_status
}
