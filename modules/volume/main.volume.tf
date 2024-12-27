resource "azapi_resource" "anf-capacity-pool-volume" {

  type      = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2024-07-01"
  parent_id = var.capacity_pool.resource_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      subnetId = ""
      usageThreshold = 
      
    }
    
  }

}
