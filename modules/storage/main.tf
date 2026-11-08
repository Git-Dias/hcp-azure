resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = var.min_tls_version

  public_network_access           = var.public_network_access_enabled ? "Enabled" : "Disabled"
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  https_traffic_only_enabled      = var.https_traffic_only_enabled

  network_rules {
    default_action = var.network_default_action
    bypass         = ["AzureServices"]
  }
}

# Com storage_account_id o container é criado pelo plano de controle (ARM),
# então funciona mesmo com acesso público e shared key desabilitados.
resource "azurerm_storage_container" "this" {
  count = var.create_container ? 1 : 0

  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = var.container_access_type
}
