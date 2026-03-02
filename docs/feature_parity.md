# Feature Parity: OCI VCN vs AWS VPC

Comparison between this module (`terraform-oci-modules/vcn/oci`) and the reference
AWS module (`terraform-aws-modules/vpc/aws`).

The goal is not 1:1 mapping — OCI and AWS have fundamentally different networking
primitives — but to make the interface feel familiar to users coming from the AWS module,
while being idiomatic OCI.

**Legend:**
- ✅ Implemented
- N/A Not applicable to this cloud (architectural difference, not a gap)
- OCI-only No AWS equivalent — intentional addition

---

## 1. Core Network Resource

| Feature                       | AWS                                                | OCI                                      | Status   |
| ----------------------------- | -------------------------------------------------- | ---------------------------------------- | -------- |
| Create toggle                 | `create_vpc`                                       | `create_vcn`                             | ✅        |
| Resource name                 | `name`                                             | `name`                                   | ✅        |
| Primary CIDR                  | `cidr`                                             | `cidr`                                   | ✅        |
| Secondary CIDRs               | `secondary_cidr_blocks` (list)                     | `secondary_cidr_blocks` (list)           | ✅        |
| DNS hostnames                 | `enable_dns_hostnames`                             | `enable_dns_hostnames` + `vcn_dns_label` | ✅        |
| DNS support                   | `enable_dns_support`                               | Always on in OCI                         | N/A      |
| DNS label                     | —                                                  | `vcn_dns_label` (regex-validated)        | OCI-only |
| IPv6                          | `enable_ipv6`                                      | `enable_ipv6` → `is_ipv6enabled` on VCN  | ✅        |
| IPv6 via IPAM                 | `ipv6_ipam_pool_id`                                | —                                        | N/A      |
| IPv4 via IPAM                 | `use_ipam_pool`, `ipv4_ipam_pool_id`               | —                                        | N/A      |
| Instance tenancy              | `instance_tenancy`                                 | Not a VCN concept                        | N/A      |
| Network address usage metrics | `enable_network_address_usage_metrics`             | —                                        | N/A      |
| Block public access           | `vpc_block_public_access_options` / `*_exclusions` | —                                        | N/A      |
| Freeform tags                 | `tags`                                             | `freeform_tags` / `vcn_tags`             | ✅        |
| Defined tags                  | —                                                  | `defined_tags`                           | OCI-only |

---

## 2. Subnet Tiers

| Tier             | AWS | OCI | Status               |
| ---------------- | --- | --- | -------------------- |
| Public           | ✅   | ✅   | ✅                    |
| Private          | ✅   | ✅   | ✅                    |
| Database         | ✅   | ✅   | ✅                    |
| Intra (isolated) | ✅   | ✅   | ✅                    |
| Redshift         | ✅   | —   | N/A (see note below) |
| ElastiCache      | ✅   | —   | N/A (see note below) |
| Outpost          | ✅   | —   | N/A                  |

> **Redshift / ElastiCache tiers**: AWS added these because those services require
> dedicated subnet groups. OCI has no equivalent managed services with that constraint;
> the `database` tier covers all PaaS/DBaaS use cases on OCI.

### Per-tier interface (all four OCI tiers)

| Sub-feature               | AWS                                                         | OCI                                               | Status             |
| ------------------------- | ----------------------------------------------------------- | ------------------------------------------------- | ------------------ |
| CIDR list                 | `<tier>_subnets`                                            | `<tier>_subnets`                                  | ✅                  |
| Custom names list         | `<tier>_subnet_names`                                       | `<tier>_subnet_names`                             | ✅                  |
| Name suffix               | `<tier>_subnet_suffix`                                      | `<tier>_subnet_suffix`                            | ✅                  |
| Freeform tags per tier    | `<tier>_subnet_tags`                                        | `<tier>_subnet_tags`                              | ✅                  |
| Defined tags per tier     | —                                                           | `<tier>_subnet_defined_tags`                      | OCI-only ✅         |
| Per-AZ/AD tags            | `<tier>_subnet_tags_per_az`                                 | `<tier>_subnet_tags_per_ad`                       | ✅                  |
| IPv6 prefixes/CIDRs       | `<tier>_subnet_ipv6_prefixes`                               | `<tier>_subnet_ipv6_cidrs` (explicit /64 strings) | ✅ (see note below) |
| IPv6-native mode          | `<tier>_subnet_ipv6_native`                                 | —                                                 | N/A                |
| DNS64                     | `<tier>_subnet_enable_dns64`                                | —                                                 | N/A                |
| Private DNS hostname type | `<tier>_subnet_private_dns_hostname_type_on_launch`         | —                                                 | N/A                |
| Resource-name DNS records | `<tier>_subnet_enable_resource_name_dns_*_record_on_launch` | —                                                 | N/A                |

