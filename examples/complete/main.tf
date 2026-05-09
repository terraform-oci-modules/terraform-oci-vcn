provider "oci" {
  region = local.region
}

locals {
  name   = "ex-complete"
  region = "us-ashburn-1"

  vcn_cidr = "10.0.0.0/16"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# VCN Module — Complete example
#
# Demonstrates:
#  - All four subnet types (public, private, database, intra)
#  - Regional subnets (span all ADs)
#  - Internet Gateway, NAT Gateway (single), Service Gateway
#  - Dedicated database subnet route table
#  - Per-subnet route tables (public + intra)
#  - Custom DHCP options (search domain + VcnLocalPlusInternet resolver)
#  - Flow logs enabled
#  - Default security list lockdown (default)
#  - Custom NAT route rules
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id

  cidr = local.vcn_cidr

  # Public subnets — regional (span all ADs); internet-facing (IGW route), public IPs eligible
  public_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 8),  # 10.0.128.0/20
    cidrsubnet(local.vcn_cidr, 4, 9),  # 10.0.144.0/20
    cidrsubnet(local.vcn_cidr, 4, 10), # 10.0.160.0/20
  ]

  # Private subnets — regional; outbound via NAT, no inbound from internet
  private_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 0), # 10.0.0.0/20
    cidrsubnet(local.vcn_cidr, 4, 1), # 10.0.16.0/20
    cidrsubnet(local.vcn_cidr, 4, 2), # 10.0.32.0/20
  ]

  # Database subnets — regional; dedicated route table (set below)
  database_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 4), # 10.0.64.0/20
    cidrsubnet(local.vcn_cidr, 4, 5), # 10.0.80.0/20
    cidrsubnet(local.vcn_cidr, 4, 6), # 10.0.96.0/20
  ]
  create_database_subnet_route_table = true

  # Intra subnets — dedicated empty route table per subnet (no rules — fully isolated)
  intra_subnets = [
    cidrsubnet(local.vcn_cidr, 8, 52), # 10.0.52.0/24
    cidrsubnet(local.vcn_cidr, 8, 53), # 10.0.53.0/24
  ]

  # Gateways
  create_igw             = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  # Per-subnet route tables: one dedicated route table per public subnet and per intra subnet
  create_multiple_public_route_tables = true
  create_multiple_intra_route_tables  = true

  # Custom DHCP options — search domain with OCI VCN resolver (default type)
  enable_dhcp_options      = true
  dhcp_options_domain_name = "example.internal"
  dhcp_options_server_type = "VcnLocalPlusInternet"

  # Flow logs (OCI Logging service)
  enable_flow_log             = true
  flow_log_retention_duration = 30

  # Custom route rules on the NAT route table: symbolic 'drg' key resolves to var.attached_drg_id
  # Uncomment and provide attached_drg_id when you have a DRG attached to the VCN:
  # attached_drg_id = "<your-drg-ocid>"
  # nat_gateway_route_rules = [
  #   {
  #     destination        = "192.168.0.0/16"
  #     destination_type   = "CIDR_BLOCK"
  #     network_entity_id  = "drg"
  #     description        = "Route to on-premises via DRG"
  #   }
  # ]

  tags = local.tags
}
