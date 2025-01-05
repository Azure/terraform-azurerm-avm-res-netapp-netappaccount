resource "azapi_resource" "anf-backup-policy" {

  type      = "Microsoft.NetApp/netAppAccounts/backupPolicies@2024-07-01"
  parent_id = var.account.resource_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      enabled              = var.enabled
      dailyBackupsToKeep   = var.daily_backups_to_keep
      weeklyBackupsToKeep  = var.weekly_backups_to_keep
      monthlyBackupsToKeep = var.monthly_backups_to_keep
    }
  }

  schema_validation_enabled = false
}
