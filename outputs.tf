
# Output
output "vm_rg" {
  value = azurerm_virtual_machine.Windows.resource_group_name[count.index]
  description = "VM Resource Group"
  depends_on = [azurerm_resource_group.example_rg]
}
output "vm_location" {
  value = azurerm_virtual_machine.Windows.location[count.index]
  description = "VM Location"
  depends_on = [azurerm_virtual_machine.Windows]
}
output "vm_name" {
  value = azurerm_virtual_machine.Windows.name[count.index]
  description = "VM name"
  depends_on = [azurerm_virtual_machine.Windows]
}
output "vm_ip" {
  value = azurerm_public_ip.example_public_ip.*.ip_address[count.index]
  description = "VM IP"
  depends_on = [azurerm_public_ip.example_public_ip]
}
output "vm_username" {
  value = azurerm_virtual_machine.Windows.os_profile_windows_config[0].admin_username
  description = "Username"
  depends_on = [azurerm_public_ip.example_public_ip]
}
output "vm_password" {
  value = azurerm_virtual_machine.Windows.os_profile_windows_config[0].admin_password
  description = "Password"
  depends_on = [azurerm_public_ip.example_public_ip]
}
output "vm_size" {
  value = azurerm_virtual_machine.Windows[count.index]
  description = "VM Size"
  depends_on = [azurerm_public_ip.example_public_ip]
}



