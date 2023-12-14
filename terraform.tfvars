subscription_id = "731e526d-23cb-457a-8880-2872231a45a2"
node_location   = "Brazil South"
resource_prefix = "srv-sharegate"
Environment     = "Development"
node_count      = 2
admin_username  = "xbox"
admin_password  = "Pa$$w0rd"
vm_size         = "Standard_D4s_v3" 

tags = {
  project     = "MigrationProject"
  access      = "terraform"
  environment = "development"
  application = "sharegate"
}

windows_image_reference = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2019-Datacenter"
  version   = "latest"
}
