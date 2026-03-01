# Feature Parity: terraform-aws-vpc ↔ terraform-oci-vcn

Last updated: 2026-02-22 (drg-peering example added; Phase 8 OCI-specific examples complete except dhcp-options)

This document tracks feature parity between the AWS reference module
(`terraform-aws-vpc`) and the new OCI module (`terraform-oci-vcn`).
For every feature that is common to both clouds the status column shows
whether OCI has it. Features that are cloud-specific are listed
separately with a rationale for including or excluding them.

Legend:
- ✅ implemented
- ❌ not implemented (gap)
- N/A not applicable to this cloud
- OCI-only  no AWS equivalent

---

## 1. Core Network Resource

| Feature | AWS variable / resource | OCI variable / resource | Status |
|---|---|---|---|
| Create toggle | `create_vpc` | `create_vcn` | ✅ |
| Primary CIDR | `cidr` | `cidr` | ✅ |
| Secondary CIDRs | `secondary_cidr_blocks` (list) | `secondary_cidrs` (list) | ✅ |
| DNS hostnames | `enable_dns_hostnames` | `enable_dns_hostnames` / `vcn_dns_label` | ✅ |
| DNS support | `enable_dns_support` | always on in OCI | N/A |
| DNS label validation | — | `vcn_dns_label` with regex validation | OCI-only |
| Instance tenancy | `instance_tenancy` (default/dedicated) | not a VCN concept | N/A |
| IPv6 CIDR (AWS-assigned) | `enable_ipv6` | `enable_ipv6` → `is_ipv6enabled` on VCN | ✅ |
| IPv6 via IPAM | `ipv6_ipam_pool_id` | — | N/A |
| IPAM IPv4 pool | `use_ipam_pool`, `ipv4_ipam_pool_id` | — | N/A |
| Network address usage metrics | `enable_network_address_usage_metrics` | — | N/A |
| Block public access options | `vpc_block_public_access_options` | — | N/A |
| Block public access exclusions | `vpc_block_public_access_exclusions` map | — | N/A |
| Resource name | `name` | `name` | ✅ |
| Freeform tags on VCN | `tags` | `freeform_tags` / `vcn_tags` | ✅ |
| Defined tags on VCN | — | `defined_tags` | OCI-only |

---

## 2. Subnet Tiers

| Tier | AWS | OCI | Status |
|---|---|---|---|
| Public | ✅ | ✅ | ✅ |
| Private | ✅ | ✅ | ✅ |
| Database | ✅ | ✅ | ✅ |
| Intra (isolated) | ✅ | ✅ | ✅ |
| Redshift | ✅ | — | N/A (see note 1) |
| ElastiCache | ✅ | — | N/A (see note 1) |
| Outpost | ✅ | — | N/A |

> **Note 1 — Redshift / ElastiCache tiers**: AWS added these as convenience
> layers because Redshift and ElastiCache require dedicated subnet groups.
> OCI has no equivalent managed services that need subnet groups; the
> `database` tier covers all PaaS/DBaaS use cases on OCI.

### Per-tier interface (all four OCI tiers)

| Sub-feature | AWS | OCI | Status |
|---|---|---|---|
| CIDR list | `<tier>_subnets` | `<tier>_subnets` | ✅ |
| Custom names list | `<tier>_subnet_names` | `<tier>_subnet_names` | ✅ |
| Name suffix | `<tier>_subnet_suffix` | `<tier>_subnet_suffix` | ✅ |
| Freeform tags per tier | `<tier>_subnet_tags` | `<tier>_subnet_tags` | ✅ |
| Defined tags per tier | — | `<tier>_subnet_defined_tags` | ✅ (all 4 tiers; merged with global `defined_tags`) |
| Per-AZ/AD tags | `<tier>_subnet_tags_per_az` | `<tier>_subnet_tags_per_ad` | ✅ (all 4 tiers; key = AD name string) |
| IPv6 prefixes | `<tier>_subnet_ipv6_prefixes` | `<tier>_subnet_ipv6_cidrs` (explicit CIDRs; see note 2b) | ✅ |
| IPv6-native mode | `<tier>_subnet_ipv6_native` | — | N/A (OCI requires cidr_block on every subnet) |
| DNS64 | `<tier>_subnet_enable_dns64` | — | N/A |
| Private DNS hostname type | `<tier>_subnet_private_dns_hostname_type_on_launch` | — | N/A |
| Resource-name DNS A record | `<tier>_subnet_enable_resource_name_dns_a_record_on_launch` | — | N/A |
| Resource-name DNS AAAA record | `<tier>_subnet_enable_resource_name_dns_aaaa_record_on_launch` | — | N/A |

