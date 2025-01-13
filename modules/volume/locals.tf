locals {
  avs_data_store = var.avs_data_store == true ? "Enabled" : "Disabled"
  creation_token = var.creation_token != null ? var.creation_token : var.name
}
