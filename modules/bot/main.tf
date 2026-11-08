# Identidade gerenciada usada como app do bot (evita criar App Registration no Entra ID)
resource "azurerm_user_assigned_identity" "this" {
  name                = "id-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_bot_service_azure_bot" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = "global"
  sku                 = "F0"

  microsoft_app_type      = "UserAssignedMSI"
  microsoft_app_id        = azurerm_user_assigned_identity.this.client_id
  microsoft_app_msi_id    = azurerm_user_assigned_identity.this.id
  microsoft_app_tenant_id = var.tenant_id

  public_network_access_enabled = var.public_network_access_enabled
}
