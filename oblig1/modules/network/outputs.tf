# Map, ikke liste: gir oppslag på navn, f.eks. subnet_ids["web"].
output "subnet_ids" {
  value       = { for k, s in azurerm_subnet.subnet : k => s.id }
  description = "Subnet-ID per subnettnavn."
}

output "subnet_prefixes" {
  value       = { for k, s in azurerm_subnet.subnet : k => s.address_prefixes[0] }
  description = "Utregnet adresseprefiks per subnettnavn."
}

output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "ID-en til vnet."
}

output "vnet_name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Navnet på vnet."
}
