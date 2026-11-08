resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Só existe quando a autenticação por senha está habilitada (cenário FAIL)
resource "random_password" "admin" {
  count = var.disable_password_authentication ? 0 : 1

  length           = 20
  special          = true
  override_special = "!#%*-_=+"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  instances           = var.instances

  admin_username                  = var.admin_username
  admin_password                  = one(random_password.admin[*].result)
  disable_password_authentication = var.disable_password_authentication

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.this.public_key_openssh
  }

  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled        = var.vtpm_enabled

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  network_interface {
    name    = "nic-${var.name}"
    primary = true

    ip_configuration {
      name      = "ipconfig1"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}
