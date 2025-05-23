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
  default     = 2
  description = "(Required) The number of daily backups to keep. Defaults to 2."

  validation {
    condition     = var.daily_backups_to_keep >= 2
    error_message = "The number of daily backups to keep must be greater than or equal to 2."
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "enabled" {
  type        = bool
  default     = true
  description = "(Required) Whether the backup policy is enabled. Defaults to true."
}

variable "monthly_backups_to_keep" {
  type        = number
  default     = 1
  description = "(Required) The number of monthly backups to keep. Defaults to 1."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "weekly_backups_to_keep" {
  type        = number
  default     = 1
  description = "(Required) The number of weekly backups to keep. Defaults to 1."
}
