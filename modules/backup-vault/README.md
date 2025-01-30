<!-- BEGIN_TF_DOCS -->
# Backup Vault

This module deploys a Backup Vault in an Azure NetApp Files account.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.1)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.anf_backup_vault](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_client_config.telemetry](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_account"></a> [account](#input\_account)

Description:   (Required) The Azure NetApp Files Account Resource ID, into which the Backup Vault will be created.

  - resource\_id - The Azure NetApp Files Account Resource ID.

Type:

```hcl
object({
    resource_id = string
  })
```

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) The name of the backup vault.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Azure NetApp Files Backup Vault.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The Azure NetApp Files Backup Vault Resource ID.

## Modules

No modules.

<!-- END_TF_DOCS -->