> **Note 2 — Per-AD tags**: OCI supports this but it is low priority; the
> AWS module's per-AZ tags are mainly used for EKS node tagging which has
> no direct OCI equivalent.
>
> **Note 2b — IPv6 subnet CIDRs**: AWS takes integer prefix offsets (`{tier}_subnet_ipv6_prefixes = [0, 1, 2]`)
> and computes `/64` blocks via `cidrsubnet`. OCI assigns the VCN's `/56` block at apply time (not plan time),
> so the module cannot compute subnet CIDRs automatically. Users must pass explicit `/64` CIDR strings
> after a first apply reveals the VCN's `/56`. See `examples/ipv6-dualstack/` for the two-step workflow.

---

## 3. Availability Domain / Zone Placement

| Feature | AWS | OCI | Status |
|---|---|---|---|
| AZ / AD list input | `azs` (list of AZ names) | `ads` (list of AD numbers, e.g. [1,2,3]) | ✅ |
| Regional subnets (default) | implied when `azs = []` | `ads = []` → `availability_domain = null` | ✅ |
| AD-specific subnet placement | — | resolved from `oci_identity_availability_domains` | OCI-only |
| AD names output | — | `ad_names`, `ads` outputs | OCI-only |

---

## 4. Route Tables

| Feature | AWS variable | OCI variable | Status |
|---|---|---|---|
| Public route table | auto-created | `oci_core_route_table.ig` | ✅ |
| Private route table(s) | auto-created | `oci_core_route_table.nat` | ✅ |
| Database route table | `create_database_subnet_route_table` | `create_database_subnet_route_table` | ✅ |
| Database → IGW route | `create_database_internet_gateway_route` | `create_database_internet_gateway_route` | ✅ |
| Database → NAT route | `create_database_nat_gateway_route` | auto-included when DB RT created | ✅ (see note 3) |
| Intra (isolated) route table | auto-created | `oci_core_route_table.intra` | ✅ |
| Redshift route table | `create_redshift_subnet_route_table` | — | N/A |
| ElastiCache route table | `create_elasticache_subnet_route_table` | — | N/A |
| Multiple public route tables | `create_multiple_public_route_tables` | `create_multiple_public_route_tables` | ✅ |
| Multiple intra route tables | `create_multiple_intra_route_tables` | `create_multiple_intra_route_tables` | ✅ |
| Route table tags | per-tier `*_route_table_tags` | per-tier `*_route_table_tags` | ✅ |
| Custom route rules (symbolic) | — | `internet_gateway_route_rules`, `nat_gateway_route_rules` | OCI-only |

> **Note 3 — Database → IGW**: OCI databases (Autonomous DB, DBaaS) use
> private endpoints and should not be publicly routed. This feature can be
> added if there is a use case, but is intentionally omitted for now.
>
> **Note 3b — Database → NAT**: The OCI module always includes NAT (and SGW
> when `create_service_gateway = true`) in the DB route table when
> `create_database_subnet_route_table = true`. AWS makes this an opt-in
> flag; OCI treats it as the only sensible default since DB subnets need
> egress for patching.

---

## 5. Internet Gateway

