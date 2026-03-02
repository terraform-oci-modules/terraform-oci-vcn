################################################################################
# VCN
################################################################################

output "vcn_id" {
  description = "The OCID of the VCN"
  value       = try(oci_core_vcn.this[0].id, null)
}

output "vcn_cidr_block" {
  description = "The primary CIDR block of the VCN"
  value       = try(oci_core_vcn.this[0].cidr_block, null)
}

output "vcn_cidr_blocks" {
  description = "All CIDR blocks (primary + secondary) of the VCN"
  value       = try(oci_core_vcn.this[0].cidr_blocks, [])
}

output "vcn_ipv6_cidr_blocks" {
  description = "The IPv6 CIDR blocks assigned to the VCN"
  value       = try(oci_core_vcn.this[0].ipv6cidr_blocks, [])
}

output "vcn_dns_label" {
  description = "The DNS label of the VCN"
  value       = try(oci_core_vcn.this[0].dns_label, null)
}

output "default_security_list_id" {
  description = "The OCID of the VCN default security list"
  value       = try(oci_core_vcn.this[0].default_security_list_id, null)
}

output "default_route_table_id" {
  description = "The OCID of the VCN default route table"
  value       = try(oci_core_vcn.this[0].default_route_table_id, null)
}

output "default_dhcp_options_id" {
  description = "The OCID of the VCN default DHCP options"
  value       = try(oci_core_vcn.this[0].default_dhcp_options_id, null)
}

output "dhcp_options_id" {
  description = "The OCID of the custom DHCP options set created by this module. Null when enable_dhcp_options = false"
  value       = try(oci_core_dhcp_options.this[0].id, null)
}

output "vcn_all_attributes" {
  description = "All attributes of the created VCN (full object, auto-updating)"
  value       = { for k, v in oci_core_vcn.this : k => v }
}

################################################################################
# Public Subnets
################################################################################

output "public_subnet_objects" {
  description = "A list of all public subnet objects (full attributes)"
  value       = oci_core_subnet.public
}

output "public_subnets" {
  description = "List of OCIDs of public subnets"
  value       = oci_core_subnet.public[*].id
}

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = compact(oci_core_subnet.public[*].cidr_block)
}

output "public_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of public subnets"
  value       = [for s in oci_core_subnet.public : s.ipv6cidr_block]
}

output "public_route_table_id" {
  description = "The OCID of the Internet Gateway route table (used by public subnets)"
  value       = try(oci_core_route_table.ig[0].id, null)
}

output "public_security_list_id" {
  description = "The OCID of the dedicated public security list (null if not created)"
  value       = try(oci_core_security_list.public[0].id, null)
}

################################################################################
# Private Subnets
################################################################################

output "private_subnet_objects" {
  description = "A list of all private subnet objects (full attributes)"
  value       = oci_core_subnet.private
}

output "private_subnets" {
  description = "List of OCIDs of private subnets"
  value       = oci_core_subnet.private[*].id
}

output "private_subnets_cidr_blocks" {
  description = "List of CIDR blocks of private subnets"
  value       = compact(oci_core_subnet.private[*].cidr_block)
}

output "private_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of private subnets"
  value       = [for s in oci_core_subnet.private : s.ipv6cidr_block]
}

output "private_route_table_ids" {
  description = "List of OCIDs of the NAT Gateway route tables (one per NAT GW, used by private subnets)"
  value       = oci_core_route_table.nat[*].id
}

output "private_security_list_id" {
  description = "The OCID of the dedicated private security list (null if not created)"
  value       = try(oci_core_security_list.private[0].id, null)
}

################################################################################
# Database Subnets
################################################################################

output "database_subnet_objects" {
  description = "A list of all database subnet objects (full attributes)"
  value       = oci_core_subnet.database
}

output "database_subnets" {
  description = "List of OCIDs of database subnets"
  value       = oci_core_subnet.database[*].id
}

output "database_subnets_cidr_blocks" {
  description = "List of CIDR blocks of database subnets"
  value       = compact(oci_core_subnet.database[*].cidr_block)
}

output "database_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of database subnets"
  value       = [for s in oci_core_subnet.database : s.ipv6cidr_block]
}

output "database_route_table_id" {
  description = "The OCID of the dedicated database route table (if created)"
  value       = try(oci_core_route_table.database[0].id, null)
}

output "database_security_list_id" {
  description = "The OCID of the dedicated database security list (null if not created)"
  value       = try(oci_core_security_list.database[0].id, null)
}

