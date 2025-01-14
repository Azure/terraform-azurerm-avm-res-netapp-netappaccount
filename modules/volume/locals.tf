locals {
  avs_data_store                       = var.avs_data_store == true ? "Enabled" : "Disabled"
  creation_token                       = var.creation_token != null ? var.creation_token : var.name
  security_style                       = contains(lower(var.protocol_types), "cifs") ? "ntfs" : "unix"
  smb_access_based_enumeration_enabled = var.smb_access_based_enumeration_enabled == true ? "Enabled" : "Disabled"
  smb_non_browsable                    = var.smb_non_browsable == true ? "Enabled" : "Disabled"
  volume_size_in_bytes                 = var.volume_size_in_gib * 1073741824
  placement_rules                      = length(var.placement_rules) > 0 ? var.placement_rules : null
}

locals {
  export_policy_rules = length(var.export_policy_rules) > 0 ? [
    for rule in var.export_policy_rules : {
      rule_index      = rule.rule_index
      allowed_clients = join(",", rule.allowed_clients)
      chown_mode      = rule.chown_mode
      cifs            = rule.cifs
      ntfsv3          = rule.ntfsv3
      ntfsv41         = rule.ntfsv41
      has_root_access = rule.has_root_access
      kerberos5i_ro   = rule.kerberos5i_ro
      kerberos5i_rw   = rule.kerberos5i_rw
      kerberos5p_ro   = rule.kerberos5p_ro
      kerberos5p_rw   = rule.kerberos5p_rw
      kerberos5_ro    = rule.kerberos5_ro
      kerberos5_rw    = rule.kerberos5_rw
      unix_ro         = rule.unix_ro
      unix_rw         = rule.unix_rw
    }
  ] : null
}
