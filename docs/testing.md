# Testing

The test suite lives in `tests/` - one `.tftest.hcl` file per example. All tests run from the module root via a single `terraform test` invocation.

## Prerequisites

- Terraform >= 1.6
- OCI credentials configured - any of:
  - Environment variables (`OCI_CLI_TENANCY`, `OCI_CLI_USER`, `OCI_CLI_FINGERPRINT`, `OCI_CLI_KEY_FILE`, `OCI_CLI_REGION`)
  - A config file at `~/.oci/config`
  - Instance principal (when running from an OCI compute instance)
- A target compartment OCID

## Quick start

```bash
export TF_VAR_compartment_id="ocid1.compartment.oc1.."
terraform init
terraform test -filter=tests/simple.tftest.hcl
```

## Running all tests

```bash
export TF_VAR_compartment_id="ocid1.compartment.oc1.."
terraform init
terraform test
```

## Notes

- Tests use `command = apply` - they create and destroy **real** OCI resources and may incur cost.
- The `drg-peering` example requires your tenancy to be subscribed to both `us-ashburn-1` and `us-chicago-1`.
- The `ipv6-dualstack` example follows a two-step apply workflow; the test covers step 1 only (VCN + subnets created, IPv6 /56 assigned).
