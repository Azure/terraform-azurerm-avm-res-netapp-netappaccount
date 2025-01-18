output "name" {
  description = "The name of the Azure NetApp Files Backup Vault."
  value       = azapi_resource.anf_backup_vault.name
}

output "resource_id" {
  description = "The Azure NetApp Files Backup Vault Resource ID."
  value       = azapi_resource.anf_backup_vault.id
}
