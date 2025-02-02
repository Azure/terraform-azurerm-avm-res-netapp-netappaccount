locals {
  cmk_key_vault_uri = var.customer_managed_key != null ? concat("https://", split("/", var.customer_managed_key.key_vault_resource_id)[8], ".vault.azure.net") : null
  role_definition_id_principal_and_definition_uuidv5 = var.role_assignments != null ? {
    for k, v in var.role_assignments : k => uuidv5(v.principal_id, v.role_definition_id)
  } : {}
  subscription_id = coalesce(var.subscription_id, data.azapi_client_config.this.subscription_id)
}

locals {
  managed_identities = {
    system_assigned_user_assigned = (var.managed_identities.system_assigned || length(var.managed_identities.user_assigned_resource_ids) > 0) ? {
      this = {
        type                       = var.managed_identities.system_assigned && length(var.managed_identities.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(var.managed_identities.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
    system_assigned = var.managed_identities.system_assigned ? {
      this = {
        type = "SystemAssigned"
      }
    } : {}
    user_assigned = length(var.managed_identities.user_assigned_resource_ids) > 0 ? {
      this = {
        type                       = "UserAssigned"
        user_assigned_resource_ids = var.managed_identities.user_assigned_resource_ids
      }
    } : {}
  }
}
