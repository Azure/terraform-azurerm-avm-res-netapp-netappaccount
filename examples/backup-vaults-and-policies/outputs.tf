output "anf_account_name" {
  value = module.test.name
}

output "anf_account_resource_id" {
  value = module.test.resource_id
}

output "backup_policies_resource_ids" {
  value = module.test.backup_policies_resource_ids
}

output "backup_vaults_resource_ids" {
  value = module.test.backup_vaults_resource_ids
}

output "snapshot_policies_resource_ids" {
  value = module.test.snapshot_policies_resource_ids
}

output "volumes_resource_ids" {
  value = module.test.volumes_resource_ids
}
