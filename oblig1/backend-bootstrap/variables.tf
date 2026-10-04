variable "shortname" {
  type        = string
  description = "Personlig kortnavn, brukes i navn på ressurser (globalt unikt storage account)."
}

variable "pipeline_principal_id" {
  type        = string
  description = "Object-ID til service principal-en workflowen logger inn som"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure-region."
}

variable "container_name" {
  type        = string
  default     = "tfstate"
  description = "Navn på containeren som holder state-filene."
}
