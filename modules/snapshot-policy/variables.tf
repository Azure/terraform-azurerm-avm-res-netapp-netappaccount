variable "account" {
  type = object({
    resource_id = string
  })
  description = <<DESCRIPTION
  (Required) The Azure NetApp Files Account Resource ID, into which the Snapshot Policy will be created.

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
    error_message = "The Azure NetApp Files Snapshot Policy name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores."
  }
}

variable "enabled" {
  type        = bool
  description = "(Required) Whether the snapshot policy is enabled. Defaults to `true`."
  default     = true
}

variable "hourly_schedule" {
  type = object({
    snapshots_to_keep = number
    minute            = number
  })
  description = <<DESCRIPTION
  (Optional) The hourly schedule for the snapshot policy.

  - snapshots_to_keep - The number of snapshots to keep. Must be between 0 and 255.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.
  
  DESCRIPTION
  default     = null
}

variable "daily_schedule" {
  type = object({
    snapshots_to_keep = number
    hour              = number
    minute            = number
  })
  description = <<DESCRIPTION
  (Optional) The daily schedule for the snapshot policy.

  - snapshots_to_keep - The number of snapshots to keep. Must be between 0 and 255.
  - hour              - The hour of the day to take the snapshot. Must be between 0 and 23.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.
  
  DESCRIPTION
  default     = null
}

variable "weekly_schedule" {
  type = object({
    snapshots_to_keep = number
    day               = set(string)
    hour              = number
    minute            = number
  })
  description = <<DESCRIPTION
  (Optional) The weekly schedule for the snapshot policy.

  - snapshots_to_keep - The number of snapshots to keep. Must be between 0 and 255.
  - day               - A list of the days of the week to take the snapshot. Must use the following in the list: `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`.
  - hour              - The hour of the day to take the snapshot. Must be between 0 and 23.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.
  
  DESCRIPTION
  default     = null

}

variable "monthly_schedule" {
  type = object({
    snapshots_to_keep = number
    days_of_month     = set(number)
    hour              = number
    minute            = number
  })
  description = <<DESCRIPTION
  (Optional) The monthly schedule for the snapshot policy.

  - snapshots_to_keep - The number of snapshots to keep. Must be between 0 and 255.
  - days_of_month     - The list of days of the month (number) to take the snapshot. Values must be between 1 and 30.
  - hour              - The hour of the day to take the snapshot. Must be between 0 and 23.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.
  
  DESCRIPTION
  default     = null
}
