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
# VCN Module
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  # Regional subnets (ads = [] is the default — subnets span all ADs automatically)
  private_subnets = [cidrsubnet(local.vcn_cidr, 4, 0), cidrsubnet(local.vcn_cidr, 4, 1), cidrsubnet(local.vcn_cidr, 4, 2)]
  public_subnets  = [cidrsubnet(local.vcn_cidr, 4, 8), cidrsubnet(local.vcn_cidr, 4, 9), cidrsubnet(local.vcn_cidr, 4, 10)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  tags = local.tags
}
