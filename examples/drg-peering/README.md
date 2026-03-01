# DRG Peering (Cross-Region)

Configuration in this directory demonstrates connecting two VCNs in **different OCI regions** using Dynamic Routing Gateways (DRGs) and Remote Peering Connections (RPCs). DRG peering is the standard cross-region connectivity pattern in OCI; for same-region peering use Local Peering Gateways (LPGs) instead.

The example creates:

```
Ashburn VCN (10.0.0.0/16) ── DRG-A ── RPC ── DRG-C ── Chicago VCN (10.1.0.0/16)
```

The Ashburn VCN has public and private subnets, an Internet Gateway, a NAT Gateway, and a Service Gateway. The Chicago VCN has only private subnets and no internet egress — it communicates with Oracle Services via its own Service Gateway, and with Ashburn via the DRG cross-region link.

**How OCI cross-region DRG peering works:**

1. A DRG is created in each region and attached to its VCN.
2. An RPC is created on each DRG. One side is the *requestor* — it sets `peer_id` and `peer_region_name` to initiate the connection. The other side is the *acceptor* and omits `peer_id`. Here Ashburn is the requestor and Chicago is the acceptor.
3. Route tables on each VCN must have a route pointing the remote CIDR at the local DRG. This example uses the symbolic `"drg"` value in `nat_gateway_route_rules`, which the module resolves to the correct DRG OCID via `attached_drg_id`.

[Read more about OCI DRG Remote Peering](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/remoteVCNpeering.htm).

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example creates resources in two OCI regions (`us-ashburn-1` and `us-chicago-1`). Your OCI tenancy must be subscribed to both regions. Resources that may incur cost include the NAT Gateway and Service Gateways. Run `terraform destroy` when you no longer need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci.ashburn"></a> [oci.ashburn](#provider\_oci.ashburn) | >= 5.0 |
| <a name="provider_oci.chicago"></a> [oci.chicago](#provider\_oci.chicago) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vcn_ashburn"></a> [vcn\_ashburn](#module\_vcn\_ashburn) | ../../ | n/a |
| <a name="module_vcn_chicago"></a> [vcn\_chicago](#module\_vcn\_chicago) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_core_drg.ashburn](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg) | resource |
| [oci_core_drg.chicago](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg) | resource |
| [oci_core_drg_attachment.ashburn](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg_attachment) | resource |
| [oci_core_drg_attachment.chicago](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg_attachment) | resource |
| [oci_core_remote_peering_connection.ashburn](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_remote_peering_connection) | resource |
| [oci_core_remote_peering_connection.chicago](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_remote_peering_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | The OCID of the compartment where resources will be created in both regions | `string` | n/a | yes |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | The OCID of the tenancy (used to resolve availability domain names) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ashburn_drg_id"></a> [ashburn\_drg\_id](#output\_ashburn\_drg\_id) | The OCID of the Ashburn Dynamic Routing Gateway |
| <a name="output_ashburn_internet_gateway_id"></a> [ashburn\_internet\_gateway\_id](#output\_ashburn\_internet\_gateway\_id) | The OCID of the Ashburn Internet Gateway |
| <a name="output_ashburn_nat_ids"></a> [ashburn\_nat\_ids](#output\_ashburn\_nat\_ids) | List of OCIDs of Ashburn NAT Gateways |
| <a name="output_ashburn_private_subnets"></a> [ashburn\_private\_subnets](#output\_ashburn\_private\_subnets) | List of OCIDs of Ashburn private subnets |
| <a name="output_ashburn_public_subnets"></a> [ashburn\_public\_subnets](#output\_ashburn\_public\_subnets) | List of OCIDs of Ashburn public subnets |
| <a name="output_ashburn_rpc_id"></a> [ashburn\_rpc\_id](#output\_ashburn\_rpc\_id) | The OCID of the Ashburn Remote Peering Connection (requestor) |
| <a name="output_ashburn_rpc_peering_status"></a> [ashburn\_rpc\_peering\_status](#output\_ashburn\_rpc\_peering\_status) | The peering status of the Ashburn RPC |
| <a name="output_ashburn_service_gateway_id"></a> [ashburn\_service\_gateway\_id](#output\_ashburn\_service\_gateway\_id) | The OCID of the Ashburn Service Gateway |
| <a name="output_ashburn_vcn_cidr_block"></a> [ashburn\_vcn\_cidr\_block](#output\_ashburn\_vcn\_cidr\_block) | The primary CIDR block of the Ashburn VCN |
| <a name="output_ashburn_vcn_id"></a> [ashburn\_vcn\_id](#output\_ashburn\_vcn\_id) | The OCID of the Ashburn VCN |
| <a name="output_chicago_drg_id"></a> [chicago\_drg\_id](#output\_chicago\_drg\_id) | The OCID of the Chicago Dynamic Routing Gateway |
| <a name="output_chicago_private_subnets"></a> [chicago\_private\_subnets](#output\_chicago\_private\_subnets) | List of OCIDs of Chicago private subnets |
| <a name="output_chicago_rpc_id"></a> [chicago\_rpc\_id](#output\_chicago\_rpc\_id) | The OCID of the Chicago Remote Peering Connection (acceptor) |
| <a name="output_chicago_rpc_peering_status"></a> [chicago\_rpc\_peering\_status](#output\_chicago\_rpc\_peering\_status) | The peering status of the Chicago RPC |
| <a name="output_chicago_service_gateway_id"></a> [chicago\_service\_gateway\_id](#output\_chicago\_service\_gateway\_id) | The OCID of the Chicago Service Gateway |
| <a name="output_chicago_vcn_cidr_block"></a> [chicago\_vcn\_cidr\_block](#output\_chicago\_vcn\_cidr\_block) | The primary CIDR block of the Chicago VCN |
| <a name="output_chicago_vcn_id"></a> [chicago\_vcn\_id](#output\_chicago\_vcn\_id) | The OCID of the Chicago VCN |
<!-- END_TF_DOCS -->
