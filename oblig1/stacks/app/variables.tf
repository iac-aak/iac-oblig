variable "name_prefix" {
  type        = string
  description = "Personlig kortnavn (aak). Tenanten er delt, så det skal inn i alle navn."

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.name_prefix))
    error_message = "name_prefix må være 2–8 små bokstaver eller tall."
  }
}

variable "owner" {
  type        = string
  description = "Eier (e-post), brukes i tags."
}

variable "environment" {
  type        = string
  description = "dev, test eller prod."

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "environment må være dev, test eller prod."
  }
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure-region."
}

# De tre backend_*-variablene settes av workflowen fra shared/backend.hcl,
# slik at storage account-navnet bare står ett sted (K5).
variable "backend_resource_group_name" {
  type        = string
  description = "Ressursgruppa med state-kontoen. Kommer fra shared/backend.hcl."
}

variable "backend_storage_account_name" {
  type        = string
  description = "State-kontoen. Kommer fra shared/backend.hcl."
}

variable "backend_container_name" {
  type        = string
  description = "Containeren med state-filene. Kommer fra shared/backend.hcl."
}

variable "vm_subnet_key" {
  type        = string
  default     = "app"
  description = "Nøkkel i nettverkets subnet_ids for subnettet VM-en havner i."
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2as_v2"
  description = "VM-SKU."
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Admin-bruker på VM-en."
}

variable "ssh_public_key" {
  type        = string
  description = "Offentlig SSH-nøkkel. Ingen passord, så det ligger ikke noe hemmelig i state."
}