> **IPv6 subnet CIDRs**: AWS takes integer prefix offsets and computes `/64` blocks via
> `cidrsubnet` at plan time. OCI assigns the VCN's `/56` block at apply time (not plan time),
> so automatic computation is not possible. Users pass explicit `/64` strings after a first
> apply reveals the VCN's `/56`. See `examples/ipv6-dualstack/` for the two-step workflow.

---

## 3. Availability Domain / Zone Placement

| Feature                          | AWS                     | OCI                                                             | Status   |
| -------------------------------- | ----------------------- | --------------------------------------------------------------- | -------- |
| AZ / AD list input               | `azs` (AZ name strings) | `ads` (AD numbers: 1, 2, 3)                                     | ✅        |
| Regional subnets (no AD pinning) | Implied when `azs = []` | `ads = []` → `availability_domain = null`                       | ✅        |
| AD name resolution               | —                       | Resolved automatically from `oci_identity_availability_domains` | OCI-only |
| AD names / IDs output            | `azs`                   | `ads`, `ad_names`                                               | ✅        |

---

## 4. Route Tables

| Feature                             | AWS                                          | OCI                                                       | Status             |
| ----------------------------------- | -------------------------------------------- | --------------------------------------------------------- | ------------------ |
| Public route table                  | Auto-created                                 | `oci_core_route_table.ig`                                 | ✅                  |
| Multiple public route tables        | `create_multiple_public_route_tables`        | `create_multiple_public_route_tables`                     | ✅                  |
| Private route table(s)              | Auto-created                                 | `oci_core_route_table.nat`                                | ✅                  |
| Database route table                | `create_database_subnet_route_table`         | `create_database_subnet_route_table`                      | ✅                  |
| Database → IGW route                | `create_database_internet_gateway_route`     | `create_database_internet_gateway_route`                  | ✅                  |
| Database → NAT route                | `create_database_nat_gateway_route` (opt-in) | Always included when DB RT created                        | ✅ (see note below) |
| Intra (isolated) route table        | Auto-created                                 | `oci_core_route_table.intra`                              | ✅                  |
| Multiple intra route tables         | `create_multiple_intra_route_tables`         | `create_multiple_intra_route_tables`                      | ✅                  |
| Route table tags (per tier)         | `*_route_table_tags`                         | `*_route_table_tags`                                      | ✅                  |
| Redshift / ElastiCache route tables | ✅                                            | —                                                         | N/A                |
| Custom route rules (symbolic)       | —                                            | `internet_gateway_route_rules`, `nat_gateway_route_rules` | OCI-only           |
| VGW route propagation               | `propagate_*_route_tables_vgw`               | —                                                         | N/A                |

> **Database → NAT**: OCI always includes NAT (and SGW when enabled) in the DB route table when
> `create_database_subnet_route_table = true`. AWS makes this opt-in; OCI treats it as the only
> sensible default since DB subnets require egress for OS patching.

---

## 5. Internet Gateway

| Feature                | AWS                         | OCI                         | Status                                              |
| ---------------------- | --------------------------- | --------------------------- | --------------------------------------------------- |
| Create IGW             | `create_igw` (default true) | `create_igw` (default true) | ✅                                                   |
| Egress-only IGW (IPv6) | `create_egress_only_igw`    | —                           | N/A (OCI's single IGW handles IPv4 and IPv6 egress) |
| IGW tags               | `igw_tags`                  | `igw_tags`                  | ✅                                                   |

---

## 6. NAT Gateway

| Feature                 | AWS                                    | OCI                                  | Status                              |
| ----------------------- | -------------------------------------- | ------------------------------------ | ----------------------------------- |
| Enable NAT GW           | `enable_nat_gateway`                   | `enable_nat_gateway`                 | ✅                                   |
| Single NAT GW           | `single_nat_gateway`                   | `single_nat_gateway`                 | ✅                                   |
| One NAT per AZ/AD       | `one_nat_gateway_per_az`               | `one_nat_gateway_per_ad`             | ✅                                   |
| Custom destination CIDR | `nat_gateway_destination_cidr_block`   | `nat_gateway_destination_cidr_block` | ✅                                   |
| Reuse existing EIPs     | `reuse_nat_ips`, `external_nat_ip_ids` | —                                    | N/A (OCI NAT GW owns its public IP) |
| NAT GW tags             | `nat_gateway_tags`                     | `nat_gateway_tags`                   | ✅                                   |

---

## 7. Service Gateway (OCI-only)

OCI's Service Gateway provides private access to Oracle-managed services (Object Storage,
DBaaS APIs, etc.) without traversing the public internet. The closest AWS analogy is a
VPC Gateway Endpoint for S3/DynamoDB, but the SGW is broader in scope and is always
region-scoped to Oracle Services.

