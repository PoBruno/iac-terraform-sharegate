

# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}



# Create a resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "${var.resource_prefix}-rg"
  location = var.node_location
  tags = var.tags
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.node_location
  address_space       = var.node_address_space
  tags = var.tags
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "example_subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = [var.node_address_prefix]
  }

# Create Linux Public IP
resource "azurerm_public_ip" "example_public_ip" {
  count = var.node_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  #name = "${var.resource_prefix}-PublicIP"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = var.Environment == "Test" ? "Static" : "Dynamic"
  tags = var.tags
}

# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
  count = var.node_count
  #name = "${var.resource_prefix}-NIC"
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  tags = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.example_public_ip.*.id, count.index)
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
  }
}

# Creating resource NSG
resource "azurerm_network_security_group" "example_nsg" {

  name                = "${var.resource_prefix}-nsg"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name

  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }
  tags = var.tags
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

# Virtual Machine Creation — Windows Server
resource "azurerm_virtual_machine" "Windows" {
    count = var.node_count
    name  = "${var.resource_prefix}-${format("%02d", count.index)}"
    location                      = azurerm_resource_group.example_rg.location
    resource_group_name           = azurerm_resource_group.example_rg.name
    network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true
    
    storage_image_reference {
        publisher = var.windows_image_reference["publisher"]
        offer     = var.windows_image_reference["offer"]
        sku       = var.windows_image_reference["sku"]
        version   = var.windows_image_reference["version"]
    }


    storage_os_disk {
        name              = "${var.resource_prefix}-disk-${format("%02d", count.index)}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "sharegate${format("%02d", count.index)}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }
    os_profile_windows_config {
        provision_vm_agent = true
    }
    
    tags = var.tags
  
}

# Create a Virtual Machine Extension to install .msi file
resource "azurerm_virtual_machine_extension" "install_msi" {
  depends_on = [azurerm_virtual_machine.Windows ]
  count                 = var.node_count
  name                  = "${var.resource_prefix}-${format("%02d", count.index)}-extension"
  virtual_machine_id    = azurerm_virtual_machine.Windows[count.index].id
  publisher             = "Microsoft.Compute"
  type                  = "CustomScriptExtension"
  type_handler_version  = "1.10"

  settings = <<SETTINGS
    {
        "fileUris": ["https://github.com/pobruno/iac-terraform-sharegate/blob/main/sharegate/Sharegate.Extension.2.2.0.msi"],
        "commandToExecute": "msiexec /i Sharegate.Extension.2.2.0.msi /quiet /qn /norestart"
    }
SETTINGS
}


# Output
#output "vm_rg" {
#  value = azurerm_virtual_machine.Windows.resource_group_name[count.index]
#  description = "VM Resource Group"
#  depends_on = [azurerm_resource_group.example_rg]
#}
#output "vm_location" {
#  value = azurerm_virtual_machine.Windows.location[count.index]
#  description = "VM Location"
#  depends_on = [azurerm_virtual_machine.Windows]
#}
#output "vm_name" {
#  value = azurerm_virtual_machine.Windows.name[count.index]
#  description = "VM name"
#  depends_on = [azurerm_virtual_machine.Windows]
#}
#output "vm_ip" {
#  value = azurerm_public_ip.example_public_ip.*.ip_address[count.index]
#  description = "VM IP"
#  depends_on = [azurerm_public_ip.example_public_ip]
#}
#output "vm_username" {
#  value = azurerm_virtual_machine.Windows.os_profile_windows_config[0].admin_username
#  description = "Username"
#  depends_on = [azurerm_public_ip.example_public_ip]
#}
#output "vm_password" {
#  value = azurerm_virtual_machine.Windows.os_profile_windows_config[0].admin_password
#  description = "Password"
#  depends_on = [azurerm_public_ip.example_public_ip]
#}
#output "vm_size" {
#  value = azurerm_virtual_machine.Windows.vm_size.count.index
#  description = "VM Size"
#  depends_on = [azurerm_public_ip.example_public_ip]
#}


# Path: variables.tf
# Compare this snippet from variables.tf:
# variable "node_location" {
# type = string
# }
#
# variable "resource_prefix" {
# type = string
# }
#
# variable "node_address_space" {
# default = ["
#
# variable "node_address_prefix" {
# default = "
#
# variable "Environment" {
# type = string
# }
#
# variable "node_count" {
# type = number
# }
#
# variable "admin_username" {
# type = string
# }
#
# variable "admin_password" {
# type = string
# }
#
# variable "vm_size" {
# type = string
# }
#
# variable "subscription_id" {
# type = string
# }


# Path: terraform.tfvars
# Compare this snippet from terraform.tfvars:
# node_location = "eastus"
# resource_prefix = "sharegate"
# node_address_space = ["
# node_address_prefix = "
# Environment = "Test"
# node_count = 1
# admin_username = "sharegate"
# admin_password = "Password123"
# vm_size = "Standard_DS1_v2"
# subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"


# Path: terraform.tfvars
# Compare this snippet from terraform.tfvars:
# node_location = "eastus"
# resource_prefix = "sharegate"
# node_address_space = ["
# node_address_prefix = "

# Environment = "Test"
# node_count = 1
# admin_username = "sharegate"
# admin_password = "Password123"
# vm_size = "Standard_DS1_v2"
# subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"



