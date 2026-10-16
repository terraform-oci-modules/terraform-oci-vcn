################################################################################
# Mock unit tests: fast, free, no real OCI resources.
#
# Subnets without a route table, DHCP options or dedicated security list of
# their own must point at the VCN defaults, not null: the OCI provider keeps the
# old value when the argument is null, so turning NAT, custom DHCP options or a
# dedicated security list off left subnets attached to what the module was
# deleting. Uses command = apply against the mock because the default OCIDs are
# only known after apply. Run on its own:
#   terraform test -filter=tests/vcn_defaults.tftest.hcl
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
      default_route_table_id   = "ocid1.routetable.oc1..aaaaaaaadefault"
      default_dhcp_options_id  = "ocid1.dhcpoptions.oc1..aaaaaaaadefault"
      default_security_list_id = "ocid1.securitylist.oc1..aaaaaaaadefault"
    }
  }
}

variables {
  compartment_id   = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  name             = "test"
  public_subnets   = ["10.0.1.0/24"]
  private_subnets  = ["10.0.11.0/24"]
  database_subnets = ["10.0.21.0/24"]
  intra_subnets    = ["10.0.31.0/24"]
}

run "nat_on_uses_nat_route_table" {
  command = apply

  variables {
    enable_nat_gateway = true
    single_nat_gateway = true
  }

  assert {
    condition     = oci_core_subnet.private[0].route_table_id == oci_core_route_table.nat[0].id
    error_message = "with NAT on, private subnets must use the NAT route table"
  }
}

run "nat_off_moves_private_and_database_to_default" {
  command = apply

  variables {
    enable_nat_gateway = false
  }

  assert {
    condition     = oci_core_subnet.private[0].route_table_id == "ocid1.routetable.oc1..aaaaaaaadefault"
    error_message = "with NAT off, private subnets must point at the VCN default route table, not null"
  }
  assert {
    condition     = oci_core_subnet.database[0].route_table_id == "ocid1.routetable.oc1..aaaaaaaadefault"
    error_message = "with NAT off and no database route table, database subnets must point at the VCN default route table"
  }
  assert {
    condition     = length(oci_core_route_table.nat) == 0
    error_message = "with NAT off, the NAT route table must be removed"
  }
}

run "no_igw_moves_public_to_default" {
  command = apply

  variables {
    create_igw = false
  }

  assert {
    condition     = oci_core_subnet.public[0].route_table_id == "ocid1.routetable.oc1..aaaaaaaadefault"
    error_message = "with create_igw = false, public subnets must point at the VCN default route table, not null"
  }
}

run "custom_dhcp_options_attached_when_enabled" {
  command = apply

  variables {
    enable_dhcp_options = true
  }

  assert {
    condition     = alltrue([for s in concat(oci_core_subnet.public, oci_core_subnet.private, oci_core_subnet.database, oci_core_subnet.intra) : s.dhcp_options_id == oci_core_dhcp_options.this[0].id])
    error_message = "with enable_dhcp_options = true, every subnet must use the custom DHCP options"
  }
}

run "dhcp_options_off_moves_subnets_to_default" {
  command = apply

  variables {
    enable_dhcp_options = false
  }

  assert {
    condition     = alltrue([for s in concat(oci_core_subnet.public, oci_core_subnet.private, oci_core_subnet.database, oci_core_subnet.intra) : s.dhcp_options_id == "ocid1.dhcpoptions.oc1..aaaaaaaadefault"])
    error_message = "with enable_dhcp_options = false, every subnet must point at the VCN default DHCP options, not null"
  }
}

run "dedicated_security_lists_attached_when_enabled" {
  command = apply

  variables {
    public_dedicated_security_list   = true
    private_dedicated_security_list  = true
    database_dedicated_security_list = true
    intra_dedicated_security_list    = true
  }

  assert {
    condition = (
      oci_core_subnet.public[0].security_list_ids == toset([oci_core_security_list.public[0].id])
      && oci_core_subnet.private[0].security_list_ids == toset([oci_core_security_list.private[0].id])
      && oci_core_subnet.database[0].security_list_ids == toset([oci_core_security_list.database[0].id])
      && oci_core_subnet.intra[0].security_list_ids == toset([oci_core_security_list.intra[0].id])
    )
    error_message = "each tier's dedicated security list must be attached to that tier's subnets"
  }
}

run "dedicated_security_lists_off_move_subnets_to_default" {
  command = apply

  variables {
    public_dedicated_security_list   = false
    private_dedicated_security_list  = false
    database_dedicated_security_list = false
    intra_dedicated_security_list    = false
  }

  assert {
    condition     = alltrue([for s in concat(oci_core_subnet.public, oci_core_subnet.private, oci_core_subnet.database, oci_core_subnet.intra) : s.security_list_ids == toset(["ocid1.securitylist.oc1..aaaaaaaadefault"])])
    error_message = "without a dedicated security list, every subnet must point at the VCN default security list, not null"
  }
}