| Feature                     | OCI                                                            | Status     |
| --------------------------- | -------------------------------------------------------------- | ---------- |
| Create SGW                  | `create_service_gateway`                                       | OCI-only ✅ |
| SGW tags                    | `service_gateway_tags`                                         | OCI-only ✅ |
| SGW route in DB route table | Auto-included when `create_database_subnet_route_table = true` | OCI-only ✅ |

---

## 8. Local Peering Gateway / DRG (OCI-only)

OCI's VCN-level peering primitives have no direct AWS equivalent (AWS uses VPC Peering
at the account level, not the VGW/DRG model). VPN and Direct Connect connectivity via
DRG is intentionally out of scope for v1.

| Feature                       | OCI                            | Status     |
| ----------------------------- | ------------------------------ | ---------- |
| Attach existing DRG           | `attached_drg_id`              | OCI-only ✅ |
| Create Local Peering Gateways | `local_peering_gateways` (map) | OCI-only ✅ |

---

## 9. DHCP Options

| Feature                    | AWS                                                                           | OCI                                                                          | Status                                              |
| -------------------------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| Create custom DHCP options | `enable_dhcp_options`                                                         | `enable_dhcp_options`                                                        | ✅                                                   |
| Search domain              | `dhcp_options_domain_name`                                                    | `dhcp_options_domain_name`                                                   | ✅                                                   |
| DNS server type            | `dhcp_options_domain_name_servers` (list, magic string `"AmazonProvidedDNS"`) | `dhcp_options_server_type` (`"VcnLocalPlusInternet"` \| `"CustomDnsServer"`) | ✅ (see note below)                                  |
| Custom DNS server IPs      | Part of the list above                                                        | `dhcp_options_domain_name_servers` (list)                                    | ✅                                                   |
| NTP servers                | `dhcp_options_ntp_servers`                                                    | —                                                                            | N/A (OCI uses platform NTP; configured at OS level) |
| NetBIOS options            | `dhcp_options_netbios_*`                                                      | —                                                                            | N/A                                                 |
| DHCP options tags          | `dhcp_options_tags`                                                           | `dhcp_options_tags`                                                          | ✅                                                   |

> **DNS server type**: AWS uses a flat list where `"AmazonProvidedDNS"` is a magic string for
> the VPC resolver. OCI separates the concept into an enum: `"VcnLocalPlusInternet"` (OCI
> resolver + internet DNS) or `"CustomDnsServer"` (bring your own IPs).

---

## 10. Customer / VPN Gateway

| Feature               | AWS                            | OCI               | Status |
| --------------------- | ------------------------------ | ----------------- | ------ |
| Customer Gateway      | `customer_gateways` map        | —                 | N/A    |
| VPN Gateway           | `enable_vpn_gateway`           | IPSec VPN via DRG | N/A    |
| VPN route propagation | `propagate_*_route_tables_vgw` | —                 | N/A    |

> OCI IPSec VPN is configured via DRG and CPE resources, which are outside the VCN module scope.

---

## 11. Default Resource Management

| Feature                                         | AWS                             | OCI                        | Status                                                          |
| ----------------------------------------------- | ------------------------------- | -------------------------- | --------------------------------------------------------------- |
| Manage default VPC/VCN                          | `manage_default_vpc`            | —                          | N/A (OCI has no tenancy-level default VCN)                      |
| Default security group / security list lockdown | `manage_default_security_group` | `lockdown_default_seclist` | ✅ (see note below)                                              |
| Default network ACL                             | `manage_default_network_acl`    | —                          | N/A (OCI uses security lists, not NACLs as a separate resource) |
| Default route table                             | `manage_default_route_table`    | —                          | N/A (handled via subnet-to-RT association)                      |