| Feature | AWS variable | OCI variable | Status |
|---|---|---|---|
| Create IGW | `create_igw` (default true) | `create_internet_gateway` (default true) | ✅ |
| Egress-only IGW (IPv6) | `create_egress_only_igw` | — | N/A (OCI's single IGW handles IPv4 and IPv6 egress) |
| IGW tags | `igw_tags` | `internet_gateway_tags` | ✅ |

---

## 6. NAT Gateway

| Feature | AWS variable | OCI variable | Status |
|---|---|---|---|
| Enable NAT GW | `enable_nat_gateway` | `enable_nat_gateway` | ✅ |
| Single NAT GW | `single_nat_gateway` | `single_nat_gateway` | ✅ |
| One NAT per AZ/AD | `one_nat_gateway_per_az` | `one_nat_gateway_per_ad` | ✅ |
| Reuse existing EIPs | `reuse_nat_ips`, `external_nat_ip_ids` | — | N/A (OCI NAT GW manages its own public IP) |
| Custom destination CIDR | `nat_gateway_destination_cidr_block` | `nat_gateway_destination_cidr_block` | ✅ |
| NAT GW tags | `nat_gateway_tags` | `nat_gateway_tags` | ✅ |

---

## 7. Service Gateway (OCI-only)

| Feature | OCI variable | Status |
|---|---|---|
| Create SGW | `create_service_gateway` | OCI-only ✅ |
| SGW tags | `service_gateway_tags` | OCI-only ✅ |
| SGW route in database RT | automatic when `create_database_subnet_route_table = true` | OCI-only ✅ |

---

## 8. Local Peering / DRG (OCI-only)

| Feature | OCI variable | Status |
|---|---|---|
| Attach existing DRG | `attached_drg_id` | OCI-only ✅ |
| Create LPGs | `local_peering_gateways` map | OCI-only ✅ |

AWS equivalent is VPN/Direct Connect/Transit Gateway — out of scope for v1.

---

## 9. DHCP Options

| Feature | AWS variable | OCI variable | Status |
|---|---|---|---|
| Create custom DHCP options set | `enable_dhcp_options` (bool, default `false`) | `create_dhcp_options` (bool, default `false`) | ✅ |
| Search domain | `dhcp_options_domain_name` (string) | `dhcp_options_search_domain` (string) | ✅ |
| DNS server type | `dhcp_options_domain_name_servers` (list, default `["AmazonProvidedDNS"]`) | `dhcp_options_server_type` (`"VcnLocalPlusInternet"` \| `"CustomDnsServer"`, default `"VcnLocalPlusInternet"`) | ✅ (see note 4a) |
| Custom DNS server IPs | part of `dhcp_options_domain_name_servers` | `dhcp_options_custom_dns_servers` (list, required when `server_type = "CustomDnsServer"`) | ✅ |
| NTP servers | `dhcp_options_ntp_servers` (list) | — | N/A (see note 4b) |
| NetBIOS name servers | `dhcp_options_netbios_name_servers` (list) | — | N/A (see note 4c) |
| NetBIOS node type | `dhcp_options_netbios_node_type` (string) | — | N/A (see note 4c) |
| IPv6 lease time | `dhcp_options_ipv6_address_preferred_lease_time` (number) | — | N/A (OCI VCN has no IPv6) |
| DHCP options tags | `dhcp_options_tags` (map) | `dhcp_options_tags` (map) | ✅ |
| Association to VCN/subnets | `aws_vpc_dhcp_options_association` (one per VPC) | `dhcp_options_id` set on each `oci_core_subnet` | ✅ (see note 4d) |

> **Note 4a — DNS server type**: AWS takes a flat list where `"AmazonProvidedDNS"` is a magic string
> meaning "use the VPC resolver". OCI separates the concept into a `server_type` enum:
> `"VcnLocalPlusInternet"` (OCI resolver + internet DNS, equivalent to AmazonProvidedDNS),
> or `"CustomDnsServer"` (bring your own IPs via `dhcp_options_custom_dns_servers`).
>
> **Note 4b — NTP servers**: OCI DHCP options have no NTP field. OCI instances use
> platform-provided NTP (`169.254.169.254`) by default; custom NTP is configured at the
> OS level (e.g. `chrony.conf`), not via DHCP.
>
> **Note 4c — NetBIOS**: NetBIOS is a Windows-only legacy protocol. OCI has no equivalent
> and there is no planned support.
>
> **Note 4d — Association model**: AWS uses a separate `aws_vpc_dhcp_options_association`
> resource to attach the options set to the VPC (one association covers all subnets). OCI
> sets `dhcp_options_id` directly on each `oci_core_subnet` resource. When
> `create_dhcp_options = true` the OCI module passes the custom options ID to every subnet;
> when `false` each subnet inherits the VCN default DHCP options automatically.

---

## 10. Customer / VPN Gateway

| Feature | AWS | OCI equivalent | Status |
|---|---|---|---|
| Customer Gateway map | `customer_gateways` | — | N/A (see note 5) |
| VPN Gateway | `enable_vpn_gateway`, `vpn_gateway_id` | IPSec VPN via DRG | N/A |
| VPN route propagation | `propagate_*_route_tables_vgw` | — | N/A |

> **Note 5**: OCI IPSec VPN is configured via DRG and CPE resources, which
> are outside the VCN module scope for v1.

---

## 11. Default Resource Management

| Feature | AWS variable | OCI variable | Status |
|---|---|---|---|
| Manage default VPC/VCN | `manage_default_vpc` | — | N/A (OCI has no tenancy-level default VCN resource) |
| Default security group / security list | `manage_default_security_group` | `lockdown_default_seclist` | partial ✅ (see note 6) |
| Default network ACL | `manage_default_network_acl` | — | N/A (OCI uses security lists, not NACLs as a separate resource) |
| Default route table | `manage_default_route_table` | — | N/A (handled via subnet-to-RT association) |

> **Note 6**: OCI's `lockdown_default_seclist` removes all default rules from
> the VCN's default security list (deny-all posture). The AWS module allows
> setting arbitrary ingress/egress rules on the default SG; OCI's resource
> model makes full rule management straightforward to add.

---

## 12. Network ACLs / Security Lists

| Feature | AWS | OCI | Status |
|---|---|---|---|
| Dedicated Network ACL per tier | `<tier>_dedicated_network_acl` + rule lists | `<tier>_dedicated_security_list` + rule lists | ✅ |
| Default seclist lockdown | — | `lockdown_default_seclist` | OCI-only ✅ |

> **Note 7 — Dedicated security lists per tier**: AWS NACLs are stateless
> and subnet-level; OCI security lists are equivalent. Adding per-tier
> security lists with custom ingress/egress rules is a medium-priority gap.

---

## 13. Subnet Groups (AWS-only)

| Feature | AWS | OCI | Status |
|---|---|---|---|
| DB subnet group | `create_database_subnet_group` | — | N/A (OCI DBaaS uses subnets directly) |
| Redshift subnet group | `create_redshift_subnet_group` | — | N/A |
| ElastiCache subnet group | `create_elasticache_subnet_group` | — | N/A |

---

## 14. Flow Logs

| Feature | AWS variable | OCI variable | Status |
|---|---|---|---|
| Enable flow logs | `enable_flow_log` | `enable_flow_log` | ✅ |
| Destination type | `flow_log_destination_type` (CloudWatch / S3 / Kinesis) | OCI Logging Service (fixed) | ✅ (OCI-native) |
| Log retention | `flow_log_cloudwatch_log_group_retention_in_days` | `flow_log_retention_duration` (days) | ✅ |
| IAM role for CloudWatch | `create_flow_log_cloudwatch_iam_role`, `flow_log_cloudwatch_iam_role_arn` | — | N/A |
| Custom log format | `flow_log_log_format` | — | N/A (OCI format is fixed) |
| Traffic type filter | `flow_log_traffic_type` | — | N/A (OCI logs all traffic) |
| Aggregation interval | `flow_log_max_aggregation_interval` | — | N/A |
| Per-subnet log groups | — | `oci_logging_log_group` per subnet type | OCI-only ✅ |
| Flow log tags | `vpc_flow_log_tags` | `flow_log_tags` | ✅ |
| Standalone flow-log submodule | `modules/flow-log` | `modules/flow-log` | ✅ |
| Cross-account delivery | `flow_log_deliver_cross_account_role` | — | N/A |
| S3 / Kinesis delivery | `flow_log_destination_arn` | — | N/A |

---

## 15. Submodules

| Submodule | AWS | OCI | Status |
|---|---|---|---|
| flow-log | `modules/flow-log` | `modules/flow-log` | ✅ |
| vpc-endpoints / service-endpoints | `modules/vpc-endpoints` | — | N/A (Oracle Services via SGW in root module; private-endpoint deferred to v2) |

> **Note 8 — Service Endpoints**: OCI routes to Oracle services via the
> Service Gateway (already in the root module). There is no need for a
> separate endpoints submodule for the Oracle service network. However, a
> module for OCI Private Endpoints (for third-party PaaS) could be added in v2.

---

## 16. Wrappers

| Wrapper | AWS | OCI | Status |
|---|---|---|---|
| Root module wrapper | `wrappers/` | `wrappers/` | ✅ |
| flow-log wrapper | `wrappers/flow-log/` | `wrappers/flow-log/` | ✅ |
| vpc-endpoints wrapper | `wrappers/vpc-endpoints/` | — | N/A (no endpoints submodule) |

---

## 17. Examples

| Example | AWS | OCI | Status |
|---|---|---|---|
| simple | ✅ | ✅ | ✅ |
| complete | ✅ | ✅ | ✅ |
| flow-log | ✅ | ✅ | ✅ |
| ipam | ✅ | — | N/A (OCI IPAM is a different product) |
| ipv6-dualstack | ✅ | ✅ | ✅ |
| ipv6-only | ✅ | — | N/A (IPv6-native subnets not supported in OCI) |
| network-acls | ✅ | ✅ | ✅ |
| outpost | ✅ | — | N/A |
| secondary-cidr-blocks | ✅ | ✅ | ✅ |
| separate-route-tables | ✅ | ✅ | ✅ |
| local-peering | — | ✅ | ✅ OCI-specific (hub-and-spoke LPG topology) |
| service-gateway | — | ✅ | ✅ OCI-specific (private VCN, Oracle Services only via SGW) |
| drg-peering | — | ✅ | ✅ OCI-specific (cross-region DRG + RPC topology: us-ashburn-1 ↔ us-chicago-1) |
| manage-default-vcn | ✅ | — | N/A (no OCI default VCN concept) |
| block-public-access | ✅ | — | N/A |
| issues (regression tests) | ✅ | — | deferred (add as coverage grows) |

---

## 18. CI/CD & Tooling

| File / workflow | AWS | OCI | Status |
|---|---|---|---|
| `.pre-commit-config.yaml` | ✅ | ✅ | ✅ |
| `.github/workflows/pre-commit.yml` | ✅ | ✅ | ✅ |
| `.github/workflows/pr-title.yml` | ✅ | ✅ | ✅ |
| `.github/workflows/release.yml` | ✅ | ✅ | ✅ |
| `.github/workflows/lock.yml` | ✅ | ✅ | ✅ |
| `.github/workflows/stale-actions.yaml` | ✅ | ✅ | ✅ |
| `README.md` (root) | ✅ | ✅ | ✅ |
| `README.md` (submodules / examples) | ✅ | ✅ | ✅ |
| `schema.yaml` | — (AWS module has none) | — | N/A |

---

## 19. Variables Present in AWS but Missing in OCI (gap summary)

These are the AWS variables that have no OCI equivalent yet and are
**actionable** (either implementable or explicitly deferred).

| Priority | AWS variable(s) | Gap description |
|---|---|---|
| Implemented | `nat_gateway_destination_cidr_block` | Custom NAT GW route destination CIDR — `nat_gateway_destination_cidr_block` (default `"0.0.0.0/0"`) |
| Implemented | `create_multiple_public_route_tables`, `create_multiple_intra_route_tables` | One public/intra RT per subnet — `create_multiple_public_route_tables`, `create_multiple_intra_route_tables` |
| Implemented | `dhcp_options_*` | Custom DHCP options — `enable_dhcp_options` → `create_dhcp_options`; `dhcp_options_domain_name` → `dhcp_options_search_domain`; `dhcp_options_domain_name_servers` → `dhcp_options_server_type` + `dhcp_options_custom_dns_servers`; NTP/NetBIOS/IPv6 lease time are N/A in OCI |
| Implemented | `<tier>_subnet_tags_per_az` (4 vars) | Per-AD subnet tags — `<tier>_subnet_tags_per_ad` |
| N/A | `manage_default_vpc` / default VCN management | OCI has no tenancy-level default VCN resource |
| Implemented | `<tier>_subnet_defined_tags` (per-tier defined tags) | OCI defined tags per subnet tier — `<tier>_subnet_defined_tags` (merged with global `defined_tags`) |
| Implemented | `enable_ipv6`, `<tier>_subnet_ipv6_prefixes` | IPv6 VCN support — `enable_ipv6` on VCN; `<tier>_subnet_ipv6_cidrs` (explicit /64 strings, two-step workflow) |

---

## 20. OCI-Only Variables (no AWS equivalent)

These exist in the OCI module and have no AWS counterpart. They are correct
and intentional.

| OCI variable | Description |
|---|---|
| `compartment_id` | OCI compartment (required — no AWS concept) |
| `tenancy_id` | Used to resolve availability domain names |
| `defined_tags` | OCI's second tag type (key/value in a namespace) |
| `ads` | List of AD numbers — OCI's equivalent of `azs` |
| `vcn_dns_label` | OCI-specific VCN DNS label (validated) |
| `secondary_cidrs` | OCI supports multiple VCN CIDRs natively |
| `create_service_gateway` | Routes to Oracle services without public internet |
| `service_gateway_tags` | Tags for the SGW |
| `lockdown_default_seclist` | Removes all rules from default security list |
| `attached_drg_id` | Attach an existing Dynamic Routing Gateway |
| `local_peering_gateways` | Create Local Peering Gateways map |
| `internet_gateway_route_rules` | Symbolic custom route rules on IG RT |
| `nat_gateway_route_rules` | Symbolic custom route rules on NAT RT |
| `flow_log_retention_duration` | OCI log retention in days |

---

## 21. Prioritised Gap Backlog

### Must-do before v0.1 release

- [x] README.md files for submodules and examples (required for terraform-docs hooks)

### Medium priority (v0.2) — all items complete ✅

- [x] **Per-tier dedicated security lists**: add `<tier>_dedicated_security_list`, `<tier>_inbound_security_rules`, `<tier>_outbound_security_rules` (mirrors `<tier>_dedicated_network_acl` in AWS)
- [x] **`create_database_internet_gateway_route`**: add flag + route rule to DB route table
- [x] **`network-acls` example**: demonstrate per-tier dedicated security lists
- [x] **`secondary-cidr-blocks` example**: demonstrate `secondary_cidrs` with subnets spread across CIDRs
- [x] **`separate-route-tables` example**: demonstrate `create_database_subnet_route_table = true`
- [x] **`flow-log` example**: demonstrate standalone `modules/flow-log` usage (VCN-level and subnet-level)

### Low priority (v0.3)

- [x] **DHCP options**: `create_dhcp_options`, `dhcp_options_search_domain`, `dhcp_options_server_type` (`"VcnLocalPlusInternet"` | `"CustomDnsServer"`), `dhcp_options_custom_dns_servers`, `dhcp_options_tags` → `oci_core_dhcp_options`; NTP / NetBIOS / IPv6 lease time have no OCI equivalent (N/A)
- [x] **Per-AD subnet tags** (`<tier>_subnet_tags_per_ad`)
- [x] **Multiple public / intra route tables** (`create_multiple_public_route_tables`, `create_multiple_intra_route_tables`)
- [x] **Custom NAT GW destination CIDR** (`nat_gateway_destination_cidr_block`)
- [x] **Default VCN management** (`manage_default_vcn`) — N/A: OCI has no tenancy-level default VCN resource
- [x] **Per-tier defined tags** (`<tier>_subnet_defined_tags`)
- [x] **`modules/private-endpoint`** — deferred to v2: Oracle Services are handled by SGW in the root module; OCI Private Endpoint (third-party PaaS) has no direct v0.1 scope
- [x] **Issues / regression example** — deferred: add as test coverage grows
- [x] **`manage-default-vcn` example** — N/A: no OCI default VCN concept
- [x] **IPv6 dual-stack** — `enable_ipv6`, `<tier>_subnet_ipv6_cidrs`, `::/0` IGW route, 5 IPv6 outputs, `examples/ipv6-dualstack/`
- [x] **`local-peering` example** — hub-and-spoke LPG topology: hub VCN (public+private, NAT+SGW) peered with spoke VCN (private-only) via acceptor/requestor LPG pattern; symbolic `lpg@<name>` notation in route rules
- [x] **`service-gateway` example** — fully-private VCN (no IGW, no NAT); private + database subnets; dedicated DB route table with SGW → all-Oracle-services route; `service_gateway_tags` demonstrated

### Phase 8 — OCI-specific examples (in progress)

- [x] **`drg-peering` example** — cross-region DRG + RPC topology (us-ashburn-1 requestor ↔ us-chicago-1 acceptor); multi-region provider aliases; symbolic `"drg"` route rules; both RPCs verified `PEERED` via OCI CLI
- [ ] **`service-gateway` example** — dedicated example for `create_service_gateway = true` + Oracle Services routing
- [ ] **`dhcp-options` example** — custom search domain + custom DNS servers
