run "creates_ipv6_dualstack_vcn" {
  command = apply

  assert {
    condition     = output.vcn_id != null
    error_message = "VCN must be created"
  }
  assert {
    condition     = output.vcn_cidr_block == "10.0.0.0/16"
    error_message = "VCN IPv4 CIDR must be 10.0.0.0/16"
  }
  assert {
    condition     = length(output.vcn_ipv6_cidr_blocks) > 0
    error_message = "VCN must have an IPv6 /56 CIDR assigned (enable_ipv6 = true)"
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
    condition     = length(output.public_subnets_cidr_blocks) == 3
    error_message = "Expected 3 public subnet IPv4 CIDR blocks"
  }
  assert {
    condition     = length(output.public_subnets_ipv6_cidr_blocks) == 3
    error_message = "Each public subnet must have an IPv6 /64 CIDR auto-derived from the VCN /56"
  }
  assert {
    condition     = length(output.private_subnets_cidr_blocks) == 3
    error_message = "Expected 3 private subnet IPv4 CIDR blocks"
  }
}
