

variable "node_address_space" {
default = ["1.0.0.0/16"]
}

variable "node_address_prefix" {
default = "1.0.1.0/24"
}

variable "tags" {
  type    = map(string)
  default = {
    project     = "MigrationProject"
    access      = "terraform"
    environment = "development"
    application = "sharegate"
  }
}

variable "windows_image_reference" {
  type = map(string)
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

variable "node_location" {
type = string
}

variable "resource_prefix" {
type = string
}

variable "Environment" {
type = string
}

variable "node_count" {
type = number
}

variable "admin_username" {
type = string
}

variable "admin_password" {
type = string
}

variable "vm_size" {
type = string
}

variable "subscription_id" {
type = string
}


