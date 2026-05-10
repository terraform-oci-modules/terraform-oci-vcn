run "creates_local_peering" {
  command = apply

  assert {
    condition     = output.hub_vcn_id != null
    error_message = "Hub VCN must be created"
  }
  assert {
    condition     = output.spoke_vcn_id != null
    error_message = "Spoke VCN must be created"
  }
  assert {
    condition     = output.hub_vcn_cidr_block == "10.0.0.0/16"
    error_message = "Hub VCN CIDR must be 10.0.0.0/16"
  }
  assert {
    condition     = output.spoke_vcn_cidr_block == "10.1.0.0/16"
    error_message = "Spoke VCN CIDR must be 10.1.0.0/16"
  }
  assert {
    condition     = length(output.hub_public_subnets) == 2
    error_message = "Expected 2 public subnets in hub VCN"
  }
  assert {
    condition     = length(output.hub_private_subnets) == 2
    error_message = "Expected 2 private subnets in hub VCN"
  }
  assert {
    condition     = length(output.spoke_private_subnets) == 2
    error_message = "Expected 2 private subnets in spoke VCN"
  }
  assert {
    condition     = output.hub_internet_gateway_id != null
    error_message = "Hub Internet Gateway must be created"
  }
  assert {
    condition     = output.hub_service_gateway_id != null
    error_message = "Hub Service Gateway must be created"
  }
  assert {
    condition     = length(output.hub_nat_ids) == 1
    error_message = "Hub must have 1 NAT Gateway (single_nat_gateway = true)"
  }
  assert {
    condition     = length(output.hub_lpg_ids) == 1
    error_message = "Hub must have 1 Local Peering Gateway (to-spoke)"
  }
  assert {
    condition     = length(output.spoke_lpg_ids) == 1
    error_message = "Spoke must have 1 Local Peering Gateway (to-hub)"
  }
}
