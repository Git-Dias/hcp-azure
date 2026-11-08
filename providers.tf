terraform {
  required_version = ">= 1.9.0, < 2.0.0"

  # backend "azurerm" {
  #   resource_group_name  = "RG-REMOTE-STATE"
  #   storage_account_name = "storemotestate01"
  #   container_name       = "remote-state"
  #   key                  = "lab-env/terraform.tfstate"
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}

provider "azurerm" {
  resource_providers_to_register = [
    "Microsoft.Storage",
    "Microsoft.Network",
    "Microsoft.ManagedIdentity",
    "Microsoft.BotService",
    "Microsoft.Compute",
    "Microsoft.KeyVault",
  ]

  features {}
}
