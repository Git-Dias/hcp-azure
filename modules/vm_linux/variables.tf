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
  default = "vm-tf-lab-01"
}

variable "size" {
  type    = string
  default = "Standard_B1s"
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
  description = "Standard_LRS (HDD), StandardSSD_LRS, Premium_LRS..."
  type        = string
  default     = "StandardSSD_LRS"
}
