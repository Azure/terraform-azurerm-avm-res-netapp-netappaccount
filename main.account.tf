

resource "azapi_resource" "anf-account" {
  type      = "Microsoft.NetApp/netAppAccounts@2024-07-01"
  name      = var.name
  location  = var.location
  parent_id = provider::azapi::subscription_resource_id(local.subscription_id, "Microsoft.Resources/resourceGroups", [var.resource_group_name])
  tags      = var.tags

  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned
    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  body = {
    properties = {
      activeDirectories = var.active_directories != null ? [
        for ad in var.active_directories : {
          username      = ad.adds_admin_user_name
          password      = ad.adds_admin_password
          domain        = ad.adds_domain
          dns           = ad.dns_servers
          site          = ad.adds_site_name
          smbServerName = ad.smb_server_name
        }
      ] : null
      # encryption = {}
    }
  }
  retry = {
    error_message_regex = ["CannotDeleteResource"]
  }

  schema_validation_enabled = false
}

resource "azapi_resource" "anf-account-lock" {
  count     = var.lock != null ? 1 : 0
  type      = "Microsoft.Authorization/locks@2020-05-01"
  name      = coalesce(var.lock.name, "lock-${var.lock.kind}")
  parent_id = azapi_resource.anf-account.id

  body = {
    properties = {
      level = var.lock.kind
      notes = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
    }
  }

}
