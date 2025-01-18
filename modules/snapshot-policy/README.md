<!-- BEGIN_TF_DOCS -->
# Snapshot Policy

This module deploys a Snapshot Policy in an Azure NetApp Files account.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9.2)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.1)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

## Resources

The following resources are used by this module:

- [azapi_resource.anf_snapshot_policy](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azapi_client_config.telemetry](https://registry.terraform.io/providers/azure/azapi/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_account"></a> [account](#input\_account)

Description:   (Required) The Azure NetApp Files Account Resource ID, into which the Snapshot Policy will be created.

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

Description: (Required) The name of the backup policy.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_daily_schedule"></a> [daily\_schedule](#input\_daily\_schedule)

Description:   (Optional) The daily schedule for the snapshot policy.

  - snapshots\_to\_keep - The number of snapshots to keep. Must be between 0 and 255.
  - hour              - The hour of the day to take the snapshot. Must be between 0 and 23.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.

Type:

```hcl
object({
    snapshots_to_keep = number
    hour              = number
    minute            = number
  })
```

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_enabled"></a> [enabled](#input\_enabled)

Description: (Required) Whether the snapshot policy is enabled. Defaults to `true`.

Type: `bool`

Default: `true`

### <a name="input_hourly_schedule"></a> [hourly\_schedule](#input\_hourly\_schedule)

Description:   (Optional) The hourly schedule for the snapshot policy.

  - snapshots\_to\_keep - The number of snapshots to keep. Must be between 0 and 255.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.

Type:

```hcl
object({
    snapshots_to_keep = number
    minute            = number
  })
```

Default: `null`

### <a name="input_monthly_schedule"></a> [monthly\_schedule](#input\_monthly\_schedule)

Description:   (Optional) The monthly schedule for the snapshot policy.

  - snapshots\_to\_keep - The number of snapshots to keep. Must be between 0 and 255.
  - days\_of\_month     - The list of days of the month (number) to take the snapshot. Values must be between 1 and 30.
  - hour              - The hour of the day to take the snapshot. Must be between 0 and 23.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.

Type:

```hcl
object({
    snapshots_to_keep = number
    days_of_month     = set(number)
    hour              = number
    minute            = number
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) Tags of the resource.

Type: `map(string)`

Default: `null`

### <a name="input_weekly_schedule"></a> [weekly\_schedule](#input\_weekly\_schedule)

Description:   (Optional) The weekly schedule for the snapshot policy.

  - snapshots\_to\_keep - The number of snapshots to keep. Must be between 0 and 255.
  - day               - A list of the days of the week to take the snapshot. Must use the following in the list: `Monday`, `Tuesday`, `Wednesday`, `Thursday`, `Friday`, `Saturday`, `Sunday`.
  - hour              - The hour of the day to take the snapshot. Must be between 0 and 23.
  - minute            - The minute of the hour to take the snapshot. Must be between 0 and 59.

Type:

```hcl
object({
    snapshots_to_keep = number
    day               = set(string)
    hour              = number
    minute            = number
  })
```

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Azure NetApp Files Snapshot Policy.

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: The Azure NetApp Files Snapshot Policy Resource ID.

## Modules

No modules.

<!-- END_TF_DOCS -->
