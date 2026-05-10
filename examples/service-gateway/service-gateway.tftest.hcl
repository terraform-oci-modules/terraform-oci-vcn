run "creates_service_gateway_only_vcn" {
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
    condition     = length(output.private_subnets) == 3
    error_message = "Expected 3 private subnets (no public subnets — fully private VCN)"
  }
  assert {
    condition     = length(output.database_subnets) == 3
    error_message = "Expected 3 database subnets"
  }
  assert {
    condition     = output.service_gateway_id != null
    error_message = "Service Gateway must be created"
  }
  assert {
    condition     = length(output.database_route_table_ids) > 0
    error_message = "Dedicated database route table must be created (create_database_subnet_route_table = true)"
  }
  assert {
    condition     = contains(output.private_subnets_cidr_blocks, "10.0.0.0/20")
    error_message = "First private subnet must be at 10.0.0.0/20"
  }
  assert {
    condition     = contains(output.database_subnets_cidr_blocks, "10.0.64.0/20")
    error_message = "First database subnet must be at 10.0.64.0/20"
  }
}
