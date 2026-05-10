run "creates_flow_log_resources" {
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
    condition     = length(output.public_subnets) == 1
    error_message = "Expected 1 public subnet"
  }
  assert {
    condition     = length(output.private_subnets) == 1
    error_message = "Expected 1 private subnet"
  }
  assert {
    condition     = output.flow_log_public_id != null
    error_message = "Public subnet flow log must be created"
  }
  assert {
    condition     = output.flow_log_public_log_group_id != null
    error_message = "Flow log group must be created for public subnet"
  }
  assert {
    condition     = output.flow_log_private_id != null
    error_message = "Private subnet flow log must be created (sharing log group from public)"
  }
}
