resource "azurerm_virtual_network" "VNET-01" {
  name                = "vnet-01"
  location            = var.lab_location_dev
  resource_group_name = var.rg_dev
  address_space       = ["192.168.0.0/16"]
  dns_servers         = ["8.8.8.8"]

  tags = local.tags

}

resource "azurerm_subnet" "SNET-01" {
  name                 = "snet-01"
  resource_group_name  = var.rg_dev
  virtual_network_name = azurerm_virtual_network.VNET-01.name
  address_prefixes     = ["192.168.0.0/24"]

}
