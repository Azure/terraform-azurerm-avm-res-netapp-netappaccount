<!-- BEGIN_TF_DOCS -->
# Backup Vaults & Backup Policies

This deploys the with backup vaults in an Azure NetApp Files account with backup policies.

```hcl
terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
provider "azapi" {
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.3"

  availability_zones_filter = true
  geography_group_filter    = "Europe"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

resource "random_pet" "name" {
  length = 1
}

resource "random_shuffle" "region" {
  input        = module.regions.valid_region_names
  result_count = 1
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.

# This is required for resource modules
resource "azapi_resource" "rsg" {
  location = random_shuffle.region.result[0]
  name     = "rsg-${random_shuffle.region.result[0]}-anf-example-backup-vlt-and-pol-${random_pet.name.id}"
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body = {
    properties = {}
  }
  schema_validation_enabled = false
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  location            = azapi_resource.rsg.location
  name                = "anf-account-example-backup-vlt-${random_pet.name.id}"
  resource_group_name = azapi_resource.rsg.name
  backup_policies = {
    "backup-policy-1" = {
      name = "backup-policy-1"
      tags = {
        environment   = "prod"
        configuration = "defaults"
      }
    }
    "backup-policy-2" = {
      name = "backup-policy-2"
      tags = {
        environment   = "test"
        configuration = "custom"
      }
      daily_backups_to_keep   = 7
      weekly_backups_to_keep  = 4
      monthly_backups_to_keep = 6
    }
  }
  backup_vaults = {
    "backup-vault-1" = {
      name = "backup-vault-1"
      tags = {
        environment = "prod"
      }
    }
    "backup-vault-2" = {
      name = "backup-vault-2"
      tags = {
        environment = "test"
      }
    }
  }
}






```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9, < 2.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.1)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.rsg](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)
- [random_pet.name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
- [random_shuffle.region](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_anf_account_name"></a> [anf\_account\_name](#output\_anf\_account\_name)

Description: n/a

### <a name="output_anf_account_resource_id"></a> [anf\_account\_resource\_id](#output\_anf\_account\_resource\_id)

Description: n/a

### <a name="output_backup_policies_resource_ids"></a> [backup\_policies\_resource\_ids](#output\_backup\_policies\_resource\_ids)

Description: n/a

### <a name="output_backup_vaults_resource_ids"></a> [backup\_vaults\_resource\_ids](#output\_backup\_vaults\_resource\_ids)

Description: n/a

### <a name="output_snapshot_policies_resource_ids"></a> [snapshot\_policies\_resource\_ids](#output\_snapshot\_policies\_resource\_ids)

Description: n/a

### <a name="output_volumes_resource_ids"></a> [volumes\_resource\_ids](#output\_volumes\_resource\_ids)

Description: n/a

## Modules

The following Modules are called:

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: ~> 0.3

### <a name="module_test"></a> [test](#module\_test)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->