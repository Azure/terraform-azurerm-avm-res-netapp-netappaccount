# terraform-azurerm-avm-res-netapp-netappaccount

This repo contains the AVM Resource Module for creating an Azure NetApp Files Account & associated resources.

Customer-managed encryption uses `Microsoft.KeyVault` automatically; omit the former
`customer_managed_key.key_source` attribute. Set `customer_managed_key = null` for
NetApp-managed encryption. The vault URI is read from the vault to support sovereign
clouds. Supply and assign the encryption identity, and omit `key_version`: NetApp
accepts only a key name.
