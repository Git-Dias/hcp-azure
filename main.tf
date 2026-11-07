resource "azurerm_resource_group" "hcp_tf_lab" {
  name     = var.rg_name
  location = var.location
}

# ---------------------------------------------------------------------------
# LAB DE TESTES DE CSPM/IaC: os recursos abaixo violam regras de propósito.
# Não reutilize esta configuração em ambientes reais.
# ---------------------------------------------------------------------------

# --- Rede ------------------------------------------------------------------

resource "azurerm_virtual_network" "lab_vnet" {
  name                = "vnet-tf-lab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
}

resource "azurerm_subnet" "lab_subnet" {
  name                 = "snet-tf-lab"
  resource_group_name  = azurerm_resource_group.hcp_tf_lab.name
  virtual_network_name = azurerm_virtual_network.lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "lab_pip" {
  name                = "pip-tf-lab"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# VIOLA: "Network Interface should not have public IP addresses"
resource "azurerm_network_interface" "lab_nic" {
  name                = "nic-tf-lab"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_pip.id
  }
}

# --- Storage ---------------------------------------------------------------

resource "azurerm_storage_account" "lab_storage" {
  name                     = "sthcptflab01"
  resource_group_name      = azurerm_resource_group.hcp_tf_lab.name
  location                 = azurerm_resource_group.hcp_tf_lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # VIOLA: "Storage Account public network access should be disabled"
  public_network_access = "Enabled"

  # Permite que containers sejam públicos (pré-requisito para o container abaixo)
  allow_nested_items_to_be_public = true

  # VIOLA: "Storage Account should prevent shared key access"
  shared_access_key_enabled = true

  # VIOLA: "Storage Account's network rules should not allow public access"
  network_rules {
    default_action = "Allow"
  }
}

# VIOLA: "Storage Account container should not allow public access"
resource "azurerm_storage_container" "lab_public_container" {
  name                  = "public-lab"
  storage_account_id    = azurerm_storage_account.lab_storage.id
  container_access_type = "blob"
}

# --- Bot Service -----------------------------------------------------------

# Identidade gerenciada usada como app do bot (evita criar App Registration no Entra ID)
resource "azurerm_user_assigned_identity" "lab_bot_identity" {
  name                = "id-bot-tf-lab"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
}

data "azurerm_client_config" "current" {}

# VIOLA: "Bot Service public network access should be disabled"
resource "azurerm_bot_service_azure_bot" "lab_bot" {
  name                = "bot-tf-lab-01"
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = "global"
  sku                 = "F0"

  microsoft_app_type      = "UserAssignedMSI"
  microsoft_app_id        = azurerm_user_assigned_identity.lab_bot_identity.client_id
  microsoft_app_msi_id    = azurerm_user_assigned_identity.lab_bot_identity.id
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = true
}
