# Migração dos recursos da raiz para os módulos sem destruir/recriar o que já está no state.
# Pode ser removido depois que um apply com esta versão tiver rodado.

moved {
  from = azurerm_virtual_network.lab_vnet
  to   = module.network[0].azurerm_virtual_network.this
}

moved {
  from = azurerm_subnet.lab_subnet
  to   = module.network[0].azurerm_subnet.this
}

moved {
  from = azurerm_public_ip.lab_pip
  to   = module.network[0].azurerm_public_ip.test_nic[0]
}

moved {
  from = azurerm_network_interface.lab_nic
  to   = module.network[0].azurerm_network_interface.test[0]
}

moved {
  from = azurerm_storage_account.lab_storage
  to   = module.storage[0].azurerm_storage_account.this
}

moved {
  from = azurerm_storage_container.lab_public_container
  to   = module.storage[0].azurerm_storage_container.this[0]
}

moved {
  from = azurerm_user_assigned_identity.lab_bot_identity
  to   = module.bot[0].azurerm_user_assigned_identity.this
}

moved {
  from = azurerm_bot_service_azure_bot.lab_bot
  to   = module.bot[0].azurerm_bot_service_azure_bot.this
}

moved {
  from = azurerm_key_vault.lab_kv
  to   = module.keyvault[0].azurerm_key_vault.this
}

moved {
  from = azurerm_key_vault_key.lab_key
  to   = module.keyvault[0].azurerm_key_vault_key.this[0]
}

moved {
  from = azurerm_key_vault_secret.lab_secret
  to   = module.keyvault[0].azurerm_key_vault_secret.this[0]
}

moved {
  from = random_password.lab_vm_admin
  to   = module.vm_linux[0].random_password.admin[0]
}

moved {
  from = azurerm_network_interface.lab_vm_nic
  to   = module.vm_linux[0].azurerm_network_interface.this
}

moved {
  from = azurerm_linux_virtual_machine.lab_vm
  to   = module.vm_linux[0].azurerm_linux_virtual_machine.this
}

moved {
  from = azurerm_linux_virtual_machine_scale_set.lab_vmss
  to   = module.vmss_linux[0].azurerm_linux_virtual_machine_scale_set.this
}
