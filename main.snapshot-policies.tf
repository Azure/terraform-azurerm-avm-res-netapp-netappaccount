module "snapshot_policies" {
  source   = "./modules/snapshot-policy"
  for_each = var.snapshot_policies

  account          = { resource_id = azapi_resource.anf_account.id }
  location         = var.location
  name             = each.value.name
  daily_schedule   = each.value.daily_schedule
  enable_telemetry = var.enable_telemetry
  enabled          = each.value.enabled
  hourly_schedule  = each.value.hourly_schedule
  monthly_schedule = each.value.monthly_schedule
  tags             = each.value.tags == null ? var.inherit_tags_from_parent_resource == true ? var.tags : null : each.value.tags
  weekly_schedule  = each.value.weekly_schedule
}
