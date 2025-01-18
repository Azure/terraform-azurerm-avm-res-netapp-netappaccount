locals {
  avs_data_store                       = var.avs_data_store == true ? "Enabled" : "Disabled"
  creation_token                       = var.creation_token != null ? var.creation_token : var.name
  enable_sub_volumes                   = var.enable_sub_volumes == true ? "Enabled" : "Disabled"
  security_style                       = var.security_style == null ? contains([for protocol in var.protocol_types : lower(protocol)], "CIFS") ? "NTFS" : "Unix" : var.security_style
  smb_access_based_enumeration_enabled = var.smb_access_based_enumeration_enabled == true ? "Enabled" : "Disabled"
  smb_non_browsable                    = var.smb_non_browsable == true ? "Enabled" : "Disabled"
  volume_size_in_bytes                 = var.volume_size_in_gib * 1073741824
}

locals {
  export_policy_rules = length(coalesce(var.export_policy_rules, {})) > 0 ? [
    for rule in var.export_policy_rules : {
      ruleIndex           = rule.rule_index
      allowedClients      = join(",", rule.allowed_clients)
      chownMode           = rule.chown_mode
      cifs                = rule.cifs
      nfsv3               = rule.nfsv3
      nfsv41              = rule.nfsv41
      hasRootAccess       = rule.has_root_access
      kerberos5iReadOnly  = rule.kerberos5i_ro
      kerberos5iReadWrite = rule.kerberos5i_rw
      kerberos5pReadOnly  = rule.kerberos5p_ro
      kerberos5pReadWrite = rule.kerberos5p_rw
      kerberos5ReadOnly   = rule.kerberos5_ro
      kerberos5ReadWrite  = rule.kerberos5_rw
      unixReadOnly        = rule.unix_ro
      unixReadWrite       = rule.unix_rw
    }
  ] : null
}

