run "creates_secondary_cidr_vcn" {
  command = apply

  assert {
    condition     = output.vcn_id != null
    error_message = "VCN must be created"
  }
  assert {
    condition     = output.vcn_cidr_block == "10.0.0.0/16"
    error_message = "VCN primary CIDR must be 10.0.0.0/16"
  }
  assert {
    condition     = length(output.vcn_cidr_blocks) == 2
    error_message = "VCN must have 2 CIDR blocks (primary + 1 secondary)"
  }
  assert {
    condition     = contains(output.vcn_cidr_blocks, "10.1.0.0/16")
    error_message = "Secondary CIDR 10.1.0.0/16 must be attached to the VCN"
  }
  assert {
    condition     = length(output.public_subnets) == 2
    error_message = "Expected 2 public subnets (from primary CIDR)"
  }
  assert {
    condition     = length(output.private_subnets) == 2
    error_message = "Expected 2 private subnets (from primary CIDR)"
  }
  assert {
    condition     = length(output.intra_subnets) == 2
    error_message = "Expected 2 intra subnets (carved from secondary CIDR 10.1.0.0/16)"
  }
  assert {
    condition     = contains(output.intra_subnets_cidr_blocks, "10.1.0.0/20")
    error_message = "First intra subnet must be carved from the secondary CIDR"
  }
  assert {
    condition     = length(output.nat_ids) == 1
    error_message = "Expected 1 NAT Gateway (single_nat_gateway = true)"
  }
  assert {
    condition     = output.service_gateway_id != null
    error_message = "Service Gateway must be created"
  }
}
