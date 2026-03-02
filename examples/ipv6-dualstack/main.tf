provider "oci" {}

locals {
  name = "ex-${basename(path.cwd)}"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# VCN — dual-stack (IPv4 + IPv6)
#
# OCI assigns a /56 IPv6 prefix to the VCN automatically when enable_ipv6 = true.
# The assigned prefix is only known after the first apply and is visible in the
# vcn_ipv6_cidr_blocks output.
#
# Two-step workflow for subnet IPv6 CIDRs:
#   1. Apply with enable_ipv6 = true (no subnet IPv6 CIDRs yet).
#      Note the /56 printed in vcn_ipv6_cidr_blocks.
#   2. Carve /64 blocks from the /56 and set public_subnet_ipv6_cidrs /
#      private_subnet_ipv6_cidrs, then apply again.
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  vcn_dns_label  = "exipv6dual"

  cidr = "10.0.0.0/16"

  # Request an Oracle-provided /56 IPv6 CIDR block for the VCN.
  enable_ipv6 = true

  # Public subnets — IPv4 only on first apply.
  # After noting the VCN's /56, uncomment public_subnet_ipv6_cidrs and re-apply
  # with /64 blocks carved from that prefix.
  public_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
  # public_subnet_ipv6_cidrs = ["<vcn_ipv6_prefix>:0000::/64", "<vcn_ipv6_prefix>:0001::/64", "<vcn_ipv6_prefix>:0002::/64"]

  # Private subnets — IPv4 only.
  # IPv6 is optional for private subnets; outbound IPv6 also goes via the IGW
  # in OCI (there is no separate egress-only gateway).
  private_subnets = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]

  create_igw         = true
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = local.tags
}
