module "capacity-pools" {
  source = "./modules/capacity-pool"

  for_each = var.capacity_pools

  account  = { resource_id = azapi_resource.anf-account.id }
  location = var.location

  name            = each.value.name
  size            = each.value.size
  service_level   = each.value.service_level
  tags            = each.value.tags
  qos_type        = each.value.qos_type
  encryption_type = each.value.encryption_type
  cool_access     = each.value.cool_access
}
