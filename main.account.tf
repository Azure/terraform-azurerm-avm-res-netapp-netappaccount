resource "azapi_resource" "anf_account" {
  location  = var.location
  name      = var.name
  parent_id = provider::azapi::subscription_resource_id(local.subscription_id, "Microsoft.Resources/resourceGroups", [var.resource_group_name])
  type      = "Microsoft.NetApp/netAppAccounts@2024-07-01"
  body = {
    properties = {
      activeDirectories = var.active_directories != null ? [
        for ad in var.active_directories : {
          username                = ad.adds_admin_user_name
          password                = ad.adds_admin_password
          domain                  = ad.adds_domain
          dns                     = join(",", ad.dns_servers)
          site                    = ad.adds_site_name
          smbServerName           = ad.smb_server_name
          organizationalUnit      = ad.adds_ou
          administrators          = ad.administrators
          backupOperators         = ad.backup_operators
          securityOperators       = ad.security_operators
          serverRootCACertificate = ad.server_root_ca_certificate
          adName                  = ad.kerberos_ad_server_name
          kdcIP                   = ad.kerberos_kdc_ip
          ldapSearchScope = ad.ldap_search_scope != null ? {
            userDN                = ad.ldap_search_scope.user_dn
            groupDN               = ad.ldap_search_scope.group_dn
            groupMembershipFilter = ad.ldap_search_scope.group_membership_filter
          } : {}
          allowLocalNfsUsersWithLdap = ad.local_nfs_users_with_ldap_allowed
          aesEncryption              = ad.aes_encryption_enabled
          ldapOverTLS                = ad.ldap_over_tls_enabled
          ldapSigning                = ad.ldap_signing_enabled
        }
      ] : null

      encryption = var.customer_managed_key != null ? {
        identity = {
          userAssignedIdentity = local.cmk_identity_resource_id
        }
        keySource = "Microsoft.KeyVault"
        keyVaultProperties = {
          keyVaultUri        = local.cmk_key_vault_uri
          keyVaultResourceId = var.customer_managed_key.key_vault_resource_id
          keyName            = var.customer_managed_key.key_name
        }
        } : {
        identity           = null
        keySource          = "Microsoft.NetApp"
        keyVaultProperties = null
      }
    }
  }
  retry = {
    error_message_regex = ["CannotDeleteResource"]
  }
  schema_validation_enabled = false
  tags                      = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  lifecycle {
    precondition {
      condition     = var.customer_managed_key == null || local.cmk_identity_resource_id != null
      error_message = "`customer_managed_key.user_assigned_identity.resource_id` is required for NetApp customer-managed encryption."
    }
    precondition {
      condition     = local.cmk_identity_resource_id == null ? true : contains(var.managed_identities.user_assigned_resource_ids, local.cmk_identity_resource_id)
      error_message = "The encryption identity must also be assigned through `managed_identities.user_assigned_resource_ids`."
    }
    precondition {
      condition     = var.customer_managed_key == null ? true : var.customer_managed_key.key_version == null
      error_message = "NetApp accepts a key name rather than a pinned version; omit `customer_managed_key.key_version`."
    }
  }
}

resource "azapi_resource" "anf_account_lock" {
  count = var.lock != null ? 1 : 0

  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.anf_account.id
  type      = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
}
