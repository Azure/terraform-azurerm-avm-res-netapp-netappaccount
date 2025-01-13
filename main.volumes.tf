module "volumes" {
  source = "./modules/volume"

  for_each = var.volumes

  name     = each.value.name
  location = var.location
  tags     = each.value.tags

  capacity_pool      = { resource_id = module.capacity-pools[each.value.capacity_pool_map_key].capacity_pool_resource_id }
  subnet_resource_id = each.value.subnet_resource_id

  depends_on = [
    module.capacity-pools
  ]
}