> **Default seclist lockdown**: OCI's `lockdown_default_seclist = true` removes all default rules
> from the VCN's default security list (deny-all posture). The AWS module allows setting arbitrary
> rules on the default SG; OCI's equivalent deny-all is a simpler and safer default.

---

## 12. Network ACLs / Security Lists

| Feature                              | AWS                                         | OCI                                           | Status     |
| ------------------------------------ | ------------------------------------------- | --------------------------------------------- | ---------- |
| Dedicated ACL/security list per tier | `<tier>_dedicated_network_acl` + rule lists | `<tier>_dedicated_security_list` + rule lists | ✅          |
| Default seclist lockdown             | —                                           | `lockdown_default_seclist`                    | OCI-only ✅ |

---

## 13. Subnet Groups (AWS-only)

These AWS constructs exist because managed services (Redshift, ElastiCache, RDS) require
explicit subnet group registration. OCI DBaaS and PaaS services use subnets directly.

| Feature                  | AWS                               | OCI | Status |
| ------------------------ | --------------------------------- | --- | ------ |
| DB subnet group          | `create_database_subnet_group`    | —   | N/A    |
| Redshift subnet group    | `create_redshift_subnet_group`    | —   | N/A    |
| ElastiCache subnet group | `create_elasticache_subnet_group` | —   | N/A    |

---

## 14. Flow Logs

| Feature                       | AWS                                               | OCI                                     | Status                     |
| ----------------------------- | ------------------------------------------------- | --------------------------------------- | -------------------------- |
| Enable flow logs              | `enable_flow_log`                                 | `enable_flow_log`                       | ✅                          |
| Destination type              | CloudWatch / S3 / Kinesis (configurable)          | OCI Logging Service (fixed)             | ✅ (OCI-native)             |
| Log retention                 | `flow_log_cloudwatch_log_group_retention_in_days` | `flow_log_retention_duration` (days)    | ✅                          |
| IAM role for CloudWatch       | `create_flow_log_cloudwatch_iam_role`             | —                                       | N/A                        |
| Custom log format             | `flow_log_log_format`                             | —                                       | N/A (OCI format is fixed)  |
| Traffic type filter           | `flow_log_traffic_type`                           | —                                       | N/A (OCI logs all traffic) |
| Aggregation interval          | `flow_log_max_aggregation_interval`               | —                                       | N/A                        |
| S3 / Kinesis delivery         | `flow_log_destination_arn`                        | —                                       | N/A                        |
| Cross-account delivery        | `flow_log_deliver_cross_account_role`             | —                                       | N/A                        |
| Per-subnet log groups         | —                                                 | `oci_logging_log_group` per subnet type | OCI-only ✅                 |
| Flow log tags                 | `vpc_flow_log_tags`                               | `flow_log_tags`                         | ✅                          |
| Standalone flow-log submodule | `modules/flow-log`                                | `modules/flow-log`                      | ✅                          |

---

## 15. Submodules

| Submodule               | AWS | OCI | Status                                                                                                        |
| ----------------------- | --- | --- | ------------------------------------------------------------------------------------------------------------- |
| `modules/flow-log`      | ✅   | ✅   | ✅                                                                                                             |
| `modules/vpc-endpoints` | ✅   | —   | N/A (Oracle Services routed via SGW in root module; OCI Private Endpoint for third-party PaaS deferred to v2) |

---

## 16. Wrappers

| Wrapper                 | AWS                       | OCI                  | Status                       |
| ----------------------- | ------------------------- | -------------------- | ---------------------------- |
| Root module wrapper     | `wrappers/`               | `wrappers/`          | ✅                            |
| `flow-log` wrapper      | `wrappers/flow-log/`      | `wrappers/flow-log/` | ✅                            |
| `vpc-endpoints` wrapper | `wrappers/vpc-endpoints/` | —                    | N/A (no endpoints submodule) |

---

## Variables — Matched (equivalent concept, different name)

