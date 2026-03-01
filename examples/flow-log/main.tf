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
# VCN Module — used here only to create a VCN and subnets
# Flow logs are attached via the standalone modules/flow-log submodule below.
################################################################################

module "vcn" {
  source = "../../"

  name           = local.name
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  public_subnets  = [cidrsubnet(local.vcn_cidr, 4, 8)]
  private_subnets = [cidrsubnet(local.vcn_cidr, 4, 0)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_service_gateway = true

  # Root-module flow logs are disabled here — we attach them manually below
  enable_flow_log = false

  tags = local.tags
}

################################################################################
# Flow Log — standalone submodule usage
#
# Demonstrates: examples/flow-log in terraform-aws-vpc.
#
# Two patterns are shown:
#   1. Subnet-level flow log on the first public subnet (new log group created)
#   2. Subnet-level flow log on the first private subnet (shared log group)
################################################################################

# Pattern 1 — public subnet flow log with its own log group
module "flow_log_public" {
  source = "../../modules/flow-log"

  name           = "${local.name}-public-flow-log"
  compartment_id = var.compartment_id

  subnet_id = module.vcn.public_subnets[0]

  create_log_group      = true
  log_group_description = "Flow log group for the public subnet"
  retention_duration    = 30

  tags = local.tags
}

# Pattern 2 — private subnet flow log reusing the log group from pattern 1
module "flow_log_private" {
  source = "../../modules/flow-log"

  name           = "${local.name}-private-flow-log"
  compartment_id = var.compartment_id

  subnet_id = module.vcn.private_subnets[0]

  create_log_group   = false
  log_group_id       = module.flow_log_public.log_group_id
  retention_duration = 30

  tags = local.tags
}
