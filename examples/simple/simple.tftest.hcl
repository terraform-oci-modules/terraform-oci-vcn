run "creates_simple_vcn" {
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
    condition     = output.internet_gateway_id != null
    error_message = "Internet Gateway must be created"
  }
  assert {
    condition     = length(output.nat_ids) == 1
    error_message = "Expected exactly 1 NAT Gateway (single_nat_gateway = true)"
  }
  assert {
    condition     = output.nat_public_ips[0] != ""
    error_message = "NAT Gateway must have a public IP"
  }
  assert {
    condition     = output.service_gateway_id != null
    error_message = "Service Gateway must be created"
  }
}
