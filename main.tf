resource "azurerm_resource_group" "hcp_tf_lab" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_resource_group" "hcp_tf_lab_02" {
  name     = var.rg_name_02
  location = var.location
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = "vnet-tf-lab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
}
