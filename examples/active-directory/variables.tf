variable "adds_admin_password" {
  type        = string
  description = "The password for the Active Directory Domain Services (ADDS) admin user."
  sensitive   = true
}
