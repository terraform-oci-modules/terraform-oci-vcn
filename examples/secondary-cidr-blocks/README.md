# Secondary CIDR Blocks

Configuration in this directory demonstrates attaching a secondary IPv4 CIDR block to a VCN and carving subnets from both the primary and secondary CIDR ranges. This mirrors the `examples/secondary-cidr-blocks` pattern from `terraform-aws-vpc`.

OCI supports up to five CIDR blocks per VCN. Subnets can be allocated from any attached CIDR — they are not restricted to the primary range.

[Read more about OCI VCN CIDR blocks](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/Overview_of_VCNs_and_Subnets.htm).

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
| <a name="output_intra_subnets"></a> [intra\_subnets](#output\_intra\_subnets) | List of OCIDs of intra subnets |
| <a name="output_intra_subnets_cidr_blocks"></a> [intra\_subnets\_cidr\_blocks](#output\_intra\_subnets\_cidr\_blocks) | List of CIDR blocks of intra subnets |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | List of OCIDs of NAT Gateways |
| <a name="output_nat_public_ips"></a> [nat\_public\_ips](#output\_nat\_public\_ips) | List of public IP addresses of NAT Gateways |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of OCIDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of CIDR blocks of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of OCIDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of CIDR blocks of public subnets |
| <a name="output_service_gateway_id"></a> [service\_gateway\_id](#output\_service\_gateway\_id) | The OCID of the Service Gateway |
| <a name="output_vcn_cidr_block"></a> [vcn\_cidr\_block](#output\_vcn\_cidr\_block) | The primary CIDR block of the VCN |
| <a name="output_vcn_cidr_blocks"></a> [vcn\_cidr\_blocks](#output\_vcn\_cidr\_blocks) | All CIDR blocks (primary + secondary) of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
<!-- END_TF_DOCS -->
