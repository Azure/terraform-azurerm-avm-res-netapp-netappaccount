resource "azapi_resource" "anf_backup_policy" {
  type = "Microsoft.NetApp/netAppAccounts/backupPolicies@2024-07-01"
  body = {
    properties = {
      enabled              = var.enabled
      dailyBackupsToKeep   = var.daily_backups_to_keep
      weeklyBackupsToKeep  = var.weekly_backups_to_keep
      monthlyBackupsToKeep = var.monthly_backups_to_keep
    }
  }
  location                  = var.location
  name                      = var.name
  parent_id                 = var.account.resource_id
  schema_validation_enabled = false
  tags                      = var.tags
}
