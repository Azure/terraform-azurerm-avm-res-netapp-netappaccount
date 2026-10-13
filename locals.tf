locals {
  cmk_key_vault_uri        = var.customer_managed_key == null ? null : data.azapi_resource.customer_managed_key_vault[0].output.properties.vaultUri
  cmk_identity_resource_id = var.customer_managed_key == null ? null : try(var.customer_managed_key.user_assigned_identity.resource_id, null)
  role_definition_ids_by_name = var.role_assignment_definition_lookup_enabled && length(var.role_assignments) > 0 ? {
    for definition in data.azapi_resource_list.role_definitions[0].output.results : definition.role_name => definition.id
  } : {}
  role_definition_resource_ids = {
    for k, v in var.role_assignments : k => v.role_definition_id_or_name == null ? null : (
      can(provider::azapi::parse_resource_id("Microsoft.Authorization/roleDefinitions", v.role_definition_id_or_name)) ? v.role_definition_id_or_name :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", v.role_definition_id_or_name)) ?
      provider::azapi::subscription_resource_id(local.subscription_id, "Microsoft.Authorization/roleDefinitions", [v.role_definition_id_or_name]) :
      lookup(local.role_definition_ids_by_name, v.role_definition_id_or_name, null)
    )
  }
  role_definition_id_principal_and_definition_uuidv5 = {
    for k, v in var.role_assignments : k => (
      local.role_definition_resource_ids[k] == null ? null :
      uuidv5(v.principal_id, provider::azapi::parse_resource_id("Microsoft.Authorization/roleDefinitions", local.role_definition_resource_ids[k]).name)
    )
  }
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
