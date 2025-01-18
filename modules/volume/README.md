<!-- BEGIN_TF_DOCS -->
# Volume

This module deploys a Volume in a Capacity Pool in an Azure NetApp Files account.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9.2)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.1)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

## Resources

The following resources are used by this module:

- [azapi_resource.anf-capacity-pool-volume](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_client_config.telemetry](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_capacity_pool_resource_id"></a> [capacity\_pool\_resource\_id](#input\_capacity\_pool\_resource\_id)

Description: (Required) The Azure Resource ID of the Capacity Pool where the volume should be placed.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) The name of the volume.

Type: `string`

### <a name="input_subnet_resource_id"></a> [subnet\_resource\_id](#input\_subnet\_resource\_id)

Description: The Azure Resource ID of the Subnet where the volume should be placed. Subnet must have the delegation `Microsoft.NetApp/volumes`.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_avs_data_store"></a> [avs\_data\_store](#input\_avs\_data\_store)

Description: (Optional) Specifies whether the volume is enabled for Azure VMware Solution (AVS) datastore purposes. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_backup_policy_enforced"></a> [backup\_policy\_enforced](#input\_backup\_policy\_enforced)

Description: (Optional) Specifies whether the backup policy is enforced for the volume. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_backup_policy_resource_id"></a> [backup\_policy\_resource\_id](#input\_backup\_policy\_resource\_id)

Description: (Optional) The Azure Resource ID of the Backup Policy to associate with the volume. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_backup_vault_resource_id"></a> [backup\_vault\_resource\_id](#input\_backup\_vault\_resource\_id)

Description: (Optional) The Azure Resource ID of the Backup Vault to associate with the volume. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_cool_access"></a> [cool\_access](#input\_cool\_access)

Description: (Optional) Specifies whether the volume is cool access enabled. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_cool_access_retrieval_policy"></a> [cool\_access\_retrieval\_policy](#input\_cool\_access\_retrieval\_policy)

Description: (Optional) determines the data retrieval behavior from the cool tier to standard storage based on the read pattern for cool access enabled volumes. Possible values are `default`, `never`, `onread` or `null`. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_coolness_period"></a> [coolness\_period](#input\_coolness\_period)

Description: (Optional) Specifies the number of days after which data that is not accessed by clients will be tiered. Values must be between 2 and 183. Default is `null`.

Type: `number`

Default: `null`

### <a name="input_creation_token"></a> [creation\_token](#input\_creation\_token)

Description: (Optional) A unique file path for the volume. Used when creating mount targets. Default is `null` which means the `name` variable value is used in place.

Type: `string`

Default: `null`

### <a name="input_default_group_quota_in_kibs"></a> [default\_group\_quota\_in\_kibs](#input\_default\_group\_quota\_in\_kibs)

Description: (Optional) Default group quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `0`.

Type: `number`

Default: `0`

### <a name="input_default_quota_enabled"></a> [default\_quota\_enabled](#input\_default\_quota\_enabled)

Description: (Optional) Specifies if default quota is enabled for the volume. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_default_user_quota_in_kibs"></a> [default\_user\_quota\_in\_kibs](#input\_default\_user\_quota\_in\_kibs)

Description: (Optional) Default user quota for volume in KiBs. If `default_quota_enabled` is set, the minimum value of 4 KiBs applies. Default is `0`.

Type: `number`

Default: `0`

### <a name="input_delete_base_snapshot"></a> [delete\_base\_snapshot](#input\_delete\_base\_snapshot)

Description: (Optional) If enabled (`true`) the snapshot the volume was created from will be automatically deleted after the volume create operation has finished. Defaults to `false`.

Type: `bool`

Default: `false`

### <a name="input_enable_sub_volumes"></a> [enable\_sub\_volumes](#input\_enable\_sub\_volumes)

Description: (Optional) Flag indicating whether sub volume operations are enabled on the volume. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_encryption_key_source"></a> [encryption\_key\_source](#input\_encryption\_key\_source)

Description: (Optional) Source of key used to encrypt data in volume. Applicable if NetApp account has encryption.keySource = `Microsoft.KeyVault`. Possible values (case-insensitive) are: `Microsoft.NetApp` & `Microsoft.KeyVault`. Default is `Microsoft.NetApp`.

Type: `string`

Default: `"Microsoft.NetApp"`

### <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type)

