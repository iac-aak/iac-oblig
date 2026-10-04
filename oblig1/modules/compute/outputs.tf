output "vm_name" {
  value       = azurerm_linux_virtual_machine.vm.name
  description = "VM-navn."
}

output "vm_id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "VM-ID."
}

output "private_ip_address" {
  value       = azurerm_network_interface.nic.private_ip_address
  description = "Privat IP i subnettet."
}
