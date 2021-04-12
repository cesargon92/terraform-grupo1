output "publicip" {
  value = azurerm_public_ip.publicip-grupo1.ip_address
}

output "username" {
  value = azurerm_linux_virtual_machine.vm-grupo1.admin_username
}

output "password" {
  value = azurerm_linux_virtual_machine.vm-grupo1.admin_password
}