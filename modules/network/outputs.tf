output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_id" {
  value = azurerm_subnet.this.id
}

output "test_nic_public_ip" {
  value = one(azurerm_public_ip.test_nic[*].ip_address)
}
