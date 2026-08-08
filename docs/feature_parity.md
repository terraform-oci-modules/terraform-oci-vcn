# VPC to VCN feature parity

Comparison against [`terraform-aws-vpc`](https://github.com/terraform-aws-modules/terraform-aws-vpc)
v6.6.1. This module mirrors that module's scope (one network, four subnet tiers,
route tables, gateways, DHCP options, flow logs) and maps each concept to its OCI
equivalent. It is not a 1:1 mapping: OCI and AWS networking primitives differ.

Gaps are split three ways:

- [Not applicable](#not-applicable-to-oci): no OCI equivalent exists.
- [Out of scope](#out-of-scope): OCI supports it, this module deliberately does not.
- [Not yet implemented](#not-yet-implemented): the backlog.

## Feature mapping

### Core network resource

| Feature               | AWS                                                       | OCI                                      | Status   |
| --------------------- | --------------------------------------------------------- | ---------------------------------------- | -------- |
| Create toggle         | `create_vpc`                                              | `create_vcn`                             | mapped   |
| Resource name         | `name`                                                    | `name`                                   | mapped   |
| Primary CIDR          | `cidr`                                                    | `vcn_cidr_block`                         | mapped   |
| Secondary CIDRs       | `secondary_cidr_blocks`                                   | `secondary_cidr_blocks`                  | mapped   |
| DNS hostnames         | `enable_dns_hostnames`                                    | `enable_dns_hostnames` + `vcn_dns_label` | mapped   |
| DNS support           | `enable_dns_support`                                      | always on in OCI                         | n/a      |
| DNS label             | none                                                      | `vcn_dns_label` (regex-validated)        | OCI-only |
| IPv6                  | `enable_ipv6`                                             | `enable_ipv6` (`is_ipv6enabled` on VCN)  | mapped   |
| IPv4/IPv6 by IPAM     | `use_ipam_pool`, `ipv4_ipam_pool_id`, `ipv6_ipam_pool_id` | none                                     | n/a      |
| Instance tenancy      | `instance_tenancy`                                        | not a VCN concept                        | n/a      |
| Address usage metrics | `enable_network_address_usage_metrics`                    | none                                     | n/a      |
| Block public access   | `vpc_block_public_access_options` / `*_exclusions`        | none                                     | n/a      |
| Freeform tags         | `tags`                                                    | `tags` / `vcn_tags`                      | mapped   |
| Defined tags          | none                                                      | `defined_tags`                           | OCI-only |

### Subnet tiers

| Tier             | AWS | OCI | Status |
| ---------------- | --- | --- | ------ |
| Public           | yes | yes | mapped |
| Private          | yes | yes | mapped |
| Database         | yes | yes | mapped |
| Intra (isolated) | yes | yes | mapped |
| Redshift         | yes | no  | n/a    |
| ElastiCache      | yes | no  | n/a    |
| Outpost          | yes | no  | n/a    |

> **Redshift / ElastiCache tiers**: AWS added these because those services require
> dedicated subnet groups. OCI has no equivalent managed services with that
> constraint; the `database` tier covers all PaaS/DBaaS use cases on OCI.

Per-tier interface, identical across all four OCI tiers:

| Sub-feature               | AWS                                                         | OCI                                       | Status            |
| ------------------------- | ----------------------------------------------------------- | ----------------------------------------- | ----------------- |
| CIDR list                 | `<tier>_subnets`                                            | `<tier>_subnets`                          | mapped            |
| Custom names list         | `<tier>_subnet_names`                                       | `<tier>_subnet_names`                     | mapped            |
| Name suffix               | `<tier>_subnet_suffix`                                      | `<tier>_subnet_suffix`                    | mapped            |
| Freeform tags per tier    | `<tier>_subnet_tags`                                        | `<tier>_subnet_tags`                      | mapped            |
| Defined tags per tier     | none                                                        | `<tier>_subnet_defined_tags`              | OCI-only          |
| Per-AZ/AD tags            | `<tier>_subnet_tags_per_az`                                 | `<tier>_subnet_tags_per_ad`               | mapped            |
| IPv6 prefixes/CIDRs       | `<tier>_subnet_ipv6_prefixes`                               | auto-derived from the VCN `/56`           | mapped (see note) |
| IPv6-native mode          | `<tier>_subnet_ipv6_native`                                 | none                                      | n/a               |
| DNS64                     | `<tier>_subnet_enable_dns64`                                | none                                      | n/a               |
| Private DNS hostname type | `<tier>_subnet_private_dns_hostname_type_on_launch`         | none (OCI uses `hostname_label` per VNIC) | n/a               |
| Resource-name DNS records | `<tier>_subnet_enable_resource_name_dns_*_record_on_launch` | none                                      | n/a               |

> **IPv6 subnet CIDRs**: AWS takes integer prefix offsets and computes `/64` blocks
> with `cidrsubnet` at plan time. OCI assigns the VCN's `/56` at apply time, but
> because the module calls `cidrsubnet(oci_core_vcn.this[0].ipv6cidr_blocks[0], 8, index)`
> internally, Terraform resolves the dependency automatically. No manual CIDR input
> and no two-step apply. Public subnets get offsets 0 to N, private continue from
> there, then database, then intra.

### Availability domain / zone placement

| Feature                     | AWS                     | OCI                                                           | Status   |
| --------------------------- | ----------------------- | ------------------------------------------------------------- | -------- |
| AZ / AD list input          | `azs` (AZ name strings) | `availability_domains` (integers 1, 2, 3)                     | mapped   |
| Regional (no AZ/AD pinning) | implied when `azs = []` | `availability_domains = []` sets `availability_domain = null` | mapped   |
| AD name resolution          | none                    | resolved from `oci_identity_availability_domains`             | OCI-only |
| AZ/AD names output          | `azs`                   | `availability_domains`, `availability_domain_names`           | mapped   |

### Route tables

| Feature                             | AWS                                          | OCI                                                       | Status            |
| ----------------------------------- | -------------------------------------------- | --------------------------------------------------------- | ----------------- |
| Public route table                  | auto-created                                 | `oci_core_route_table.ig`                                 | mapped            |
| Multiple public route tables        | `create_multiple_public_route_tables`        | `create_multiple_public_route_tables`                     | mapped            |
| Private route table(s)              | auto-created                                 | `oci_core_route_table.nat`                                | mapped            |
| Database route table                | `create_database_subnet_route_table`         | `create_database_subnet_route_table`                      | mapped            |
| Database to IGW route               | `create_database_internet_gateway_route`     | `create_database_internet_gateway_route`                  | mapped            |
| Database to NAT route               | `create_database_nat_gateway_route` (opt-in) | always included when the DB route table is created        | mapped (see note) |
| Intra (isolated) route table        | auto-created                                 | `oci_core_route_table.intra`                              | mapped            |
| Multiple intra route tables         | `create_multiple_intra_route_tables`         | `create_multiple_intra_route_tables`                      | mapped            |
| Route table tags (per tier)         | `*_route_table_tags`                         | `*_route_table_tags`                                      | mapped            |
| Redshift / ElastiCache route tables | yes                                          | none                                                      | n/a               |
| VGW route propagation               | `propagate_*_route_tables_vgw`               | none                                                      | n/a               |
| Custom symbolic route rules         | none                                         | `internet_gateway_route_rules`, `nat_gateway_route_rules` | OCI-only          |

> **Database to NAT**: OCI always includes NAT (and the service gateway when
> enabled) in the DB route table once `create_database_subnet_route_table = true`.
> AWS makes this opt-in; OCI treats it as the only sensible default, since DB
> subnets need egress for OS patching.

### Gateways

| Feature                 | AWS                                       | OCI                                              | Status   |
| ----------------------- | ----------------------------------------- | ------------------------------------------------ | -------- |
| Create IGW              | `create_igw`                              | `create_igw`                                     | mapped   |
| IGW tags                | `igw_tags`                                | `igw_tags`                                       | mapped   |
| Egress-only IGW (IPv6)  | `create_egress_only_igw`                  | none (one OCI IGW handles IPv4 and IPv6 egress)  | n/a      |
| Enable NAT GW           | `enable_nat_gateway`                      | `enable_nat_gateway`                             | mapped   |
| Single NAT GW           | `single_nat_gateway`                      | `single_nat_gateway`                             | mapped   |
| One NAT per AZ/AD       | `one_nat_gateway_per_az`                  | `one_nat_gateway_per_ad`                         | mapped   |
| Custom destination CIDR | `nat_gateway_destination_cidr_block`      | `nat_gateway_destination_cidr_block`             | mapped   |
| NAT GW tags             | `nat_gateway_tags`                        | `nat_gateway_tags`                               | mapped   |
| Reuse / reserve NAT IPs | `reuse_nat_ips`, `external_nat_ip_ids`    | `nat_gateway_public_ip_id`                       | partial  |
| Service Gateway         | closest analog is a VPC gateway endpoint  | `create_service_gateway`, `service_gateway_tags` | OCI-only |
| Attach existing DRG     | none                                      | `attached_drg_id`                                | OCI-only |
| Local Peering Gateways  | none                                      | `local_peering_gateways` (map)                   | OCI-only |
| Customer Gateway / VPN  | `customer_gateways`, `enable_vpn_gateway` | none                                             | backlog  |

> **NAT public IP**: AWS lets you pass a list of pre-allocated EIPs. OCI's NAT
> gateway takes exactly one IP, so `nat_gateway_public_ip_id` is a single value
> with three modes: `null` lets OCI assign an ephemeral IP, `"RESERVED"` creates a
> new reserved public IP and attaches it (for a stable outbound IP you can
> allowlist), and an OCID attaches an existing reserved public IP. There is no
> list form because there is nothing to put in a list.

> **Service Gateway**: provides private access to Oracle-managed services (Object
> Storage, DBaaS APIs) without traversing the public internet. Broader than an S3
> or DynamoDB gateway endpoint and always region-scoped to Oracle Services.

### DHCP options

| Feature                    | AWS                                                              | OCI                                                                          | Status            |
| -------------------------- | ---------------------------------------------------------------- | ---------------------------------------------------------------------------- | ----------------- |
| Create custom DHCP options | `enable_dhcp_options`                                            | `enable_dhcp_options`                                                        | mapped            |
| Search domain              | `dhcp_options_domain_name`                                       | `dhcp_options_domain_name`                                                   | mapped            |
| DNS server type            | `dhcp_options_domain_name_servers` (magic `"AmazonProvidedDNS"`) | `dhcp_options_server_type` (`"VcnLocalPlusInternet"` \| `"CustomDnsServer"`) | mapped (see note) |
| Custom DNS server IPs      | part of the list above                                           | `dhcp_options_domain_name_servers`                                           | mapped            |
| DHCP options tags          | `dhcp_options_tags`                                              | `dhcp_options_tags`                                                          | mapped            |
| NTP servers                | `dhcp_options_ntp_servers`                                       | none (OCI uses platform NTP, configured at the OS level)                     | n/a               |
| NetBIOS options            | `dhcp_options_netbios_*`                                         | none                                                                         | n/a               |

> **DNS server type**: AWS uses a flat list where `"AmazonProvidedDNS"` is a magic
> string for the VPC resolver. OCI splits the concept into an enum plus a list.

### Security lists and default resources

| Feature                              | AWS                                        | OCI                                                                | Status            |
| ------------------------------------ | ------------------------------------------ | ------------------------------------------------------------------ | ----------------- |
| Dedicated ACL/security list per tier | `<tier>_dedicated_network_acl`             | `<tier>_dedicated_security_list`                                   | mapped            |
| Per-tier rules                       | `<tier>_inbound_acl_rules` / `_outbound_*` | `<tier>_inbound_security_rules` / `<tier>_outbound_security_rules` | mapped            |
| Per-tier ACL/seclist tags            | `<tier>_acl_tags`                          | `<tier>_acl_tags`                                                  | mapped            |
| Default SG / seclist lockdown        | `manage_default_security_group`            | `lockdown_default_security_list`                                   | mapped (inverted) |
| Manage default VPC/VCN               | `manage_default_vpc`                       | none                                                               | n/a               |
| Default network ACL                  | `manage_default_network_acl`               | none (OCI has no NACL resource separate from seclists)             | n/a               |
| Default route table                  | `manage_default_route_table`               | none (handled by subnet-to-route-table association)                | n/a               |

> **Default security list lockdown**: `lockdown_default_security_list = true` (the
> default) strips every rule from the VCN's default security list, giving a deny-all
> posture. The AWS module instead lets you set arbitrary rules on the default security
> group. The rules carry `ignore_changes`, so out-of-band writes to this list (for
> example by OKE's cloud-controller-manager when a `Service` of `type: LoadBalancer`
> is created) do not appear as drift.

### Flow logs

| Feature                      | AWS                                                               | OCI                                     | Status   |
| ---------------------------- | ----------------------------------------------------------------- | --------------------------------------- | -------- |
| Enable flow logs             | `enable_flow_log`                                                 | `enable_flow_log`                       | mapped   |
| Destination                  | CloudWatch / S3 / Kinesis, configurable                           | OCI Logging Service, fixed              | mapped   |
| Log retention                | `flow_log_cloudwatch_log_group_retention_in_days`                 | `flow_log_retention_duration`           | mapped   |
| Flow log tags                | `vpc_flow_log_tags`                                               | `flow_log_tags`                         | mapped   |
| Standalone submodule         | `modules/flow-log`                                                | `modules/flow-log`                      | mapped   |
| Per-subnet log groups        | none                                                              | `oci_logging_log_group` per subnet tier | OCI-only |
| IAM role for delivery        | `create_flow_log_cloudwatch_iam_role`                             | none                                    | n/a      |
| Custom log format            | `flow_log_log_format`                                             | none (OCI's format is fixed)            | n/a      |
| Traffic type filter          | `flow_log_traffic_type`                                           | none (OCI logs all traffic)             | n/a      |
| Aggregation interval         | `flow_log_max_aggregation_interval`                               | none                                    | n/a      |
| S3 / Kinesis / cross-account | `flow_log_destination_arn`, `flow_log_deliver_cross_account_role` | none                                    | n/a      |

### Submodules and wrappers

| Component                 | AWS         | OCI         | Status  |
| ------------------------- | ----------- | ----------- | ------- |
| Root module wrapper       | `wrappers/` | `wrappers/` | mapped  |
| `modules/flow-log`        | yes         | yes         | mapped  |
| `wrappers/flow-log/`      | yes         | yes         | mapped  |
| `modules/vpc-endpoints`   | yes         | none        | backlog |
| `wrappers/vpc-endpoints/` | yes         | none        | backlog |

## Variable mapping

Equivalent concept, different name. Anything not listed maps by an identical name.

| AWS                                     | OCI                                                             | Notes                                                      |
| --------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------- |
| `create_vpc`                            | `create_vcn`                                                    | master toggle                                              |
| `cidr`                                  | `vcn_cidr_block`                                                | primary CIDR block                                         |
| `azs`                                   | `availability_domains`                                          | AWS takes AZ name strings, OCI takes integers 1/2/3        |
| `tags`                                  | `tags` (freeform) + `defined_tags`                              | OCI has two tag systems                                    |
| `<tier>_subnet_tags_per_az`             | `<tier>_subnet_tags_per_ad`                                     |                                                            |
| `<tier>_subnet_ipv6_prefixes`           | none, derived from `enable_ipv6`                                | OCI auto-computes `/64`s from the VCN `/56`                |
| `one_nat_gateway_per_az`                | `one_nat_gateway_per_ad`                                        |                                                            |
| `reuse_nat_ips` + `external_nat_ip_ids` | `nat_gateway_public_ip_id`                                      | single value, not a list: `null`, `"RESERVED"`, or an OCID |
| `manage_default_security_group`         | `lockdown_default_security_list`                                | inverted semantics: AWS manages rules, OCI denies all      |
| `<tier>_dedicated_network_acl`          | `<tier>_dedicated_security_list`                                |                                                            |
| `<tier>_inbound_acl_rules`              | `<tier>_inbound_security_rules`                                 |                                                            |
| `<tier>_outbound_acl_rules`             | `<tier>_outbound_security_rules`                                |                                                            |
| `dhcp_options_domain_name_servers`      | `dhcp_options_server_type` + `dhcp_options_domain_name_servers` | different model, see DHCP options above                    |
| `vpc_flow_log_tags`                     | `flow_log_tags`                                                 |                                                            |

OCI-only variables, no AWS counterpart:

| OCI variable                                     | What it does                                                  |
| ------------------------------------------------ | ------------------------------------------------------------- |
| `compartment_id`                                 | required OCI compartment scoping, no AWS concept              |
| `vcn_dns_label`                                  | VCN DNS label (regex-validated)                               |
| `defined_tags`, `<tier>_subnet_defined_tags`     | OCI's tag namespace system                                    |
| `availability_domains`                           | AD numbers for AD-pinned subnet placement                     |
| `create_service_gateway`, `service_gateway_tags` | private Oracle Services access without the public internet    |
| `lockdown_default_security_list`                 | deny-all posture on the default security list                 |
| `attached_drg_id`                                | attach an existing Dynamic Routing Gateway                    |
| `local_peering_gateways`                         | Local Peering Gateway map for hub-and-spoke peering           |
| `internet_gateway_route_rules`                   | custom symbolic route rules on the IG route table             |
| `nat_gateway_route_rules`                        | custom symbolic route rules on the NAT route table            |
| `nat_gateway_public_ip_id`                       | ephemeral, newly-reserved, or existing reserved NAT public IP |
| `flow_log_retention_duration`                    | OCI log retention in days                                     |
| `dhcp_options_server_type`                       | `VcnLocalPlusInternet` or `CustomDnsServer`                   |

## Output mapping

| AWS                               | OCI                                                 | Notes                             |
| --------------------------------- | --------------------------------------------------- | --------------------------------- |
| `vpc_id`                          | `vcn_id`                                            |                                   |
| `vpc_cidr_block`                  | `vcn_cidr_block`                                    |                                   |
| `vpc_secondary_cidr_blocks`       | `vcn_cidr_blocks`                                   | all CIDRs, primary plus secondary |
| `vpc_ipv6_cidr_block`             | `vcn_ipv6_cidr_blocks`                              |                                   |
| `default_route_table_id`          | `default_route_table_id`                            |                                   |
| `default_security_group_id`       | `default_security_list_id`                          |                                   |
| `dhcp_options_id`                 | `dhcp_options_id`                                   |                                   |
| `igw_id`                          | `internet_gateway_id`                               |                                   |
| `nat_ids`, `nat_public_ips`       | `nat_ids`, `nat_public_ips`                         |                                   |
| `<tier>_subnets`                  | `<tier>_subnets`                                    | subnet IDs, all four tiers        |
| `<tier>_subnet_objects`           | `<tier>_subnet_objects`                             |                                   |
| `<tier>_subnets_cidr_blocks`      | `<tier>_subnets_cidr_blocks`                        |                                   |
| `<tier>_subnets_ipv6_cidr_blocks` | `<tier>_subnets_ipv6_cidr_blocks`                   |                                   |
| `<tier>_route_table_ids`          | `<tier>_route_table_id(s)`                          | singular for public/intra         |
| `<tier>_network_acl_id`           | `<tier>_security_list_id`                           |                                   |
| `azs`                             | `availability_domains`, `availability_domain_names` |                                   |
| `name`                            | `name`                                              |                                   |
| `vpc_flow_log_id`                 | `flow_log_ids`                                      |                                   |

OCI-only outputs: `vcn_dns_label`, `default_dhcp_options_id`, `vcn_all_attributes`,
`internet_gateway_all_attributes`, `public_route_table_all_attributes`,
`private_route_table_all_attributes`, `nat_reserved_public_ip_id`,
`nat_gateway_all_attributes`, `service_gateway_id`, `service_gateway_all_attributes`,
`local_peering_gateway_ids`, `local_peering_gateway_all_attributes`,
`flow_log_group_ids`, `availability_domain_names`.

AWS-only outputs with no OCI counterpart: every `*_arn` (OCI uses OCIDs),
`vpc_owner_id`, `vpc_instance_tenancy`, `vpc_enable_dns_support`,
`vpc_main_route_table_id`, `vpc_block_public_access_exclusions`,
`<tier>_route_table_association_ids` (OCI associates on the subnet resource),
`natgw_ids` / `natgw_interface_ids` (redundant with `nat_ids`),
`egress_only_internet_gateway_id`, the customer/VPN gateway outputs, the eleven
`default_vpc_*` outputs, the Redshift / ElastiCache / Outpost outputs, and
`database_subnet_group*`.

## Not applicable to OCI

AWS-platform constructs with no OCI counterpart. The corresponding variables are
absent rather than stubbed.

| AWS feature                                                                                                                           | Why it does not port                                                                                                                       |
| ------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `enable_dns_support`                                                                                                                  | DNS resolution is always on in a VCN, there is nothing to toggle.                                                                          |
| `instance_tenancy`                                                                                                                    | Dedicated hardware is an instance-level choice in OCI (dedicated VM hosts), not a network attribute.                                       |
| `use_ipam_pool`, `ipv4_ipam_pool_id`, `ipv6_ipam_pool_id`                                                                             | OCI has no IPAM service that allocates VCN CIDRs.                                                                                          |
| `enable_network_address_usage_metrics`                                                                                                | No OCI equivalent metric.                                                                                                                  |
| `vpc_block_public_access_options` and `*_exclusions`                                                                                  | No account-wide public-access kill switch in OCI.                                                                                          |
| `create_egress_only_igw`                                                                                                              | One OCI internet gateway handles IPv4 and IPv6 egress; there is no egress-only variant.                                                    |
| `<tier>_subnet_ipv6_native`                                                                                                           | OCI requires an IPv4 CIDR on every subnet, so an IPv6-only subnet cannot exist.                                                            |
| `<tier>_subnet_enable_dns64`, `<tier>_subnet_enable_resource_name_dns_*_record_on_launch`                                             | No OCI equivalents.                                                                                                                        |
| `<tier>_subnet_private_dns_hostname_type_on_launch`                                                                                   | OCI sets hostnames per VNIC through `hostname_label`, not as a subnet-level policy.                                                        |
| Redshift / ElastiCache subnet tiers, route tables and subnet groups                                                                   | Those AWS services need dedicated subnet groups. OCI's DBaaS and PaaS services consume subnets directly, so the `database` tier covers it. |
| `create_database_subnet_group`, `create_redshift_subnet_group`, `create_elasticache_subnet_group`                                     | Same reason: OCI has no subnet-group resource.                                                                                             |
| Outpost subnets                                                                                                                       | AWS Outposts has no OCI equivalent. OCI Dedicated Region and Compute Cloud@Customer are whole-region constructs, not subnet flags.         |
| `manage_default_vpc`, `manage_default_route_table`, `manage_default_network_acl`                                                      | OCI has no tenancy-level default VCN, and no NACL resource distinct from security lists.                                                   |
| `propagate_*_route_tables_vgw`                                                                                                        | OCI DRG routing uses DRG route tables and distributions, a different model with no per-subnet propagation flag.                            |
| `dhcp_options_ntp_servers`, `dhcp_options_netbios_*`                                                                                  | OCI supplies platform NTP (configured at the OS level) and has no NetBIOS options.                                                         |
| `flow_log_traffic_type`, `flow_log_log_format`, `flow_log_max_aggregation_interval`                                                   | OCI's VCN flow log format and capture behaviour are fixed.                                                                                 |
| `flow_log_destination_type`, `flow_log_destination_arn`, `flow_log_deliver_cross_account_role`, `create_flow_log_cloudwatch_iam_role` | OCI flow logs deliver to the OCI Logging Service only.                                                                                     |
| Every `*_arn` output                                                                                                                  | OCI identifies resources by OCID; there is no ARN.                                                                                         |
| `vpc_owner_id`                                                                                                                        | No AWS-account-owner concept; compartments serve a different purpose.                                                                      |
| `<tier>_route_table_association_ids`                                                                                                  | OCI associates a route table on the subnet resource itself, so there is no association object to expose.                                   |

## Out of scope

OCI supports these; this module does not, to stay a network-only building block.

- **No IAM creation.** The module creates no `oci_identity_policy` or
  `oci_identity_dynamic_group`, matching the sibling `terraform-oci-oke` and
  `terraform-oci-compute-instance` convention. It stays compartment-scoped and
  needs no home-region provider.
- **No compute, no load balancers, no NSGs for workloads.** Security *lists* are
  in scope because they are a subnet attribute. Network security groups belong to
  the workload that uses them, so they are created by the consuming module
  (`terraform-oci-oke`'s `create_worker_nsg`, `terraform-oci-compute-instance`'s
  `create_nsg`) or passed in by the caller.
- **No cross-region peering resources in the root module.** Remote Peering
  Connections need a second provider alias, so they live in `examples/drg-peering`
  as a demonstrated pattern rather than root-module variables.
- **No DRG creation.** `attached_drg_id` attaches an existing one. Creating a DRG
  is a tenancy-topology decision that usually outlives any single VCN.

## Not yet implemented

| Gap                            | Detail                                                                                                                                                 | AWS analog                                        |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------- |
| Private Endpoint submodule     | Private connectivity to third-party and non-Oracle PaaS services. The Service Gateway already covers Oracle-managed services, leaving only this slice. | `modules/vpc-endpoints`, `wrappers/vpc-endpoints` |
| IPSec VPN connectivity via DRG | Requires DRG, CPE and IPSec connection resources with their own variables and outputs.                                                                 | `customer_gateways`, `enable_vpn_gateway`         |

## Examples

| Example                 | What it covers                                                                                         | AWS counterpart                           |
| ----------------------- | ------------------------------------------------------------------------------------------------------ | ----------------------------------------- |
| `simple`                | Minimal VCN: public, private and database subnets, NAT and SGW, IGW                                    | `simple`                                  |
| `complete`              | All features: four tiers, dedicated security lists, multiple CIDRs, flow logs, DHCP options, DRG, LPGs | `complete`                                |
| `flow-log`              | Standalone `modules/flow-log`, both VCN-level and per-subnet logging                                   | `flow-log`                                |
| `ipv6-dualstack`        | Dual-stack VCN                                                                                         | `ipv6-dualstack`                          |
| `network-acls`          | Per-tier dedicated security lists with custom ingress/egress rules                                     | `network-acls`                            |
| `secondary-cidr-blocks` | Multiple CIDR blocks on one VCN, subnets spread across them                                            | `secondary-cidr-blocks`                   |
| `separate-route-tables` | Database subnet with its own route table (NAT plus SGW)                                                | `separate-route-tables`                   |
| `issues`                | Regression-test scaffold, one module block per fixed bug                                               | `issues`                                  |
| `dhcp-options`          | Custom search domain and custom DNS servers                                                            | none (AWS covers it inline in `complete`) |
| `local-peering`         | Hub-and-spoke LPG topology via the acceptor/requestor pattern                                          | none                                      |
| `service-gateway`       | Fully-private VCN (no IGW, no NAT), Oracle Services routing via SGW only                               | none                                      |
| `drg-peering`           | Cross-region DRG plus Remote Peering Connection, multi-provider aliases                                | none                                      |

AWS examples with no OCI counterpart: `ipam`, `ipv6-only`, `outpost`,
`manage-default-vpc`, `block-public-access`, and the VPN/Customer Gateway half of
AWS's `complete`.
