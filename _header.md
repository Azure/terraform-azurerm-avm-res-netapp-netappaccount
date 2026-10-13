# terraform-azurerm-avm-res-netapp-netappaccount

This repo contains the AVM Resource Module for creating an Azure NetApp Files Account & associated resources.

Customer-managed encryption uses `Microsoft.KeyVault` automatically; omit the former
`customer_managed_key.key_source` attribute. Set `customer_managed_key = null` for
NetApp-managed encryption. The vault URI is read from the vault to support sovereign
clouds. Supply and assign the encryption identity, and omit `key_version`: NetApp
accepts only a key name.

Rename `role_assignments[*].role_definition_id` to `role_definition_id_or_name`.
Keep existing map keys, principal IDs and role GUIDs to preserve assignment IDs.
Omitting `name` retains this module's deterministic assignment UUIDs; an explicit
`name` overrides them. GUIDs and resource IDs need no role-definition lookup.
For role names, set `role_assignment_definition_lookup_enabled = true` and grant
the deployment identity role-definition read permission at subscription scope.
AzAPI performs no directory lookup, so `skip_service_principal_aad_check` has no
additional effect.
