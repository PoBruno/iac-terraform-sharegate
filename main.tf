

# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  subscription_id = "9fcc9c96–8044–XXXX-XXXX–XXXXXXXXXXXX"
  client_id       = "97545937–XXXX–XXXX-XXXX-XXXXXXXXXXXX"
  client_secret   = ".3GGR_XXXXX~XXXX-XXXXXXXXXXXXXXXX"
  tenant_id       = "73d20f0d-XXXX–XXXX–XXXX-XXXXXXXXXXXX"
  version         = "=2.0.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "${var.resource_prefix}-rg"
  location = var.node_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.node_location
  address_space       = var.node_address_space
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

  tags = {
    environment = "sharegate"
  }
}

# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
  count = var.node_count
  #name = "${var.resource_prefix}-NIC"
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-nic"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  #

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
  tags = {
    environment = "sharegate"
  }
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
    #name = "${var.resource_prefix}-VM"
    location                      = azurerm_resource_group.example_rg.location
    resource_group_name           = azurerm_resource_group.example_rg.name
    network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
    vm_size                       = "${var.vm_size}"
    delete_os_disk_on_termination = true
    
    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter"
        version   = "latest"
    }
    storage_os_disk {
        name              = "${var.resource_prefix}-disk-${format("%02d", count.index)}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "${var.resource_prefix}-${format("%02d", count.index)}"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }
    os_profile_windows_config {
        provision_vm_agent = true
    }
    
    tags = {
        environment = "sharegate"
    }
  
}

# Virtual Machine Creation — Linux
resource "azurerm_virtual_machine" "example_linux_vm" {
  count = var.node_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}"
  #name = "${var.resource_prefix}-VM"
  location                      = azurerm_resource_group.example_rg.location
  resource_group_name           = azurerm_resource_group.example_rg.name
  network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
  vm_size                       = "Standard_A1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "linuxhost"
    admin_username = "terminator"
    admin_password = "Password@1234"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "sharegate"
  }
}







