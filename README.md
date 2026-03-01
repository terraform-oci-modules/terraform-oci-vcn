# OCI VCN Terraform Module

Terraform module which creates VCN resources on Oracle Cloud Infrastructure (OCI).

Designed to be familiar to users of the [terraform-aws-modules/vpc/aws](https://github.com/terraform-aws-modules/terraform-aws-vpc) module — same variable naming conventions, same file structure, same developer experience.

## Usage

```hcl
module "vcn" {
  source = "terraform-oci-modules/vcn/oci"

  name           = "my-vcn"
  compartment_id = var.compartment_id
  tenancy_id     = var.tenancy_id
  cidr           = "10.0.0.0/16"

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

## Regional vs AD-specific Subnets

OCI has a concept with no direct AWS equivalent: subnets can be **regional** (default) or **AD-specific**.

- **Regional subnets** (recommended): `ads = []` (the default). Subnets span all Availability Domains in the region automatically. Most resilient, simplest.
- **AD-specific subnets**: `ads = [1, 2, 3]`. Each subnet is pinned to one AD. Use this only when you need workload-level AD affinity (e.g. bare metal instances, local NVMe, AD-local services).

When `ads` is set, subnets are distributed round-robin across the listed ADs, so you can create more subnets than ADs (e.g. 6 subnets across 3 ADs = 2 subnets per AD).

```hcl
# Regional subnets (default — no ads needed)
module "vcn" {
  source = "terraform-oci-modules/vcn/oci"
  # ...
  # ads = []  <-- this is the default
}

# AD-specific subnets
module "vcn" {
  source = "terraform-oci-modules/vcn/oci"
  # ...
  ads = [1, 2, 3]
}
```

## NAT Gateway Scenarios

This module supports three scenarios for creating NAT Gateways:

- **One NAT Gateway per private subnet** (default):
  - `enable_nat_gateway = true`
  - `single_nat_gateway = false`
  - `one_nat_gateway_per_ad = false`

- **Single NAT Gateway** (cost-optimised for dev/test):
  - `enable_nat_gateway = true`
  - `single_nat_gateway = true`

- **One NAT Gateway per AD** (HA with AD-specific subnets):
  - `enable_nat_gateway = true`
  - `single_nat_gateway = false`
  - `one_nat_gateway_per_ad = true`
  - `ads = [1, 2, 3]`

> **Note:** `one_nat_gateway_per_ad` has no effect when `ads = []` (regional subnets). Regional subnets already span all ADs automatically, so a single NAT Gateway is sufficient.

## Service Gateway (OCI-specific)

OCI's Service Gateway allows private connectivity to Oracle Services Network (Object Storage, etc.) without going through the internet. Enable it with:

```hcl
module "vcn" {
  source = "terraform-oci-modules/vcn/oci"
  # ...
  create_service_gateway = true
}
```

When a Service Gateway is enabled, NAT Gateway route tables automatically include a route to Oracle Services via the SGW.

## Tags

OCI supports two tag types, both mapped:

| Variable | OCI tag type |
|---|---|
| `tags` | `freeform_tags` |
| `defined_tags` | `defined_tags` |

## Examples

- [Simple](examples/simple) — public + private subnets, single NAT, service gateway
- [Complete](examples/complete) — all subnet types, AD-specific placement, flow logs, dedicated DB route table

## Submodules

- [modules/flow-log](modules/flow-log) — standalone flow log for a single subnet or VCN

## Wrappers

- [wrappers](wrappers) — Terragrunt-style `for_each` wrapper for the root module
- [wrappers/flow-log](wrappers/flow-log) — `for_each` wrapper for the flow-log submodule

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_default_security_list.lockdown](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_default_security_list) | resource |
| [oci_core_default_security_list.restore_default](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_default_security_list) | resource |
| [oci_core_dhcp_options.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_dhcp_options) | resource |
| [oci_core_internet_gateway.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_local_peering_gateway.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_local_peering_gateway) | resource |
| [oci_core_nat_gateway.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_nat_gateway) | resource |
| [oci_core_public_ip.nat](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_public_ip) | resource |
| [oci_core_route_table.database](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_route_table.ig](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_route_table.intra](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_route_table.nat](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_security_list.database](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.intra](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.private](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_security_list.public](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_service_gateway.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_service_gateway) | resource |
| [oci_core_subnet.database](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.intra](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.private](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_subnet.public](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn) | resource |
| [oci_logging_log.vcn_flow_logs](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log_group.vcn_flow_logs](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log_group) | resource |
| [oci_core_services.all_oci_services](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_services) | data source |
| [oci_identity_availability_domains.ads](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ads"></a> [ads](#input\_ads) | List of availability domain numbers (e.g. [1, 2, 3]) to pin subnets to specific ADs.<br/><br/>OCI supports two subnet placement modes:<br/>  - Regional (default, recommended): leave ads = [] — subnets span all ADs in the<br/>    region automatically. This is the simplest and most resilient choice for most workloads.<br/>  - AD-specific: set ads = [1, 2, 3] — each subnet is pinned to one AD. Use this only<br/>    when you need workload-level AD affinity (e.g. bare metal, local NVMe, AD-local services).<br/><br/>When ads is set, subnets are distributed round-robin across the listed ADs so you can<br/>create more subnets than ADs (e.g. 6 subnets across 3 ADs gives two subnets per AD). | `list(number)` | `[]` | no |
| <a name="input_attached_drg_id"></a> [attached\_drg\_id](#input\_attached\_drg\_id) | OCID of a DRG already attached to the VCN. Used for symbolic 'drg' route rules | `string` | `null` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | The primary IPv4 CIDR block for the VCN | `string` | `"10.0.0.0/16"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The OCID of the compartment where the VCN and all resources will be created | `string` | n/a | yes |
| <a name="input_create_database_internet_gateway_route"></a> [create\_database\_internet\_gateway\_route](#input\_create\_database\_internet\_gateway\_route) | Controls if an Internet Gateway route is added to the database route table. Requires create\_database\_subnet\_route\_table = true and create\_internet\_gateway = true. Use with caution — database subnets are normally private | `bool` | `false` | no |
| <a name="input_create_database_subnet_route_table"></a> [create\_database\_subnet\_route\_table](#input\_create\_database\_subnet\_route\_table) | Controls if a dedicated route table for database subnets should be created. When false, database subnets use the private route table | `bool` | `false` | no |
| <a name="input_create_dhcp_options"></a> [create\_dhcp\_options](#input\_create\_dhcp\_options) | Controls if a custom DHCP options set is created and associated with all subnets. When false, subnets use the VCN default DHCP options (VcnLocalPlusInternet resolver) | `bool` | `false` | no |
| <a name="input_create_internet_gateway"></a> [create\_internet\_gateway](#input\_create\_internet\_gateway) | Controls if an Internet Gateway is created for public subnets | `bool` | `true` | no |
| <a name="input_create_multiple_intra_route_tables"></a> [create\_multiple\_intra\_route\_tables](#input\_create\_multiple\_intra\_route\_tables) | When true, creates a dedicated route table for each intra subnet. When false, all intra subnets share a single route table | `bool` | `false` | no |
| <a name="input_create_multiple_public_route_tables"></a> [create\_multiple\_public\_route\_tables](#input\_create\_multiple\_public\_route\_tables) | When true, creates a dedicated route table for each public subnet. When false, all public subnets share a single route table | `bool` | `false` | no |
| <a name="input_create_service_gateway"></a> [create\_service\_gateway](#input\_create\_service\_gateway) | Controls if an OCI Service Gateway is created (routes traffic to Oracle Services Network without going to the internet) | `bool` | `false` | no |
| <a name="input_create_vcn"></a> [create\_vcn](#input\_create\_vcn) | Controls if VCN should be created (it affects almost all resources) | `bool` | `true` | no |
| <a name="input_database_acl_tags"></a> [database\_acl\_tags](#input\_database\_acl\_tags) | Additional freeform tags for the database dedicated security list | `map(string)` | `{}` | no |
| <a name="input_database_dedicated_security_list"></a> [database\_dedicated\_security\_list](#input\_database\_dedicated\_security\_list) | Whether to create a dedicated security list for database subnets and attach it | `bool` | `false` | no |
| <a name="input_database_inbound_security_rules"></a> [database\_inbound\_security\_rules](#input\_database\_inbound\_security\_rules) | Inbound (ingress) security rules for the database dedicated security list | <pre>list(object({<br/>    protocol    = string<br/>    source      = string<br/>    source_type = optional(string, "CIDR_BLOCK")<br/>    description = optional(string, null)<br/>    stateless   = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all inbound traffic",<br/>    "protocol": "all",<br/>    "source": "0.0.0.0/0",<br/>    "source_type": "CIDR_BLOCK"<br/>  }<br/>]</pre> | no |
| <a name="input_database_outbound_security_rules"></a> [database\_outbound\_security\_rules](#input\_database\_outbound\_security\_rules) | Outbound (egress) security rules for the database dedicated security list | <pre>list(object({<br/>    protocol         = string<br/>    destination      = string<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    description      = optional(string, null)<br/>    stateless        = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all outbound traffic",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "all"<br/>  }<br/>]</pre> | no |
| <a name="input_database_route_table_tags"></a> [database\_route\_table\_tags](#input\_database\_route\_table\_tags) | Additional freeform tags for the database route tables | `map(string)` | `{}` | no |
| <a name="input_database_subnet_defined_tags"></a> [database\_subnet\_defined\_tags](#input\_database\_subnet\_defined\_tags) | Additional defined tags for the database subnets, merged with var.defined\_tags | `map(string)` | `{}` | no |
| <a name="input_database_subnet_ipv6_cidrs"></a> [database\_subnet\_ipv6\_cidrs](#input\_database\_subnet\_ipv6\_cidrs) | List of IPv6 CIDR blocks for database subnets. Length must match database\_subnets. Requires enable\_ipv6 = true | `list(string)` | `[]` | no |
| <a name="input_database_subnet_names"></a> [database\_subnet\_names](#input\_database\_subnet\_names) | Explicit display names for database subnets. If empty, names are generated | `list(string)` | `[]` | no |
| <a name="input_database_subnet_suffix"></a> [database\_subnet\_suffix](#input\_database\_subnet\_suffix) | Suffix to append to database subnet names | `string` | `"db"` | no |
| <a name="input_database_subnet_tags"></a> [database\_subnet\_tags](#input\_database\_subnet\_tags) | Additional freeform tags for the database subnets | `map(string)` | `{}` | no |
| <a name="input_database_subnet_tags_per_ad"></a> [database\_subnet\_tags\_per\_ad](#input\_database\_subnet\_tags\_per\_ad) | Additional freeform tags for the database subnets where the primary key is the AD name (e.g. "NATD:US-ASHBURN-AD-1") | `map(map(string))` | `{}` | no |
| <a name="input_database_subnets"></a> [database\_subnets](#input\_database\_subnets) | A list of database subnet CIDR blocks inside the VCN (private + service gateway route) | `list(string)` | `[]` | no |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | A map of defined tags (namespace.key = value) to add to all resources | `map(string)` | `{}` | no |
| <a name="input_dhcp_options_custom_dns_servers"></a> [dhcp\_options\_custom\_dns\_servers](#input\_dhcp\_options\_custom\_dns\_servers) | List of custom DNS server IP addresses. Required when dhcp\_options\_server\_type = 'CustomDnsServer'. Only used when create\_dhcp\_options = true | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_search_domain"></a> [dhcp\_options\_search\_domain](#input\_dhcp\_options\_search\_domain) | A domain name to append to DNS search for instances in the VCN. Only used when create\_dhcp\_options = true | `string` | `""` | no |
| <a name="input_dhcp_options_server_type"></a> [dhcp\_options\_server\_type](#input\_dhcp\_options\_server\_type) | DNS server type for the DHCP options set. 'VcnLocalPlusInternet' uses the OCI VCN resolver (equivalent to AmazonProvidedDNS). 'CustomDnsServer' uses the IPs in dhcp\_options\_custom\_dns\_servers. Only used when create\_dhcp\_options = true | `string` | `"VcnLocalPlusInternet"` | no |
| <a name="input_dhcp_options_tags"></a> [dhcp\_options\_tags](#input\_dhcp\_options\_tags) | Additional freeform tags for the DHCP options set. Only used when create\_dhcp\_options = true | `map(string)` | `{}` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VCN (sets vcn\_dns\_label) | `bool` | `true` | no |
| <a name="input_enable_flow_log"></a> [enable\_flow\_log](#input\_enable\_flow\_log) | Whether or not to enable VCN Flow Logs (OCI Logging service) | `bool` | `false` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Requests an Oracle-provided IPv6 CIDR block for the VCN. Subnets must be assigned explicit IPv6 CIDR blocks via <tier>\_subnet\_ipv6\_cidrs | `bool` | `false` | no |
| <a name="input_enable_nat_gateway"></a> [enable\_nat\_gateway](#input\_enable\_nat\_gateway) | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `false` | no |
| <a name="input_flow_log_retention_duration"></a> [flow\_log\_retention\_duration](#input\_flow\_log\_retention\_duration) | Log retention duration in days for VCN flow logs. Allowed values: 30, 60, 90, 180, 365 | `number` | `30` | no |
| <a name="input_flow_log_tags"></a> [flow\_log\_tags](#input\_flow\_log\_tags) | Additional freeform tags for the flow log resources | `map(string)` | `{}` | no |
| <a name="input_internet_gateway_route_rules"></a> [internet\_gateway\_route\_rules](#input\_internet\_gateway\_route\_rules) | Additional route rules to add to the Internet Gateway route table. Use symbolic network\_entity\_id values: 'drg', 'internet\_gateway', 'lpg@<key>' | `list(map(string))` | `null` | no |
| <a name="input_internet_gateway_tags"></a> [internet\_gateway\_tags](#input\_internet\_gateway\_tags) | Additional freeform tags for the Internet Gateway | `map(string)` | `{}` | no |
| <a name="input_intra_acl_tags"></a> [intra\_acl\_tags](#input\_intra\_acl\_tags) | Additional freeform tags for the intra dedicated security list | `map(string)` | `{}` | no |
| <a name="input_intra_dedicated_security_list"></a> [intra\_dedicated\_security\_list](#input\_intra\_dedicated\_security\_list) | Whether to create a dedicated security list for intra subnets and attach it | `bool` | `false` | no |
| <a name="input_intra_inbound_security_rules"></a> [intra\_inbound\_security\_rules](#input\_intra\_inbound\_security\_rules) | Inbound (ingress) security rules for the intra dedicated security list | <pre>list(object({<br/>    protocol    = string<br/>    source      = string<br/>    source_type = optional(string, "CIDR_BLOCK")<br/>    description = optional(string, null)<br/>    stateless   = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all inbound traffic",<br/>    "protocol": "all",<br/>    "source": "0.0.0.0/0",<br/>    "source_type": "CIDR_BLOCK"<br/>  }<br/>]</pre> | no |
| <a name="input_intra_outbound_security_rules"></a> [intra\_outbound\_security\_rules](#input\_intra\_outbound\_security\_rules) | Outbound (egress) security rules for the intra dedicated security list | <pre>list(object({<br/>    protocol         = string<br/>    destination      = string<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    description      = optional(string, null)<br/>    stateless        = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all outbound traffic",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "all"<br/>  }<br/>]</pre> | no |
| <a name="input_intra_route_table_tags"></a> [intra\_route\_table\_tags](#input\_intra\_route\_table\_tags) | Additional freeform tags for the intra route table | `map(string)` | `{}` | no |
| <a name="input_intra_subnet_defined_tags"></a> [intra\_subnet\_defined\_tags](#input\_intra\_subnet\_defined\_tags) | Additional defined tags for the intra subnets, merged with var.defined\_tags | `map(string)` | `{}` | no |
| <a name="input_intra_subnet_ipv6_cidrs"></a> [intra\_subnet\_ipv6\_cidrs](#input\_intra\_subnet\_ipv6\_cidrs) | List of IPv6 CIDR blocks for intra subnets. Length must match intra\_subnets. Requires enable\_ipv6 = true | `list(string)` | `[]` | no |
| <a name="input_intra_subnet_names"></a> [intra\_subnet\_names](#input\_intra\_subnet\_names) | Explicit display names for intra subnets. If empty, names are generated | `list(string)` | `[]` | no |
| <a name="input_intra_subnet_suffix"></a> [intra\_subnet\_suffix](#input\_intra\_subnet\_suffix) | Suffix to append to intra subnet names | `string` | `"intra"` | no |
| <a name="input_intra_subnet_tags"></a> [intra\_subnet\_tags](#input\_intra\_subnet\_tags) | Additional freeform tags for the intra subnets | `map(string)` | `{}` | no |
| <a name="input_intra_subnet_tags_per_ad"></a> [intra\_subnet\_tags\_per\_ad](#input\_intra\_subnet\_tags\_per\_ad) | Additional freeform tags for the intra subnets where the primary key is the AD name (e.g. "NATD:US-ASHBURN-AD-1") | `map(map(string))` | `{}` | no |
| <a name="input_intra_subnets"></a> [intra\_subnets](#input\_intra\_subnets) | A list of intra subnet CIDR blocks inside the VCN (fully isolated, no outbound route) | `list(string)` | `[]` | no |
| <a name="input_local_peering_gateways"></a> [local\_peering\_gateways](#input\_local\_peering\_gateways) | Map of Local Peering Gateways to attach to the VCN. Key is the LPG name, value is an object with optional peer\_id and route\_table\_id | `map(any)` | `null` | no |
| <a name="input_lockdown_default_seclist"></a> [lockdown\_default\_seclist](#input\_lockdown\_default\_seclist) | Whether to remove all default security rules from the VCN Default Security List. Recommended true for security best practice | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | `""` | no |
| <a name="input_nat_gateway_destination_cidr_block"></a> [nat\_gateway\_destination\_cidr\_block](#input\_nat\_gateway\_destination\_cidr\_block) | Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route | `string` | `"0.0.0.0/0"` | no |
| <a name="input_nat_gateway_public_ip_id"></a> [nat\_gateway\_public\_ip\_id](#input\_nat\_gateway\_public\_ip\_id) | Controls the public IP attached to the first (or only) NAT Gateway:<br/>  - null (default): OCI assigns an ephemeral public IP automatically.<br/>  - "RESERVED": the module creates a new reserved public IP and attaches it.<br/>    Use this to get a stable, predictable outbound IP (e.g. for firewall allowlisting).<br/>  - "<ocid>": attach an existing reserved public IP by OCID.<br/>Has no effect when enable\_nat\_gateway = false.<br/>When multiple NAT gateways are created, only the first one gets this IP. | `string` | `null` | no |
| <a name="input_nat_gateway_route_rules"></a> [nat\_gateway\_route\_rules](#input\_nat\_gateway\_route\_rules) | Additional route rules to add to the NAT Gateway route table(s). Use symbolic network\_entity\_id values: 'drg', 'nat\_gateway', 'lpg@<key>' | `list(map(string))` | `null` | no |
| <a name="input_nat_gateway_tags"></a> [nat\_gateway\_tags](#input\_nat\_gateway\_tags) | Additional freeform tags for the NAT Gateways | `map(string)` | `{}` | no |
| <a name="input_one_nat_gateway_per_ad"></a> [one\_nat\_gateway\_per\_ad](#input\_one\_nat\_gateway\_per\_ad) | Should be true if you want one NAT Gateway per availability domain. Has no effect when ads = [] (regional subnets) — in that case a single NAT Gateway is sufficient since regional subnets already span all ADs. Requires var.ads to be set and var.single\_nat\_gateway to be false | `bool` | `false` | no |
| <a name="input_private_acl_tags"></a> [private\_acl\_tags](#input\_private\_acl\_tags) | Additional freeform tags for the private dedicated security list | `map(string)` | `{}` | no |
| <a name="input_private_dedicated_security_list"></a> [private\_dedicated\_security\_list](#input\_private\_dedicated\_security\_list) | Whether to create a dedicated security list for private subnets and attach it | `bool` | `false` | no |
| <a name="input_private_inbound_security_rules"></a> [private\_inbound\_security\_rules](#input\_private\_inbound\_security\_rules) | Inbound (ingress) security rules for the private dedicated security list | <pre>list(object({<br/>    protocol    = string<br/>    source      = string<br/>    source_type = optional(string, "CIDR_BLOCK")<br/>    description = optional(string, null)<br/>    stateless   = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all inbound traffic",<br/>    "protocol": "all",<br/>    "source": "0.0.0.0/0",<br/>    "source_type": "CIDR_BLOCK"<br/>  }<br/>]</pre> | no |
| <a name="input_private_outbound_security_rules"></a> [private\_outbound\_security\_rules](#input\_private\_outbound\_security\_rules) | Outbound (egress) security rules for the private dedicated security list | <pre>list(object({<br/>    protocol         = string<br/>    destination      = string<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    description      = optional(string, null)<br/>    stateless        = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all outbound traffic",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "all"<br/>  }<br/>]</pre> | no |
| <a name="input_private_route_table_tags"></a> [private\_route\_table\_tags](#input\_private\_route\_table\_tags) | Additional freeform tags for the private route tables | `map(string)` | `{}` | no |
| <a name="input_private_subnet_defined_tags"></a> [private\_subnet\_defined\_tags](#input\_private\_subnet\_defined\_tags) | Additional defined tags for the private subnets, merged with var.defined\_tags | `map(string)` | `{}` | no |
| <a name="input_private_subnet_ipv6_cidrs"></a> [private\_subnet\_ipv6\_cidrs](#input\_private\_subnet\_ipv6\_cidrs) | List of IPv6 CIDR blocks for private subnets. Length must match private\_subnets. Requires enable\_ipv6 = true | `list(string)` | `[]` | no |
| <a name="input_private_subnet_names"></a> [private\_subnet\_names](#input\_private\_subnet\_names) | Explicit display names for private subnets. If empty, names are generated | `list(string)` | `[]` | no |
| <a name="input_private_subnet_suffix"></a> [private\_subnet\_suffix](#input\_private\_subnet\_suffix) | Suffix to append to private subnet names | `string` | `"private"` | no |
| <a name="input_private_subnet_tags"></a> [private\_subnet\_tags](#input\_private\_subnet\_tags) | Additional freeform tags for the private subnets | `map(string)` | `{}` | no |
| <a name="input_private_subnet_tags_per_ad"></a> [private\_subnet\_tags\_per\_ad](#input\_private\_subnet\_tags\_per\_ad) | Additional freeform tags for the private subnets where the primary key is the AD name (e.g. "NATD:US-ASHBURN-AD-1") | `map(map(string))` | `{}` | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | A list of private subnet CIDR blocks inside the VCN | `list(string)` | `[]` | no |
| <a name="input_public_acl_tags"></a> [public\_acl\_tags](#input\_public\_acl\_tags) | Additional freeform tags for the public dedicated security list | `map(string)` | `{}` | no |
| <a name="input_public_dedicated_security_list"></a> [public\_dedicated\_security\_list](#input\_public\_dedicated\_security\_list) | Whether to create a dedicated security list for public subnets and attach it (instead of relying solely on the VCN default security list) | `bool` | `false` | no |
| <a name="input_public_inbound_security_rules"></a> [public\_inbound\_security\_rules](#input\_public\_inbound\_security\_rules) | Inbound (ingress) security rules for the public dedicated security list | <pre>list(object({<br/>    protocol    = string<br/>    source      = string<br/>    source_type = optional(string, "CIDR_BLOCK")<br/>    description = optional(string, null)<br/>    stateless   = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all inbound traffic",<br/>    "protocol": "all",<br/>    "source": "0.0.0.0/0",<br/>    "source_type": "CIDR_BLOCK"<br/>  }<br/>]</pre> | no |
| <a name="input_public_outbound_security_rules"></a> [public\_outbound\_security\_rules](#input\_public\_outbound\_security\_rules) | Outbound (egress) security rules for the public dedicated security list | <pre>list(object({<br/>    protocol         = string<br/>    destination      = string<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    description      = optional(string, null)<br/>    stateless        = optional(bool, false)<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }), null)<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number, null)<br/>    }), null)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "description": "Allow all outbound traffic",<br/>    "destination": "0.0.0.0/0",<br/>    "destination_type": "CIDR_BLOCK",<br/>    "protocol": "all"<br/>  }<br/>]</pre> | no |
| <a name="input_public_route_table_tags"></a> [public\_route\_table\_tags](#input\_public\_route\_table\_tags) | Additional freeform tags for the public route table | `map(string)` | `{}` | no |
| <a name="input_public_subnet_defined_tags"></a> [public\_subnet\_defined\_tags](#input\_public\_subnet\_defined\_tags) | Additional defined tags for the public subnets, merged with var.defined\_tags | `map(string)` | `{}` | no |
| <a name="input_public_subnet_ipv6_cidrs"></a> [public\_subnet\_ipv6\_cidrs](#input\_public\_subnet\_ipv6\_cidrs) | List of IPv6 CIDR blocks for public subnets. Length must match public\_subnets. Requires enable\_ipv6 = true | `list(string)` | `[]` | no |
| <a name="input_public_subnet_names"></a> [public\_subnet\_names](#input\_public\_subnet\_names) | Explicit display names for public subnets. If empty, names are generated | `list(string)` | `[]` | no |
| <a name="input_public_subnet_suffix"></a> [public\_subnet\_suffix](#input\_public\_subnet\_suffix) | Suffix to append to public subnet names | `string` | `"public"` | no |
| <a name="input_public_subnet_tags"></a> [public\_subnet\_tags](#input\_public\_subnet\_tags) | Additional freeform tags for the public subnets | `map(string)` | `{}` | no |
| <a name="input_public_subnet_tags_per_ad"></a> [public\_subnet\_tags\_per\_ad](#input\_public\_subnet\_tags\_per\_ad) | Additional freeform tags for the public subnets where the primary key is the AD name (e.g. "NATD:US-ASHBURN-AD-1") | `map(map(string))` | `{}` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of public subnet CIDR blocks inside the VCN | `list(string)` | `[]` | no |
| <a name="input_secondary_cidrs"></a> [secondary\_cidrs](#input\_secondary\_cidrs) | List of secondary IPv4 CIDR blocks to associate with the VCN | `list(string)` | `[]` | no |
| <a name="input_service_gateway_tags"></a> [service\_gateway\_tags](#input\_service\_gateway\_tags) | Additional freeform tags for the Service Gateway | `map(string)` | `{}` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | Should be true if you want to provision a single shared NAT Gateway across all private networks | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of freeform tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The OCID of the tenancy, used to resolve availability domain names.<br/><br/>Optional — when null (default), the module uses var.compartment\_id to query ADs,<br/>which works for any compartment in the tenancy. Set this explicitly only when your<br/>compartment lacks IAM permission to list ADs, which is rare. | `string` | `null` | no |
| <a name="input_vcn_dns_label"></a> [vcn\_dns\_label](#input\_vcn\_dns\_label) | A DNS label for the VCN. When null and enable\_dns\_hostnames is true, derived from var.name. Set to empty string to disable DNS | `string` | `null` | no |
| <a name="input_vcn_tags"></a> [vcn\_tags](#input\_vcn\_tags) | Additional freeform tags for the VCN | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ad_names"></a> [ad\_names](#output\_ad\_names) | Resolved availability domain names for the ADs specified in var.ads |
| <a name="output_ads"></a> [ads](#output\_ads) | A list of availability domain numbers specified as argument to this module |
| <a name="output_database_route_table_id"></a> [database\_route\_table\_id](#output\_database\_route\_table\_id) | The OCID of the dedicated database route table (if created) |
| <a name="output_database_security_list_id"></a> [database\_security\_list\_id](#output\_database\_security\_list\_id) | The OCID of the dedicated database security list (null if not created) |
| <a name="output_database_subnet_objects"></a> [database\_subnet\_objects](#output\_database\_subnet\_objects) | A list of all database subnet objects (full attributes) |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of OCIDs of database subnets |
| <a name="output_database_subnets_cidr_blocks"></a> [database\_subnets\_cidr\_blocks](#output\_database\_subnets\_cidr\_blocks) | List of CIDR blocks of database subnets |
| <a name="output_database_subnets_ipv6_cidr_blocks"></a> [database\_subnets\_ipv6\_cidr\_blocks](#output\_database\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks of database subnets |
| <a name="output_default_dhcp_options_id"></a> [default\_dhcp\_options\_id](#output\_default\_dhcp\_options\_id) | The OCID of the VCN default DHCP options |
| <a name="output_default_route_table_id"></a> [default\_route\_table\_id](#output\_default\_route\_table\_id) | The OCID of the VCN default route table |
| <a name="output_default_security_list_id"></a> [default\_security\_list\_id](#output\_default\_security\_list\_id) | The OCID of the VCN default security list |
| <a name="output_dhcp_options_id"></a> [dhcp\_options\_id](#output\_dhcp\_options\_id) | The OCID of the custom DHCP options set created by this module. Null when create\_dhcp\_options = false |
| <a name="output_flow_log_group_ids"></a> [flow\_log\_group\_ids](#output\_flow\_log\_group\_ids) | Map of subnet type to flow log group OCID |
| <a name="output_flow_log_ids"></a> [flow\_log\_ids](#output\_flow\_log\_ids) | Map of subnet key to flow log OCID |
| <a name="output_ig_route_all_attributes"></a> [ig\_route\_all\_attributes](#output\_ig\_route\_all\_attributes) | All attributes of the Internet Gateway route table (full object, auto-updating) |
| <a name="output_ig_route_id"></a> [ig\_route\_id](#output\_ig\_route\_id) | The OCID of the Internet Gateway route table |
| <a name="output_internet_gateway_all_attributes"></a> [internet\_gateway\_all\_attributes](#output\_internet\_gateway\_all\_attributes) | All attributes of the created Internet Gateway (full object, auto-updating) |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The OCID of the Internet Gateway |
| <a name="output_intra_route_table_id"></a> [intra\_route\_table\_id](#output\_intra\_route\_table\_id) | The OCID of the intra (isolated) route table |
| <a name="output_intra_security_list_id"></a> [intra\_security\_list\_id](#output\_intra\_security\_list\_id) | The OCID of the dedicated intra security list (null if not created) |
| <a name="output_intra_subnet_objects"></a> [intra\_subnet\_objects](#output\_intra\_subnet\_objects) | A list of all intra subnet objects (full attributes) |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of OCIDs of intra subnets |
| <a name="output_intra_subnets_cidr_blocks"></a> [intra\_subnets\_cidr\_blocks](#output\_intra\_subnets\_cidr\_blocks) | List of CIDR blocks of intra subnets |
| <a name="output_intra_subnets_ipv6_cidr_blocks"></a> [intra\_subnets\_ipv6\_cidr\_blocks](#output\_intra\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks of intra subnets |
| <a name="output_lpg_all_attributes"></a> [lpg\_all\_attributes](#output\_lpg\_all\_attributes) | All attributes of created Local Peering Gateways (full objects, auto-updating) |
| <a name="output_lpg_ids"></a> [lpg\_ids](#output\_lpg\_ids) | Map of LPG name to OCID for all created Local Peering Gateways |
| <a name="output_name"></a> [name](#output\_name) | The name specified as argument to this module |
| <a name="output_nat_gateway_all_attributes"></a> [nat\_gateway\_all\_attributes](#output\_nat\_gateway\_all\_attributes) | All attributes of created NAT Gateways (full objects, auto-updating) |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | List of OCIDs of NAT Gateways |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | List of public IP addresses of NAT Gateways |
| <a name="output_nat_reserved_public_ip_id"></a> [nat\_reserved\_public\_ip\_id](#output\_nat\_reserved\_public\_ip\_id) | OCID of the reserved public IP created for the NAT Gateway (null when nat\_gateway\_public\_ip\_id != 'RESERVED') |
| <a name="output_nat_route_all_attributes"></a> [nat\_route\_all\_attributes](#output\_nat\_route\_all\_attributes) | All attributes of NAT Gateway route tables (full objects, auto-updating) |
| <a name="output_nat_route_ids"></a> [nat\_route\_ids](#output\_nat\_route\_ids) | List of OCIDs of NAT Gateway route tables |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of OCIDs of the NAT Gateway route tables (one per NAT GW, used by private subnets) |
| <a name="output_private_security_list_id"></a> [private\_security\_list\_id](#output\_private\_security\_list\_id) | The OCID of the dedicated private security list (null if not created) |
| <a name="output_private_subnet_objects"></a> [private\_subnet\_objects](#output\_private\_subnet\_objects) | A list of all private subnet objects (full attributes) |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of OCIDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of CIDR blocks of private subnets |
| <a name="output_private_subnets_ipv6_cidr_blocks"></a> [private\_subnets\_ipv6\_cidr\_blocks](#output\_private\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks of private subnets |
| <a name="output_public_route_table_id"></a> [public\_route\_table\_id](#output\_public\_route\_table\_id) | The OCID of the Internet Gateway route table (used by public subnets) |
| <a name="output_public_security_list_id"></a> [public\_security\_list\_id](#output\_public\_security\_list\_id) | The OCID of the dedicated public security list (null if not created) |
| <a name="output_public_subnet_objects"></a> [public\_subnet\_objects](#output\_public\_subnet\_objects) | A list of all public subnet objects (full attributes) |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of OCIDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of CIDR blocks of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks of public subnets |
| <a name="output_service_gateway_all_attributes"></a> [service\_gateway\_all\_attributes](#output\_service\_gateway\_all\_attributes) | All attributes of the created Service Gateway (full object, auto-updating) |
| <a name="output_service_gateway_id"></a> [service\_gateway\_id](#output\_service\_gateway\_id) | The OCID of the Service Gateway (OCI-specific) |
| <a name="output_vcn_all_attributes"></a> [vcn\_all\_attributes](#output\_vcn\_all\_attributes) | All attributes of the created VCN (full object, auto-updating) |
| <a name="output_vcn_cidr_block"></a> [vcn\_cidr\_block](#output\_vcn\_cidr\_block) | The primary CIDR block of the VCN |
| <a name="output_vcn_cidr_blocks"></a> [vcn\_cidr\_blocks](#output\_vcn\_cidr\_blocks) | All CIDR blocks (primary + secondary) of the VCN |
| <a name="output_vcn_dns_label"></a> [vcn\_dns\_label](#output\_vcn\_dns\_label) | The DNS label of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
| <a name="output_vcn_ipv6_cidr_blocks"></a> [vcn\_ipv6\_cidr\_blocks](#output\_vcn\_ipv6\_cidr\_blocks) | The IPv6 CIDR blocks assigned to the VCN |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](LICENSE) for full details.
