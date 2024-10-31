variable "account" {
  type = object({
    resource_id = string
  })
  description = <<DESCRIPTION
  (Required) The NetApp Account, into which the capacity pool will be created.

  - resource_id - The ID of the NetApp Account.
  DESCRIPTION
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "(Optional) Subscription ID passed in by an external process.  If this is not supplied, then the configuration either needs to include the subscription ID, or needs to be supplied properties to create the subscription."
}

variable "cool_access" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is cool access enabled. Default is false."
}

variable "encryption_type" {
  type        = string
  description = "(Optional) Specifies the encryption type of the volume."
  default     = "Single"

  validation {
    condition     = can(regex("^(Single|Double)$", var.encryption_type))
    error_message = "The encryption_type value must be either Single or Double."
  }

}

variable "qos_type" {
  type        = string
  description = "(Optional) Specifies the QoS type of the volume."
  default     = "Auto"

  validation {
    condition     = can(regex("^(Auto|Manual)$", var.qos_type))
    error_message = "The qos_type value must be either Auto or Manual."
  }

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
  description = "(Required) The name of the capacity pool."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name))
    error_message = "The NetApp Files Capacity Pool name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores."
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

variable "service_level" {
  type        = string
  description = "(Optional) The service level of the capacity pool. Defaults to 'Premium'."
  default     = "Premium"

  validation {
    condition     = can(regex("^(Standard|Premium|Ultra)$", var.service_level))
    error_message = "The NetApp Files Capacity Pool service level must be either 'Standard', 'Premium' or 'Ultra'."
  }
}



