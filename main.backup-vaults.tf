module "backup_vaults" {
  source   = "./modules/backup-vault"
  for_each = var.backup_vaults

  account          = { resource_id = azapi_resource.anf_account.id }
  location         = var.location
  name             = each.value.name
  enable_telemetry = var.enable_telemetry
  tags             = each.value.tags == null ? var.inherit_tags_from_parent_resource == true ? var.tags : null : each.value.tags
}
