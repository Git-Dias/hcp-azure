# ---------------------------------------------------------------------------
# LAB DE TESTES DE CSPM/IaC
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
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location

  create_test_nic           = true
  nic_public_ip_enabled     = false # FAIL: true  -> "Network Interface should not have public IP addresses"
  nic_ip_forwarding_enabled = false # FAIL: true  -> "Network Interface IP forwarding should be disabled"
}

# --- Storage ---------------------------------------------------------------

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  name                = "sthcptflab001"

  public_network_access_enabled   = true     # FAIL: true      -> "Storage Account public network access should be disabled"
  shared_access_key_enabled       = true     # FAIL: true      -> "Storage Account should prevent shared key access"
  https_traffic_only_enabled      = false      # FAIL: false     -> "Storage Account 'Secure transfer required' should be enabled"
  min_tls_version                 = "TLS1_2"  # FAIL: "TLS1_0"  -> "Storage Account should use minimum TLS 1.2"
  network_default_action          = "Allow"    # FAIL: "Allow"   -> "Storage Account's network rules should not allow public access"
  allow_nested_items_to_be_public = true     # FAIL: true      -> pré-requisito do container público abaixo
  container_access_type           = "blob" # FAIL: "blob"    -> "Storage Account container should not allow public access" (exige a linha acima = true)
}

# --- Bot Service -----------------------------------------------------------

module "bot" {
  source = "./modules/bot"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  public_network_access_enabled = true # FAIL: true -> "Bot Service public network access should be disabled"
}

# --- Key Vault -------------------------------------------------------------

# Sem módulo de propósito: valores literais direto no recurso, para o scanner de IaC
# (Wiz) conseguir avaliar cada atributo sem precisar resolver variáveis de módulo.

resource "azurerm_key_vault" "lab_kv" {
  # Com purge protection, um KV destruído "segura" o nome pelos dias de retenção: troque o nome se precisar recriar.
  name                = "kv-hcp-tf-lab-001"
  location            = azurerm_resource_group.hcp_tf_lab.location
  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Access policies (em vez de RBAC) para o próprio deployer criar key/secret sem role assignment
  rbac_authorization_enabled = false

  public_network_access_enabled = true  # FAIL: true  -> "Key Vault public network access should be disabled"
  purge_protection_enabled      = var.purge_protection # FAIL: false -> "Key Vault purge protection should be enabled" (true -> false recria o KV)
  soft_delete_retention_days    = 90    # FAIL: 7     -> "Key Vault soft delete retention" (Azure aceita só 7 a 90)

  network_acls {
    default_action = "Deny" # FAIL: "Allow" -> "Key Vault firewall should be enabled"
    bypass         = "AzureServices"
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    key_permissions    = ["Get", "List", "Create", "Delete", "Purge", "Recover", "GetRotationPolicy"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }
}

# Key e secret são criados pelo data plane: com o KV fechado (default_action = "Deny"), o apply a partir
# do runner do HCP falha. Para um apply real: remova key/secret ou use um agent com acesso privado.

resource "azurerm_key_vault_key" "lab_key" {
  name            = "key-tf-lab"
  key_vault_id    = azurerm_key_vault.lab_kv.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  expiration_date = "2027-11-01T00:00:00Z" # FAIL: apague a linha -> "Key Vault key should have an expiration date"
}

resource "azurerm_key_vault_secret" "lab_secret" {
  name            = "secret-tf-lab"
  key_vault_id    = azurerm_key_vault.lab_kv.id
  value           = "lab-not-a-real-secret"
  content_type    = "text/plain"
  expiration_date = "2027-11-01T00:00:00Z" # FAIL: apague a linha -> "Key Vault secret should have an expiration date"
}

# --- Compute ---------------------------------------------------------------

module "vm_linux" {
  source = "./modules/vm_linux"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  subnet_id           = module.network.subnet_id
  size                = var.vm_size

  disable_password_authentication = false             # FAIL: false          -> "Linux Virtual Machine password authentication should be disabled"
  secure_boot_enabled             = false              # FAIL: false          -> "Virtual Machine Secure Boot should be enabled"
  vtpm_enabled                    = false              # FAIL: false          -> "Virtual Machine vTPM should be enabled"
  os_disk_storage_account_type    = "StandardSSD_LRS" # FAIL: "Standard_LRS" -> "Virtual Machine should be using Standard SSD disk volumes"
}

module "vmss_linux" {
  source = "./modules/vmss_linux"

  resource_group_name = azurerm_resource_group.hcp_tf_lab.name
  location            = azurerm_resource_group.hcp_tf_lab.location
  subnet_id           = module.network.subnet_id
  sku                 = var.vm_size

  disable_password_authentication = true              # FAIL: false          -> "Linux Virtual Machine password authentication should be disabled"
  secure_boot_enabled             = true              # FAIL: false          -> "Virtual Machine Secure Boot should be enabled"
  vtpm_enabled                    = true              # FAIL: false          -> "Virtual Machine vTPM should be enabled"
  os_disk_storage_account_type    = "StandardSSD_LRS" # FAIL: "Standard_LRS" -> "Virtual Machine should be using Standard SSD disk volumes"
}
