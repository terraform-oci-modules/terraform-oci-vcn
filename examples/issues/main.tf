provider "oci" {
  region = "us-ashburn-1"
}

################################################################################
# Regression tests for reported bugs
#
# Mirrors terraform-aws-modules/vpc's examples/issues: one module block per
# historical bug report, named vcn_issue_<number>, with a comment linking to
# the issue and a config that reproduces the exact conditions that triggered
# it. No bugs have been reported against this module yet, so there is nothing
# to regress against - add the first module block here the next time one is
# fixed. See README.md for the exact steps (name/region/tags locals and the
# compartment_id variable go back in variables.tf/here at that point).
################################################################################
