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
  type = "Microsoft.Resources/resourceGroups@2024-03-01"
  body = {
    properties = {}
  }
  location                  = random_shuffle.region.result[0]
  name                      = "rsg-${random_shuffle.region.result[0]}-anf-example-default-${random_pet.name.id}"
  schema_validation_enabled = false
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  name                = "anf-account-example-default-${random_pet.name.id}"
  location            = azapi_resource.rsg.location
  resource_group_name = azapi_resource.rsg.name
}

output "anf_account_resource_id" {
  value = module.test.resource_id
}

output "anf_account_name" {
  value = module.test.name
}

output "backup_vaults_resource_ids" {
  value = module.test.backup_vaults_resource_ids
}

output "backup_policies_resource_ids" {
  value = module.test.backup_policies_resource_ids
}

output "snapshot_policies_resource_ids" {
  value = module.test.snapshot_policies_resource_ids
}

output "volumes_resource_ids" {
  value = module.test.volumes_resource_ids
}
