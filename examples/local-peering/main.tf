provider "oci" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-ashburn-1"

  hub_cidr   = "10.0.0.0/16"
  spoke_cidr = "10.1.0.0/16"

  tags = {
    Example    = local.name
    GithubRepo = "terraform-oci-vcn"
    GithubOrg  = "terraform-oci-modules"
  }
}

################################################################################
# Local Peering example
#
# Demonstrates connecting two VCNs in the same region using Local Peering
# Gateways (LPGs). LPG peering is a same-region feature; for cross-region
# connectivity use a Dynamic Routing Gateway (DRG) instead.
#
# Topology:
#   hub VCN  (10.0.0.0/16)  ──LPG──  spoke VCN  (10.1.0.0/16)
#
# How OCI LPG peering works:
#   - Each VCN gets one LPG resource.
#   - One side is the "requestor" — it sets peer_id to the other LPG's OCID.
#   - The other side is the "acceptor" — it omits peer_id and waits for the
#     requestor to initiate.
#   - Here the spoke drives the connection: spoke.lpg.peer_id = hub.lpg.id
#
# After peering, each VCN's route table needs a route rule pointing the
# remote CIDR at its own LPG. The hub uses internet_gateway_route_rules
# with the symbolic "lpg@to-spoke" notation. The spoke module does the same
# with "lpg@to-hub".
################################################################################

################################################################################
# Hub VCN
################################################################################

module "vcn_hub" {
  source = "../../"

  name           = "${local.name}-hub"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.hub_cidr

  public_subnets  = [cidrsubnet(local.hub_cidr, 4, 8), cidrsubnet(local.hub_cidr, 4, 9)]
  private_subnets = [cidrsubnet(local.hub_cidr, 4, 0), cidrsubnet(local.hub_cidr, 4, 1)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  # Create the hub-side LPG in acceptor mode (no peer_id — spoke initiates)
  local_peering_gateways = {
    to-spoke = {}
  }

  # Route traffic destined for the spoke CIDR through the LPG
  internet_gateway_route_rules = [
    {
      destination       = local.spoke_cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "lpg@to-spoke"
      description       = "Route to spoke VCN via LPG"
    }
  ]

  nat_gateway_route_rules = [
    {
      destination       = local.spoke_cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "lpg@to-spoke"
      description       = "Route to spoke VCN via LPG"
    }
  ]

  tags = local.tags
}

################################################################################
# Spoke VCN
################################################################################

module "vcn_spoke" {
  source = "../../"

  name           = "${local.name}-spoke"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.spoke_cidr

  private_subnets = [cidrsubnet(local.spoke_cidr, 4, 0), cidrsubnet(local.spoke_cidr, 4, 1)]

  # Spoke has no IGW or NAT — it reaches the internet only via the hub
  create_internet_gateway = false
  enable_nat_gateway      = false
  create_service_gateway  = false

  # Create the spoke-side LPG in requestor mode — sets peer_id to initiate peering
  local_peering_gateways = {
    to-hub = {
      peer_id = module.vcn_hub.lpg_ids["to-spoke"]
    }
  }

  # Route all egress from spoke private subnets through the LPG to the hub
  nat_gateway_route_rules = [
    {
      destination       = local.hub_cidr
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "lpg@to-hub"
      description       = "Route to hub VCN via LPG"
    }
  ]

  tags = local.tags
}
