terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.7"
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = format("vnet-%s", var.base_name)
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.address_space]
  tags                = var.tags
}

# for_each på map: nøkkelen ("web") er identiteten i state, ikke posisjonen.
resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = format("snet-%s-%s", each.key, var.base_name)
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name

  # netnum kommer fra mapet, ikke fra index(), så et subnett beholder adressen
  # sin om andre legges til eller fjernes.
  address_prefixes = [cidrsubnet(var.address_space, var.subnet_newbits, each.value)]
}

# Ingen egne regler – Azures standardregler holder.
resource "azurerm_network_security_group" "nsg" {
  name                = format("nsg-%s", var.base_name)
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
}

# for_each over subnet-ressursen gir samme nøkler, så koblingene følger subnettene.
resource "azurerm_subnet_network_security_group_association" "snet_nsg" {
  for_each = azurerm_subnet.subnet

  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
