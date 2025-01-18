resource "azapi_resource" "anf-backup-vault" {
  type                      = "Microsoft.NetApp/netAppAccounts/backupVaults@2024-07-01"
  location                  = var.location
  name                      = var.name
  parent_id                 = var.account.resource_id
  schema_validation_enabled = false
  tags                      = var.tags
}
