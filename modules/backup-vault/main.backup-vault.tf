resource "azapi_resource" "anf-backup-vault" {

  type      = "Microsoft.NetApp/netAppAccounts/backupVaults@2024-07-01"
  parent_id = var.account.resource_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  schema_validation_enabled = false
}
