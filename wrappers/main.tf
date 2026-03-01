module "wrapper" {
  source = "../"

  for_each = var.items

  ads                                    = try(each.value.ads, var.defaults.ads, [])
  attached_drg_id                        = try(each.value.attached_drg_id, var.defaults.attached_drg_id, null)
  cidr                                   = try(each.value.cidr, var.defaults.cidr, "10.0.0.0/16")
  compartment_id                         = try(each.value.compartment_id, var.defaults.compartment_id)
  create_database_internet_gateway_route = try(each.value.create_database_internet_gateway_route, var.defaults.create_database_internet_gateway_route, false)
  create_database_subnet_route_table     = try(each.value.create_database_subnet_route_table, var.defaults.create_database_subnet_route_table, false)
  create_dhcp_options                    = try(each.value.create_dhcp_options, var.defaults.create_dhcp_options, false)
  create_internet_gateway                = try(each.value.create_internet_gateway, var.defaults.create_internet_gateway, true)
  create_multiple_intra_route_tables     = try(each.value.create_multiple_intra_route_tables, var.defaults.create_multiple_intra_route_tables, false)
  create_multiple_public_route_tables    = try(each.value.create_multiple_public_route_tables, var.defaults.create_multiple_public_route_tables, false)
  create_service_gateway                 = try(each.value.create_service_gateway, var.defaults.create_service_gateway, false)
  create_vcn                             = try(each.value.create_vcn, var.defaults.create_vcn, true)
  database_acl_tags                      = try(each.value.database_acl_tags, var.defaults.database_acl_tags, {})
  database_dedicated_security_list       = try(each.value.database_dedicated_security_list, var.defaults.database_dedicated_security_list, false)
  database_inbound_security_rules = try(each.value.database_inbound_security_rules, var.defaults.database_inbound_security_rules, [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ])
  database_outbound_security_rules = try(each.value.database_outbound_security_rules, var.defaults.database_outbound_security_rules, [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ])
  database_route_table_tags       = try(each.value.database_route_table_tags, var.defaults.database_route_table_tags, {})
  database_subnet_defined_tags    = try(each.value.database_subnet_defined_tags, var.defaults.database_subnet_defined_tags, {})
  database_subnet_ipv6_cidrs      = try(each.value.database_subnet_ipv6_cidrs, var.defaults.database_subnet_ipv6_cidrs, [])
  database_subnet_names           = try(each.value.database_subnet_names, var.defaults.database_subnet_names, [])
  database_subnet_suffix          = try(each.value.database_subnet_suffix, var.defaults.database_subnet_suffix, "db")
  database_subnet_tags            = try(each.value.database_subnet_tags, var.defaults.database_subnet_tags, {})
  database_subnet_tags_per_ad     = try(each.value.database_subnet_tags_per_ad, var.defaults.database_subnet_tags_per_ad, {})
  database_subnets                = try(each.value.database_subnets, var.defaults.database_subnets, [])
  defined_tags                    = try(each.value.defined_tags, var.defaults.defined_tags, {})
  dhcp_options_custom_dns_servers = try(each.value.dhcp_options_custom_dns_servers, var.defaults.dhcp_options_custom_dns_servers, [])
  dhcp_options_search_domain      = try(each.value.dhcp_options_search_domain, var.defaults.dhcp_options_search_domain, "")
  dhcp_options_server_type        = try(each.value.dhcp_options_server_type, var.defaults.dhcp_options_server_type, "VcnLocalPlusInternet")
  dhcp_options_tags               = try(each.value.dhcp_options_tags, var.defaults.dhcp_options_tags, {})
  enable_dns_hostnames            = try(each.value.enable_dns_hostnames, var.defaults.enable_dns_hostnames, true)
  enable_flow_log                 = try(each.value.enable_flow_log, var.defaults.enable_flow_log, false)
  enable_ipv6                     = try(each.value.enable_ipv6, var.defaults.enable_ipv6, false)
  enable_nat_gateway              = try(each.value.enable_nat_gateway, var.defaults.enable_nat_gateway, false)
  flow_log_retention_duration     = try(each.value.flow_log_retention_duration, var.defaults.flow_log_retention_duration, 30)
  flow_log_tags                   = try(each.value.flow_log_tags, var.defaults.flow_log_tags, {})
  internet_gateway_route_rules    = try(each.value.internet_gateway_route_rules, var.defaults.internet_gateway_route_rules, null)
  internet_gateway_tags           = try(each.value.internet_gateway_tags, var.defaults.internet_gateway_tags, {})
  intra_acl_tags                  = try(each.value.intra_acl_tags, var.defaults.intra_acl_tags, {})
  intra_dedicated_security_list   = try(each.value.intra_dedicated_security_list, var.defaults.intra_dedicated_security_list, false)
  intra_inbound_security_rules = try(each.value.intra_inbound_security_rules, var.defaults.intra_inbound_security_rules, [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ])
  intra_outbound_security_rules = try(each.value.intra_outbound_security_rules, var.defaults.intra_outbound_security_rules, [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ])
  intra_route_table_tags             = try(each.value.intra_route_table_tags, var.defaults.intra_route_table_tags, {})
  intra_subnet_defined_tags          = try(each.value.intra_subnet_defined_tags, var.defaults.intra_subnet_defined_tags, {})
  intra_subnet_ipv6_cidrs            = try(each.value.intra_subnet_ipv6_cidrs, var.defaults.intra_subnet_ipv6_cidrs, [])
  intra_subnet_names                 = try(each.value.intra_subnet_names, var.defaults.intra_subnet_names, [])
  intra_subnet_suffix                = try(each.value.intra_subnet_suffix, var.defaults.intra_subnet_suffix, "intra")
  intra_subnet_tags                  = try(each.value.intra_subnet_tags, var.defaults.intra_subnet_tags, {})
  intra_subnet_tags_per_ad           = try(each.value.intra_subnet_tags_per_ad, var.defaults.intra_subnet_tags_per_ad, {})
  intra_subnets                      = try(each.value.intra_subnets, var.defaults.intra_subnets, [])
  local_peering_gateways             = try(each.value.local_peering_gateways, var.defaults.local_peering_gateways, null)
  lockdown_default_seclist           = try(each.value.lockdown_default_seclist, var.defaults.lockdown_default_seclist, true)
  name                               = try(each.value.name, var.defaults.name, "")
  nat_gateway_destination_cidr_block = try(each.value.nat_gateway_destination_cidr_block, var.defaults.nat_gateway_destination_cidr_block, "0.0.0.0/0")
  nat_gateway_public_ip_id           = try(each.value.nat_gateway_public_ip_id, var.defaults.nat_gateway_public_ip_id, null)
  nat_gateway_route_rules            = try(each.value.nat_gateway_route_rules, var.defaults.nat_gateway_route_rules, null)
  nat_gateway_tags                   = try(each.value.nat_gateway_tags, var.defaults.nat_gateway_tags, {})
  one_nat_gateway_per_ad             = try(each.value.one_nat_gateway_per_ad, var.defaults.one_nat_gateway_per_ad, false)
  private_acl_tags                   = try(each.value.private_acl_tags, var.defaults.private_acl_tags, {})
  private_dedicated_security_list    = try(each.value.private_dedicated_security_list, var.defaults.private_dedicated_security_list, false)
  private_inbound_security_rules = try(each.value.private_inbound_security_rules, var.defaults.private_inbound_security_rules, [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ])
  private_outbound_security_rules = try(each.value.private_outbound_security_rules, var.defaults.private_outbound_security_rules, [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ])
  private_route_table_tags       = try(each.value.private_route_table_tags, var.defaults.private_route_table_tags, {})
  private_subnet_defined_tags    = try(each.value.private_subnet_defined_tags, var.defaults.private_subnet_defined_tags, {})
  private_subnet_ipv6_cidrs      = try(each.value.private_subnet_ipv6_cidrs, var.defaults.private_subnet_ipv6_cidrs, [])
  private_subnet_names           = try(each.value.private_subnet_names, var.defaults.private_subnet_names, [])
  private_subnet_suffix          = try(each.value.private_subnet_suffix, var.defaults.private_subnet_suffix, "private")
  private_subnet_tags            = try(each.value.private_subnet_tags, var.defaults.private_subnet_tags, {})
  private_subnet_tags_per_ad     = try(each.value.private_subnet_tags_per_ad, var.defaults.private_subnet_tags_per_ad, {})
  private_subnets                = try(each.value.private_subnets, var.defaults.private_subnets, [])
  public_acl_tags                = try(each.value.public_acl_tags, var.defaults.public_acl_tags, {})
  public_dedicated_security_list = try(each.value.public_dedicated_security_list, var.defaults.public_dedicated_security_list, false)
  public_inbound_security_rules = try(each.value.public_inbound_security_rules, var.defaults.public_inbound_security_rules, [
    {
      protocol    = "all"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      description = "Allow all inbound traffic"
    },
  ])
  public_outbound_security_rules = try(each.value.public_outbound_security_rules, var.defaults.public_outbound_security_rules, [
    {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Allow all outbound traffic"
    },
  ])
  public_route_table_tags    = try(each.value.public_route_table_tags, var.defaults.public_route_table_tags, {})
  public_subnet_defined_tags = try(each.value.public_subnet_defined_tags, var.defaults.public_subnet_defined_tags, {})
  public_subnet_ipv6_cidrs   = try(each.value.public_subnet_ipv6_cidrs, var.defaults.public_subnet_ipv6_cidrs, [])
  public_subnet_names        = try(each.value.public_subnet_names, var.defaults.public_subnet_names, [])
  public_subnet_suffix       = try(each.value.public_subnet_suffix, var.defaults.public_subnet_suffix, "public")
  public_subnet_tags         = try(each.value.public_subnet_tags, var.defaults.public_subnet_tags, {})
  public_subnet_tags_per_ad  = try(each.value.public_subnet_tags_per_ad, var.defaults.public_subnet_tags_per_ad, {})
  public_subnets             = try(each.value.public_subnets, var.defaults.public_subnets, [])
  secondary_cidrs            = try(each.value.secondary_cidrs, var.defaults.secondary_cidrs, [])
  service_gateway_tags       = try(each.value.service_gateway_tags, var.defaults.service_gateway_tags, {})
  single_nat_gateway         = try(each.value.single_nat_gateway, var.defaults.single_nat_gateway, false)
  tags                       = try(each.value.tags, var.defaults.tags, {})
  tenancy_id                 = try(each.value.tenancy_id, var.defaults.tenancy_id, null)
  vcn_dns_label              = try(each.value.vcn_dns_label, var.defaults.vcn_dns_label, null)
  vcn_tags                   = try(each.value.vcn_tags, var.defaults.vcn_tags, {})
}
