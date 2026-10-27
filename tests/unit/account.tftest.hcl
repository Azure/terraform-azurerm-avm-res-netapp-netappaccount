mock_provider "azapi" {
  alias = "mocked"

  mock_data "azapi_client_config" {
    defaults = {
      subscription_id          = "00000000-0000-0000-0000-000000000000"
      tenant_id                = "00000000-0000-0000-0000-000000000001"
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }

  mock_data "azapi_resource" {
    defaults = {
      output = {
        properties = {
          vaultUri = "https://netapp-test.vault.usgovcloudapi.net/"
        }
      }
    }
  }

  mock_data "azapi_resource_list" {
    defaults = {
      output = {
        results = [{
          id        = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
          role_name = "Reader"
        }]
      }
    }
  }

  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.NetApp/netAppAccounts/netapp-test"
    }
  }
}

mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  name                 = "netapp-test"
  location             = "usgovvirginia"
  resource_group_name  = "netapp-test"
  enable_telemetry     = false
  customer_managed_key = null
}

run "netapp_managed_encryption" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }

  assert {
    condition     = azapi_resource.anf_account.body.properties.encryption.keySource == "Microsoft.NetApp"
    error_message = "The default must retain NetApp-managed encryption."
  }
  assert {
    condition     = length(data.azapi_resource.customer_managed_key_vault) == 0
    error_message = "Default encryption must not read a Key Vault."
  }
  assert {
    condition     = length(data.azapi_resource_list.role_definitions) == 0
    error_message = "Default configuration must not read role definitions."
  }
  assert {
    condition     = output.resource_id == azapi_resource.anf_account.id && length(azapi_resource.telemetry) == 0
    error_message = "The account output and telemetry opt-out must remain unchanged."
  }
}

run "customer_managed_encryption" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }
  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"
      key_name              = "netapp-key"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"]
    }
  }

  assert {
    condition     = azapi_resource.anf_account.body.properties.encryption.keySource == "Microsoft.KeyVault"
    error_message = "Customer-managed encryption must select Microsoft.KeyVault without a key_source override."
  }
  assert {
    condition     = azapi_resource.anf_account.body.properties.encryption.keyVaultProperties.keyName == "netapp-key"
    error_message = "The request must use the NetApp API's keyName property."
  }
  assert {
    condition     = azapi_resource.anf_account.body.properties.encryption.keyVaultProperties.keyVaultUri == "https://netapp-test.vault.usgovcloudapi.net/"
    error_message = "The vault URI must come from the vault, not a public-cloud DNS suffix."
  }
  assert {
    condition     = azapi_resource.anf_account.body.properties.encryption.identity.userAssignedIdentity == var.customer_managed_key.user_assigned_identity.resource_id
    error_message = "The configured encryption identity must reach the account body."
  }
}

run "rejects_invalid_key_vault_resource_id" {
  command = plan
  providers = {
    azapi = azapi.mocked
  }
  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"
      key_name              = "netapp-key"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"]
    }
  }
  expect_failures = [var.customer_managed_key]
}

run "rejects_invalid_encryption_identity_resource_id" {
  command = plan
  providers = {
    azapi = azapi.mocked
  }
  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"
      key_name              = "netapp-key"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"]
    }
  }
  expect_failures = [var.customer_managed_key]
}

run "requires_encryption_identity" {
  command = plan
  providers = {
    azapi = azapi.mocked


  }
  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"
      key_name              = "netapp-key"
    }
  }
  expect_failures = [azapi_resource.anf_account]
}

run "requires_assigned_encryption_identity" {
  command = plan
  providers = {
    azapi = azapi.mocked


  }
  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"
      key_name              = "netapp-key"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"
      }
    }
  }
  expect_failures = [azapi_resource.anf_account]
}

run "rejects_unsupported_key_version" {
  command = plan
  providers = {
    azapi = azapi.mocked


  }
  variables {
    customer_managed_key = {
      key_vault_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/netapp-test"
      key_name              = "netapp-key"
      key_version           = "pinned-version"
      user_assigned_identity = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"
      }
    }
    managed_identities = {
      user_assigned_resource_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/netapp-test"]
    }
  }
  expect_failures = [azapi_resource.anf_account]
}

run "preserves_role_assignment_address_and_name" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignments = {
      reader = {
        role_definition_id_or_name = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
        principal_id               = "00000000-0000-0000-0000-000000000002"
        principal_type             = "ServicePrincipal"
      }
    }
  }

  assert {
    condition     = azapi_resource.name["reader"].name == uuidv5("oid", uuidv5("00000000-0000-0000-0000-000000000002", "acdd72a7-3385-48ef-bd42-f606fba81ae7"))
    error_message = "Renaming the role field must preserve existing resource keys and assignment UUIDs."
  }
  assert {
    condition     = length(data.azapi_resource_list.role_definitions) == 0
    error_message = "Existing GUID callers must not gain a role-definition read requirement."
  }
  assert {
    condition     = azapi_resource.name["reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    error_message = "Existing role-definition GUIDs must retain their subscription scope."
  }
}

