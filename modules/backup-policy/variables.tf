variable "account" {
  type = object({
    resource_id = string
  })
  description = <<DESCRIPTION
  (Required) The Azure NetApp Files Account Resource ID, into which the Backup Policy will be created.

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
  description = "(Required) The name of the backup policy."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name))
    error_message = "The Azure NetApp Files Backup Policy name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores."
  }
}

variable "daily_backups_to_keep" {
  type        = number
  description = "(Required) The number of daily backups to keep. Defaults to 2."
  default     = 2

  validation {
    condition     = var.daily_backups_to_keep >= 2
    error_message = "The number of daily backups to keep must be greater than or equal to 2."
  }
}

variable "weekly_backups_to_keep" {
  type        = number
  description = "(Required) The number of weekly backups to keep. Defaults to 1."
  default     = 1
}

variable "monthly_backups_to_keep" {
  type        = number
  description = "(Required) The number of monthly backups to keep. Defaults to 1."
  default     = 1
}

variable "enabled" {
  type        = bool
  description = "(Required) Whether the backup policy is enabled. Defaults to true."
  default     = true
}


