################################################################################
# Mock unit tests: fast, free, no real OCI resources.
#
# Exercises input->config mapping logic (AD resolution/round-robin, NAT gateway
# count, VCN DNS label derivation, subnet naming, per-AD tags) against the
# module root with a mocked OCI provider (command = plan). Run on its own:
#   terraform test -filter=tests/unit_mappings.tftest.hcl
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
}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  name           = "test"
}

# --- Availability domain resolution + round-robin ----------------------------

run "availability_domains_resolve_and_wrap_across_subnets" {
  command = plan

  variables {
    availability_domains = [2, 3]
    public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }

  assert {
    condition     = oci_core_subnet.public[0].availability_domain == "AD-2"
    error_message = "availability_domains = [2, 3] must resolve subnet 0 to AD-2"
  }

  assert {
    condition     = oci_core_subnet.public[1].availability_domain == "AD-3"
    error_message = "availability_domains = [2, 3] must resolve subnet 1 to AD-3"
  }

  assert {
    condition     = oci_core_subnet.public[2].availability_domain == "AD-2"
    error_message = "a 3rd subnet must wrap back around to AD-2 with only 2 ADs listed"
  }
}

# Regional mode (availability_domains = [], the default) is intentionally not
# asserted here: availability_domain is Optional+Computed on the provider, so
# an explicit null argument is unknown at `plan` time, and a full `apply`
# against the generic mock provider synthesizes a random value for any
# computed attribute rather than preserving the null - neither command can
# observe "the module passed null" for a field shaped like this.

# --- NAT gateway count logic --------------------------------------------------

run "nat_gateway_count_single" {
  command = plan

  variables {
    enable_nat_gateway = true
    private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    single_nat_gateway = true
  }

  assert {
    condition     = length(oci_core_nat_gateway.this) == 1
    error_message = "single_nat_gateway = true must create exactly 1 NAT gateway regardless of subnet count"
  }
}

run "nat_gateway_count_one_per_ad" {
  command = plan

  variables {
    availability_domains   = [1, 2, 3]
    enable_nat_gateway     = true
    private_subnets        = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24", "10.0.15.0/24"]
    one_nat_gateway_per_ad = true
  }

  assert {
    condition     = length(oci_core_nat_gateway.this) == 3
    error_message = "one_nat_gateway_per_ad must create one NAT gateway per listed AD (3), not one per subnet (5)"
  }
}

run "nat_gateway_count_default_one_per_subnet" {
  command = plan

  variables {
    enable_nat_gateway = true
    private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
  }

  assert {
    condition     = length(oci_core_nat_gateway.this) == 4
    error_message = "with neither single_nat_gateway nor one_nat_gateway_per_ad set, must default to one NAT gateway per private subnet"
  }
}

# --- VCN DNS label derivation --------------------------------------------------

run "dns_label_strips_punctuation_and_lowercases" {
  command = plan

  variables {
    name = "My-Complex.VCN!"
  }

  assert {
    condition     = oci_core_vcn.this[0].dns_label == "mycomplexvcn"
    error_message = "vcn_dns_label must be derived from name: lowercased with non-alphanumerics stripped"
  }
}

run "dns_label_digit_prefix_gets_letter_prefix" {
  command = plan

  variables {
    name = "123-abc"
  }

  assert {
    condition     = oci_core_vcn.this[0].dns_label == "aabc"
    error_message = "a name whose derived label starts with a digit must get an 'a' prefix substituted (OCI DNS labels can't start with a digit)"
  }
}

run "dns_label_truncates_to_15_chars" {
  command = plan

  variables {
    name = "abcdefghijklmnopqrstuvwxyz"
  }

  assert {
    condition     = oci_core_vcn.this[0].dns_label == "abcdefghijklmno"
    error_message = "a derived dns_label longer than 15 chars must be truncated to OCI's 15-char DNS label limit"
  }
}

# enable_dns_hostnames = false (dns_label resolves to null) is not asserted
# here for the same reason as the regional-AD case above: dns_label is also
# Optional+Computed on oci_core_vcn, so an explicit null is unknown at plan
# time and not observable through this testing tool.

# --- Subnet naming + per-AD tags ----------------------------------------------

run "default_subnet_name_uses_suffix" {
  command = plan

  variables {
    public_subnets       = ["10.0.1.0/24"]
    public_subnet_suffix = "pub"
  }

  assert {
    condition     = oci_core_subnet.public[0].display_name == "test-pub-1"
    error_message = "an unnamed public subnet must be named '<name>-<suffix>-<n>'"
  }
}

run "explicit_subnet_name_overrides_generated" {
  command = plan

  variables {
    public_subnets      = ["10.0.1.0/24"]
    public_subnet_names = ["custom-name"]
  }

  assert {
    condition     = oci_core_subnet.public[0].display_name == "custom-name"
    error_message = "an explicit public_subnet_names entry must override the generated name"
  }
}

run "per_ad_tags_applied_by_resolved_ad_name" {
  command = plan

  variables {
    availability_domains = [1]
    public_subnets       = ["10.0.1.0/24"]
    public_subnet_tags_per_ad = {
      "AD-1" = { team = "networking" }
    }
  }

  assert {
    condition     = oci_core_subnet.public[0].freeform_tags["team"] == "networking"
    error_message = "public_subnet_tags_per_ad must be looked up by the subnet's resolved AD name and merged into freeform_tags"
  }
}
