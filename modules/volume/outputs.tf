output "name" {
  description = "The name of the Azure Netapp Files Volume"
  value       = azapi_resource.anf-capacity-pool-volume.name
}

output "resource_id" {
  description = "The Resource ID of the Azure Netapp Files Volume"
  value       = azapi_resource.anf-capacity-pool-volume.id
}
