module "capacity-pools" {
  source = "./modules/capacity-pool"

  for_each = var.capacity_pools

  account  = { resource_id = azapi_resource.anf-account.id }
  location = var.location

  name            = each.value.name
  tags            = each.value.tags == null ? var.inherit_tags_from_parent_resource == true ? var.tags : null : each.value.tags
  size            = each.value.size
  service_level   = each.value.service_level
  qos_type        = each.value.qos_type
  encryption_type = each.value.encryption_type
  cool_access     = each.value.cool_access
}
