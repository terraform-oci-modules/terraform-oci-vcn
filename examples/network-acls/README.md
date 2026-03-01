# Network ACLs (Security Lists)

Configuration in this directory demonstrates per-tier dedicated security lists — the OCI equivalent of AWS dedicated Network ACLs. Each subnet tier (public, private, database, intra) gets its own `oci_core_security_list` with explicit inbound and outbound rules, instead of relying solely on the VCN default security list.

OCI security list rules differ from AWS NACLs in two key ways: there is no `rule_number` (all matching rules are evaluated), and protocol is specified as a string (`"6"` for TCP, `"17"` for UDP, `"1"` for ICMP, `"all"` for all traffic).

[Read more about OCI security lists](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securitylists.htm).

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (NAT Gateway, for example). Run `terraform destroy` when you don't need these resources.

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
| <a name="output_database_security_list_id"></a> [database\_security\_list\_id](#output\_database\_security\_list\_id) | The OCID of the dedicated database security list |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of OCIDs of database subnets |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The OCID of the Internet Gateway |
| <a name="output_intra_security_list_id"></a> [intra\_security\_list\_id](#output\_intra\_security\_list\_id) | The OCID of the dedicated intra security list |
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of OCIDs of intra subnets |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | List of OCIDs of NAT Gateways |
| <a name="output_private_security_list_id"></a> [private\_security\_list\_id](#output\_private\_security\_list\_id) | The OCID of the dedicated private security list |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of OCIDs of private subnets |
| <a name="output_public_security_list_id"></a> [public\_security\_list\_id](#output\_public\_security\_list\_id) | The OCID of the dedicated public security list |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of OCIDs of public subnets |
| <a name="output_service_gateway_id"></a> [service\_gateway\_id](#output\_service\_gateway\_id) | The OCID of the Service Gateway |
| <a name="output_vcn_cidr_block"></a> [vcn\_cidr\_block](#output\_vcn\_cidr\_block) | The primary CIDR block of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
<!-- END_TF_DOCS -->
