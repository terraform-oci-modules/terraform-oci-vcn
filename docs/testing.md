# Testing

Each example in this repository ships with a `terraform test` file that applies real OCI resources, asserts key outputs, then destroys everything on completion.

## Prerequisites

- Terraform >= 1.6
- OCI credentials configured — any of:
  - Environment variables (`OCI_CLI_TENANCY`, `OCI_CLI_USER`, `OCI_CLI_FINGERPRINT`, `OCI_CLI_KEY_FILE`, `OCI_CLI_REGION`)
  - A config file at `~/.oci/config`
  - Instance principal (when running from an OCI compute instance)
- A target compartment OCID

## Quick start

```bash
export TF_VAR_compartment_id="ocid1.compartment.oc1.."
cd examples/simple
terraform init
terraform test
```

## Running all examples

```bash
export TF_VAR_compartment_id="ocid1.compartment.oc1.."

for example in examples/*/; do
  echo "=== ${example} ==="
  terraform -chdir="${example}" init -upgrade -input=false
  terraform -chdir="${example}" test
done
```

## Notes

- Tests use `command = apply` — they create and destroy **real** OCI resources and may incur cost.
- The `drg-peering` example requires your tenancy to be subscribed to both `us-ashburn-1` and `us-chicago-1`.
- The `ipv6-dualstack` example follows a two-step apply workflow; the test covers step 1 only (VCN + subnets created, IPv6 /56 assigned).
