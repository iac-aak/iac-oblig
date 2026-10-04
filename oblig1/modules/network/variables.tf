variable "rg_name" {
  type        = string
  description = "Ressursgruppa nettverket ligger i."
}

variable "location" {
  type        = string
  description = "Azure-region."
}

variable "base_name" {
  type        = string
  description = "Navnegrunnlag, f.eks. dev-aak. Modulen legger til vnet-, snet- og nsg-."
}

variable "address_space" {
  type        = string
  description = "Adresserom som CIDR, f.eks. 10.162.0.0/16."

  validation {
    condition     = can(cidrhost(var.address_space, 0))
    error_message = "address_space må være en gyldig CIDR-blokk."
  }
}

variable "subnets" {
  type        = map(number)
  description = "Subnett: navn => netnum i adresserommet."
}

variable "subnet_newbits" {
  type        = number
  default     = 8
  description = "Bit lagt til prefikset. 8 gir /24 av et /16."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags fra miljøet."
}
