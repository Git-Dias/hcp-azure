variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "name" {
  type    = string
  default = "vmss-tf-lab"
}

variable "sku" {
  type    = string
  default = "Standard_B1s"
}

variable "instances" {
  type    = number
  default = 1
}

variable "admin_username" {
  type    = string
  default = "labadmin"
}

# Defaults = conforme
variable "disable_password_authentication" {
  type    = bool
  default = true
}

variable "secure_boot_enabled" {
  type    = bool
  default = true
}

variable "vtpm_enabled" {
  type    = bool
  default = true
}

variable "os_disk_storage_account_type" {
  type    = string
  default = "StandardSSD_LRS"
}
