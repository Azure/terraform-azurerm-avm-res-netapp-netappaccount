data "azapi_client_config" "this" {}

data "azapi_resource" "customer_managed_key_vault" {
  count = var.customer_managed_key == null ? 0 : 1

  resource_id            = var.customer_managed_key.key_vault_resource_id
  type                   = "Microsoft.KeyVault/vaults@2023-07-01"
  response_export_values = ["properties.vaultUri"]
}
