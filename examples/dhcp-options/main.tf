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
# VCN Module — DHCP Options examples
#
# OCI creates a default DHCP options set for every VCN (VcnLocalPlusInternet
# resolver, no custom search domain). This example demonstrates overriding those
# defaults using the module's create_dhcp_options flag.
#
# Two VCNs are created side-by-side:
#
#   vcn_search_domain  — VcnLocalPlusInternet resolver with a custom search
#                        domain (corp.example.internal). Instances resolve
#                        short names via OCI's built-in resolver first, then
#                        append the search domain for unqualified names.
#
#   vcn_custom_dns     — CustomDnsServer resolver pointing at two on-premises
#                        DNS forwarders (192.168.100.10 and 192.168.100.11).
#                        All DNS queries bypass OCI's resolver entirely and go
#                        to the custom servers.
#
# Key module settings:
#   create_dhcp_options              = true   — opt-in; false = use VCN default
#   dhcp_options_server_type         — "VcnLocalPlusInternet" or "CustomDnsServer"
#   dhcp_options_search_domain       — optional; appended to unqualified DNS names
#   dhcp_options_custom_dns_servers  — required when server_type = "CustomDnsServer"
#   dhcp_options_tags                — optional extra freeform tags on the DHCP set
################################################################################

################################################################################
# VCN 1: OCI resolver + custom search domain
################################################################################

module "vcn_search_domain" {
  source = "../../"

  name           = "${local.name}-search-domain"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = local.vcn_cidr

  private_subnets = [cidrsubnet(local.vcn_cidr, 4, 0), cidrsubnet(local.vcn_cidr, 4, 1)]
  public_subnets  = [cidrsubnet(local.vcn_cidr, 4, 8)]

  create_internet_gateway = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  create_service_gateway  = true

  # Custom DHCP options: use OCI's VCN resolver but append a search domain so
  # that unqualified hostnames like "db01" resolve as "db01.corp.example.internal"
  create_dhcp_options        = true
  dhcp_options_server_type   = "VcnLocalPlusInternet"
  dhcp_options_search_domain = "corp.example.internal"
  dhcp_options_tags = {
    DhcpOptionsPurpose = "vcn-resolver-with-search-domain"
  }

  tags = local.tags
}

################################################################################
# VCN 2: Custom DNS servers (on-premises forwarders)
################################################################################

module "vcn_custom_dns" {
  source = "../../"

  name           = "${local.name}-custom-dns"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = "10.1.0.0/16"

  private_subnets = [cidrsubnet("10.1.0.0/16", 4, 0), cidrsubnet("10.1.0.0/16", 4, 1)]

  create_internet_gateway = false
  enable_nat_gateway      = false
  create_service_gateway  = true

  # Custom DHCP options: bypass OCI's resolver; all DNS queries go to these
  # on-premises forwarders (placeholder IPs — replace with your actual servers)
  create_dhcp_options             = true
  dhcp_options_server_type        = "CustomDnsServer"
  dhcp_options_custom_dns_servers = ["192.168.100.10", "192.168.100.11"]
  dhcp_options_tags = {
    DhcpOptionsPurpose = "custom-dns-forwarders"
  }

  tags = local.tags
}