Description: (Optional) Specifies the encryption type of the volume. Possible values are `Single` or `Double`. Default is `Single`.

Type: `string`

Default: `"Single"`

### <a name="input_export_policy_rules"></a> [export\_policy\_rules](#input\_export\_policy\_rules)

Description:   (Optional) A map of export policy rules for the volume. Default is `{}`.

  > The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - rule\_index      - The index (number) of the rule. Must be unique.
  - allowed\_clients - The list of allowed clients. Must be IP addresses or CIDR ranges.
  - chown\_mode      - (Optional) The chown mode of the rule. Possible values are `Restricted` or `Unrestricted`. This variable specifies who is authorized to change the ownership of a file. `Restricted` - Only root user can change the ownership of the file. `Unrestricted` - Non-root users can change ownership of files that they own.
  - cifs            - (Optional) Specifies whether CIFS protocol is allowed.
  - nfsv3          - (Optional) Specifies whether NFSv3 protocol is allowed. Enable only for NFSv3 type volumes.
  - nfsv41         - (Optional) Specifies whether NFSv4.1 protocol is allowed. Enable only for NFSv4.1 type volumes.
  - has\_root\_access - (Optional) Specifies whether root access is allowed.
  - kerberos5i\_ro   - (Optional) Specifies whether Kerberos 5i read-only is allowed.
  - kerberos5i\_rw   - (Optional) Specifies whether Kerberos 5i read-write is allowed.
  - kerberos5p\_ro   - (Optional) Specifies whether Kerberos 5p read-only is allowed.
  - kerberos5p\_rw   - (Optional) Specifies whether Kerberos 5p read-write is allowed.
  - kerberos5\_ro    - (Optional) Specifies whether Kerberos 5 read-only is allowed.
  - kerberos5\_rw    - (Optional) Specifies whether Kerberos 5 read-write is allowed.
  - unix\_ro         - (Optional) Specifies whether UNIX read-only is allowed.
  - unix\_rw         - (Optional) Specifies whether UNIX read-write is allowed.

Type:

```hcl
map(object({
    rule_index      = number
    allowed_clients = list(string)
    chown_mode      = optional(string)
    cifs            = optional(bool)
    nfsv3           = optional(bool)
    nfsv41          = optional(bool)
    has_root_access = optional(bool)
    kerberos5i_ro   = optional(bool)
    kerberos5i_rw   = optional(bool)
    kerberos5p_ro   = optional(bool)
    kerberos5p_rw   = optional(bool)
    kerberos5_ro    = optional(bool)
    kerberos5_rw    = optional(bool)
    unix_ro         = optional(bool)
    unix_rw         = optional(bool)
  }))
```

Default: `{}`

### <a name="input_is_large_volume"></a> [is\_large\_volume](#input\_is\_large\_volume)

Description: (Optional) Specifies whether the volume is a large volume. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_kerberos_enabled"></a> [kerberos\_enabled](#input\_kerberos\_enabled)

Description: (Optional) Specifies whether the volume is Kerberos enabled. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_key_vault_private_endpoint_resource_id"></a> [key\_vault\_private\_endpoint\_resource\_id](#input\_key\_vault\_private\_endpoint\_resource\_id)

Description: (Optional) The Azure Resource ID of the Private Endpoint to access the required Key Vault. Required if `encryption_key_source` is set to `Microsoft.KeyVault`. Default is `null`. Example: `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1/providers/Microsoft.Network/privateEndpoints/pep-kvlt-001`.

Type: `string`

Default: `null`

### <a name="input_ldap_enabled"></a> [ldap\_enabled](#input\_ldap\_enabled)

Description: (Optional) Specifies whether the volume is LDAP enabled. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_network_features"></a> [network\_features](#input\_network\_features)

Description: (Optional) Specifies the network features of the volume Possible values are: `Basic` or `Standard`. Default is `Standard`.

Type: `string`

Default: `"Standard"`

### <a name="input_protocol_types"></a> [protocol\_types](#input\_protocol\_types)

Description: (Optional) The set of protocol types for the volume. Possible values are `NFSv3`, `NFSv4.1`, `CIFS`. Default is `NFSv3`.

Type: `set(string)`

Default:

```json
[
  "NFSv3"
]
```

### <a name="input_proximity_placement_group_resource_id"></a> [proximity\_placement\_group\_resource\_id](#input\_proximity\_placement\_group\_resource\_id)

