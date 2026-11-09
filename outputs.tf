output "resource_group_name" {
  value = azurerm_resource_group.hcp_tf_lab.name
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "nic_public_ip" {
  description = "Só tem valor no cenário FAIL (nic_public_ip_enabled = true)"
  value       = module.network.test_nic_public_ip
}

output "storage_account_name" {
  value = module.storage.name
}

output "container_url" {
  value = module.storage.container_url
}

output "key_vault_uri" {
  value = azurerm_key_vault.lab_kv.vault_uri
}

output "vm_private_ip" {
  value = module.vm_linux.private_ip
}
