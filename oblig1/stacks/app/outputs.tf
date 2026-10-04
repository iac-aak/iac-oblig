output "vm_name" {
  value       = module.compute.vm_name
  description = "Navnet på VM-en."
}

output "private_ip_address" {
  value       = module.compute.private_ip_address
  description = "Privat IP-adresse til VM-en i subnettet."
}
