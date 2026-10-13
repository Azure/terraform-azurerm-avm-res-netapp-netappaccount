resource "azapi_resource" "name" {
  for_each = var.role_assignments

  name      = each.value.name != null ? each.value.name : local.role_definition_id_principal_and_definition_uuidv5[each.key] == null ? null : uuidv5("oid", local.role_definition_id_principal_and_definition_uuidv5[each.key])
  parent_id = azapi_resource.anf_account.id
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  body = {
    properties = {
      principalId                        = each.value.principal_id
      roleDefinitionId                   = local.role_definition_resource_ids[each.key]
      description                        = each.value.description
      principalType                      = each.value.principal_type
      condition                          = each.value.condition
      conditionVersion                   = each.value.condition_version
      delegatedManagedIdentityResourceId = each.value.delegated_managed_identity_resource_id
    }

  }

  lifecycle {
    precondition {
      condition     = local.role_definition_resource_ids[each.key] != null
      error_message = "Each `role_assignments[*].role_definition_id_or_name` must be a role definition GUID or resource ID, or an available role name with `role_assignment_definition_lookup_enabled` enabled."
    }
  }
}
