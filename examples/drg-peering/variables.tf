variable "compartment_id" {
  description = "The OCID of the compartment where resources will be created in both regions"
  type        = string
}

variable "tenancy_id" {
  description = "The OCID of the tenancy (used to resolve availability domain names)"
  type        = string
  default     = null
}
