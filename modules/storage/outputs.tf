output "id" {
  value = azurerm_storage_account.this.id
}

output "name" {
  value = azurerm_storage_account.this.name
}

output "container_url" {
  value = var.create_container ? "${azurerm_storage_account.this.primary_blob_endpoint}${var.container_name}" : null
}
