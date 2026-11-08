variable "resource_group_name" {
  type = string
}

variable "location" {
  description = "Região da identidade gerenciada (o bot em si é sempre 'global')"
  type        = string
}

variable "tenant_id" {
  type = string
}

variable "name" {
  type    = string
  default = "bot-tf-lab-01"
}

# Default = conforme
variable "public_network_access_enabled" {
  type    = bool
  default = false
}