run "resolves_role_name" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignment_definition_lookup_enabled = true
    role_assignments = {
      reader = {
        role_definition_id_or_name = "Reader"
        principal_id               = "00000000-0000-0000-0000-000000000002"
      }
    }
  }

  assert {
    condition     = azapi_resource.name["reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    error_message = "Role names must resolve to their role definition resource IDs."
  }
  assert {
    condition     = azapi_resource.name["reader"].name == uuidv5("oid", uuidv5("00000000-0000-0000-0000-000000000002", "acdd72a7-3385-48ef-bd42-f606fba81ae7"))
    error_message = "Using the equivalent role name must retain the GUID-based assignment UUID."
  }
  assert {
    condition     = azapi_resource.name["reader"].body.properties.principalType == null
    error_message = "Omitted principal types must remain optional."
  }
}

run "accepts_role_definition_resource_id" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignments = {
      reader = {
        role_definition_id_or_name = "/subscriptions/00000000-0000-0000-0000-000000000001/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
        principal_id               = "00000000-0000-0000-0000-000000000002"
      }
    }
  }

  assert {
    condition     = azapi_resource.name["reader"].body.properties.roleDefinitionId == var.role_assignments.reader.role_definition_id_or_name
    error_message = "Fully qualified role IDs must preserve their supplied scope."
  }
  assert {
    condition     = azapi_resource.name["reader"].name == uuidv5("oid", uuidv5("00000000-0000-0000-0000-000000000002", "acdd72a7-3385-48ef-bd42-f606fba81ae7"))
    error_message = "Fully qualified role IDs must retain the GUID-based assignment UUID."
  }
}

run "honors_role_assignment_overrides" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignment_definition_lookup_enabled = true
    role_assignments = {
      reader = {
        name                                   = "00000000-0000-0000-0000-000000000003"
        role_definition_id_or_name             = "Reader"
        principal_id                           = "00000000-0000-0000-0000-000000000002"
        principal_type                         = "ServicePrincipal"
        description                            = "Restricted reader"
        skip_service_principal_aad_check       = true
        condition                              = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEquals 'example'"
        condition_version                      = "2.0"
        delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/delegated"
      }
    }
  }

  assert {
    condition     = azapi_resource.name["reader"].name == var.role_assignments.reader.name
    error_message = "An explicit assignment name must override the deterministic default."
  }
  assert {
    condition = (
      azapi_resource.name["reader"].body.properties.description == var.role_assignments.reader.description &&
      azapi_resource.name["reader"].body.properties.principalType == var.role_assignments.reader.principal_type &&
      azapi_resource.name["reader"].body.properties.condition == var.role_assignments.reader.condition &&
      azapi_resource.name["reader"].body.properties.conditionVersion == var.role_assignments.reader.condition_version &&
      azapi_resource.name["reader"].body.properties.delegatedManagedIdentityResourceId == var.role_assignments.reader.delegated_managed_identity_resource_id
    )
    error_message = "Role assignment metadata must reach the ARM request unchanged."
  }
}

run "rejects_unresolved_role_name" {
  command = plan
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignment_definition_lookup_enabled = true
    role_assignments = {
      missing = {
        role_definition_id_or_name = "Missing role"
        principal_id               = "00000000-0000-0000-0000-000000000002"
      }
    }
  }
  expect_failures = [azapi_resource.name]
}

run "rejects_invalid_delegated_identity" {
  command = plan
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignment_definition_lookup_enabled = true
    role_assignments = {
      reader = {
        role_definition_id_or_name             = "Reader"
        principal_id                           = "00000000-0000-0000-0000-000000000002"
        delegated_managed_identity_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.KeyVault/vaults/not-an-identity"
      }
    }
  }
  expect_failures = [var.role_assignments]
}

run "preserves_uppercase_role_guid" {
  command = apply
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignments = {
      reader = {
        role_definition_id_or_name = "ACDD72A7-3385-48EF-BD42-F606FBA81AE7"
        principal_id               = "00000000-0000-0000-0000-000000000002"
        principal_type             = "ServicePrincipal"
      }
    }
  }

  assert {
    condition     = azapi_resource.name["reader"].name == uuidv5("oid", uuidv5("00000000-0000-0000-0000-000000000002", "ACDD72A7-3385-48EF-BD42-F606FBA81AE7"))
    error_message = "The input rename must preserve assignment UUIDs for uppercase GUID callers."
  }
}

run "requires_lookup_for_role_names" {
  command = plan
  providers = {
    azapi = azapi.mocked


  }
  variables {
    role_assignments = {
      reader = {
        role_definition_id_or_name = "Reader"
        principal_id               = "00000000-0000-0000-0000-000000000002"
      }
    }
  }
  expect_failures = [azapi_resource.name]
}
