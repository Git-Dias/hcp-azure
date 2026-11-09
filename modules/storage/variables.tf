variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  description = "Nome global e único do Storage Account (3-24, minúsculas e números)"
  type        = string
}

variable "create_container" {
  type    = bool
  default = true
}

variable "container_name" {
  type    = string
  default = "lab"
}

# Defaults = conforme
variable "public_network_access_enabled" {
  type    = bool
  default = true
}

variable "allow_nested_items_to_be_public" {
  type    = bool
  default = true
}

variable "shared_access_key_enabled" {
  type    = bool
  default = true
}

variable "https_traffic_only_enabled" {
  type    = bool
  default = true
}

variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}

variable "network_default_action" {
  type    = string
  default = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "network_default_action deve ser Allow ou Deny."
  }
}

variable "container_access_type" {
  type    = string
  default = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "container_access_type deve ser private, blob ou container."
  }

  validation {
    condition     = var.container_access_type == "private" || var.allow_nested_items_to_be_public
    error_message = "Container público exige allow_nested_items_to_be_public = true."
  }
}
