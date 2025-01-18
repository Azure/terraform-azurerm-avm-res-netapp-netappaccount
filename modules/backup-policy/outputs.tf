output "name" {
  description = "The name of the Azure NetApp Files Backup Policy."
  value       = azapi_resource.anf-backup-policy.name
}

output "resource_id" {
  description = "The Azure NetApp Files Backup Policy Resource ID."
  value       = azapi_resource.anf-backup-policy.id
}
