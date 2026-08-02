# Regression Tests for Reported Issues

Configuration in this directory collects regression tests for reported bugs, mirroring
`terraform-aws-modules/vpc`'s `examples/issues` pattern: one `module` block per historical bug
report, named `vcn_issue_<number>`, with a comment linking to the GitHub issue and a config that
reproduces the exact conditions that triggered it.

No bugs have been reported against this module yet, so this directory is currently empty of
`module` blocks. When fixing a reported bug:

1. Add a new `module "vcn_issue_<number>"` block to `main.tf`, sourced from `../../`, configured
   to reproduce the conditions from the issue. Restore the `name`/`region`/`tags` locals (see the
   `simple` example for the pattern) once something actually references them.
2. Add a comment header above it linking to the issue, matching the AWS module's convention.
3. Add `compartment_id` to `variables.tf` (left empty in this scaffold to satisfy
   `terraform_standard_module_structure` without tripping `terraform_unused_declarations`).
4. Add a corresponding `tests/issues.tftest.hcl` run block asserting the fix holds.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you no longer need these resources.
