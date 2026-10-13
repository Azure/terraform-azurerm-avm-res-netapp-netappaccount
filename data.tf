data "azapi_client_config" "this" {}

data "azapi_resource" "customer_managed_key_vault" {
  count = var.customer_managed_key == null ? 0 : 1

  resource_id            = var.customer_managed_key.key_vault_resource_id
  type                   = "Microsoft.KeyVault/vaults@2023-07-01"
  response_export_values = ["properties.vaultUri"]
}

data "azapi_resource_list" "role_definitions" {
  count = var.role_assignment_definition_lookup_enabled && length(var.role_assignments) > 0 ? 1 : 0

  parent_id = "/subscriptions/${local.subscription_id}"
  type      = "Microsoft.Authorization/roleDefinitions@2022-04-01"
  response_export_values = {
    results = "value[].{id: id, role_name: properties.roleName}"
  }
}
