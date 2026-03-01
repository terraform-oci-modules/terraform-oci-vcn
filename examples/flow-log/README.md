# Flow Log

Configuration in this directory demonstrates two patterns for attaching OCI flow logs to subnets using the standalone `modules/flow-log` submodule directly, without enabling the root module's built-in `enable_flow_log` toggle. This mirrors the `examples/flow-log` pattern from `terraform-aws-vpc`.

**Pattern 1** — Public subnet flow log with its own dedicated log group (new `oci_logging_log_group` created).
**Pattern 2** — Private subnet flow log that reuses the log group created in Pattern 1.

[Read more about OCI flow logs](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/vcn_flow_logs.htm).

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (NAT Gateway, flow log storage, for example). Run `terraform destroy` when you don't need these resources.

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
| <a name="module_flow_log_private"></a> [flow\_log\_private](#module\_flow\_log\_private) | ../../modules/flow-log | n/a |
| <a name="module_flow_log_public"></a> [flow\_log\_public](#module\_flow\_log\_public) | ../../modules/flow-log | n/a |
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
| <a name="output_flow_log_private_id"></a> [flow\_log\_private\_id](#output\_flow\_log\_private\_id) | The OCID of the flow log for the private subnet |
| <a name="output_flow_log_public_id"></a> [flow\_log\_public\_id](#output\_flow\_log\_public\_id) | The OCID of the flow log for the public subnet |
| <a name="output_flow_log_public_log_group_id"></a> [flow\_log\_public\_log\_group\_id](#output\_flow\_log\_public\_log\_group\_id) | The OCID of the log group created for the public subnet flow log |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of OCIDs of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of OCIDs of public subnets |
| <a name="output_vcn_cidr_block"></a> [vcn\_cidr\_block](#output\_vcn\_cidr\_block) | The primary CIDR block of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
<!-- END_TF_DOCS -->
