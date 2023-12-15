

# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}



# Create a resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags = var.tags
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.location
  address_space       = var.address_space
  tags = var.tags
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "example_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefixes     = [var.address_prefix]
  }

# Create Linux Public IP
resource "azurerm_public_ip" "example_public_ip" {
  count = var.count
  name  = "${var.prefix}-${format("%02d", count.index)}-PublicIP"
  #name = "${var.prefix}-PublicIP"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = var.env == "Test" ? "Static" : "Dynamic"
  tags = var.tags
}

# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
  count = var.count
  #name = "${var.prefix}-NIC"
  name                = "${var.prefix}-${format("%02d", count.index)}-nic"
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

  name                = "${var.prefix}-nsg"
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
  tags = merge(var.tags, { env = var.env })
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}


# Definição de recurso para criação das máquinas virtuais do Windows
resource "azurerm_virtual_machine" "Windows" {
  count = var.count
  name  = "${var.prefix}-${format("%02d", count.index)}"
  location                      = azurerm_resource_group.example_rg.location
  resource_group_name           = azurerm_resource_group.example_rg.name
  network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = true
  
  # Definição da imagem da VM
  storage_image_reference {
      publisher = var.win_image["publisher"]
      offer     = var.win_image["offer"]
      sku       = var.win_image["sku"]
      version   = var.win_image["version"]
  }
  
  # Configuração do disco OS da VM
  storage_os_disk {
      name              = "${var.prefix}-disk-${format("%02d", count.index)}"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
  }
  
  # Configuração do perfil do sistema operacional da VM
  os_profile {
      computer_name  = "sharegate${format("%02d", count.index)}"
      admin_username = "${var.username}"
      admin_password = "${var.password}"
  }
  
  # Configuração adicional para o Windows
  os_profile_windows_config {
      provision_vm_agent = true
  }

  # Definição dos provisioners para configurar a VM e executar o playbook do Ansible
  provisioner "remote-exec" {
    inline = [
      "powershell -Command \"Set-ExecutionPolicy Unrestricted -Force\"; winrm quickconfig -q; winrm set winrm/config/service @{AllowUnencrypted='true'}; winrm set winrm/config/service/auth @{Basic='true'}"
    ]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${azurerm_public_ip.example_public_ip[count.index].ip_address}, -u ${var.username} -e 'ansible_ssh_pass=${var.password}' -e 'ansible_connection=winrm' ./ansible/server_setup.yml"
  }
   
  tags = var.tags
}



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



