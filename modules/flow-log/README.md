# OCI Flow Log Terraform Module

Terraform module which creates an OCI Logging flow log (and optionally a log group) for a subnet or VCN.

Use this standalone module when you need to attach flow logs to resources that are managed outside of the root `terraform-oci-vcn` module, or when you want fine-grained control over log group settings.

## Usage

### Subnet-level flow log (with a new log group)

```hcl
module "flow_log" {
  source = "terraform-oci-modules/vcn/oci//modules/flow-log"

  name           = "my-subnet-flow-log"
  compartment_id = var.compartment_id
  subnet_id      = module.vcn.private_subnets[0]

  tags = {
    Environment = "prod"
  }
}
```

### VCN-level flow log (using an existing log group)

```hcl
module "flow_log" {
  source = "terraform-oci-modules/vcn/oci//modules/flow-log"

  name             = "my-vcn-flow-log"
  compartment_id   = var.compartment_id
  vcn_id           = module.vcn.vcn_id
  create_log_group = false
  log_group_id     = var.existing_log_group_id

  tags = {
    Environment = "prod"
  }
}
```

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
| [oci_logging_log.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log_group.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The OCID of the compartment where the log group and log will be created | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Determines whether to create an OCI Logging log group for the flow log. Set to false to supply an existing log\_group\_id | `bool` | `true` | no |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | A map of defined tags (namespace.key = value) to add to all resources | `map(string)` | `{}` | no |
| <a name="input_flow_log_tags"></a> [flow\_log\_tags](#input\_flow\_log\_tags) | Map of additional freeform tags to add to the flow log | `map(string)` | `{}` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether the flow log is enabled | `bool` | `true` | no |
| <a name="input_log_group_description"></a> [log\_group\_description](#input\_log\_group\_description) | Description of the log group | `string` | `null` | no |
| <a name="input_log_group_id"></a> [log\_group\_id](#input\_log\_group\_id) | Existing log group OCID to use when create\_log\_group is false | `string` | `null` | no |
| <a name="input_log_group_tags"></a> [log\_group\_tags](#input\_log\_group\_tags) | Map of additional freeform tags to add to the log group | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to use across resources created | `string` | `""` | no |
| <a name="input_retention_duration"></a> [retention\_duration](#input\_retention\_duration) | Log retention duration in days | `number` | `30` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet OCID to attach the flow log to. Mutually exclusive with vcn\_id | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of freeform tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id) | VCN OCID to attach the flow log to (VCN-level logging). Mutually exclusive with subnet\_id | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_display_name"></a> [display\_name](#output\_display\_name) | The display name of the flow log |
| <a name="output_id"></a> [id](#output\_id) | The OCID of the flow log |
| <a name="output_log_group_display_name"></a> [log\_group\_display\_name](#output\_log\_group\_display\_name) | The display name of the log group |
| <a name="output_log_group_id"></a> [log\_group\_id](#output\_log\_group\_id) | The OCID of the log group |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-oci-modules/terraform-oci-vcn/blob/master/LICENSE) for full details.
