output "name" {
  description = "The name of the Azure NetApp Files Snapshot Policy."
  value       = azapi_resource.anf-snapshot-policy.name
}

output "resource_id" {
  description = "The Azure NetApp Files Snapshot Policy Resource ID."
  value       = azapi_resource.anf-snapshot-policy.id
}