| AWS                                      | OCI                                                             | Notes                                                 |
| ---------------------------------------- | --------------------------------------------------------------- | ----------------------------------------------------- |
| `create_vpc`                             | `create_vcn`                                                    | Master toggle                                         |
| `name`                                   | `name`                                                          | Identical                                             |
| `cidr`                                   | `cidr`                                                          | Primary CIDR block                                    |
| `secondary_cidr_blocks`                  | `secondary_cidr_blocks`                                         | Identical                                             |
| `azs`                                    | `ads`                                                           | AWS: AZ name strings. OCI: integers (1/2/3)           |
| `enable_dns_hostnames`                   | `enable_dns_hostnames`                                          | Identical                                             |
| `enable_ipv6`                            | `enable_ipv6`                                                   | Enables IPv6 on VCN/VPC                               |
| `tags`                                   | `freeform_tags` / `vcn_tags`                                    | OCI also has `defined_tags`                           |
| `<tier>_subnets`                         | `<tier>_subnets`                                                | Identical for all 4 tiers                             |
| `<tier>_subnet_names`                    | `<tier>_subnet_names`                                           | Custom names per subnet                               |
| `<tier>_subnet_suffix`                   | `<tier>_subnet_suffix`                                          | Name suffix                                           |
| `<tier>_subnet_tags`                     | `<tier>_subnet_tags`                                            | Per-tier freeform tags                                |
| `<tier>_subnet_tags_per_az`              | `<tier>_subnet_tags_per_ad`                                     | Per-AD/AZ tags                                        |
| `<tier>_subnet_ipv6_prefixes`            | `<tier>_subnet_ipv6_cidrs`                                      | AWS: integer offsets. OCI: explicit /64 strings       |
| `create_igw`                             | `create_igw`                                                    | Identical                                             |
| `igw_tags`                               | `igw_tags`                                                      | Identical                                             |
| `enable_nat_gateway`                     | `enable_nat_gateway`                                            | Identical                                             |
| `single_nat_gateway`                     | `single_nat_gateway`                                            | Identical                                             |
| `one_nat_gateway_per_az`                 | `one_nat_gateway_per_ad`                                        | One NAT per AD/AZ                                     |
| `nat_gateway_destination_cidr_block`     | `nat_gateway_destination_cidr_block`                            | Identical                                             |
| `nat_gateway_tags`                       | `nat_gateway_tags`                                              | Identical                                             |
| `create_database_subnet_route_table`     | `create_database_subnet_route_table`                            | Identical                                             |
| `create_database_internet_gateway_route` | `create_database_internet_gateway_route`                        | Identical                                             |
| `create_multiple_public_route_tables`    | `create_multiple_public_route_tables`                           | Identical                                             |
| `create_multiple_intra_route_tables`     | `create_multiple_intra_route_tables`                            | Identical                                             |
| `*_route_table_tags`                     | `*_route_table_tags`                                            | Per-tier RT tags                                      |
| `manage_default_security_group`          | `lockdown_default_seclist`                                      | Inverted semantics (AWS: manage rules; OCI: deny-all) |
| `<tier>_dedicated_network_acl`           | `<tier>_dedicated_security_list`                                | Per-tier ACL/seclist                                  |
| `enable_dhcp_options`                    | `enable_dhcp_options`                                           | Identical                                             |
| `dhcp_options_domain_name`               | `dhcp_options_domain_name`                                      | Identical                                             |
| `dhcp_options_domain_name_servers`       | `dhcp_options_server_type` + `dhcp_options_domain_name_servers` | Different model (see §9)                              |
| `dhcp_options_tags`                      | `dhcp_options_tags`                                             | Identical                                             |
| `enable_flow_log`                        | `enable_flow_log`                                               | Identical                                             |
| `vpc_flow_log_tags`                      | `flow_log_tags`                                                 | Flow log tags                                         |

---

## Variables — AWS only (no OCI equivalent)

