variable "avs_data_store" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is enabled for Azure VMware Solution (AVS) datastore purposes. Default is `false`."
}

variable "backup_policy_resource_id" {
  type        = string
  description = "(Optional) The Azure Resource ID of the Backup Policy to associate with the volume. Default is `null`."
  default     = null

  validation {
    condition     = var.backup_policy_resource_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.NetApp/netAppAccounts/[^/]+/backupPolicies/[^/]+$", var.backup_policy_resource_id))
    error_message = "The `backup_policy_resource_id` must be set and it must also be a valid Azure Resource ID or `null`."
  }
}

variable "backup_vault_resource_id" {
  type        = string
  description = "(Optional) The Azure Resource ID of the Backup Vault to associate with the volume. Default is `null`."
  default     = null

  validation {
    condition     = var.backup_vault_resource_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.NetApp/netAppAccounts/[^/]+/backupVaults/[^/]+$", var.backup_vault_resource_id))
    error_message = "The `backup_vault_resource_id` must be set and it must also be a valid Azure Resource ID or `null`."
  }
}

variable "backup_policy_enforced" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the backup policy is enforced for the volume. Default is `false`."
}

variable "capacity_pool_resource_id" {
  type        = string
  description = "(Required) The Azure Resource ID of the Capacity Pool where the volume should be placed."
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
    condition     = var.cool_access_retrieval_policy == null || can(regex("^(default|never|onread|null)$", var.cool_access_retrieval_policy))
    error_message = "The cool_access_retrieval_policy value must be either `default`, `never`, `onread` or `null`."
  }
}

