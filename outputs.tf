output "resource_id" {
  value = azapi_resource.anf-account.id
  description = "The Resource ID of the Azure Netapp Files Account"
}

output "name" {
  value = azapi_resource.anf-account.name
  description = "The name of the Azure Netapp Files Account"
}
