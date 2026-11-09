# ---------------------------------------------------------------------------
# LAB DE TESTES DE CSPM/IaC
# - Liga/desliga módulos em lab.auto.tfvars (enable_*).
# - Por padrão TUDO está em conformidade (cenário PASS).
# - Para gerar o FAIL, troque o valor indicado no comentário "FAIL:" da linha.
# Não reutilize esta configuração em ambientes reais.
# ---------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "hcp_tf_lab" {
  name     = var.rg_name
  location = var.location
}

# --- Rede ------------------------------------------------------------------

module "network" {
  count  = var.enable_network ? 1 : 0
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location

  create_test_nic           = true
  nic_public_ip_enabled     = false # FAIL: true  -> "Network Interface should not have public IP addresses"
  nic_ip_forwarding_enabled = false # FAIL: true  -> "Network Interface IP forwarding should be disabled"
}

# --- Storage ---------------------------------------------------------------

module "storage" {
  count  = var.enable_storage ? 1 : 0
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  name                = "sthcptflab001"

  public_network_access_enabled   = true     # FAIL: true      -> "Storage Account public network access should be disabled"
  shared_access_key_enabled       = true     # FAIL: true      -> "Storage Account should prevent shared key access"
  https_traffic_only_enabled      = true      # FAIL: false     -> "Storage Account 'Secure transfer required' should be enabled"
  min_tls_version                 = "TLS1_2"  # FAIL: "TLS1_0"  -> "Storage Account should use minimum TLS 1.2"
  network_default_action          = "Deny"    # FAIL: "Allow"   -> "Storage Account's network rules should not allow public access"
  allow_nested_items_to_be_public = false     # FAIL: true      -> pré-requisito do container público abaixo
  container_access_type           = "private" # FAIL: "blob"    -> "Storage Account container should not allow public access" (exige a linha acima = true)
}

# --- Bot Service -----------------------------------------------------------

module "bot" {
  count  = var.enable_bot ? 1 : 0
  source = "./modules/bot"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = false # FAIL: true -> "Bot Service public network access should be disabled"
}

# --- Key Vault -------------------------------------------------------------

module "keyvault" {
  count  = var.enable_keyvault ? 1 : 0
  source = "./modules/keyvault"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  deployer_object_id  = data.azurerm_client_config.current.object_id
  # Com purge protection, um KV destruído "segura" o nome pelos dias de retenção: troque o nome se precisar recriar.
  name = "kv-hcp-tf-lab-001"

  # Key e secret são criados pelo data plane: com o KV fechado (padrão), o apply a partir
  # do runner do HCP falha. Para um apply real: desligue-os aqui ou use um agent com acesso privado.
  create_key    = var.enable_keyvault_objects
  create_secret = var.enable_keyvault_objects

  public_network_access_enabled = false  # FAIL: true    -> "Key Vault public network access should be disabled"
  network_default_action        = "Deny" # FAIL: "Allow" -> "Key Vault firewall should be enabled"
  purge_protection_enabled      = true   # FAIL: false   -> "Key Vault purge protection should be enabled" (true -> false recria o KV)
  soft_delete_retention_days    = 90     # FAIL: 7       -> "Key Vault soft delete retention" (Azure aceita só 7 a 90)

  key_expiration_date    = var.keyvault_object_expiration_date # FAIL: null -> "Key Vault key should have an expiration date"
  secret_expiration_date = var.keyvault_object_expiration_date # FAIL: null -> "Key Vault secret should have an expiration date"
}

# --- Compute ---------------------------------------------------------------

module "vm_linux" {
  count  = var.enable_vm ? 1 : 0
  source = "./modules/vm_linux"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  subnet_id           = one(module.network[*].subnet_id)
  size                = var.vm_size

  disable_password_authentication = false             # FAIL: false          -> "Linux Virtual Machine password authentication should be disabled"
  secure_boot_enabled             = false              # FAIL: false          -> "Virtual Machine Secure Boot should be enabled"
  vtpm_enabled                    = false              # FAIL: false          -> "Virtual Machine vTPM should be enabled"
  os_disk_storage_account_type    = "StandardSSD_LRS" # FAIL: "Standard_LRS" -> "Virtual Machine should be using Standard SSD disk volumes"
}

module "vmss_linux" {
  count  = var.enable_vmss ? 1 : 0
  source = "./modules/vmss_linux"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  subnet_id           = one(module.network[*].subnet_id)
  sku                 = var.vm_size

  disable_password_authentication = true              # FAIL: false          -> "Linux Virtual Machine password authentication should be disabled"
  secure_boot_enabled             = true              # FAIL: false          -> "Virtual Machine Secure Boot should be enabled"
  vtpm_enabled                    = true              # FAIL: false          -> "Virtual Machine vTPM should be enabled"
  os_disk_storage_account_type    = "StandardSSD_LRS" # FAIL: "Standard_LRS" -> "Virtual Machine should be using Standard SSD disk volumes"
}
