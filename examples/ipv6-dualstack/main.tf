provider "oci" {}

locals {
  name = "ex-ipv6-dualstack"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# VCN — dual-stack (IPv4 + IPv6)
#
# Setting enable_ipv6 = true causes OCI to assign a /56 prefix to the VCN and
# the module automatically derives a /64 for every subnet — no manual CIDR
# input required, no two-step apply.
#
# Subnet /64 offsets (sequential across all tiers):
#   public-1  → offset 0   (e.g. 2603:c020:xx:yy:0000::/64)
#   public-2  → offset 1
#   public-3  → offset 2
#   private-1 → offset 3   (len(public_subnets) = 3)
#   private-2 → offset 4
#   private-3 → offset 5
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  vcn_dns_label  = "exipv6dual"

  cidr = "10.0.0.0/16"

  enable_ipv6 = true

  # Regional subnets — ads = [] (default); each subnet spans all ADs automatically

  # Public subnets — internet-facing; each gets a /64 IPv6 prefix (offsets 0, 1, 2)
  public_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]

  # Private subnets — outbound via NAT; each gets a /64 IPv6 prefix (offsets 3, 4, 5)
  private_subnets = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}
