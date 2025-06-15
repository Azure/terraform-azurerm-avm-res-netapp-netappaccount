resource "azapi_resource" "anf_backup_vault" {
  location                  = var.location
  name                      = var.name
  parent_id                 = var.account.resource_id
  type                      = "Microsoft.NetApp/netAppAccounts/backupVaults@2024-07-01"
  schema_validation_enabled = false
  tags                      = var.tags
}
