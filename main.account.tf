resource "azapi_resource" "anf-account" {
  type      = "Microsoft.NetApp/netAppAccounts@2024-03-01"
  name      = var.name
  location  = var.location
  parent_id = "/subscriptions/${local.subscription_id}/resourceGroups/${var.resource_group_name}"
  tags      = var.tags

  body = {
    properties = {
      # activeDirectories = []
      # encryption = {}
    }
  }
}
