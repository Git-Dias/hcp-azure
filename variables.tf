variable "rg_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "RG-HCP-Azure"
}

variable "location" {
  description = "Região do Azure"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "Tamanho da VM e das instâncias do VMSS do lab"
  type        = string
  default     = "Standard_B1s"
}

# --- Liga/desliga módulos (valores atuais em lab.auto.tfvars) ----------------

variable "enable_network" {
  description = "VNet, subnet e NIC de teste"
  type        = bool
  default     = true
}

variable "enable_storage" {
  description = "Storage Account + container"
  type        = bool
  default     = true
}

variable "enable_bot" {
  description = "Azure Bot Service + identidade gerenciada"
  type        = bool
  default     = true
}

variable "enable_keyvault" {
  description = "Key Vault"
  type        = bool
  default     = true
}

variable "enable_keyvault_objects" {
  description = "Key e secret dentro do Key Vault"
  type        = bool
  default     = true
}

variable "enable_vm" {
  description = "VM Linux (exige enable_network)"
  type        = bool
  default     = true

  validation {
    condition     = !var.enable_vm || var.enable_network
    error_message = "enable_vm = true exige enable_network = true (a VM usa a subnet do módulo de rede)."
  }
}

variable "enable_vmss" {
  description = "VM Scale Set Linux (exige enable_network)"
  type        = bool
  default     = true

  validation {
    condition     = !var.enable_vmss || var.enable_network
    error_message = "enable_vmss = true exige enable_network = true (o VMSS usa a subnet do módulo de rede)."
  }
}

variable "keyvault_object_expiration_date" {
  description = "Expiração (RFC3339) da key e do secret do Key Vault. null = sem expiração (FAIL)"
  type        = string
  default     = "2027-11-01T00:00:00Z"
}
