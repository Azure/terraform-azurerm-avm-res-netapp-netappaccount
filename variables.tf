variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the this resource."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,128}$", var.name))
    error_message = "The NetApp Files Account name must be be 1-128 characters in length and can only contain alphanumeric, hyphens and underscores." #
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "subscription_id" {
  type        = string
  default     = null
  description = "(Optional) Subscription ID passed in by an external process. If this is not supplied, then the configuration either needs to include the subscription ID, or needs to be supplied properties to create the subscription."
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.
DESCRIPTION  
  nullable    = false

  validation {
    condition     = alltrue([for _, v in var.diagnostic_settings : contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
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

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

# tflint-ignore: terraform_unused_declarations
variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  default     = {}
  description = <<DESCRIPTION
Controls the Managed Identity configuration on this resource. The following properties can be specified:

- `system_assigned` - (Optional) Specifies if the System Assigned Managed Identity should be enabled.
- `user_assigned_resource_ids` - (Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource.
DESCRIPTION
  nullable    = false
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

# Capacity Pools
variable "capacity_pools" {
  type = map(object({
    name            = string
    cool_access     = optional(bool, false)
    encryption_type = optional(string, "Single")
    size            = number
    qos_type        = optional(string, "Auto")
    service_level   = optional(string)
    tags            = optional(map(string), null)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })))
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of capacity pools to create

- `cool_access` - (Optional) Specifies whether the volume is cool access enabled. Default is false.
- `encryption_type` - (Optional) Specifies the encryption type of the volume.
- `size` - (Optional) Specifies the size of the volume. Default is 4 TiB (4398046511104 bytes).
- `qos_type` - (Optional) Specifies the QoS type of the volume. Default is 'Auto'
- `service_level` - (Optional) Specifies the service level of the volume. Default is 'Premium'
- `tags` - (Optional) Tags of the resource.
- `timeouts` - (Optional) A `timeouts` block that allows you to specify timeouts for certain actions:
  - `create` - (Defaults to 30 minutes) Used when creating the Capacity Pool.
  - `delete` - (Defaults to 30 minutes) Used when deleting the Capacity Pool.
  - `read` - (Defaults to 5 minutes) Used when retrieving the Capacity Pool.
  - `update` - (Defaults to 30 minutes) Used when updating the Capacity Pool.
- `role_assignments` - (Optional) A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time. 
DESCRIPTION

  validation {
    condition     = alltrue([for _, pool in var.capacity_pools : pool.size != null && pool.service_level != null])
    error_message = "The size and service_level must be set for all capacity pools."
  }
}

variable "active_directories" {
  type = map(object({
    adds_domain                       = string
    dns_servers                       = set(string)
    adds_site_name                    = string
    adds_admin_user_name              = string
    adds_admin_password               = string
    smb_server_name                   = string
    adds_ou                           = optional(string, "CN=Computers")
    kerberos_ad_server_name           = optional(string)
    kerberos_kdc_ip                   = optional(string)
    aes_encryption_enabled            = optional(bool, false)
    local_nfs_users_with_ldap_allowed = optional(bool, false)
    ldap_over_tls_enabled             = optional(bool, false)
    server_root_ca_certificate        = optional(string)
    ldap_signing_enabled              = optional(bool, false)
    administrators                    = optional(set(string))
    backup_operators                  = optional(set(string))
    security_operators                = optional(set(string))
    ldap_search_scope = optional(object({
      user_dn                 = string
      group_dn                = string
      group_membership_filter = optional(string)
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of Active Directory connections to create on the Azure Netapp Files Account.

The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `adds_domain` - The Active Directory Domain Services domain name.
- `dns_servers` - The DNS servers to use to resolve the Active Directory Domain Services domain.
- `adds_site_name` - The Active Directory site the service will limit Domain Controller discovery to.
- `adds_admin_user_name` - The Active Directory Domain Services domain admin user name. Can be any user with sufficient permissions as per: https://learn.microsoft.com/azure/azure-netapp-files/create-active-directory-connections#requirements-for-active-directory-connections.
- `adds_admin_password` - The Active Directory Domain Services domain admin password.
- `smb_server_name` - NetBIOS name of the SMB server. This name will be registered as a computer account in the AD and used to mount volumes.
- `adds_ou` - (Optional) LDAP Path for the Organization Unit where SMB Server machine accounts will be created (i.e. OU=SecondLevel,OU=FirstLevel). Default is `CN=Computers`.
- `kerberos_ad_server_name` - (Optional) The name of the server that will be used for Kerberos authentication.
- `kerberos_kdc_ip` - (Optional) The IP address of the Key Distribution Center for Kerberos authentication.
- `aes_encryption_enabled` - (Optional) If enabled, AES encryption will be enabled for SMB communication. Default is `false`.
- `local_nfs_users_with_ldap_allowed` - (Optional) If enabled, NFS client local users can also (in addition to LDAP users) access the NFS volumes. Default is `false`.
- `ldap_over_tls_enabled` - (Optional) Specifies whether or not the LDAP traffic needs to be secured via TLS. Default is `false`.
- `server_root_ca_certificate` - (Optional) When LDAP over SSL/TLS is enabled, the LDAP client is required to have base64 encoded Active Directory Certificate Service's self-signed root CA certificate, this optional parameter is used only for dual protocol with LDAP user-mapping volumes.
- `ldap_signing_enabled` - (Optional) Specifies whether or not the LDAP traffic needs to be signed. Default is `false`.
- `administrators` - (Optional) This option grants additional security privileges to AD DS domain users or groups that require elevated privileges to access the Azure NetApp Files volumes. The specified accounts will have elevated permissions at the file or folder level.
- `backup_operators` - (Optional) This option grants addition security privileges to AD DS domain users or groups that require elevated backup privileges to support backup, restore, and migration workflows in Azure NetApp Files. The specified AD DS user accounts or groups will have elevated NTFS permissions at the file or folder level.
- `security_operators` - (Optional) This option grants security privilege (SeSecurityPrivilege) to AD DS domain users or groups that require elevated privileges to access Azure NetApp Files volumes. The specified AD DS users or groups will be allowed to perform certain actions on SMB shares that require security privilege not assigned by default to domain users.
- `ldap_search_scope` - (Optional) The LDAP search scope option optimizes Azure NetApp Files storage LDAP queries for use with large AD DS topologies and LDAP with extended groups or Unix security style with an Azure NetApp Files dual-protocol volume. The following properties can be specified:
  - `user_dn` - This specifies the user DN, which overrides the base DN for user lookups.
  - `group_dn` - This specifies the group DN, which overrides the base DN for group lookups.
  - `group_membership_filter` - (Optional) This specifies the custom LDAP search filter to be used when looking up group membership from LDAP server

DESCRIPTION
}

variable "backup_vaults" {
  type = map(object({
    name = string
    tags = optional(map(string), null)

  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of backup vaults to create on the Azure Netapp Files Account.

The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - The name of the backup vault.
- `tags` - (Optional) Tags of the resource.

DESCRIPTION
}

variable "backup_policies" {
  type = map(object({
    name                    = string
    tags                    = optional(map(string), null)
    enabled                 = optional(bool, true)
    daily_backups_to_keep   = optional(number, 2)
    weekly_backups_to_keep  = optional(number, 1)
    monthly_backups_to_keep = optional(number, 1)
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of backup policies to create on the Azure Netapp Files Account.

The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - The name of the backup policy.
- `tags` - (Optional) Tags of the resource.
- `enabled` - (Optional) Whether the backup policy is enabled. Defaults to `true`.
- `daily_backups_to_keep` - (Optional) The number of daily backups to keep. Defaults to `2`.
- `weekly_backups_to_keep` - (Optional) The number of weekly backups to keep. Defaults to `1`.
- `monthly_backups_to_keep` - (Optional) The number of monthly backups to keep. Defaults to `1`.

DESCRIPTION
}

variable "snapshot_policies" {
  type = map(object({
    name    = string
    tags    = optional(map(string), null)
    enabled = optional(bool, true)
    hourly_schedule = optional(object({
      snapshots_to_keep = number
      minute            = number
    }))
    daily_schedule = optional(object({
      snapshots_to_keep = number
      hour              = number
      minute            = number
    }))
    weekly_schedule = optional(object({
      snapshots_to_keep = number
      day               = set(string)
      minute            = number
      hour              = number
    }))
    monthly_schedule = optional(object({
      snapshots_to_keep = number
      days_of_month     = set(number)
      hour              = number
      minute            = number
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
(Optional) A map of snapshot policies to create on the Azure Netapp Files Account.

The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - The name of the snapshot policy.
- `tags` - (Optional) Tags of the resource.
- `enabled` - (Optional) Whether the snapshot policy is enabled. Defaults to `true`.
- `hourly_schedule` - (Optional) The hourly schedule for the snapshot policy. The following properties can be specified:
  - `snapshots_to_keep` - The number of snapshots to keep. Must be between 0 and 255.
  - `minute` - The minute of the hour to take the snapshot. Must be between 0 and 59.
- `daily_schedule` - (Optional) The daily schedule for the snapshot policy. The following properties can be specified:
  - `snapshots_to_keep` - The number of snapshots to keep. Must be between 0 and 255.
  - `hour` - The hour of the day to take the snapshot. Must be between 0 and 23.
  - `minute` - The minute of the hour to take the snapshot. Must be between 0 and 59.
- `weekly_schedule` - (Optional) The weekly schedule for the snapshot policy. The following properties can be specified:
  - `snapshots_to_keep` - The number of snapshots to keep. Must be between 0 and 255.
  - `day` - A list of the days of the week to take the snapshot. Must use the following in the list: `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`.
  - `hour` - The hour of the day to take the snapshot. Must be between 0 and 23.
  - `minute` - The minute of the hour to take the snapshot. Must be between 0 and 59.
- `monthly_schedule` - (Optional) The monthly schedule for the snapshot policy. The following properties can be specified:
  - `snapshots_to_keep` - The number of snapshots to keep. Must be between 0 and 255.
  - `days_of_month` - A list of the days of the month to take the snapshot. Must be between 1 and 31.
  - `hour` - The hour of the day to take the snapshot. Must be between 0 and 23.
  - `minute` - The minute of the hour to take the snapshot. Must be between 0 and 59.

DESCRIPTION
}

variable "volumes" {
  type = map(object({
    name                         = string
    capacity_pool_map_key        = string
    subnet_resource_id           = string
    tags                         = optional(map(string))
    avs_data_store               = optional(bool)
    backup_policy_map_key        = optional(string)
    backup_vault_map_key         = optional(string)
    backup_policy_enforced       = optional(bool)
    cool_access                  = optional(bool, false)
    cool_access_retrieval_policy = optional(string)
    coolness_period              = optional(number)
    creation_token               = optional(string)
    default_quota_enabled        = optional(bool, false)
    default_group_quota_in_kibs  = optional(number, 0)
    default_user_quota_in_kibs   = optional(number, 0)
    delete_base_snapshot         = optional(bool)
    enable_sub_volumes           = optional(bool)
    encryption_key_source        = optional(string, "Microsoft.NetApp")
    export_policy_rules = optional(map(object({
      rule_index      = number
      allowed_clients = list(string)
      chown_mode      = optional(string)
      cifs            = optional(bool)
      nfsv3          = optional(bool)
      nfsv41         = optional(bool)
      has_root_access = optional(bool)
      kerberos5i_ro   = optional(bool)
      kerberos5i_rw   = optional(bool)
      kerberos5p_ro   = optional(bool)
      kerberos5p_rw   = optional(bool)
      kerberos5_ro    = optional(bool)
      kerberos5_rw    = optional(bool)
      unix_ro         = optional(bool)
      unix_rw         = optional(bool)
    })))
    key_vault_private_endpoint_resource_id = optional(string)
    encryption_type                        = optional(string, "Single")
    is_large_volume                        = optional(bool, false)
    kerberos_enabled                       = optional(bool, false)
    ldap_enabled                           = optional(bool, false)
    network_features                       = optional(string, "Standard")
    protocol_types                        = optional(set(string), ["NFSv3"])
    proximity_placement_group_resource_id = optional(string)
    security_style                        = optional(string)
    service_level                         = optional(string, "Standard")
    smb_access_based_enumeration_enabled  = optional(bool)
    smb_continuously_available            = optional(bool, false)
    smb_encryption                        = optional(bool, false)
    smb_non_browsable                     = optional(bool)
    snapshot_directory_visible            = optional(bool, true)
    snapshot_policy_map_key               = optional(string)
    throughput_mibps                      = optional(number)
    unix_permissions                      = optional(string, "0770")
    volume_size_in_gib                    = optional(number, 50)
    volume_spec_name                      = optional(string)
    volume_type                           = optional(string, "")
    zone                                  = optional(number)
  }))
  default = {}

  description = <<DESCRIPTION

(Optional) A map of volumes to create in the Azure Netapp Files account capacity pool specified by the `capacity_pool_map_key`. 

> The capacity pool must be specified in the `capacity_pools` variable of this module. If it is not, then please call the volume child module directly to create a volume on a capacity pool managed outside of this module.

> The backup policy must be specified in the `backup_policies` variable of this module. If it is not, then please call the volume child module directly to create a volume with a backup policy managed outside of this module.

> The backup vault must be specified in the `backup_vaults` variable of this module. If it is not, then please call the volume child module directly to create a volume with a backup vault managed outside of this module.

> The snapshot policy must be specified in the `snapshot_policies` variable of this module. If it is not, then please call the volume child module directly to create a volume with a snapshot policy managed outside of this module.

The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - The name of the volume.
- `capacity_pool_map_key` - The key of the capacity pool in the `var.capacity_pools` map to create the volume in.
- `subnet_resource_id` - The Azure Resource ID of the Subnet where the volume should be placed. Subnet must have the delegation `Microsoft.NetApp/volumes`.
- `tags` - (Optional) Tags of the resource.
- `avs_data_store` - (Optional) Specifies if the volume is an AVS data store. Default is `false`.
- `backup_policy_map_key` - (Optional) The key of the backup policy in the `var.backup_policies` map to associate with the volume. Default is `null`.
- `backup_vault_map_key` - (Optional) The key of the backup vault in the `var.backup_vaults` map to associate with the volume. Default is `null`.
- `backup_policy_enforced` - (Optional) Specifies whether the backup policy is enforced for the volume. Default is `false`.
- `cool_access` - (Optional) Specifies whether the volume is cool access enabled. Default is `false`.
- `cool_access_retrieval_policy` - (Optional) determines the data retrieval behavior from the cool tier to standard storage based on the read pattern for cool access enabled volumes. Possible values are `default`, `never`, `onread` or `null`. Default is `null`.
- `coolness_period` - (Optional) Specifies the number of days after which data that is not accessed by clients will be tiered. Values must be between 2 and 183. Default is `null`.
- `creation_token` - (Optional) A unique file path for the volume. Used when creating mount targets. Default is `null` which means the `name` variable value is used in place.
- `default_quota_enabled` - (Optional) Specifies if default quota is enabled for the volume. Default is `false`.
- `default_group_quota_in_kibs` - (Optional) Default group quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `null`.
- `default_user_quota_in_kibs` - (Optional) Default user quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `null`.
- `delete_base_snapshot` - (Optional) If enabled (`true`) the snapshot the volume was created from will be automatically deleted after the volume create operation has finished. Defaults to `false`.
- `enable_sub_volumes` - (Optional) Flag indicating whether subvolume operations are enabled on the volume. Default is `false`.
- `encryption_key_source` - (Optional) Source of key used to encrypt data in volume. Applicable if NetApp account has encryption.keySource = `Microsoft.KeyVault`. Possible values (case-insensitive) are: `Microsoft.NetApp` & `Microsoft.KeyVault`. Default is `Microsoft.NetApp`.
- `export_policy_rules` - (Optional) A map of export policy rules for the volume. Default is `{}`. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `rule_index` - The index (number) of the rule. Must be unique.
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
- `key_vault_private_endpoint_resource_id` - (Optional) The Azure Resource ID of the Private Endpoint to access the required Key Vault. Required if `encryption_key_source` is set to `Microsoft.KeyVault`. Default is `null`. Example: `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/privateEndpoints/pep-kvlt-001`.
- `encryption_type` - (Optional) Specifies the encryption type of the volume. Possible values are `Single` or `Double`. Default is `Single`.
- `is_large_volume` - (Optional) Specifies whether the volume is a large volume. Default is `false`.
- `kerberos_enabled` - (Optional) Specifies whether Kerberos is enabled for the volume. Default is `false`.
- `ldap_enabled` - (Optional) Specifies whether LDAP is enabled for the volume. Default is `false`.
- `network_features` - (Optional) Specifies the network features of the volume Possible values are: `Basic` or `Standard`. Default is `Standard`.
- `protocol_types` - (Optional) The set of protocol types for the volume. Possible values are `NFSv3`, `NFSv4.1`, `CIFS`. Default is `NFSv3`.
- `proximity_placement_group_resource_id` - (Optional) The resource ID of the Proximity Placement Group the volume should be placed in. Default is `null`.
- `security_style` - (Optional) The security style of the volume. Possible values are `ntfs` or `unix`. Defaults to `unix` for NFS volumes or `ntfs` for CIFS and dual protocol volumes via `local.security_style` in module which uses the `var.protocol_types` values to set this value accordingly. Default is `null`.
- `service_level` - (Optional) The service level of the volume. Possible values are `Standard`, `Premium` or `Ultra`. Defaults to `Standard`.
- `smb_access_based_enumeration_enabled` - (Optional) Specifies whether SMB access-based enumeration is enabled. Only support on SMB or dual protocol volumes. Default is `false`.
- `smb_continuously_available` - (Optional) Specifies whether the volume is continuously available. Only supported on SMB volumes. Default is `false`.
- `smb_encryption` - (Optional) Enables encryption for in-flight smb3 data. Only support on SMB or dual protocol volumes. Default is `false`.
- `smb_non_browsable` - (Optional) Enables non-browsable property for SMB Shares. Only support on SMB or dual protocol volumes. Default is `false`.
- `snapshot_directory_visible` - (Optional) If enabled (`true`) the volume will contain a read-only snapshot directory which provides access to each of the volume's snapshots. Default is `true`.
- `snapshot_policy_map_key` - (Optional) The key of the snapshot policy in the `var.snapshot_policies` map to associate with the volume. Default is `null`.
- `throughput_mibps` - (Optional) Maximum throughput in MiB/s that can be achieved by this volume and this will be accepted as input only for manual qosType volume. Default is `null`.
- `unix_permissions` - (Optional) UNIX permissions for NFS volume accepted in octal 4 digit format. First digit selects the set user ID(4), set group ID (2) and sticky (1) attributes. Second digit selects permission for the owner of the file: read (4), write (2) and execute (1). Third selects permissions for other users in the same group. The fourth for other users not in the group. `0755` - gives read/write/execute permissions to owner and read/execute to group and other users. For more information, see https://learn.microsoft.com/azure/azure-netapp-files/configure-unix-permissions-change-ownership-mode and https://wikipedia.org/wiki/File-system_permissions#Numeric_notation. Default is `0770`.
- `volume_size_in_gib` - (Optional) The size of the volume in Gibibytes (GiB). Default is `50` GiB.
- `volume_spec_name` - (Optional) Volume spec name is the application specific designation or identifier for the particular volume in a volume group for e.g. `data`, `log`. Default is `null`.
- `volume_type` - (Optional) What type of volume is this. For destination volumes in Cross Region Replication, set type to `DataProtection`. Default is `null`.
- `zone` - (Optional) The number of the availability zone where the volume should be created. Possible values are `1`, `2`, `3` or `null`. Default is `null`.

DESCRIPTION
}
