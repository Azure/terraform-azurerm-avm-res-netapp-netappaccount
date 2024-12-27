variable "account" {
  type = object({
    resource_id = string
  })
  description = <<DESCRIPTION
  (Required) The Azure NetApp Files Account Resource ID, into which the capacity pool will be created.

  - resource_id - The Azure NetApp Files Account Resource ID.
  DESCRIPTION
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "name" {
  type        = string
  description = "(Required) The name of the backup vault."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name))
    error_message = "The Azure NetApp Files Backup Vault name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores."
  }
}




