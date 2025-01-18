output "backup_policies_resource_ids" {
  description = "The Resource IDs of the Azure Netapp Files Account Backup Policies in a map alongside the map key specified in `var.backup_policies`"
  value       = { for key, value in var.backup_policies : key => module.backup-policies[key].resource_id }
}

output "backup_vaults_resource_ids" {
  description = "The Resource IDs of the Azure Netapp Files Account Backup Vaults in a map alongside the map key specified in `var.backup_vaults`"
  value       = { for key, value in var.backup_vaults : key => module.backup_vaults[key].resource_id }
}

output "name" {
  description = "The name of the Azure Netapp Files Account"
  value       = azapi_resource.anf_account.name
}

output "resource_id" {
  description = "The Resource ID of the Azure Netapp Files Account"
  value       = azapi_resource.anf_account.id
}

output "snapshot_policies_resource_ids" {
  description = "The Resource IDs of the Azure Netapp Files Account Snapshot Policies in a map alongside the map key specified in `var.snapshot_policies`"
  value       = { for key, value in var.snapshot_policies : key => module.snapshot_policies[key].resource_id }
}

output "volumes_resource_ids" {
  description = "The Resource IDs of the Azure Netapp Files Volumes in a map alongside the map key specified in `var.volumes`"
  value       = { for key, value in var.volumes : key => module.volumes[key].resource_id }
}
