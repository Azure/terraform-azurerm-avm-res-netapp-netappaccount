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