| AWS Variable                                                                                        | Reason not in OCI                             |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `enable_dns_support`                                                                                | Always on in OCI                              |
| `instance_tenancy`                                                                                  | Not a VCN concept                             |
| `use_ipam_pool` / `ipv4_ipam_pool_id` / `ipv6_ipam_pool_id`                                         | OCI has no IPAM service                       |
| `enable_network_address_usage_metrics`                                                              | No OCI equivalent                             |
| `vpc_block_public_access_options` / `*_exclusions`                                                  | No OCI equivalent                             |
| `reuse_nat_ips` / `external_nat_ip_ids`                                                             | OCI NAT GW owns its public IP                 |
| `create_egress_only_igw`                                                                            | OCI's IGW handles IPv4 and IPv6 egress        |
| `<tier>_subnet_ipv6_native`                                                                         | OCI requires a CIDR on every subnet           |
| `<tier>_subnet_enable_dns64`                                                                        | N/A                                           |
| `<tier>_subnet_private_dns_hostname_type_on_launch`                                                 | OCI uses `hostname_label`                     |
| `<tier>_subnet_enable_resource_name_dns_*_record_on_launch`                                         | N/A                                           |
| `create_redshift_subnet_route_table` / `create_elasticache_subnet_route_table`                      | No OCI equivalent services                    |
| `manage_default_vpc` / `manage_default_route_table` / `manage_default_network_acl`                  | OCI has no tenancy-level default VCN          |
| `propagate_*_route_tables_vgw`                                                                      | OCI DRG routing is different                  |
| `customer_gateways` / `enable_vpn_gateway`                                                          | VPN via DRG is out of module scope            |
| `dhcp_options_ntp_servers`                                                                          | OCI uses platform NTP; configured at OS level |
| `dhcp_options_netbios_*`                                                                            | No OCI equivalent                             |
| `create_database_nat_gateway_route`                                                                 | Always included in OCI DB route table         |
| `flow_log_destination_type` / `flow_log_destination_arn`                                            | OCI uses Logging Service only                 |
| `flow_log_traffic_type` / `flow_log_log_format` / `flow_log_max_aggregation_interval`               | OCI format is fixed                           |
| `create_flow_log_cloudwatch_iam_role` / `flow_log_cloudwatch_iam_role_arn`                          | No CloudWatch in OCI                          |
| `flow_log_deliver_cross_account_role`                                                               | N/A                                           |
| Redshift / ElastiCache subnet tier variables                                                        | No OCI equivalent services                    |
| `create_database_subnet_group` / `create_redshift_subnet_group` / `create_elasticache_subnet_group` | OCI services use subnets directly             |

---

## Variables — OCI only (no AWS equivalent)

| OCI Variable                                      | What it does                                                |
| ------------------------------------------------- | ----------------------------------------------------------- |
| `compartment_id`                                  | Required OCI compartment scoping — no AWS concept           |
| `tenancy_id`                                      | Used to resolve availability domain names                   |
| `vcn_dns_label`                                   | OCI-specific VCN DNS label (regex-validated)                |
| `defined_tags` / `<tier>_subnet_defined_tags`     | OCI's tag namespace system                                  |
| `ads`                                             | AD numbers (1/2/3) for AD-pinned subnet placement           |
| `create_service_gateway` / `service_gateway_tags` | Private Oracle Services access without public internet      |
| `lockdown_default_seclist`                        | Deny-all posture on the default security list               |
| `attached_drg_id`                                 | Attach an existing Dynamic Routing Gateway                  |
| `local_peering_gateways`                          | Create Local Peering Gateways map for hub-and-spoke peering |
| `internet_gateway_route_rules`                    | Custom symbolic route rules on the IG route table           |
| `nat_gateway_route_rules`                         | Custom symbolic route rules on the NAT route table          |
| `flow_log_retention_duration`                     | OCI log retention in days                                   |

---

## Outputs — Matched

| AWS                               | OCI                               | Notes                             |
| --------------------------------- | --------------------------------- | --------------------------------- |
| `vpc_id`                          | `vcn_id`                          | VPC/VCN identifier                |
| `vpc_cidr_block`                  | `vcn_cidr_block`                  | Primary CIDR                      |
| `vpc_secondary_cidr_blocks`       | `vcn_cidr_blocks`                 | All CIDRs (primary + secondary)   |
| `vpc_ipv6_cidr_block`             | `vcn_ipv6_cidr_blocks`            | IPv6 CIDRs                        |
| `default_route_table_id`          | `default_route_table_id`          | Default route table               |
| `default_security_group_id`       | `default_security_list_id`        | Default SG/seclist                |
| `default_network_acl_id`          | —                                 | N/A in OCI                        |
| `dhcp_options_id`                 | `dhcp_options_id`                 | Custom DHCP options ID            |
| `igw_id`                          | `internet_gateway_id`             | Internet gateway                  |
| `nat_ids`                         | `nat_ids`                         | NAT gateway IDs                   |
| `nat_public_ips`                  | `nat_public_ips`                  | NAT gateway public IPs            |
| `<tier>_subnet_objects`           | `<tier>_subnet_objects`           | Full subnet objects (all 4 tiers) |
| `<tier>_subnets`                  | `<tier>_subnets`                  | Subnet IDs (all 4 tiers)          |
| `<tier>_subnets_cidr_blocks`      | `<tier>_subnets_cidr_blocks`      | Subnet CIDRs (all 4 tiers)        |
| `<tier>_subnets_ipv6_cidr_blocks` | `<tier>_subnets_ipv6_cidr_blocks` | IPv6 CIDRs (all 4 tiers)          |
| `<tier>_route_table_ids`          | `<tier>_route_table_id(s)`        | Route table IDs (all 4 tiers)     |
| `azs`                             | `ads`                             | AZ/AD identifiers                 |
| `name`                            | `name`                            | Module name echo                  |
| `vpc_flow_log_id`                 | `flow_log_ids`                    | Flow log identifiers              |

