output "resource_id" {
  value       = azapi_resource.anf-account.id
  description = "The Resource ID of the Azure Netapp Files Account"
}

output "name" {
  value       = azapi_resource.anf-account.name
  description = "The name of the Azure Netapp Files Account"
}

output "backup_vaults_resource_ids" {
  value       = { for key, value in var.backup_vaults : key => module.backup-vaults[key].resource_id }
  description = "The Resource IDs of the Azure Netapp Files Account Backup Vaults in a map alongside the map key specified in `var.backup_vaults`"
}

output "backup_policies_resource_ids" {
  value       = { for key, value in var.backup_policies : key => module.backup-policies[key].resource_id }
  description = "The Resource IDs of the Azure Netapp Files Account Backup Policies in a map alongside the map key specified in `var.backup_policies`"
}

output "snapshot_policies_resource_ids" {
  value       = { for key, value in var.snapshot_policies : key => module.snapshot-policies[key].resource_id }
  description = "The Resource IDs of the Azure Netapp Files Account Snapshot Policies in a map alongside the map key specified in `var.snapshot_policies`"
}

output "volumes_resource_ids" {
  value       = { for key, value in var.volumes : key => module.volumes[key].resource_id }
  description = "The Resource IDs of the Azure Netapp Files Volumes in a map alongside the map key specified in `var.volumes`"
}
