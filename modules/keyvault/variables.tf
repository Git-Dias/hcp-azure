variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "deployer_object_id" {
  description = "Object ID que recebe a access policy (normalmente quem roda o Terraform)"
  type        = string
}

variable "name" {
  description = "Nome global e único do Key Vault (3-24 caracteres)"
  type        = string
}

variable "create_key" {
  type    = bool
  default = true
}

variable "create_secret" {
  type    = bool
  default = true
}

variable "allowed_ip_ranges" {
  description = "IPs/CIDRs liberados no firewall do Key Vault (só vale com acesso público habilitado)"
  type        = list(string)
  default     = []
}

# Defaults = conforme
variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "O Azure só aceita soft_delete_retention_days entre 7 e 90."
  }
}

variable "network_default_action" {
  type    = string
  default = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "network_default_action deve ser Allow ou Deny."
  }
}

variable "key_expiration_date" {
  description = "RFC3339 (ex.: 2027-11-01T00:00:00Z). null = sem expiração"
  type        = string
  default     = null
}

variable "secret_expiration_date" {
  description = "RFC3339 (ex.: 2027-11-01T00:00:00Z). null = sem expiração"
  type        = string
  default     = null
}