Description: (Optional) The resource ID of the Proximity Placement Group the volume should be placed in. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_security_style"></a> [security\_style](#input\_security\_style)

Description: (Optional) The security style of the volume. Possible values are `NTFS` or `Unix`. Defaults to `Unix` for NFS volumes or `NTFS` for CIFS and dual protocol volumes via `local.security_style` in module which uses the `var.protocol_types` values to set this value accordingly. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_service_level"></a> [service\_level](#input\_service\_level)

Description: (Optional) The service level of the volume. Possible values are `Standard`, `Premium` or `Ultra`. Defaults to `Standard`.

Type: `string`

Default: `"Standard"`

### <a name="input_smb_access_based_enumeration_enabled"></a> [smb\_access\_based\_enumeration\_enabled](#input\_smb\_access\_based\_enumeration\_enabled)

Description: (Optional) Specifies whether SMB access-based enumeration is enabled. Only support on SMB or dual protocol volumes. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_smb_continuously_available"></a> [smb\_continuously\_available](#input\_smb\_continuously\_available)

Description: (Optional) Specifies whether the volume is continuously available. Only supported on SMB volumes. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_smb_encryption"></a> [smb\_encryption](#input\_smb\_encryption)

Description: (Optional) Enables encryption for in-flight smb3 data. Only support on SMB or dual protocol volumes. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_smb_non_browsable"></a> [smb\_non\_browsable](#input\_smb\_non\_browsable)

Description: (Optional) Enables non-browsable property for SMB Shares. Only support on SMB or dual protocol volumes. Default is `false`.

Type: `bool`

Default: `false`

### <a name="input_snapshot_directory_visible"></a> [snapshot\_directory\_visible](#input\_snapshot\_directory\_visible)

Description: (Optional) If enabled (`true`) the volume will contain a read-only snapshot directory which provides access to each of the volume's snapshots. Default is `true`.

Type: `bool`

Default: `true`

### <a name="input_snapshot_policy_resource_id"></a> [snapshot\_policy\_resource\_id](#input\_snapshot\_policy\_resource\_id)

Description: (Optional) The Azure Resource ID of the Snapshot Policy to associate with the volume. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_throughput_mibps"></a> [throughput\_mibps](#input\_throughput\_mibps)

Description: (Optional) Maximum throughput in MiB/s that can be achieved by this volume and this will be accepted as input only for manual qosType volume. Default is `null`.

Type: `number`

Default: `null`

### <a name="input_unix_permissions"></a> [unix\_permissions](#input\_unix\_permissions)

Description:   UNIX permissions for NFS volume accepted in octal 4 digit format.  

  First digit selects the set user ID(4), set group ID (2) and sticky (1) attributes.  

  Second digit selects permission for the owner of the file: read (4), write (2) and execute (1).   

  Third selects permissions for other users in the same group.   

  The fourth for other users not in the group.

  `0755` - gives read/write/execute permissions to owner and read/execute to group and other users.

  For more information, see https://learn.microsoft.com/azure/azure-netapp-files/configure-unix-permissions-change-ownership-mode and https://wikipedia.org/wiki/File-system_permissions#Numeric_notation.

  Default is `0770`.

Type: `string`

Default: `"0770"`

### <a name="input_volume_size_in_gib"></a> [volume\_size\_in\_gib](#input\_volume\_size\_in\_gib)

Description: (Optional) The size of the volume in Gibibytes (GiB). Default is `50` GiB.

Type: `number`

Default: `50`

### <a name="input_volume_spec_name"></a> [volume\_spec\_name](#input\_volume\_spec\_name)

Description: (Optional) Volume spec name is the application specific designation or identifier for the particular volume in a volume group for e.g. `data`, `log`. Default is `null`.

Type: `string`

Default: `null`

### <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type)

Description: (Optional) What type of volume is this. For destination volumes in Cross Region Replication, set type to `DataProtection`. Default is `null`.

Type: `string`

Default: `""`

### <a name="input_zone"></a> [zone](#input\_zone)

Description: (Optional) The number of the availability zone where the volume should be created. Possible values are `1`, `2`, `3` or `null`. Default is `null`.

Type: `number`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Azure Netapp Files Volume

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The Resource ID of the Azure Netapp Files Volume

## Modules

No modules.

<!-- END_TF_DOCS -->