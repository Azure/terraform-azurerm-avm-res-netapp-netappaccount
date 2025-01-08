resource "azapi_resource" "anf-capacity-pool-volume" {

  type      = "Microsoft.NetApp/netAppAccounts/capacityPools/volumes@2024-07-01"
  parent_id = var.capacity_pool.resource_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  body = {
    zones = var.zone
    properties = {
      avsDataStore                      = local.avs_data_store
      backupId                          = TBC
      coolAccess                        = var.cool_access
      coolAccessRetrievalPolicy         = var.cool_access_retrieval_policy
      coolnessPeriod                    =
      creationToken                     =
      defaultGroupQuotaInKiBs           =
      defaultUserQuotaInKiBs            =
      deleteBaseSnapshot                =
      enableSubvolumes                  =
      encryptionKeySource               =
      isDefaultQuotaEnabled             =
      isLargeVolume                     =
      isRestoring                       =
      kerberosEnabled                   =
      keyVaultPrivateEndpointResourceId =
      ldapEnabled                       =
      networkFeatures                   =
      protocolTypes                     =
      proximityPlacementGroup           =
      securityStyle                     =
      serviceLevel                      =
      smbAccessBasedEnumeration         =
      smbContinuouslyAvailable          =
      smbEncryption                     =
      smbNonBrowsable                   =
      snapshotDirectoryVisible          =
      snapshotId                        =
      subnetId                          =
      throughputMibps                   =
      unixPermissions                   =
      usageThreshold                    =
      volumeSpecName                    =
      volumeType                        =

      dataProtection = {
        backup = {
          backupPolicyId =
          backupVaultId  =
          policyEnforced =
        }
        replication = {
          endpointType           = 
          remoteVolumeRegion     = 
          remoteVolumeResourceId = 
          replicationSchedule    = 
          remotePath = {
            externalHostName = 
            serverName       = 
            volumeName       = 
          }
        }
        snapshot = {
          snapshotPolicyId =
        }
        volumeRelocation = {
          relocationRequested = 
        }
      }
    }

    exportPolicy = {
      rules = {
        allowedClients      =
        chownMode           =
        cifs                =
        hasRootAccess       =
        kerberos5ReadOnly   =
        kerberos5ReadWrite  =
        kerberos5iReadOnly  =
        kerberos5iReadWrite =
        kerberos5pReadOnly  =
        kerberos5pReadWrite =
        nfsv3               =
        nfsv41              =
        ruleIndex           =
        unixReadOnly        =
        unixReadWrite       =
      }
    }

      placementRules = {
        key   =
        value =
      }
    
  }

  schema_validation_enabled = false

  # Might want to add this in to be a fail safe for accidental deletion
  # lifecycle {
  #   prevent_destroy = var.prevent_destroy
  # }

}
