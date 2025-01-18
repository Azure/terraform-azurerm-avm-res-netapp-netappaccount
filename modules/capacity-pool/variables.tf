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

variable "name" {
  type        = string
  description = "(Required) The name of the capacity pool."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name))
    error_message = "The NetApp Files Capacity Pool name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores."
  }
}

variable "cool_access" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is cool access enabled. Default is false."
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

variable "encryption_type" {
  type        = string
  default     = "Single"
  description = "(Optional) Specifies the encryption type of the volume."

  validation {
    condition     = can(regex("^(Single|Double)$", var.encryption_type))
    error_message = "The encryption_type value must be either Single or Double."
  }
}

variable "qos_type" {
  type        = string
  default     = "Auto"
  description = "(Optional) Specifies the QoS type of the volume."

  validation {
    condition     = can(regex("^(Auto|Manual)$", var.qos_type))
    error_message = "The qos_type value must be either Auto or Manual."
  }
}

variable "service_level" {
  type        = string
  default     = "Standard"
  description = "(Optional) The service level of the capacity pool. Defaults to 'Standard'."

  validation {
    condition     = can(regex("^(Standard|Premium|Ultra)$", var.service_level))
    error_message = "The NetApp Files Capacity Pool service level must be either 'Standard', 'Premium' or 'Ultra'."
  }
}

variable "size" {
  type        = number
  default     = 4398046511104
  description = <<DESCRIPTION
  (Required) The size of the capacity pool in bytes. Default is 4 TiB (4398046511104 bytes).
  
  You can only take advantage of the 1-TiB minimum if all the volumes in the capacity pool are using Standard network features. "
  DESCRIPTION

  validation {
    condition     = var.size > 1099511627776
    error_message = "The NetApp Files Capacity Pool size must be greater than 1 TiB."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
