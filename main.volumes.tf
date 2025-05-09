module "volumes" {
  source   = "./modules/volume"
  for_each = var.volumes

  capacity_pool_resource_id              = module.capacity_pools[each.value.capacity_pool_map_key].resource_id
  location                               = var.location
  name                                   = each.value.name
  subnet_resource_id                     = each.value.subnet_resource_id
  avs_data_store                         = each.value.avs_data_store
  backup_policy_enforced                 = each.value.backup_policy_enforced
  backup_policy_resource_id              = each.value.backup_policy_map_key != null ? module.backup_policies[each.value.backup_policy_map_key].resource_id : null
  backup_vault_resource_id               = each.value.backup_vault_map_key != null ? module.backup_vaults[each.value.backup_vault_map_key].resource_id : null
  cool_access                            = each.value.cool_access
  cool_access_retrieval_policy           = each.value.cool_access_retrieval_policy
  coolness_period                        = each.value.coolness_period
  default_group_quota_in_kibs            = each.value.default_group_quota_in_kibs
  default_quota_enabled                  = each.value.default_quota_enabled
  default_user_quota_in_kibs             = each.value.default_user_quota_in_kibs
  delete_base_snapshot                   = each.value.delete_base_snapshot
  enable_sub_volumes                     = each.value.enable_sub_volumes
  enable_telemetry                       = var.enable_telemetry
  encryption_key_source                  = each.value.encryption_key_source
  export_policy_rules                    = each.value.export_policy_rules
  is_large_volume                        = each.value.is_large_volume
  kerberos_enabled                       = each.value.kerberos_enabled
  key_vault_private_endpoint_resource_id = each.value.key_vault_private_endpoint_resource_id
  ldap_enabled                           = each.value.ldap_enabled
  network_features                       = each.value.network_features
  protocol_types                         = each.value.protocol_types
  proximity_placement_group_resource_id  = each.value.proximity_placement_group_resource_id
  security_style                         = each.value.security_style
  service_level                          = each.value.service_level
  smb_access_based_enumeration_enabled   = each.value.smb_access_based_enumeration_enabled
  smb_continuously_available             = each.value.smb_continuously_available
  smb_encryption                         = each.value.smb_encryption
  smb_non_browsable                      = each.value.smb_non_browsable
  snapshot_directory_visible             = each.value.snapshot_directory_visible
  snapshot_policy_resource_id            = each.value.snapshot_policy_map_key != null ? module.snapshot_policies[each.value.snapshot_policy_map_key].resource_id : null
  tags                                   = each.value.tags == null ? var.inherit_tags_from_parent_resource == true ? var.tags : null : each.value.tags
  throughput_mibps                       = each.value.throughput_mibps
  unix_permissions                       = each.value.unix_permissions
  volume_size_in_gib                     = each.value.volume_size_in_gib
  volume_spec_name                       = each.value.volume_spec_name
  volume_type                            = each.value.volume_type
  zone                                   = each.value.zone
}
