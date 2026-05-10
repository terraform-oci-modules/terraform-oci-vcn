run "creates_complete_vcn" {
  command = apply

  assert {
    condition     = output.vcn_id != null
    error_message = "VCN must be created"
  }
  assert {
    condition     = output.vcn_cidr_block == "10.0.0.0/16"
    error_message = "VCN CIDR must be 10.0.0.0/16"
  }
  assert {
    condition     = length(output.public_subnets) == 3
    error_message = "Expected 3 public subnets"
  }
  assert {
    condition     = length(output.private_subnets) == 3
    error_message = "Expected 3 private subnets"
  }
  assert {
    condition     = length(output.database_subnets) == 3
    error_message = "Expected 3 database subnets"
  }
  assert {
    condition     = length(output.intra_subnets) == 2
    error_message = "Expected 2 intra subnets"
  }
  assert {
    condition     = output.internet_gateway_id != null
    error_message = "Internet Gateway must be created"
  }
  assert {
    condition     = length(output.nat_ids) == 1
    error_message = "Expected exactly 1 NAT Gateway (single_nat_gateway = true)"
  }
  assert {
    condition     = output.service_gateway_id != null
    error_message = "Service Gateway must be created"
  }
  assert {
    condition     = length(output.flow_log_ids) > 0
    error_message = "Flow logs must be created (enable_flow_log = true)"
  }
  assert {
    condition     = length(output.flow_log_group_ids) > 0
    error_message = "Flow log groups must be created"
  }
  assert {
    condition     = length(output.database_route_table_ids) > 0
    error_message = "Database route table must be created (create_database_subnet_route_table = true)"
  }
  assert {
    condition     = output.intra_route_table_id != null
    error_message = "Intra route table must be created"
  }
  assert {
    condition     = length(output.private_route_table_ids) == 1
    error_message = "Expected 1 private route table (single_nat_gateway = true)"
  }
  assert {
    condition     = output.public_route_table_id != null
    error_message = "Public route table must be created"
  }
}
