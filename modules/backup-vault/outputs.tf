output "resource_id" {
  value       = azapi_resource.anf-backup-vault.id
  description = "The Azure NetApp Files Backup Vault Resource ID."
}

output "name" {
  value       = azapi_resource.anf-backup-vault.name
  description = "The name of the Azure NetApp Files Backup Vault."
}
