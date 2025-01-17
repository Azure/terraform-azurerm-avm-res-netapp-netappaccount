module "snapshot-policies" {
  source = "./modules/snapshot-policy"

  for_each = var.snapshot_policies

  account  = { resource_id = azapi_resource.anf-account.id }
  location = var.location

  name    = each.value.name
  tags    = each.value.tags == null ? var.inherit_tags_from_parent_resource == true ? var.tags : null : each.value.tags
  enabled = each.value.enabled

  daily_schedule   = each.value.daily_schedule
  hourly_schedule  = each.value.hourly_schedule
  monthly_schedule = each.value.monthly_schedule
  weekly_schedule  = each.value.weekly_schedule
}
