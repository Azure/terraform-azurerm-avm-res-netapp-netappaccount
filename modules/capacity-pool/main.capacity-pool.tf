resource "azapi_resource" "anf-capacity-pool" {

  type      = "Microsoft.NetApp/netAppAccounts/capacityPools@2024-07-01"
  parent_id = var.account.resource_id
  name      = var.name
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      serviceLevel   = var.service_level
      size           = var.size
      coolAccess     = var.cool_access != null ? var.cool_access : null
      qosType        = var.qos_type != null ? var.qos_type : null
      encryptionType = var.encryption_type != null ? var.encryption_type : null
    }
  }

  schema_validation_enabled = false
}
