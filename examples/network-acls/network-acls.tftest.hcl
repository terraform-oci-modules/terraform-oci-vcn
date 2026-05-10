run "creates_network_acls" {
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
    condition     = length(output.public_subnets) == 2
    error_message = "Expected 2 public subnets"
  }
  assert {
    condition     = length(output.private_subnets) == 2
    error_message = "Expected 2 private subnets"
  }
  assert {
    condition     = length(output.database_subnets) == 2
    error_message = "Expected 2 database subnets"
  }
  assert {
    condition     = length(output.intra_subnets) == 1
    error_message = "Expected 1 intra subnet"
  }
  assert {
    condition     = output.public_security_list_id != null
    error_message = "Dedicated public security list must be created (public_dedicated_security_list = true)"
  }
  assert {
    condition     = output.private_security_list_id != null
    error_message = "Dedicated private security list must be created (private_dedicated_security_list = true)"
  }
  assert {
    condition     = output.database_security_list_id != null
    error_message = "Dedicated database security list must be created (database_dedicated_security_list = true)"
  }
  assert {
    condition     = output.intra_security_list_id != null
    error_message = "Dedicated intra security list must be created (intra_dedicated_security_list = true)"
  }
  assert {
    condition     = output.internet_gateway_id != null
    error_message = "Internet Gateway must be created"
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
