resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  # Access policies (em vez de RBAC) para o próprio deployer criar key/secret sem role assignment
  rbac_authorization_enabled = false

  public_network_access_enabled = var.public_network_access_enabled
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days

  network_acls {
    default_action = var.network_default_action
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
  }

  access_policy {
    tenant_id          = var.tenant_id
    object_id          = var.deployer_object_id
    key_permissions    = ["Get", "List", "Create", "Delete", "Purge", "Recover", "GetRotationPolicy"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }
}

resource "azurerm_key_vault_key" "this" {
  count = var.create_key ? 1 : 0

  name            = "key-tf-lab"
  key_vault_id    = azurerm_key_vault.this.id
  key_type        = "RSA"
  key_size        = 2048
  key_opts        = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]
  expiration_date = var.key_expiration_date
}

resource "azurerm_key_vault_secret" "this" {
  count = var.create_secret ? 1 : 0

  name            = "secret-tf-lab"
  key_vault_id    = azurerm_key_vault.this.id
  value           = "lab-not-a-real-secret"
  content_type    = "text/plain"
  expiration_date = var.secret_expiration_date
}
