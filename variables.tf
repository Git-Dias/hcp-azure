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

variable "purge_protection" {
  description = "Proteção de exclusão do Key Vault"
  type        = bool
  default     = true
}
