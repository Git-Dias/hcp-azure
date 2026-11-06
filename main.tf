resource "azurerm_resource_group" "hcp_tf_lab" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "lab_vnet" {
  name                = "vnet-tf-lab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
}

resource "azurerm_storage_account" "lab_storage" {
  name                     = "sthcptflab01"
  resource_group_name      = azurerm_resource_group.hcp_tf_lab.name
  location                 = azurerm_resource_group.hcp_tf_lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Acesso público: rede aberta e containers podem ser configurados como públicos
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true

  # Chaves de acesso habilitadas: necessário para gerar SAS assinado com a chave da conta
  shared_access_key_enabled = true
}

