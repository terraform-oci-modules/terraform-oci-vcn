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
# VCN Module — Separate Route Tables example
#
# Demonstrates creating a dedicated route table for the database subnet tier,
# independent from the private (NAT) route table.
# Mirrors: examples/separate-route-tables in terraform-aws-vpc.
#
# When create_database_subnet_route_table = true:
#   - Database subnets get their own route table with NAT + SGW routes
#   - Private subnets keep their own NAT route table(s)
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  # Regional subnets — ads = [] (default); each subnet spans all ADs automatically
  # Public subnets — internet-facing (IGW route), public IPs eligible
  public_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 8),  # 10.0.128.0/20
    cidrsubnet(local.vcn_cidr, 4, 9),  # 10.0.144.0/20
    cidrsubnet(local.vcn_cidr, 4, 10), # 10.0.160.0/20
  ]
  # Private subnets — outbound via NAT, no inbound from internet
  private_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 0), # 10.0.0.0/20
    cidrsubnet(local.vcn_cidr, 4, 1), # 10.0.16.0/20
    cidrsubnet(local.vcn_cidr, 4, 2), # 10.0.32.0/20
  ]

  # Database subnets — dedicated route table (NAT + SGW routes, separate from private RT)
  database_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 4), # 10.0.64.0/20
    cidrsubnet(local.vcn_cidr, 4, 5), # 10.0.80.0/20
    cidrsubnet(local.vcn_cidr, 4, 6), # 10.0.96.0/20
  ]
  create_database_subnet_route_table = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  tags = local.tags
}
