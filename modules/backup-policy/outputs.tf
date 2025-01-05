output "backup_policy_resource_id" {
  value = azapi_resource.anf-backup-policy.id
  description = "The Azure NetApp Files Backup Policy Resource ID."
}
