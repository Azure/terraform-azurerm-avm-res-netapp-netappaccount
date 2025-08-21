resource "azapi_resource" "name" {
  for_each = var.role_assignments

  name      = uuidv5("oid", local.role_definition_id_principal_and_definition_uuidv5[each.key])
  parent_id = azapi_resource.anf_account.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.principal_id
      roleDefinitionId                   = provider::azapi::subscription_resource_id(local.subscription_id, "Microsoft.Authorization/roleDefinitions", [each.value.role_definition_id])
      description                        = each.value.description
      principalType                      = each.value.principal_type
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition_version
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
}

