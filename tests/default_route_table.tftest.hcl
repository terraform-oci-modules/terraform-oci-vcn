################################################################################
# Mock unit tests: fast, free, no real OCI resources.
#
# Subnets with no route table of their own must point at the VCN default route
# table, not null: the OCI provider keeps the old route_table_id when the
# argument is null, so turning NAT off left subnets on a route table the module
# was deleting. Uses command = apply against the mock because the default route
# table OCID is only known after apply. Run on its own:
#   terraform test -filter=tests/default_route_table.tftest.hcl
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
      default_route_table_id = "ocid1.routetable.oc1..aaaaaaaadefault"
    }
  }
}

variables {
  compartment_id   = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  name             = "test"
  public_subnets   = ["10.0.1.0/24"]
  private_subnets  = ["10.0.11.0/24"]
  database_subnets = ["10.0.21.0/24"]
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
