resource "azapi_resource" "anf-capacity-pool-volume" {
  type = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2024-07-01"
  body = {
    zones = var.zone
    properties = {
      avsDataStore                      = local.avs_data_store
      coolAccess                        = var.cool_access
      coolAccessRetrievalPolicy         = var.cool_access_retrieval_policy
      coolnessPeriod                    = var.coolness_period
      creationToken                     = local.creation_token
      defaultGroupQuotaInKiBs           = var.default_group_quota_in_kibs
      defaultUserQuotaInKiBs            = var.default_user_quota_in_kibs
      deleteBaseSnapshot                = var.delete_base_snapshot
      enableSubvolumes                  = local.enable_sub_volumes
      encryptionKeySource               = var.encryption_key_source
      isDefaultQuotaEnabled             = var.default_quota_enabled
      isLargeVolume                     = var.is_large_volume
      kerberosEnabled                   = var.kerberos_enabled
      keyVaultPrivateEndpointResourceId = var.key_vault_private_endpoint_resource_id
      ldapEnabled                       = var.ldap_enabled
      networkFeatures                   = var.network_features
      protocolTypes                     = var.protocol_types
      proximityPlacementGroup           = var.proximity_placement_group_resource_id
      securityStyle                     = local.security_style
      serviceLevel                      = var.service_level
      smbAccessBasedEnumeration         = local.smb_access_based_enumeration_enabled
      smbContinuouslyAvailable          = var.smb_continuously_available
      smbEncryption                     = var.smb_encryption
      smbNonBrowsable                   = local.smb_non_browsable
      snapshotDirectoryVisible          = var.snapshot_directory_visible
      subnetId                          = var.subnet_resource_id
      throughputMibps                   = var.throughput_mibps
      unixPermissions                   = var.unix_permissions
      usageThreshold                    = local.volume_size_in_bytes
      volumeSpecName                    = var.volume_spec_name
      volumeType                        = var.volume_type

      dataProtection = {
        backup = var.backup_policy_resource_id != null && var.backup_vault_resource_id != null ? {
          backupPolicyId = var.backup_policy_resource_id
          backupVaultId  = var.backup_vault_resource_id
          policyEnforced = var.backup_policy_enforced
        } : null
        # To be added in future requires some POST operations via azapi_resource_action - do as seperate child module
        # replication = {
        #   endpointType           = 
        #   remoteVolumeRegion     = 
        #   remoteVolumeResourceId = 
        #   replicationSchedule    = 
        #   remotePath = {
        #     externalHostName = 
        #     serverName       = 
        #     volumeName       = 
        #   }
        # }
        snapshot = var.snapshot_policy_resource_id != null ? {
          snapshotPolicyId = var.snapshot_policy_resource_id
        } : null
      }

      exportPolicy = local.export_policy_rules != null ? {
        rules = local.export_policy_rules
      } : null

    }
  }
  location                  = var.location
  name                      = var.name
  parent_id                 = var.capacity_pool_resource_id
  schema_validation_enabled = true
  tags                      = var.tags
}
