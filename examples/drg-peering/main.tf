# Two provider aliases — one per region
provider "oci" {
  alias  = "ashburn"
  region = local.region_ashburn
}

provider "oci" {
  alias  = "chicago"
  region = local.region_chicago
}

locals {
  name           = "ex-${basename(path.cwd)}"
  region_ashburn = "us-ashburn-1"
  region_chicago = "us-chicago-1"

  vcn_cidr_ashburn = "10.0.0.0/16"
  vcn_cidr_chicago = "10.1.0.0/16"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# VCN Module — DRG Peering example
#
# Demonstrates connecting two VCNs in different OCI regions using Dynamic
# Routing Gateways (DRGs) and Remote Peering Connections (RPCs).
# DRG peering is the standard cross-region connectivity pattern in OCI.
#
# Topology:
#
#   Ashburn VCN (10.0.0.0/16) ── DRG-A ── RPC ── DRG-C ── Chicago VCN (10.1.0.0/16)
#
# How OCI cross-region DRG peering works:
#   1. A DRG is created in each region and attached to its VCN.
#   2. One side (here: Ashburn) creates an RPC and sets peer_id + peer_region_name
#      to initiate the connection. The other side (Chicago) creates an RPC that
#      will become the acceptor once the peer_id is set.
#   3. Route tables on each VCN must have a route pointing the remote CIDR to the
#      local DRG. This example uses the symbolic "drg" network_entity_id in
#      nat_gateway_route_rules, which the module resolves via attached_drg_id.
#
# Key module settings:
#   attached_drg_id          — tells the module which DRG to use for "drg" symbolic routes
#   nat_gateway_route_rules  — adds a route for the remote VCN CIDR via the DRG
#   single_nat_gateway       — one NAT GW per VCN (quota constraint)
################################################################################

################################################################################
# Ashburn VCN
################################################################################

module "vcn_ashburn" {
  source = "../../"

  providers = {
    oci = oci.ashburn
  }

  name           = "${local.name}-ashburn"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr_ashburn

  public_subnets  = [cidrsubnet(local.vcn_cidr_ashburn, 4, 8), cidrsubnet(local.vcn_cidr_ashburn, 4, 9)]
  private_subnets = [cidrsubnet(local.vcn_cidr_ashburn, 4, 0), cidrsubnet(local.vcn_cidr_ashburn, 4, 1)]

  create_igw             = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  # Pass the DRG OCID so the symbolic "drg" network_entity_id works in route rules
  attached_drg_id = oci_core_drg.ashburn.id

  # Route traffic destined for the Chicago VCN through the local DRG
  nat_gateway_route_rules = [
    {
      destination       = local.vcn_cidr_chicago
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "drg"
      description       = "Route to Chicago VCN via DRG"
    }
  ]

  tags = local.tags
}

################################################################################
# Chicago VCN
################################################################################

module "vcn_chicago" {
  source = "../../"

  providers = {
    oci = oci.chicago
  }

  name           = "${local.name}-chicago"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr_chicago

  private_subnets = [cidrsubnet(local.vcn_cidr_chicago, 4, 0), cidrsubnet(local.vcn_cidr_chicago, 4, 1)]

  # Chicago spoke has no internet access — traffic to Oracle Services via SGW,
  # and cross-region traffic back to Ashburn via DRG
  create_igw             = false
  enable_nat_gateway     = false
  create_service_gateway = true

  attached_drg_id = oci_core_drg.chicago.id

  tags = local.tags
}

################################################################################
# DRGs — one per region
################################################################################

resource "oci_core_drg" "ashburn" {
  provider       = oci.ashburn
  compartment_id = var.compartment_id
  display_name   = "${local.name}-drg-ashburn"
  freeform_tags  = merge({ "Name" = "${local.name}-drg-ashburn" }, local.tags)
}

resource "oci_core_drg" "chicago" {
  provider       = oci.chicago
  compartment_id = var.compartment_id
  display_name   = "${local.name}-drg-chicago"
  freeform_tags  = merge({ "Name" = "${local.name}-drg-chicago" }, local.tags)
}

################################################################################
# DRG Attachments — connect each DRG to its VCN
################################################################################

resource "oci_core_drg_attachment" "ashburn" {
  provider     = oci.ashburn
  drg_id       = oci_core_drg.ashburn.id
  vcn_id       = module.vcn_ashburn.vcn_id
  display_name = "${local.name}-drg-ashburn-attachment"
}

resource "oci_core_drg_attachment" "chicago" {
  provider     = oci.chicago
  drg_id       = oci_core_drg.chicago.id
  vcn_id       = module.vcn_chicago.vcn_id
  display_name = "${local.name}-drg-chicago-attachment"
}

################################################################################
# Remote Peering Connections — cross-region DRG link
#
# The Ashburn RPC is the requestor: it sets peer_id and peer_region_name to
# initiate the connection. The Chicago RPC is the acceptor.
################################################################################

resource "oci_core_remote_peering_connection" "chicago" {
  provider       = oci.chicago
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.chicago.id
  display_name   = "${local.name}-rpc-chicago"
  freeform_tags  = merge({ "Name" = "${local.name}-rpc-chicago" }, local.tags)
}

resource "oci_core_remote_peering_connection" "ashburn" {
  provider       = oci.ashburn
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.ashburn.id
  display_name   = "${local.name}-rpc-ashburn"
  freeform_tags  = merge({ "Name" = "${local.name}-rpc-ashburn" }, local.tags)

  # Initiate the peering from Ashburn → Chicago
  peer_id          = oci_core_remote_peering_connection.chicago.id
  peer_region_name = local.region_chicago
}
