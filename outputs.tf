output "resource_group_name" {
  value = azurerm_resource_group.hcp_tf_lab.name
}

output "vnet_id" {
  value = azurerm_virtual_network.lab_vnet.id
}

output "vnet_id_02" {
  value = azurerm_virtual_network.lab_vnet_02.id
}
