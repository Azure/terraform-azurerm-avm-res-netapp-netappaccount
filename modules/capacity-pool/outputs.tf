output "resource_id" {
  description = "The Resource ID of the Azure Netapp Files Capacity Pool"
  value = azapi_resource.anf-capacity-pool.id
}

output "name" {
  description = "The name of the Azure Netapp Files Capacity Pool"
  value = azapi_resource.anf-capacity-pool.name
}
