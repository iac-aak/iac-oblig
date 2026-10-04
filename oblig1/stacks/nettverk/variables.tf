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

variable "address_space" {
  type        = string
  description = "Miljøets adresserom, f.eks. 10.170.0.0/16."
}

variable "subnets" {
  type        = map(number)
  description = "Subnett: navn => netnum i adresserommet."
}
