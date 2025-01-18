variable "adds_admin_password" {
  type        = string
  description = "The password for the Active Directory Domain Services (ADDS) admin user."
  sensitive   = true
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
