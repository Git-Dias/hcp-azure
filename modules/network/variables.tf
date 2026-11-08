variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "vnet-tf-lab"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_name" {
  type    = string
  default = "snet-tf-lab"
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "create_test_nic" {
  description = "Cria a NIC de teste usada pelas regras de NIC"
  type        = bool
  default     = true
}

# Defaults = conforme
variable "nic_public_ip_enabled" {
  description = "Associa um IP público à NIC de teste"
  type        = bool
  default     = false
}

variable "nic_ip_forwarding_enabled" {
  description = "Habilita IP forwarding na NIC de teste"
  type        = bool
  default     = false
}
