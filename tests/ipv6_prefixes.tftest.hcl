################################################################################
# Mock unit tests: fast, free, no real OCI resources.
#
# Per-subnet IPv6 /64 selection (<tier>_subnet_ipv6_prefixes) against the module
# root with a mocked OCI provider. The VCN's /56 is only known after apply, so
# the mapping runs use command = apply against the mock. Run on its own:
#   terraform test -filter=tests/ipv6_prefixes.tftest.hcl
################################################################################

mock_provider "oci" {
  mock_data "oci_identity_availability_domains" {
    defaults = {
      availability_domains = [
        { name = "AD-1" },
        { name = "AD-2" },
        { name = "AD-3" },
      ]
    }
  }

  mock_data "oci_core_services" {
    defaults = {
      services = [{ id = "ocid1.service.oc1..aaaaaaaaunit", cidr_block = "all-iad-services-in-oracle-services-network" }]
    }
  }

  mock_resource "oci_core_vcn" {
    defaults = {
      ipv6cidr_blocks = ["2001:db8:0:ab00::/56"]
    }
  }
}

variables {
  compartment_id  = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  name            = "test"
  enable_ipv6     = true
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
}

run "default_offsets_follow_tier_order" {
  command = apply

  assert {
    condition     = output.public_subnets_ipv6_cidr_blocks == ["2001:db8:0:ab00::/64", "2001:db8:0:ab01::/64"]
    error_message = "public subnets must default to /64 indexes 0 and 1"
  }
  assert {
    condition     = output.private_subnets_ipv6_cidr_blocks == ["2001:db8:0:ab02::/64", "2001:db8:0:ab03::/64"]
    error_message = "private subnets must default to the indexes after the public ones (2 and 3)"
  }
}

run "explicit_prefixes_pick_the_64" {
  command = apply

  variables {
    public_subnet_ipv6_prefixes  = [0, 1]
    private_subnet_ipv6_prefixes = [16, 17]
  }

  assert {
    condition     = output.private_subnets_ipv6_cidr_blocks == ["2001:db8:0:ab10::/64", "2001:db8:0:ab11::/64"]
    error_message = "private_subnet_ipv6_prefixes = [16, 17] must select /64 indexes 16 and 17"
  }
  assert {
    condition     = output.public_subnets_ipv6_cidr_blocks == ["2001:db8:0:ab00::/64", "2001:db8:0:ab01::/64"]
    error_message = "public_subnet_ipv6_prefixes must select /64 indexes 0 and 1"
  }
}

run "aws_style_string_prefixes_accepted" {
  command = apply

  variables {
    private_subnet_ipv6_prefixes = ["32", "33"]
  }

  assert {
    condition     = output.private_subnets_ipv6_cidr_blocks == ["2001:db8:0:ab20::/64", "2001:db8:0:ab21::/64"]
    error_message = "string prefixes, as the AWS module takes them, must convert to numbers"
  }
}

run "prefix_length_must_match_subnets" {
  command = plan

  variables {
    private_subnet_ipv6_prefixes = [16]
  }

  expect_failures = [oci_core_subnet.private]
}

run "duplicate_index_across_tiers_rejected" {
  command = plan

  variables {
    # Collides with public subnet 1, which defaults to index 1.
    private_subnet_ipv6_prefixes = [1, 5]
  }

  expect_failures = [oci_core_vcn.this]
}

run "duplicates_ignored_without_ipv6" {
  command = plan

  variables {
    enable_ipv6                  = false
    private_subnet_ipv6_prefixes = [1, 5]
  }

  # Reaching the assert proves the duplicate check did not fire. ipv6cidr_block
  # itself is Optional+Computed, so it keeps the earlier runs' value in the mock.
  assert {
    condition     = length(oci_core_subnet.private) == 2
    error_message = "the duplicate-index check must not run when enable_ipv6 = false"
  }
}

run "prefix_out_of_range_rejected" {
  command = plan

  variables {
    public_subnet_ipv6_prefixes = [0, 256]
  }

  expect_failures = [var.public_subnet_ipv6_prefixes]
}
