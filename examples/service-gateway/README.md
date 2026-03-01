# Service Gateway

Configuration in this directory demonstrates a fully-private VCN that uses an Oracle Service Gateway (SGW) as the only egress path. There is no Internet Gateway and no NAT Gateway — all outbound traffic from private and database subnets is routed exclusively through the SGW to Oracle Services Network.

This pattern is appropriate for workloads that need to access managed Oracle services (Object Storage, Logging, Monitoring, Vault, etc.) without any exposure to the public internet.

**Key design points:**

- `create_service_gateway = true` — explicit OCI-specific opt-in (no AWS equivalent)
- `create_internet_gateway = false` / `enable_nat_gateway = false` — closed network, Oracle Services only
- `create_database_subnet_route_table = true` — the database tier gets its own route table, which automatically picks up the SGW route
- `service_gateway_tags` — optional extra freeform tags on the SGW resource

The route tables created are:

| Route table | Used by | Routes |
|---|---|---|
| `<name>-db-rt` (dedicated) | database subnets | SGW → all Oracle services |

Private subnets have **no route table** when there is no NAT Gateway — they remain fully isolated with no default gateway.

[Read more about OCI Service Gateways](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/servicegateway.htm).

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vcn"></a> [vcn](#module\_vcn) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The OCID of the compartment where resources will be created | `string` | n/a | yes |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The OCID of the tenancy (used to resolve availability domain names) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_route_table_id"></a> [database\_route\_table\_id](#output\_database\_route\_table\_id) | The OCID of the dedicated database subnet route table |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of OCIDs of database subnets |
| <a name="output_database_subnets_cidr_blocks"></a> [database\_subnets\_cidr\_blocks](#output\_database\_subnets\_cidr\_blocks) | List of CIDR blocks of database subnets |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of OCIDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of CIDR blocks of private subnets |
| <a name="output_service_gateway_id"></a> [service\_gateway\_id](#output\_service\_gateway\_id) | The OCID of the Service Gateway |
| <a name="output_vcn_cidr_block"></a> [vcn\_cidr\_block](#output\_vcn\_cidr\_block) | The primary CIDR block of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
<!-- END_TF_DOCS -->
