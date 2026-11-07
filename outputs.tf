output "resource_group_name" {
  value = azurerm_resource_group.hcp_tf_lab.name
}

output "vnet_id" {
  value = azurerm_virtual_network.lab_vnet.id
}

output "nic_public_ip" {
  value = azurerm_public_ip.lab_pip.ip_address
}

output "public_container_url" {
  value = "${azurerm_storage_account.lab_storage.primary_blob_endpoint}${azurerm_storage_container.lab_public_container.name}"
}
