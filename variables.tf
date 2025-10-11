variable "rg_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "RG-HCP-Terraform"
}

variable "location" {
  description = "Região do Azure"
  type        = string
  default     = "eastus"
}
