output "name" {
  description = "The name of the Azure Netapp Files Capacity Pool"
  value       = azapi_resource.anf_capacity_pool.name
}

output "resource_id" {
  description = "The Resource ID of the Azure Netapp Files Capacity Pool"
  value       = azapi_resource.anf_capacity_pool.id
}
