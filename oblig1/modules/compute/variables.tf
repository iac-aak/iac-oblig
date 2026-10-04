variable "rg_name" {
  type        = string
  description = "Ressursgruppa VM-en ligger i."
}

variable "location" {
  type        = string
  description = "Azure-region."
}

variable "base_name" {
  type        = string
  description = "Navnegrunnlag, f.eks. dev-aak. Modulen legger til nic- og vm-."
}

variable "subnet_id" {
  type        = string
  description = "Subnettet nettverkskortet kobles til."
}

variable "vm_size" {
  type        = string
  description = "VM-SKU, f.eks. Standard_B2as_v2."

  # ARM-SKU-ene (med «al») er utelatt fordi imaget er x86-64.
  validation {
    condition = contains([
      "Standard_B2as_v2", "Standard_B4as_v2",
      "Standard_D2s_v5", "Standard_D4s_v5",
      "Standard_D2s_v6", "Standard_D4s_v6",
      "Standard_E2s_v5", "Standard_E4s_v5",
      "Standard_E2s_v6", "Standard_E4s_v6",
    ], var.vm_size)
    error_message = "vm_size må være en tillatt x86-64-SKU."
  }
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Admin-bruker på VM-en."
}

variable "ssh_public_key" {
  type        = string
  description = "Offentlig SSH-nøkkel."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags fra miljøet."
}
