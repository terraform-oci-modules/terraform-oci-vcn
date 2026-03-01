################################################################################
# VCN 1: OCI resolver + search domain
################################################################################

output "search_domain_vcn_id" {
  description = "The OCID of the VCN using OCI resolver with a custom search domain"
  value       = module.vcn_search_domain.vcn_id
}

output "search_domain_vcn_cidr_block" {
  description = "The primary CIDR block of the search-domain VCN"
  value       = module.vcn_search_domain.vcn_cidr_block
}

output "search_domain_public_subnets" {
  description = "List of OCIDs of public subnets in the search-domain VCN"
  value       = module.vcn_search_domain.public_subnets
}

output "search_domain_private_subnets" {
  description = "List of OCIDs of private subnets in the search-domain VCN"
  value       = module.vcn_search_domain.private_subnets
}

output "search_domain_default_dhcp_options_id" {
  description = "The OCID of the VCN-default DHCP options set (not the managed custom set)"
  value       = module.vcn_search_domain.default_dhcp_options_id
}

output "search_domain_dhcp_options_id" {
  description = "The OCID of the custom DHCP options set (VcnLocalPlusInternet + search domain)"
  value       = module.vcn_search_domain.dhcp_options_id
}

################################################################################
# VCN 2: Custom DNS servers
################################################################################

output "custom_dns_vcn_id" {
  description = "The OCID of the VCN using custom DNS forwarders"
  value       = module.vcn_custom_dns.vcn_id
}

output "custom_dns_vcn_cidr_block" {
  description = "The primary CIDR block of the custom-DNS VCN"
  value       = module.vcn_custom_dns.vcn_cidr_block
}

output "custom_dns_private_subnets" {
  description = "List of OCIDs of private subnets in the custom-DNS VCN"
  value       = module.vcn_custom_dns.private_subnets
}

output "custom_dns_default_dhcp_options_id" {
  description = "The OCID of the VCN-default DHCP options set (not the managed custom set)"
  value       = module.vcn_custom_dns.default_dhcp_options_id
}

output "custom_dns_dhcp_options_id" {
  description = "The OCID of the custom DHCP options set (CustomDnsServer)"
  value       = module.vcn_custom_dns.dhcp_options_id
}
