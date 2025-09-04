output "vm_allowed_name" {
  value = azurerm_windows_virtual_machine.vm_allowed.name
}

output "vm_denied_name" {
  value = azurerm_windows_virtual_machine.vm_denied.name
}
