run "creates_dhcp_vcns" {
  command = apply

  assert {
    condition     = output.search_domain_vcn_id != null
    error_message = "Search domain VCN must be created"
  }
  assert {
    condition     = output.custom_dns_vcn_id != null
    error_message = "Custom DNS VCN must be created"
  }
  assert {
    condition     = output.search_domain_dhcp_options_id != null
    error_message = "Custom DHCP options must be created for search domain VCN"
  }
  assert {
    condition     = output.custom_dns_dhcp_options_id != null
    error_message = "Custom DHCP options must be created for custom DNS VCN"
  }
  assert {
    condition     = output.search_domain_vcn_cidr_block == "10.0.0.0/16"
    error_message = "Search domain VCN CIDR must be 10.0.0.0/16"
  }
  assert {
    condition     = output.custom_dns_vcn_cidr_block == "10.1.0.0/16"
    error_message = "Custom DNS VCN CIDR must be 10.1.0.0/16"
  }
  assert {
    condition     = length(output.search_domain_public_subnets) == 1
    error_message = "Expected 1 public subnet in search domain VCN"
  }
  assert {
    condition     = length(output.search_domain_private_subnets) == 2
    error_message = "Expected 2 private subnets in search domain VCN"
  }
  assert {
    condition     = length(output.custom_dns_private_subnets) == 2
    error_message = "Expected 2 private subnets in custom DNS VCN"
  }
}
