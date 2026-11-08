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

  # VIOLA: "Network Interface IP forwarding should be disabled"
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab_pip.id
  }
}

# --- Storage ---------------------------------------------------------------

resource "azurerm_storage_account" "lab_storage" {
  name                     = "sthcptflab001"
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

  # VIOLA: "Storage Account 'Secure transfer required' should be enabled"
  https_traffic_only_enabled = false

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

# --- Key Vault -------------------------------------------------------------

resource "azurerm_key_vault" "lab_kv" {
  name                = "kv-hcp-tf-lab-001"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Access policies (em vez de RBAC) para o próprio deployer criar key/secret sem role assignment
  rbac_authorization_enabled = false

  # VIOLA: "Key Vault public network access should be disabled"
  public_network_access_enabled = true

  # VIOLA: "Key Vault purge protection should be enabled"
  purge_protection_enabled = false

  # VIOLA (parcial): "Key Vault soft delete should be enabled"
  # Se a policy exigir retenção >= 190 dias, isto gera a não conformidade.
  soft_delete_retention_days = 7

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    key_permissions    = ["Get", "List", "Create", "Delete", "Purge", "Recover", "GetRotationPolicy"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }
}

# VIOLA: "Key Vault key should have an expiration date" (sem expiration_date)
resource "azurerm_key_vault_key" "lab_key" {
  name         = "key-tf-lab"
  key_vault_id = azurerm_key_vault.lab_kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]
}

# VIOLA: "Key Vault secret should have an expiration date" (sem expiration_date)
resource "azurerm_key_vault_secret" "lab_secret" {
  name         = "secret-tf-lab"
  key_vault_id = azurerm_key_vault.lab_kv.id
  value        = "lab-not-a-real-secret"
}

# --- Compute ---------------------------------------------------------------

resource "random_password" "lab_vm_admin" {
  length           = 20
  special          = true
  override_special = "!#%*-_=+"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# NIC privada dedicada à VM (sem IP público)
resource "azurerm_network_interface" "lab_vm_nic" {
  name                = "nic-vm-tf-lab"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "lab_vm" {
  name                  = "vm-tf-lab-01"
  location              = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name   = azurerm_resource_group.hcp_tf_lab.name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.lab_vm_nic.id]

  admin_username                  = "labadmin"
  admin_password                  = random_password.lab_vm_admin.result
  disable_password_authentication = false

  # VIOLA: "Virtual Machine Secure Boot should be enabled"
  secure_boot_enabled = false

  # VIOLA: "Virtual Machine vTPM should be enabled"
  vtpm_enabled = false

  os_disk {
    caching = "ReadWrite"
    # VIOLA: "Virtual Machine should be using Standard SSD disk volumes" (HDD Standard)
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "lab_vmss" {
  name                = "vmss-tf-lab"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  sku                 = var.vm_size
  instances           = 1

  admin_username = "labadmin"
  admin_password = random_password.lab_vm_admin.result

  # VIOLA: "Linux Virtual Machine password authentication should be disabled"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  network_interface {
    name    = "nic-vmss-tf-lab"
    primary = true

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = azurerm_subnet.lab_subnet.id
    }
  }
}
