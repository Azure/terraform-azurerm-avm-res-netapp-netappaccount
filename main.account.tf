

resource "azapi_resource" "anf-account" {
  type = "Microsoft.NetApp/netAppAccounts@2024-07-01"
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
          userAssignedIdentity = var.customer_managed_key.user_assigned_identity.resource_id
        }
        keySource = var.customer_managed_key.key_source
        keyVaultProperties = {
          keyVaultUri        = local.cmk_key_vault_uri
          keyVaultResourceId = var.customer_managed_key.key_vault_resource_id
          keyVaultKeyName    = var.customer_managed_key.key_name
        }
        } : {
        identity           = null
        keySource          = "Microsoft.NetApp"
        keyVaultProperties = null
      }
    }
  }
  location  = var.location
  name      = var.name
  parent_id = provider::azapi::subscription_resource_id(local.subscription_id, "Microsoft.Resources/resourceGroups", [var.resource_group_name])
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
}

resource "azapi_resource" "anf-account-lock" {
  count = var.lock != null ? 1 : 0

  type = "Microsoft.Authorization/locks@2020-05-01"
  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }
  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.anf-account.id
}
