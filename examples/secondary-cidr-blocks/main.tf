provider "oci" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-ashburn-1"

  # Primary VCN CIDR
  vcn_cidr = "10.0.0.0/16"

  # Secondary CIDR block — subnets can be carved from either CIDR
  secondary_cidr = "10.1.0.0/16"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# VCN Module — Secondary CIDR Blocks example
#
# Demonstrates attaching a secondary IPv4 CIDR to the VCN and carving subnets
# from both the primary and secondary CIDR ranges.
# Mirrors: examples/secondary-cidr-blocks in terraform-aws-vpc.
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  # Attach a secondary CIDR block
  secondary_cidrs = [local.secondary_cidr]

  # Public subnets from the primary CIDR
  public_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 8),
    cidrsubnet(local.vcn_cidr, 4, 9),
  ]

  # Private subnets from the primary CIDR
  private_subnets = [
    cidrsubnet(local.vcn_cidr, 4, 0),
    cidrsubnet(local.vcn_cidr, 4, 1),
  ]

  # Additional private subnets carved from the secondary CIDR
  # (OCI allows mixing CIDRs from any block attached to the VCN)
  intra_subnets = [
    cidrsubnet(local.secondary_cidr, 4, 0),
    cidrsubnet(local.secondary_cidr, 4, 1),
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  tags = local.tags
}
