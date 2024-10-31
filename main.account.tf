

resource "azapi_resource" "anf-account" {
  type      = "Microsoft.NetApp/netAppAccounts@2024-03-01"
  name      = var.name
  location  = var.location
  parent_id = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
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

      # activeDirectories = []
      # encryption = {}
    }
  }
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
