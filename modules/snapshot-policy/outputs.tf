output "resource_id" {
  value       = azapi_resource.anf-snapshot-policy.id
  description = "The Azure NetApp Files Snapshot Policy Resource ID."
}

output "name" {
  value       = azapi_resource.anf-snapshot-policy.name
  description = "The name of the Azure NetApp Files Snapshot Policy."
}
