provider "oci" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
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
#  - AD-specific subnet placement across 3 ADs
#  - Internet Gateway, NAT Gateway (single), Service Gateway
#  - Dedicated database subnet route table
#  - Per-subnet route tables (public + intra)
#  - Custom DHCP options (search domain + VcnLocalPlusInternet resolver)
#  - Per-AD subnet tags (public + private tiers)
#  - Flow logs enabled
#  - Default security list lockdown (default)
#  - Custom NAT route rules
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  # AD-specific subnet placement: pin subnets to ADs 1, 2, 3.
  # Remove this line (or set ads = []) to use regional subnets instead.
  ads = [1, 2, 3]

  # Public subnets — one per AD
  public_subnets = [cidrsubnet(local.vcn_cidr, 4, 8), cidrsubnet(local.vcn_cidr, 4, 9), cidrsubnet(local.vcn_cidr, 4, 10)]

  # Private subnets — one per AD
  private_subnets = [cidrsubnet(local.vcn_cidr, 4, 0), cidrsubnet(local.vcn_cidr, 4, 1), cidrsubnet(local.vcn_cidr, 4, 2)]

  # Database subnets — one per AD, with a dedicated route table
  database_subnets                   = [cidrsubnet(local.vcn_cidr, 4, 4), cidrsubnet(local.vcn_cidr, 4, 5), cidrsubnet(local.vcn_cidr, 4, 6)]
  create_database_subnet_route_table = true

  # Intra subnets — fully isolated (no outbound route)
  intra_subnets = [cidrsubnet(local.vcn_cidr, 8, 52), cidrsubnet(local.vcn_cidr, 8, 53)]

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

  # Per-AD freeform tags — applied on top of subnet_tags for the matching AD
  public_subnet_tags_per_ad = {
    "NATD:US-ASHBURN-AD-1" = { "Tier" = "public", "AD" = "ad-1" }
    "NATD:US-ASHBURN-AD-2" = { "Tier" = "public", "AD" = "ad-2" }
    "NATD:US-ASHBURN-AD-3" = { "Tier" = "public", "AD" = "ad-3" }
  }
  private_subnet_tags_per_ad = {
    "NATD:US-ASHBURN-AD-1" = { "Tier" = "private", "AD" = "ad-1" }
    "NATD:US-ASHBURN-AD-2" = { "Tier" = "private", "AD" = "ad-2" }
    "NATD:US-ASHBURN-AD-3" = { "Tier" = "private", "AD" = "ad-3" }
  }

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
