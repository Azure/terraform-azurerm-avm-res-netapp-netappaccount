<!-- BEGIN_TF_DOCS -->
# Combined example

This deploys an Azure NetApp Files volume with capacity pools, volumes, backup vaults, backup policies, and snapshots policies.

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

resource "azapi_resource" "rsg" {
  location = random_shuffle.region.result[0]
  name     = "rsg-${random_shuffle.region.result[0]}-anf-example-combined-${random_pet.name.id}"
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body = {
    properties = {}
  }
  schema_validation_enabled = false
}

# vNet and Subnet
resource "azapi_resource" "vnet" {
  location  = azapi_resource.rsg.location
  name      = "vnet-${random_shuffle.region.result[0]}-anf-example-combined-${random_pet.name.id}"
  parent_id = azapi_resource.rsg.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
  body = {
    properties = {
      addressSpace = {
        addressPrefixes = [
          "10.0.0.0/16"
        ]
      }
      subnets = [
        {
          name = "subnet-anf-001"
          properties = {
            addressPrefix = "10.0.1.0/24"
            delegations = [
              {
                name = "Microsoft.NetApp/volumes"
                properties = {
                  serviceName = "Microsoft.NetApp/volumes"
                }
              }
            ]
          }
        }
      ]
    }
  }
  response_export_values = {
    "anf_subnet_resource_id" = "properties.subnets[0].id"
  }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  location            = azapi_resource.rsg.location
  name                = "anf-account-example-combined-${random_pet.name.id}"
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
  capacity_pools = {
    "pool1" = {
      name          = "pool1"
      size          = 4398046511104
      service_level = "Premium"
      tags = {
        environment = "test"
      }
    }
    "pool2" = {
      name          = "pool2"
      size          = 4398046511104
      service_level = "Standard"
      qos_type      = "Manual"
      cool_access   = true
      tags = {
        environment = "prod"
      }
    }
  }
  snapshot_policies = {
    "snap-pol-1" = {
      name = "snap-pol-1"
      tags = {
        configuration = "all"
      }
      hourly_schedule = {
        snapshots_to_keep = 8
        minute            = 0
      }
      daily_schedule = {
        snapshots_to_keep = 7
        hour              = 0
        minute            = 0
      }
      weekly_schedule = {
        snapshots_to_keep = 2
        day               = ["Monday", "Friday"]
        minute            = 0
        hour              = 0
      }
      monthly_schedule = {
        snapshots_to_keep = 6
        days_of_month     = [1, 30]
        hour              = 0
        minute            = 0
      }
    }
    "snap-pol-2" = {
      name = "snap-pol-2"
      tags = {
        configuration = "daily only"
      }
      hourly_schedule = {
        snapshots_to_keep = 8
        minute            = 0
      }
      weekly_schedule = {
        snapshots_to_keep = 2
        day               = ["Monday", "Friday"]
        minute            = 0
        hour              = 0
      }
    }
  }
  tags = {
    environment = "test"
  }
  volumes = {
    "volume-1" = {
      name = "volume-1"
      tags = {
        environment = "test"
      }
      capacity_pool_map_key = "pool1"
      subnet_resource_id    = azapi_resource.vnet.output.anf_subnet_resource_id
      service_level         = "Premium"
      export_policy_rules = {
        "rule1" = {
          rule_index      = 1
          allowed_clients = ["0.0.0.0/0"]
          chown_mode      = "Restricted"
          cifs            = false
          nfsv3           = true
          nfsv41          = false
          has_root_access = true
          kerberos5i_ro   = false
          kerberos5i_rw   = false
          kerberos5p_ro   = false
          kerberos5p_rw   = false
          kerberos5_ro    = false
          kerberos5_rw    = false
          unix_ro         = false
          unix_rw         = true
        }
      }
    }
    "zone-volume-1" = {
      name = "zone-volume-1"
      tags = {
        environment = "test"
      }
      capacity_pool_map_key = "pool2"
      subnet_resource_id    = azapi_resource.vnet.output.anf_subnet_resource_id
      service_level         = "Standard"
      volume_size_in_gib    = 100
      throughput_mibps      = 32
      zone                  = 1
      export_policy_rules = {
        "rule1" = {
          rule_index      = 1
          allowed_clients = ["0.0.0.0/0"]
          chown_mode      = "Restricted"
          cifs            = false
          nfsv3           = true
          nfsv41          = false
          has_root_access = true
          kerberos5i_ro   = false
          kerberos5i_rw   = false
          kerberos5p_ro   = false
          kerberos5p_rw   = false
          kerberos5_ro    = false
          kerberos5_rw    = false
          unix_ro         = false
          unix_rw         = true
        }
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
- [azapi_resource.vnet](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
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