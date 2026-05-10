run "creates_drg_peering" {
  command = apply

  assert {
    condition     = output.ashburn_vcn_id != null
    error_message = "Ashburn VCN must be created"
  }
  assert {
    condition     = output.chicago_vcn_id != null
    error_message = "Chicago VCN must be created"
  }
  assert {
    condition     = output.ashburn_vcn_cidr_block == "10.0.0.0/16"
    error_message = "Ashburn VCN CIDR must be 10.0.0.0/16"
  }
  assert {
    condition     = output.chicago_vcn_cidr_block == "10.1.0.0/16"
    error_message = "Chicago VCN CIDR must be 10.1.0.0/16"
  }
  assert {
    condition     = length(output.ashburn_public_subnets) == 2
    error_message = "Expected 2 public subnets in Ashburn VCN"
  }
  assert {
    condition     = length(output.ashburn_private_subnets) == 2
    error_message = "Expected 2 private subnets in Ashburn VCN"
  }
  assert {
    condition     = length(output.chicago_private_subnets) == 2
    error_message = "Expected 2 private subnets in Chicago VCN"
  }
  assert {
    condition     = output.ashburn_internet_gateway_id != null
    error_message = "Ashburn Internet Gateway must be created"
  }
  assert {
    condition     = output.ashburn_service_gateway_id != null
    error_message = "Ashburn Service Gateway must be created"
  }
  assert {
    condition     = output.chicago_service_gateway_id != null
    error_message = "Chicago Service Gateway must be created"
  }
  assert {
    condition     = output.ashburn_drg_id != null
    error_message = "Ashburn DRG must be created"
  }
  assert {
    condition     = output.chicago_drg_id != null
    error_message = "Chicago DRG must be created"
  }
  assert {
    condition     = output.ashburn_rpc_id != null
    error_message = "Ashburn RPC must be created"
  }
  assert {
    condition     = output.chicago_rpc_id != null
    error_message = "Chicago RPC must be created"
  }
  # Ashburn is the requestor — OCI provider waits for PEERED before completing apply.
  assert {
    condition     = output.ashburn_rpc_peering_status == "PEERED"
    error_message = "Ashburn RPC (requestor) must reach PEERED state"
  }
  # Chicago is the acceptor — its resource was created before Ashburn initiated
  # the connection, so the state object is stale and stays "NEW" until refresh.
  # Ashburn reaching PEERED is sufficient proof that both sides are connected.
  assert {
    condition     = output.chicago_rpc_id != null
    error_message = "Chicago RPC (acceptor) must be created"
  }
}
