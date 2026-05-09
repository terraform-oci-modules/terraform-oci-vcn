provider "oci" {
  region = local.region
}

locals {
  name   = "ex-simple"
  region = "us-ashburn-1"

  vcn_cidr = "10.0.0.0/16"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# VCN Module — Simple example
#
# Minimal setup: one VCN with public and private subnets, a single shared NAT
# Gateway, and a Service Gateway for Oracle services (Object Storage, Logging…).
# create_igw defaults to true — an Internet Gateway is created automatically.
# Subnets are regional (ads = [] default), meaning each subnet spans all ADs.
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id

  cidr = local.vcn_cidr # 10.0.0.0/16

  # Regional subnets — ads = [] (default) means each subnet spans all ADs.
  # Each /20 block holds 4,094 usable addresses.
  private_subnets = [                 # outbound via NAT, no inbound from internet
    cidrsubnet(local.vcn_cidr, 4, 0), # 10.0.0.0/20
    cidrsubnet(local.vcn_cidr, 4, 1), # 10.0.16.0/20
    cidrsubnet(local.vcn_cidr, 4, 2), # 10.0.32.0/20
  ]
  public_subnets = [                   # internet-facing; public IPs eligible via IGW
    cidrsubnet(local.vcn_cidr, 4, 8),  # 10.0.128.0/20
    cidrsubnet(local.vcn_cidr, 4, 9),  # 10.0.144.0/20
    cidrsubnet(local.vcn_cidr, 4, 10), # 10.0.160.0/20
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = true # one shared NAT GW for all private subnets
  create_service_gateway = true

  tags = local.tags
}
