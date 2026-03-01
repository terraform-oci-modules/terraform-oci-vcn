variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
}

variable "compartment_id" {
  description = "The OCID of the compartment where the log group and log will be created"
  type        = string
}

variable "tags" {
  description = "A map of freeform tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "A map of defined tags (namespace.key = value) to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Flow Log
################################################################################

variable "name" {
  description = "Name to use across resources created"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet OCID to attach the flow log to. Mutually exclusive with vcn_id"
  type        = string
  default     = null
}

variable "vcn_id" {
  description = "VCN OCID to attach the flow log to (VCN-level logging). Mutually exclusive with subnet_id"
  type        = string
  default     = null
}

variable "is_enabled" {
  description = "Whether the flow log is enabled"
  type        = bool
  default     = true
}

variable "flow_log_tags" {
  description = "Map of additional freeform tags to add to the flow log"
  type        = map(string)
  default     = {}
}

################################################################################
# Log Group
################################################################################

variable "create_log_group" {
  description = "Determines whether to create an OCI Logging log group for the flow log. Set to false to supply an existing log_group_id"
  type        = bool
  default     = true
}

variable "log_group_id" {
  description = "Existing log group OCID to use when create_log_group is false"
  type        = string
  default     = null
}

variable "log_group_description" {
  description = "Description of the log group"
  type        = string
  default     = null
}

variable "log_group_tags" {
  description = "Map of additional freeform tags to add to the log group"
  type        = map(string)
  default     = {}
}

variable "retention_duration" {
  description = "Log retention duration in days"
  type        = number
  default     = 30
}
