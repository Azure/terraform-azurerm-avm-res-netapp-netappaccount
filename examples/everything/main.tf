terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.1"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
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
  source                    = "Azure/avm-utl-regions/azurerm"
  version                   = "~> 0.3"
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
  type                      = "Microsoft.Resources/resourceGroups@2024-03-01"
  name                      = "rsg-${random_shuffle.region.result[0]}-anf-example-everything-${random_pet.name.id}"
  location                  = random_shuffle.region.result[0]
  schema_validation_enabled = false

  body = {
    properties = {}
  }
}

# vNet and Subnet

resource "azapi_resource" "vnet" {
  type = "Microsoft.Network/virtualNetworks@2024-05-01"
  parent_id = azapi_resource.rsg.id
  location = azapi_resource.rsg.location
  name = "vnet-${random_shuffle.region.result[0]}-anf-example-everything-${random_pet.name.id}"

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

  name                = "anf-account-example-everything-${random_pet.name.id}"
  location            = azapi_resource.rsg.location
  resource_group_name = azapi_resource.rsg.name

  capacity_pools = {
    "pool1" = {
      name          = "pool1"
      size          = 4398046511104
      service_level = "Premium"
    }
    "pool2" = {
      name          = "pool2"
      size          = 4398046511104
      service_level = "Standard"
      qos_type      = "Manual"
      cool_access   = true
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

  volumes = {
    "volume-1" = {
      name = "volume-1"
      capacity_pool_map_key = "pool1"
      subnet_resource_id = azapi_resource.vnet.output.anf_subnet_resource_id.properties.subnets[0].id
    }
  }
}
