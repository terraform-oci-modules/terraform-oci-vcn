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
# VCN Module — Service Gateway example
#
# Demonstrates a fully-private VCN with no Internet Gateway and no NAT Gateway.
# All outbound traffic from private and database subnets is routed exclusively
# through the Oracle Service Gateway (SGW) to Oracle Services Network —
# typically used for Object Storage, Logging, Monitoring, Vault, and similar
# managed services that are reachable without leaving Oracle's network.
#
# Key settings:
#   create_service_gateway             = true   — explicit opt-in (OCI-specific flag)
#   create_internet_gateway            = false  — no public internet access
#   enable_nat_gateway                 = false  — no NAT; Oracle Services via SGW only
#   create_database_subnet_route_table = true   — dedicated RT for DB subnets; also
#                                                 picks up the SGW route automatically
#   service_gateway_tags               — optional extra freeform tags on the SGW
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  # Private subnets — no public subnets, no IGW
  private_subnets = [cidrsubnet(local.vcn_cidr, 4, 0), cidrsubnet(local.vcn_cidr, 4, 1), cidrsubnet(local.vcn_cidr, 4, 2)]

  # Database subnets with their own dedicated route table
  # The dedicated RT receives the SGW rule automatically when create_service_gateway = true
  database_subnets                   = [cidrsubnet(local.vcn_cidr, 4, 4), cidrsubnet(local.vcn_cidr, 4, 5), cidrsubnet(local.vcn_cidr, 4, 6)]
  create_database_subnet_route_table = true

  # No internet access — Oracle Services via SGW only
  create_internet_gateway = false
  enable_nat_gateway      = false
  create_service_gateway  = true

  # Optional: add extra freeform tags to the Service Gateway resource
  service_gateway_tags = {
    ServiceGatewayPurpose = "oracle-services-only"
  }

  tags = local.tags
}
