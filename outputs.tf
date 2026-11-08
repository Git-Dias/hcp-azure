output "resource_group_name" {
  value = azurerm_resource_group.hcp_tf_lab.name
}

output "vnet_id" {
  value = one(module.network[*].vnet_id)
}

output "nic_public_ip" {
  description = "Só tem valor no cenário FAIL (nic_public_ip_enabled = true)"
  value       = one(module.network[*].test_nic_public_ip)
}

output "storage_account_name" {
  value = one(module.storage[*].name)
}

output "container_url" {
  value = one(module.storage[*].container_url)
}

output "key_vault_uri" {
  value = one(module.keyvault[*].vault_uri)
}

output "vm_private_ip" {
  value = one(module.vm_linux[*].private_ip)
}
