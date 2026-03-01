# IPv6 Dual-Stack Example

This example creates a dual-stack VCN with both IPv4 and IPv6 enabled.

When `enable_ipv6 = true`, OCI automatically assigns a `/56` IPv6 prefix to the
VCN. Because this prefix is only known after the first `terraform apply`, subnet
IPv6 CIDRs cannot be set in the same apply. Use the two-step workflow below.

## Two-step workflow

**Step 1** — Apply with `enable_ipv6 = true` and no subnet IPv6 CIDRs:

```sh
terraform apply
# Note the value of vcn_ipv6_cidr_blocks in the output, e.g. 2603:c020:4:ab00::/56
```

**Step 2** — Carve `/64` blocks from the `/56` and set them on the subnets:

```hcl
public_subnet_ipv6_cidrs = [
  "2603:c020:4:ab00::/64",
  "2603:c020:4:ab01::/64",
  "2603:c020:4:ab02::/64",
]
```

Then apply again:

```sh
terraform apply
```

## Notes

- OCI's single Internet Gateway handles both IPv4 and IPv6 egress for public
  subnets. There is no separate egress-only gateway.
- Private subnets do not have IPv6 outbound by default in this example. Add
  `private_subnet_ipv6_cidrs` and they will route IPv6 via the IGW as well.
- IPv6-only subnets are not supported in OCI (`cidr_block` is always required).

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
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of OCIDs of private subnets |
| <a name="output_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#output\_private\_subnets\_cidr\_blocks) | List of IPv4 CIDR blocks of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of OCIDs of public subnets |
| <a name="output_public_subnets_cidr_blocks"></a> [public\_subnets\_cidr\_blocks](#output\_public\_subnets\_cidr\_blocks) | List of IPv4 CIDR blocks of public subnets |
| <a name="output_public_subnets_ipv6_cidr_blocks"></a> [public\_subnets\_ipv6\_cidr\_blocks](#output\_public\_subnets\_ipv6\_cidr\_blocks) | List of IPv6 CIDR blocks of public subnets (empty until public\_subnet\_ipv6\_cidrs is set) |
| <a name="output_vcn_cidr_block"></a> [vcn\_cidr\_block](#output\_vcn\_cidr\_block) | The primary IPv4 CIDR block of the VCN |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | The OCID of the VCN |
| <a name="output_vcn_ipv6_cidr_blocks"></a> [vcn\_ipv6\_cidr\_blocks](#output\_vcn\_ipv6\_cidr\_blocks) | The Oracle-assigned IPv6 /56 CIDR block(s) of the VCN. Use these to carve /64 blocks for subnets |
<!-- END_TF_DOCS -->