variable "coolness_period" {
  type        = number
  description = "(Optional) Specifies the number of days after which data that is not accessed by clients will be tiered. Values must be between 2 and 183. Default is `null`."
  default     = null

  validation {
    condition     = var.coolness_period == null ? true : (var.coolness_period >= 2 && var.coolness_period <= 183)
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
  description = "(Optional) Default group quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `0`."
  default     = 0

  validation {
    condition     = var.default_group_quota_in_kibs == 0 ? true : var.default_group_quota_in_kibs >= 4
    error_message = "The `default_user_quota_in_kibs` value must be greater than or equal to `4` or `null`."
  }
}

variable "default_user_quota_in_kibs" {
  type        = number
  description = "(Optional) Default user quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `0`."
  default     = 0

  validation {
    condition     = var.default_user_quota_in_kibs == 0 ? true : var.default_user_quota_in_kibs >= 4
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
  description = "(Optional) Flag indicating whether sub volume operations are enabled on the volume. Default is `false`."
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

variable "export_policy_rules" {
  type = map(object({
    rule_index      = number
    allowed_clients = list(string)
    chown_mode      = optional(string)
    cifs            = optional(bool)
    nfsv3           = optional(bool)
    nfsv41          = optional(bool)
    has_root_access = optional(bool)
    kerberos5i_ro   = optional(bool)
    kerberos5i_rw   = optional(bool)
    kerberos5p_ro   = optional(bool)
    kerberos5p_rw   = optional(bool)
    kerberos5_ro    = optional(bool)
    kerberos5_rw    = optional(bool)
    unix_ro         = optional(bool)
    unix_rw         = optional(bool)
  }))
  default = {}

  validation {
    condition     = var.export_policy_rules == {} ? true : alltrue([for rule in coalesce(var.export_policy_rules, {}) : alltrue([for client in rule.allowed_clients : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?:\\/[0-9]{1,2})?$", client))])])
    error_message = "The `allowed_clients` list must contain either IP addresses or CIDR ranges."
  }
  validation {
    condition     = var.export_policy_rules == {} ? true : alltrue([for rule in coalesce(var.export_policy_rules, {}) : can(regex("^(Restricted|Unrestricted)$", rule.chown_mode))])
    error_message = "The `chown_mode` value must be either `Restricted` or `Unrestricted`."
  }

  description = <<DESCRIPTION
  (Optional) A map of export policy rules for the volume. Default is `{}`.

  > The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - rule_index      - The index (number) of the rule. Must be unique.
  - allowed_clients - The list of allowed clients. Must be IP addresses or CIDR ranges.
  - chown_mode      - (Optional) The chown mode of the rule. Possible values are `Restricted` or `Unrestricted`. This variable specifies who is authorized to change the ownership of a file. `Restricted` - Only root user can change the ownership of the file. `Unrestricted` - Non-root users can change ownership of files that they own.
  - cifs            - (Optional) Specifies whether CIFS protocol is allowed.
  - nfsv3          - (Optional) Specifies whether NFSv3 protocol is allowed. Enable only for NFSv3 type volumes.
  - nfsv41         - (Optional) Specifies whether NFSv4.1 protocol is allowed. Enable only for NFSv4.1 type volumes.
  - has_root_access - (Optional) Specifies whether root access is allowed.
  - kerberos5i_ro   - (Optional) Specifies whether Kerberos 5i read-only is allowed.
  - kerberos5i_rw   - (Optional) Specifies whether Kerberos 5i read-write is allowed.
  - kerberos5p_ro   - (Optional) Specifies whether Kerberos 5p read-only is allowed.
  - kerberos5p_rw   - (Optional) Specifies whether Kerberos 5p read-write is allowed.
  - kerberos5_ro    - (Optional) Specifies whether Kerberos 5 read-only is allowed.
  - kerberos5_rw    - (Optional) Specifies whether Kerberos 5 read-write is allowed.
  - unix_ro         - (Optional) Specifies whether UNIX read-only is allowed.
  - unix_rw         - (Optional) Specifies whether UNIX read-write is allowed.

  DESCRIPTION
}

variable "key_vault_private_endpoint_resource_id" {
  type        = string
  description = "(Optional) The Azure Resource ID of the Private Endpoint to access the required Key Vault. Required if `encryption_key_source` is set to `Microsoft.KeyVault`. Default is `null`. Example: `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/privateEndpoints/pep-kvlt-001`."
  default     = null

  validation {
    condition     = var.key_vault_private_endpoint_resource_id == null || (var.encryption_key_source == "Microsoft.NetApp" && var.key_vault_private_endpoint_resource_id != null && can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/privateEndpoints/[^/]+$", var.key_vault_private_endpoint_resource_id)))
    error_message = "The `key_vault_private_endpoint_resource_id` must be set if encryption_key_source is set to `Microsoft.KeyVault`. It must also be a valid Azure Resource ID."
  }
}

variable "encryption_type" {
  type        = string
  description = "(Optional) Specifies the encryption type of the volume. Possible values are `Single` or `Double`. Default is `Single`."
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
  type        = string
  description = "(Optional) Specifies the network features of the volume Possible values are: `Basic` or `Standard`. Default is `Standard`."
  default     = "Standard"

  validation {
    condition     = can(regex("^(Basic|Standard)$", var.network_features))
    error_message = "The network_features value must be either Basic or Standard."
  }
}

variable "protocol_types" {
  type        = set(string)
  description = "(Optional) The set of protocol types for the volume. Possible values are `NFSv3`, `NFSv4.1`, `CIFS`. Default is `NFSv3`."
  default     = ["NFSv3"]

  validation {
    condition     = alltrue([for protocol in var.protocol_types : can(regex("^(NFSv3|NFSv4.1|CIFS)$", protocol))])
    error_message = "The `protocol_types` value must be a set containing values of: `NFSv3`, `NFSv4.1`, `CIFS`."
  }
}

variable "proximity_placement_group_resource_id" {
  type        = string
  description = "(Optional) The resource ID of the Proximity Placement Group the volume should be placed in. Default is `null`."
  default     = null

  validation {
    condition     = var.proximity_placement_group_resource_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Compute/proximityPlacementGroups/[^/]+$", var.proximity_placement_group_resource_id))
    error_message = "The `proximity_placement_group_resource_id` must be a valid Azure Resource ID."
  }
}

variable "security_style" {
  type        = string
  description = "(Optional) The security style of the volume. Possible values are `NTFS` or `Unix`. Defaults to `Unix` for NFS volumes or `NTFS` for CIFS and dual protocol volumes via `local.security_style` in module which uses the `var.protocol_types` values to set this value accordingly. Default is `null`."
  default     = null

  validation {
    condition     = var.security_style == null || can(regex("^(NTFS|Unix)$", var.security_style))
    error_message = "The `security_style` value must be either `NTFS`, `Unix` or `null` which will then use the `var.protocol_types` values to set this value accordingly."
  }
}

variable "service_level" {
  type        = string
  description = "(Optional) The service level of the volume. Possible values are `Standard`, `Premium` or `Ultra`. Defaults to `Standard`."
  default     = "Standard"

  validation {
    condition     = can(regex("^(Standard|Premium|Ultra)$", var.service_level))
    error_message = "The service_level value must be either `Standard`, `Premium` or `Ultra`."
  }
}

variable "smb_access_based_enumeration_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether SMB access-based enumeration is enabled. Only support on SMB or dual protocol volumes. Default is `false`."
}

variable "smb_continuously_available" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether the volume is continuously available. Only supported on SMB volumes. Default is `false`."
}

variable "smb_encryption" {
  type        = bool
  default     = false
  description = "(Optional) Enables encryption for in-flight smb3 data. Only support on SMB or dual protocol volumes. Default is `false`."
}

variable "smb_non_browsable" {
  type        = bool
  default     = false
  description = "(Optional) Enables non-browsable property for SMB Shares. Only support on SMB or dual protocol volumes. Default is `false`."
}

variable "snapshot_directory_visible" {
  type        = bool
  default     = true
  description = "(Optional) If enabled (`true`) the volume will contain a read-only snapshot directory which provides access to each of the volume's snapshots. Default is `true`."
}

variable "snapshot_policy_resource_id" {
  type        = string
  description = "(Optional) The Azure Resource ID of the Snapshot Policy to associate with the volume. Default is `null`."
  default     = null

  validation {
    condition     = var.snapshot_policy_resource_id == null || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.NetApp/netAppAccounts/[^/]+/snapshotPolicies/[^/]+$", var.snapshot_policy_resource_id))
    error_message = "The `snapshot_policy_resource_id` must be set and it must also be a valid Azure Resource ID or `null`."
  }
}

variable "subnet_resource_id" {
  type        = string
  description = "The Azure Resource ID of the Subnet where the volume should be placed. Subnet must have the delegation `Microsoft.NetApp/volumes`."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.Network/virtualNetworks/[^/]+/subnets/[^/]+$", var.subnet_resource_id))
    error_message = "The `subnet_resource_id` must be set and it must also be a valid Azure Resource ID."
  }
}

variable "throughput_mibps" {
  type        = number
  description = "(Optional) Maximum throughput in MiB/s that can be achieved by this volume and this will be accepted as input only for manual qosType volume. Default is `null`."
  default     = null
}

variable "unix_permissions" {
  type        = string
  description = <<DESCRIPTION
  UNIX permissions for NFS volume accepted in octal 4 digit format.
  
  First digit selects the set user ID(4), set group ID (2) and sticky (1) attributes.
  
  Second digit selects permission for the owner of the file: read (4), write (2) and execute (1). 
  
  Third selects permissions for other users in the same group. 
  
  The fourth for other users not in the group. 
  
  `0755` - gives read/write/execute permissions to owner and read/execute to group and other users.

  For more information, see https://learn.microsoft.com/azure/azure-netapp-files/configure-unix-permissions-change-ownership-mode and https://wikipedia.org/wiki/File-system_permissions#Numeric_notation.

  Default is `0770`.
  DESCRIPTION
  default     = "0770"

  validation {
    condition     = can(regex("^[0-7]{4}$", var.unix_permissions))
    error_message = "The `unix_permissions` value must be a 4-digit octal number in a string."
  }
}

variable "volume_size_in_gib" {
  type        = number
  description = "(Optional) The size of the volume in Gibibytes (GiB). Default is `50` GiB."
  default     = 50

  validation {
    condition     = var.volume_size_in_gib >= 50 && var.volume_size_in_gib <= 2457600
    error_message = "The volume_size_in_gib value must be greater than or equal to 50 and less than or equal to 2457600."
  }
}

variable "volume_spec_name" {
  type        = string
  description = "(Optional) Volume spec name is the application specific designation or identifier for the particular volume in a volume group for e.g. `data`, `log`. Default is `null`."
  default     = null
}

variable "volume_type" {
  type        = string
  description = "(Optional) What type of volume is this. For destination volumes in Cross Region Replication, set type to `DataProtection`. Default is `null`."
  default     = ""

  validation {
    condition     = var.volume_type == "" ? true : can(regex("^(DataProtection)$", var.volume_type))
    error_message = "The volume_type value must be either DataProtection."
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
    condition     = can(regex("^[a-zA-Z0-9_-]{1,64}$", var.name)) && var.name != "default" && var.name != "bin"
    error_message = "The NetApp Files Volume name must be be 1-64 characters in length and can only contain alphanumeric, hyphens and underscores. The name cannot be `default` or `bin`."
  }
}

variable "zone" {
  type        = number
  description = "(Optional) The number of the availability zone where the volume should be created. Possible values are `1`, `2`, `3` or `null`. Default is `null`."
  default     = null

  validation {
    condition     = var.zone == null || can(regex("^(1|2|3)$", var.zone))
    error_message = "The NetApp Files Volume zone must be either 1, 2, 3 or `null`."
  }
}
