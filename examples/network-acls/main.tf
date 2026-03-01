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
# VCN Module — Network ACLs (Security Lists) example
#
# Demonstrates per-tier dedicated security lists — the OCI equivalent of AWS
# dedicated Network ACLs. Each tier gets a dedicated oci_core_security_list
# with explicit inbound/outbound rules instead of relying solely on the VCN
# default security list.
#
# Rule shape differs from AWS NACLs:
#   - No rule_number (OCI evaluates all matching rules, not in priority order)
#   - protocol: "all", "6" (TCP), "17" (UDP), "1" (ICMP)
#   - source_type / destination_type: "CIDR_BLOCK" or "SERVICE_CIDR_BLOCK"
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  public_subnets   = [cidrsubnet(local.vcn_cidr, 4, 8), cidrsubnet(local.vcn_cidr, 4, 9)]
  private_subnets  = [cidrsubnet(local.vcn_cidr, 4, 0), cidrsubnet(local.vcn_cidr, 4, 1)]
  database_subnets = [cidrsubnet(local.vcn_cidr, 4, 4), cidrsubnet(local.vcn_cidr, 4, 5)]
  intra_subnets    = [cidrsubnet(local.vcn_cidr, 8, 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  # ---- Public dedicated security list ----------------------------------------
  public_dedicated_security_list = true

  public_inbound_security_rules = [
    {
      protocol    = "6" # TCP
      source      = "0.0.0.0/0"
      description = "Allow HTTPS from anywhere"
      tcp_options = { min = 443, max = 443 }
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow HTTP from anywhere"
      tcp_options = { min = 80, max = 80 }
    },
    {
      protocol     = "1" # ICMP
      source       = "0.0.0.0/0"
      description  = "Allow ICMP echo-request"
      icmp_options = { type = 8 }
    },
  ]

  public_outbound_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    },
  ]

  # ---- Private dedicated security list ---------------------------------------
  private_dedicated_security_list = true

  private_inbound_security_rules = [
    {
      protocol    = "6"
      source      = local.vcn_cidr
      description = "Allow all TCP from within the VCN"
      tcp_options = { min = 1, max = 65535 }
    },
    {
      protocol     = "1"
      source       = local.vcn_cidr
      description  = "Allow ICMP type 3 code 4 from VCN (Path MTU)"
      icmp_options = { type = 3, code = 4 }
    },
  ]

  private_outbound_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    },
  ]

  # ---- Database dedicated security list --------------------------------------
  database_dedicated_security_list = true

  database_inbound_security_rules = [
    {
      protocol    = "6"
      source      = cidrsubnet(local.vcn_cidr, 4, 0) # private-1 CIDR
      description = "Allow Oracle DB port from private subnet 1"
      tcp_options = { min = 1521, max = 1521 }
    },
    {
      protocol    = "6"
      source      = cidrsubnet(local.vcn_cidr, 4, 1) # private-2 CIDR
      description = "Allow Oracle DB port from private subnet 2"
      tcp_options = { min = 1521, max = 1521 }
    },
  ]

  database_outbound_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    },
  ]

  # ---- Intra dedicated security list -----------------------------------------
  intra_dedicated_security_list = true

  intra_inbound_security_rules = [
    {
      protocol    = "6"
      source      = local.vcn_cidr
      description = "Allow all TCP from within the VCN (intra)"
      tcp_options = { min = 1, max = 65535 }
    },
  ]

  intra_outbound_security_rules = [
    {
      protocol    = "6"
      destination = local.vcn_cidr
      description = "Allow all TCP within the VCN (intra)"
      tcp_options = { min = 1, max = 65535 }
    },
  ]

  tags = local.tags
}
