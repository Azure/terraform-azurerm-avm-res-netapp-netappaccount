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
  description = "(Optional) Subscription ID passed in by an external process.  If this is not supplied, then the configuration either needs to include the subscription ID, or needs to be supplied properties to create the subscription."
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
    name            = optional(string)
    cool_access     = optional(bool, false)
    encryption_type = optional(string, "Single")
    size            = optional(number)
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
(Optional) A map of Active Directory connections to create on the ANF Account.

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
(Optional) A map of backup vaults to create on the ANF Account.

DESCRIPTION
}
