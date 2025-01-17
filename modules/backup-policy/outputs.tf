output "resource_id" {
  value       = azapi_resource.anf-backup-policy.id
  description = "The Azure NetApp Files Backup Policy Resource ID."
}

output "name" {
  value       = azapi_resource.anf-backup-policy.name
  description = "The name of the Azure NetApp Files Backup Policy."
}
