################################################################################
# Mock unit tests: fast, free, no real OCI resources.
#
# NAT gateway public IP selection (nat_gateway_public_ip_id,
# reserve_nat_ip_per_gateway, external_nat_ip_ids) against the module root with
# a mocked OCI provider. Kept apart from unit_mappings.tftest.hcl because some
# runs use command = apply, whose state would leak into that file's plan runs.
# Run on its own:
#   terraform test -filter=tests/nat_public_ips.tftest.hcl
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

# command = apply: public_ip_id is Optional+Computed, so it is unknown at plan time.
run "nat_reserved_ip_first_gateway_only_by_default" {
  command = apply

  variables {
    enable_nat_gateway       = true
    private_subnets          = ["10.0.11.0/24", "10.0.12.0/24"]
    nat_gateway_public_ip_id = "RESERVED"
  }

  assert {
    condition     = length(oci_core_public_ip.nat) == 1
    error_message = "nat_gateway_public_ip_id = RESERVED must create one reserved IP, for the first gateway"
  }
  assert {
    condition     = oci_core_nat_gateway.this[0].public_ip_id == oci_core_public_ip.nat[0].id
    error_message = "the first gateway must get the reserved IP"
  }
  assert {
    condition     = oci_core_nat_gateway.this[1].public_ip_id != oci_core_public_ip.nat[0].id
    error_message = "without reserve_nat_ip_per_gateway, gateways after the first must not get a reserved IP"
  }
}

# command = apply: the reserved IP OCIDs are unknown at plan time under the mock.
run "reserve_nat_ip_per_gateway_attaches_one_ip_each" {
  command = apply

  variables {
    enable_nat_gateway         = true
    private_subnets            = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    nat_gateway_public_ip_id   = "RESERVED"
    reserve_nat_ip_per_gateway = true
  }

  assert {
    condition     = length(oci_core_public_ip.nat) == 3
    error_message = "reserve_nat_ip_per_gateway must create one reserved IP per NAT gateway"
  }
  assert {
    condition     = oci_core_public_ip.nat[0].display_name == "test-nat-ip"
    error_message = "the first reserved IP must keep the name it has with RESERVED alone, so it is not renamed"
  }
  assert {
    condition     = alltrue([for i, gw in oci_core_nat_gateway.this : gw.public_ip_id == oci_core_public_ip.nat[i].id])
    error_message = "each NAT gateway must get its own reserved IP, in order"
  }
  assert {
    condition     = output.nat_reserved_public_ip_ids == oci_core_public_ip.nat[*].id
    error_message = "nat_reserved_public_ip_ids must list every reserved IP"
  }
}

run "external_nat_ip_ids_attach_in_order" {
  command = plan

  variables {
    enable_nat_gateway  = true
    private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
    external_nat_ip_ids = ["ocid1.publicip.oc1..aaaaaaaaone", "ocid1.publicip.oc1..aaaaaaaatwo"]
  }

  assert {
    condition     = oci_core_nat_gateway.this[*].public_ip_id == ["ocid1.publicip.oc1..aaaaaaaaone", "ocid1.publicip.oc1..aaaaaaaatwo"]
    error_message = "external_nat_ip_ids must attach one IP per gateway in order"
  }
  assert {
    condition     = length(oci_core_public_ip.nat) == 0
    error_message = "external_nat_ip_ids must not create reserved IPs"
  }
}

run "external_nat_ip_ids_length_must_match_gateways" {
  command = plan

  variables {
    enable_nat_gateway  = true
    private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
    external_nat_ip_ids = ["ocid1.publicip.oc1..aaaaaaaaone"]
  }

  expect_failures = [oci_core_nat_gateway.this]
}

run "external_nat_ip_ids_conflict_with_reserved" {
  command = plan

  variables {
    enable_nat_gateway       = true
    single_nat_gateway       = true
    nat_gateway_public_ip_id = "RESERVED"
    external_nat_ip_ids      = ["ocid1.publicip.oc1..aaaaaaaaone"]
  }

  expect_failures = [oci_core_nat_gateway.this]
}

run "reserve_per_gateway_conflicts_with_existing_ip_ocid" {
  command = plan

  variables {
    enable_nat_gateway         = true
    single_nat_gateway         = true
    nat_gateway_public_ip_id   = "ocid1.publicip.oc1..aaaaaaaaone"
    reserve_nat_ip_per_gateway = true
  }

  expect_failures = [oci_core_nat_gateway.this]
}

run "external_nat_ip_ids_rejects_non_publicip_ocid" {
  command = plan

  variables {
    enable_nat_gateway  = true
    single_nat_gateway  = true
    external_nat_ip_ids = ["ocid1.subnet.oc1..aaaaaaaaone"]
  }

  expect_failures = [var.external_nat_ip_ids]
}