################################################################################
# Intra Subnets
################################################################################

output "intra_subnet_objects" {
  description = "A list of all intra subnet objects (full attributes)"
  value       = oci_core_subnet.intra
}

output "intra_subnets" {
  description = "List of OCIDs of intra subnets"
  value       = oci_core_subnet.intra[*].id
}

output "intra_subnets_cidr_blocks" {
  description = "List of CIDR blocks of intra subnets"
  value       = compact(oci_core_subnet.intra[*].cidr_block)
}

output "intra_subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of intra subnets"
  value       = [for s in oci_core_subnet.intra : s.ipv6cidr_block]
}

output "intra_route_table_id" {
  description = "The OCID of the intra (isolated) route table"
  value       = try(oci_core_route_table.intra[0].id, null)
}

output "intra_security_list_id" {
  description = "The OCID of the dedicated intra security list (null if not created)"
  value       = try(oci_core_security_list.intra[0].id, null)
}

################################################################################
# Internet Gateway
################################################################################

output "internet_gateway_id" {
  description = "The OCID of the Internet Gateway"
  value       = try(oci_core_internet_gateway.this[0].id, null)
}

output "internet_gateway_all_attributes" {
  description = "All attributes of the created Internet Gateway (full object, auto-updating)"
  value       = { for k, v in oci_core_internet_gateway.this : k => v }
}

output "ig_route_id" {
  description = "The OCID of the Internet Gateway route table"
  value       = try(oci_core_route_table.ig[0].id, null)
}

output "ig_route_all_attributes" {
  description = "All attributes of the Internet Gateway route table (full object, auto-updating)"
  value       = { for k, v in oci_core_route_table.ig : k => v }
}

################################################################################
# NAT Gateway
################################################################################

output "nat_ids" {
  description = "List of OCIDs of NAT Gateways"
  value       = oci_core_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "List of public IP addresses of NAT Gateways"
  value       = oci_core_nat_gateway.this[*].nat_ip
}

output "nat_reserved_public_ip_id" {
  description = "OCID of the reserved public IP created for the NAT Gateway (null when nat_gateway_public_ip_id != 'RESERVED')"
  value       = try(oci_core_public_ip.nat[0].id, null)
}

output "nat_gateway_all_attributes" {
  description = "All attributes of created NAT Gateways (full objects, auto-updating)"
  value       = { for k, v in oci_core_nat_gateway.this : k => v }
}

output "nat_route_ids" {
  description = "List of OCIDs of NAT Gateway route tables"
  value       = oci_core_route_table.nat[*].id
}

output "nat_route_all_attributes" {
  description = "All attributes of NAT Gateway route tables (full objects, auto-updating)"
  value       = { for k, v in oci_core_route_table.nat : k => v }
}

################################################################################
# Service Gateway (OCI-specific)
################################################################################

output "service_gateway_id" {
  description = "The OCID of the Service Gateway (OCI-specific)"
  value       = try(oci_core_service_gateway.this[0].id, null)
}

output "service_gateway_all_attributes" {
  description = "All attributes of the created Service Gateway (full object, auto-updating)"
  value       = { for k, v in oci_core_service_gateway.this : k => v }
}

################################################################################
# Local Peering Gateways (OCI-specific)
################################################################################

output "lpg_ids" {
  description = "Map of LPG name to OCID for all created Local Peering Gateways"
  value       = { for k, v in oci_core_local_peering_gateway.this : k => v.id }
}

output "lpg_all_attributes" {
  description = "All attributes of created Local Peering Gateways (full objects, auto-updating)"
  value       = { for k, v in oci_core_local_peering_gateway.this : k => v }
}

################################################################################
# Flow Logs
################################################################################

output "flow_log_group_ids" {
  description = "Map of subnet type to flow log group OCID"
  value       = { for k, v in oci_logging_log_group.vcn_flow_logs : k => v.id }
}

output "flow_log_ids" {
  description = "Map of subnet key to flow log OCID"
  value       = { for k, v in oci_logging_log.vcn_flow_logs : k => v.id }
}

################################################################################
# Static values (arguments)
################################################################################

output "ads" {
  description = "A list of availability domain numbers specified as argument to this module"
  value       = var.ads
}

output "ad_names" {
  description = "Resolved availability domain names for the ADs specified in var.ads"
  value       = local.ad_names
}

output "name" {
  description = "The name specified as argument to this module"
  value       = var.name
}
