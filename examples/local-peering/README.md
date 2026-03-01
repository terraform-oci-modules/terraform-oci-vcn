# Local Peering

Configuration in this directory demonstrates connecting two VCNs in the same region using Local Peering Gateways (LPGs). LPG peering is a same-region feature; for cross-region connectivity use a Dynamic Routing Gateway (DRG) instead.

The example creates a hub-and-spoke topology:

```
hub VCN (10.0.0.0/16)  ──LPG──  spoke VCN (10.1.0.0/16)
```

The hub has public and private subnets, a NAT Gateway, and a Service Gateway. The spoke has only private subnets and no internet egress of its own — it reaches the internet exclusively via the hub.

**How OCI LPG peering works:**

Each VCN gets one LPG. One side acts as the *requestor* (sets `peer_id` to the other LPG's OCID to initiate peering); the other side acts as the *acceptor* (omits `peer_id` and waits). Here the spoke drives the connection:

```
spoke.lpg["to-hub"].peer_id = hub.lpg["to-spoke"].id
```

After peering, each VCN's route table must have a route pointing the remote CIDR at its own LPG. This example uses the symbolic `"lpg@<key>"` notation in `internet_gateway_route_rules` and `nat_gateway_route_rules`.

[Read more about OCI Local Peering Gateways](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm).

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
| <a name="module_vcn_hub"></a> [vcn\_hub](#module\_vcn\_hub) | ../../ | n/a |
| <a name="module_vcn_spoke"></a> [vcn\_spoke](#module\_vcn\_spoke) | ../../ | n/a |

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
| <a name="output_hub_internet_gateway_id"></a> [hub\_internet\_gateway\_id](#output\_hub\_internet\_gateway\_id) | The OCID of the hub Internet Gateway |
| <a name="output_hub_lpg_ids"></a> [hub\_lpg\_ids](#output\_hub\_lpg\_ids) | Map of LPG name to OCID for hub Local Peering Gateways |
| <a name="output_hub_nat_ids"></a> [hub\_nat\_ids](#output\_hub\_nat\_ids) | List of OCIDs of hub NAT Gateways |
| <a name="output_hub_private_subnets"></a> [hub\_private\_subnets](#output\_hub\_private\_subnets) | List of OCIDs of hub private subnets |
| <a name="output_hub_public_subnets"></a> [hub\_public\_subnets](#output\_hub\_public\_subnets) | List of OCIDs of hub public subnets |
| <a name="output_hub_service_gateway_id"></a> [hub\_service\_gateway\_id](#output\_hub\_service\_gateway\_id) | The OCID of the hub Service Gateway |
| <a name="output_hub_vcn_cidr_block"></a> [hub\_vcn\_cidr\_block](#output\_hub\_vcn\_cidr\_block) | The primary CIDR block of the hub VCN |
| <a name="output_hub_vcn_id"></a> [hub\_vcn\_id](#output\_hub\_vcn\_id) | The OCID of the hub VCN |
| <a name="output_spoke_lpg_ids"></a> [spoke\_lpg\_ids](#output\_spoke\_lpg\_ids) | Map of LPG name to OCID for spoke Local Peering Gateways |
| <a name="output_spoke_private_subnets"></a> [spoke\_private\_subnets](#output\_spoke\_private\_subnets) | List of OCIDs of spoke private subnets |
| <a name="output_spoke_vcn_cidr_block"></a> [spoke\_vcn\_cidr\_block](#output\_spoke\_vcn\_cidr\_block) | The primary CIDR block of the spoke VCN |
| <a name="output_spoke_vcn_id"></a> [spoke\_vcn\_id](#output\_spoke\_vcn\_id) | The OCID of the spoke VCN |
<!-- END_TF_DOCS -->
