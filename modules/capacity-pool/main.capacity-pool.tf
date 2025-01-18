resource "azapi_resource" "anf-capacity-pool" {
  type = "Microsoft.NetApp/netAppAccounts/capacityPools@2024-07-01"
  body = {
    properties = {
      serviceLevel   = var.service_level
      size           = var.size
      coolAccess     = var.cool_access != null ? var.cool_access : null
      qosType        = var.qos_type != null ? var.qos_type : null
      encryptionType = var.encryption_type != null ? var.encryption_type : null
    }
  }
  location  = var.location
  name      = var.name
  parent_id = var.account.resource_id
  retry = {
    error_message_regex = ["CannotDeleteResource"]
  }
  schema_validation_enabled = false
  tags                      = var.tags
}
