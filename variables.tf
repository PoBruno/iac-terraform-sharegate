

variable "address_space" {
default = ["1.0.0.0/16"]
description = "Address space to be used. {type = list(string), required = false, default = 1.0.0.0/16}"
}

variable "address_prefix" {
default = "1.0.1.0/24"
description = "Address prefix to be used. {type = string, required = false, default = 1.0.1.0/24}"
}

variable "tags" {
  type    = map(string)
  description = "Tags to be used. {type = map(string), required = false, default = {project = MigrationProject, access = terraform, environment = development, application = sharegate}}"
  default = {
    project     = "MigrationProject"
    access      = "terraform"
    environment = "development"
    application = "sharegate"
  }
}

variable "win_image" {
  type = map(string)
  description = "Windows Image to be used. {type = map(string), required = false, default = {publisher = MicrosoftWindowsServer, offer = WindowsServer, sku = 2022-datacenter, version = latest}}"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

variable "location" {
type = string
default = "Brazil South"
description = "Azure Region. Ex: Brazil South, East US, West US, etc. {type = string, default = Brazil South, required = false}}"
}

variable "prefix" {
type = string
default = "sharegate"
description = "Prefix to be used. {type = string, default = sharegate, required = false}"
}

variable "env" {
type = string
default = "homolog"
description = "Environment Name. Ex: homolog, production, development"
}

variable "count" {
type = number
default = 1
description = "Nodes count to be created. {type = number, default = 1, required = false}"
}

variable "username" {
type = string
default = "azureuser"
description = "Admin username for the VM. {type = string, default = azureuser, required = false}"
}

variable "password" {
type = string
description = "Admin password for the VM. {type = string, required = true}"
}

variable "vm_size" {
type = string
default = "Standard_B2MS"
description = "VM Size to be used. {type = string, default = Standard_B2MS, required = false}"
}

variable "subscription_id" {
type = string
description = "Subscription ID. {type = string, required = true}"
}


