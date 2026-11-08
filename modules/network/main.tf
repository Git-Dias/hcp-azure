resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.subnet_prefixes
}

# NIC "de teste": existe só para exercitar as regras de NIC.
resource "azurerm_public_ip" "test_nic" {
  count = var.create_test_nic && var.nic_public_ip_enabled ? 1 : 0

  name                = "pip-tf-lab"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Duas variantes da mesma NIC (só uma existe por vez): o scanner estático do Wiz marca
# public_ip_address_id só por estar declarado, mesmo com valor null.

# PASS: sem o atributo public_ip_address_id
resource "azurerm_network_interface" "test" {
  count = var.create_test_nic && !var.nic_public_ip_enabled ? 1 : 0

  name                  = "nic-tf-lab"
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = var.nic_ip_forwarding_enabled

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FAIL: com IP público associado
resource "azurerm_network_interface" "test_public" {
  count = var.create_test_nic && var.nic_public_ip_enabled ? 1 : 0

  name                  = "nic-tf-lab"
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = var.nic_ip_forwarding_enabled

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test_nic[0].id
  }
}
