variable "avs_data_store" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is enabled for Azure VMware Solution (AVS) datastore purposes. Default is `false`."
}

variable "capacity_pool" {
  type = object({
    resource_id = string
  })
  description = <<DESCRIPTION
  (Required) The Azure NetApp Files Capacity Pool Resource ID, into which the Volume will be created.

  - resource_id - The Azure NetApp Files Capacity Pool Resource ID.
  DESCRIPTION
  nullable    = false
}

variable "cool_access" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is cool access enabled. Default is `false`."
}

variable "cool_access_retrieval_policy" {
  type        = string
  description = "(Optional) determines the data retrieval behavior from the cool tier to standard storage based on the read pattern for cool access enabled volumes. Possible values are `default`, `never`, `onread` or `null`. Default is `null`."
  default     = null

  validation {
    condition     = can(regex("^(default|never|onread|null)$", var.cool_access_retrieval_policy))
    error_message = "The cool_access_retrieval_policy value must be either `default`, `never`, `onread` or `null`."
  }
}

variable "coolness_period" {
  type        = number
  description = "(Optional) Specifies the number of days after which data that is not accessed by clients will be tiered. Values must be between 2 and 183. Default is null."
  default     = null

  validation {
    condition     = var.coolness_period == null || (var.coolness_period >= 2 && var.coolness_period <= 183)
    error_message = "The coolness_period value must be between 2 and 183 or null."
  }

}

variable "creation_token" {
  type        = string
  description = "(Optional) A unique file path for the volume. Used when creating mount targets. Default is `null` which means the `name` variable value is used in place."
  default     = null
}

variable "default_quota_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies if default quota is enabled for the volume. Default is `false`."
}

variable "default_group_quota_in_kibs" {
  type        = number
  description = "(Optional) Default group quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `null`."
  default     = null

  validation {
    condition     = var.default_group_quota_in_kibs == null || var.default_group_quota_in_kibs >= 4
    error_message = "The `default_user_quota_in_kibs` value must be greater than or equal to `4` or `null`."
  }
}

variable "default_user_quota_in_kibs" {
  type        = number
  description = "(Optional) Default user quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `null`."
  default     = null

  validation {
    condition     = var.default_user_quota_in_kibs == null || var.default_user_quota_in_kibs >= 4
    error_message = "The `default_user_quota_in_kibs` value must be greater than or equal to `4` or `null`."
  }
}

variable "delete_base_snapshot" {
  type        = bool
  default     = false
  description = "(Optional) If enabled (`true`) the snapshot the volume was created from will be automatically deleted after the volume create operation has finished. Defaults to `false`."
}

variable "enable_sub_volumes" {
  type        = bool
  default     = false
  description = "(Optional) Flag indicating whether subvolume operations are enabled on the volume. Default is `false`."
}

variable "encryption_key_source" {
  type        = string
  description = "(Optional) Source of key used to encrypt data in volume. Applicable if NetApp account has encryption.keySource = `Microsoft.KeyVault`. Possible values (case-insensitive) are: `Microsoft.NetApp` & `Microsoft.KeyVault`. Default is `Microsoft.NetApp`."
  default     = "Microsoft.NetApp"

  validation {
    condition     = can(regex("^(Microsoft.KeyVault|Microsoft.NetApp)$", var.encryption_key_source))
    error_message = "The encryption_key_source value must be either `Microsoft.KeyVault` or `Microsoft.NetApp`."
  }
}

variable "key_vault_private_endpoint_resource_id" {
  type        = string
  description = "(Optional) The Azure Resource ID of the Private Endpoint to access the required Key Vault. Required if `encryption_key_source` is set to `Microsoft.KeyVault`. Default is `null`. Example: `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/privateEndpoints/pep-kvlt-001`."
  default     = null

  validation {
    condition     = var.encryption_key_source == "Microsoft.NetApp" && var.key_vault_private_endpoint_resource_id != null
    error_message = "The `key_vault_private_endpoint_resource_id` must be set if encryption_key_source is set to `Microsoft.KeyVault`."
  }
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

variable "is_large_volume" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is a large volume. Default is `false`."  
}

variable "kerberos_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is Kerberos enabled. Default is `false`."  
}

variable "ldap_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is LDAP enabled. Default is `false`."  
}

variable "network_features" {
  type = string
  description = "(Optional) Specifies the network features of the volume Possible values are: `Basic` or `Standard`. Default is `Standard`."
  default     = "Standard"

  validation {
    condition     = can(regex("^(Basic|Standard)$", var.network_features))
    error_message = "The network_features value must be either Basic or Standard."
  } 
}

variable "protocol_types" {
  type        = list(string)
  description = "(Optional) The list of protocol types for the volume. Possible values are `NFSv3`, `NFSv4.1`, `CIFS`. Default is `NFSv3`."
  default     = ["NFSv3"]  
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
  description = "(Required) The name of the volume."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name) && var.name != "default" && var.name != "bin")
    error_message = "The NetApp Files Volume name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores. The name cannot be `default` or `bin`."
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

variable "zone" {
  type        = number
  description = "(Optional) The number of the availability zone where the volume should be created."
  default     = null

  validation {
    condition     = can(regex("^(1|2|3)$", var.zone))
    error_message = "The NetApp Files Volume zone must be either 1, 2 or 3."
  }
}

