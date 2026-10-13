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

  mock_resource "azapi_resource" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/netapp-test/providers/Microsoft.NetApp/netAppAccounts/netapp-test"
    }
  }
}

mock_provider "modtm" {
  alias = "mocked"
}

mock_provider "random" {
  alias = "mocked"
}

variables {
  name                = "netapp-test"
  location            = "usgovvirginia"
  resource_group_name = "netapp-test"
  enable_telemetry    = false
}

run "netapp_managed_encryption" {
  command = apply
  providers = {
    azapi  = azapi.mocked
    modtm  = modtm.mocked
    random = random.mocked
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
    condition     = output.resource_id == azapi_resource.anf_account.id && length(modtm_telemetry.telemetry) == 0
    error_message = "The account output and telemetry opt-out must remain unchanged."
  }
}

run "customer_managed_encryption" {
  command = apply
  providers = {
    azapi  = azapi.mocked
    modtm  = modtm.mocked
    random = random.mocked
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

run "requires_encryption_identity" {
  command = plan
  providers = {
    azapi  = azapi.mocked
    modtm  = modtm.mocked
    random = random.mocked
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
    azapi  = azapi.mocked
    modtm  = modtm.mocked
    random = random.mocked
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
    azapi  = azapi.mocked
    modtm  = modtm.mocked
    random = random.mocked
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
    azapi  = azapi.mocked
    modtm  = modtm.mocked
    random = random.mocked
  }
  variables {
    role_assignments = {
      reader = {
        role_definition_id = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
        principal_id       = "00000000-0000-0000-0000-000000000002"
        principal_type     = "ServicePrincipal"
      }
    }
  }

  assert {
    condition     = azapi_resource.name["reader"].name == uuidv5("oid", uuidv5("00000000-0000-0000-0000-000000000002", "acdd72a7-3385-48ef-bd42-f606fba81ae7"))
    error_message = "Existing role inputs, resource keys and assignment UUIDs must remain unchanged."
  }
  assert {
    condition     = azapi_resource.name["reader"].body.properties.roleDefinitionId == "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
    error_message = "Existing role-definition GUIDs must retain their subscription scope."
  }
}