---

## Outputs — AWS only

| AWS Output                                                              | Reason not in OCI                           |
| ----------------------------------------------------------------------- | ------------------------------------------- |
| `vpc_arn`                                                               | OCI uses OCIDs; no ARN concept              |
| `vpc_owner_id`                                                          | No AWS account owner concept in OCI         |
| `vpc_instance_tenancy` / `vpc_enable_dns_support`                       | N/A in OCI                                  |
| `vpc_main_route_table_id`                                               | No "main" RT concept in OCI                 |
| `vpc_block_public_access_exclusions`                                    | N/A                                         |
| `igw_arn`                                                               | No ARN concept                              |
| `<tier>_subnet_arns`                                                    | No ARN concept                              |
| `<tier>_network_acl_id` / `<tier>_network_acl_arn`                      | OCI uses security lists                     |
| `<tier>_route_table_association_ids`                                    | OCI associations are on the subnet resource |
| `natgw_ids` / `natgw_interface_ids`                                     | Redundant with `nat_ids` in OCI             |
| `egress_only_internet_gateway_id`                                       | N/A in OCI                                  |
| `cgw_ids` / `cgw_arns` / `this_customer_gateway`                        | VPN/Customer Gateway out of scope           |
| `vgw_id` / `vgw_arn`                                                    | VPN Gateway out of scope                    |
| `default_vpc_*` (11 outputs)                                            | No default VCN in OCI                       |
| `vpc_flow_log_destination_arn` / `*_type` / `*_cloudwatch_iam_role_arn` | OCI Logging Service only                    |
| Redshift / ElastiCache / Outpost outputs                                | N/A in OCI                                  |
| `database_subnet_group` / `database_subnet_group_name`                  | No subnet groups in OCI                     |

---

## Outputs — OCI only

| OCI Output                                              | What it exposes                                      |
| ------------------------------------------------------- | ---------------------------------------------------- |
| `vcn_dns_label`                                         | VCN DNS label                                        |
| `default_dhcp_options_id`                               | Default DHCP options OCID                            |
| `vcn_all_attributes`                                    | Full `oci_core_vcn` object                           |
| `internet_gateway_all_attributes`                       | Full IGW object                                      |
| `ig_route_id` / `ig_route_all_attributes`               | IG route table details                               |
| `nat_reserved_public_ip_id`                             | Reserved public IP OCID for NAT GW                   |
| `nat_gateway_all_attributes`                            | Full NAT GW object                                   |
| `nat_route_ids` / `nat_route_all_attributes`            | NAT route table details                              |
| `service_gateway_id` / `service_gateway_all_attributes` | SGW OCID and full object                             |
| `lpg_ids` / `lpg_all_attributes`                        | Local Peering Gateway OCIDs and objects              |
| `flow_log_group_ids`                                    | OCI log group OCIDs (per subnet type)                |
| `ad_names`                                              | Full AD name strings (e.g. `"abCD:US-ASHBURN-AD-1"`) |
| `<tier>_security_list_id`                               | Security list OCID per tier                          |

---

## Examples

### AWS examples

| Example                 | What it covers                                                                                |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `simple`                | Minimal VPC with public + private subnets, NAT GW, IGW                                        |
| `complete`              | All features: multiple tiers, VPN/Customer GW, DHCP options, dedicated NACLs, flow logs, EIPs |
| `flow-log`              | Standalone `modules/flow-log` usage                                                           |
| `ipam`                  | IPv4/IPv6 address allocation via AWS IPAM                                                     |
| `ipv6-dualstack`        | Dual-stack VPC with IPv6 subnets                                                              |
| `ipv6-only`             | IPv6-native subnets (no IPv4)                                                                 |
| `network-acls`          | Dedicated NACLs per subnet tier                                                               |
| `outpost`               | AWS Outposts-specific subnets                                                                 |
| `secondary-cidr-blocks` | Multiple CIDR blocks on one VPC                                                               |
| `separate-route-tables` | DB subnet with its own route table                                                            |
| `manage-default-vpc`    | Manage the default VPC resources                                                              |
| `block-public-access`   | VPC block public access options                                                               |
| `issues`                | Regression tests for reported bugs                                                            |

