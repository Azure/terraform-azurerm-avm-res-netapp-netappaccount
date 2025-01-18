module "backup-policies" {
  source = "./modules/backup-policy"

  for_each = var.backup_policies

  account  = { resource_id = azapi_resource.anf_account.id }
  location = var.location

  name = each.value.name
  tags = each.value.tags == null ? var.inherit_tags_from_parent_resource == true ? var.tags : null : each.value.tags

  enabled                 = each.value.enabled
  daily_backups_to_keep   = each.value.daily_backups_to_keep
  weekly_backups_to_keep  = each.value.weekly_backups_to_keep
  monthly_backups_to_keep = each.value.monthly_backups_to_keep
  enable_telemetry        = var.enable_telemetry
}