### OCI examples

| Example                 | What it covers                                                                                                 |
| ----------------------- | -------------------------------------------------------------------------------------------------------------- |
| `simple`                | Minimal VCN: public + private + database subnets, NAT + SGW, IGW                                               |
| `complete`              | All features: 4 tiers, dedicated security lists, multiple CIDRs, flow logs, DHCP options, DRG attachment, LPGs |
| `flow-log`              | Standalone `modules/flow-log` — both VCN-level and per-subnet logging                                          |
| `ipv6-dualstack`        | Dual-stack VCN with explicit IPv6 CIDRs (two-step workflow documented)                                         |
| `network-acls`          | Per-tier dedicated security lists with custom ingress/egress rules                                             |
| `secondary-cidr-blocks` | Multiple CIDR blocks on one VCN, subnets spread across CIDRs                                                   |
| `separate-route-tables` | Database subnet with dedicated route table (NAT + SGW)                                                         |
| `dhcp-options`          | Custom search domain + custom DNS servers                                                                      |
| `local-peering`         | Hub-and-spoke LPG topology: hub VCN ↔ spoke VCN via acceptor/requestor LPG pattern                             |
| `service-gateway`       | Fully-private VCN (no IGW, no NAT); Oracle Services routing via SGW only                                       |
| `drg-peering`           | Cross-region DRG + Remote Peering Connection: us-ashburn-1 ↔ us-chicago-1; multi-provider aliases              |

### Example gap analysis

#### OCI missing vs AWS

| AWS Example / Scenario        | OCI Status | Notes                                                           |
| ----------------------------- | ---------- | --------------------------------------------------------------- |
| `ipam`                        | N/A        | OCI IPAM is a different product, out of scope                   |
| `ipv6-only`                   | N/A        | OCI requires a CIDR on every subnet; IPv6-only is not supported |
| `outpost`                     | N/A        | AWS Outposts has no OCI equivalent                              |
| `manage-default-vpc`          | N/A        | OCI has no tenancy-level default VCN                            |
| `block-public-access`         | N/A        | No OCI equivalent                                               |
| `issues` (regression tests)   | Not yet    | Deferred — add as test coverage grows                           |
| Complete VPN/Customer Gateway | N/A        | OCI VPN via DRG is out of module scope                          |

#### AWS missing vs OCI

| OCI Example / Scenario | Notes                                                                                                     |
| ---------------------- | --------------------------------------------------------------------------------------------------------- |
| `dhcp-options`         | AWS covers DHCP inline in `complete`; OCI warrants standalone due to the `server_type` enum difference    |
| `local-peering`        | OCI-specific hub-and-spoke LPG topology; no AWS equivalent in this module                                 |
| `service-gateway`      | OCI-specific private Oracle Services routing; closest AWS concept (VPC endpoints) is a separate submodule |
| `drg-peering`          | OCI-specific cross-region peering; AWS Transit Gateway is out of scope for the VPC module                 |

---

## Summary

**Good parity:** core VCN/VPC (CIDR, DNS, IPv6, tags), all 4 subnet tiers with full per-tier
configuration, route tables (public/private/database/intra), internet gateway, NAT gateway
(single/multi/per-AD), dedicated security lists/NACLs, DHCP options, flow logs, wrappers, CI/CD tooling.

**AWS-only gaps:** IPAM, IPv6-native subnets, Outposts, VPN/Customer Gateway, Redshift/ElastiCache
tiers and subnet groups, default VPC management, block public access, VPC endpoint submodule,
CloudWatch/S3/Kinesis flow log destinations.

**OCI advantages in this module:** Service Gateway (private Oracle Services access), Local Peering
Gateways (hub-and-spoke VCN peering), DRG attachment, symbolic route rules (`"nat_gateway"`,
`"internet_gateway"`, `"drg"`, `"lpg@<name>"`), defined tags, AD-pinned vs regional subnet control,
default security list lockdown.

**Potential future additions:**
- OCI Private Endpoint submodule (third-party PaaS) — `modules/private-endpoint`
- `issues` / regression test example
- Expanded VPN/IPSec connectivity via DRG (v2 scope)
