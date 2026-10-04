# Provider stack: lager nettverket og publiserer subnett-ID-ene (se outputs.tf).
# Samme kode for alle miljøer – miljøet er variabelen environment (K4).

terraform {
  required_version = ">= 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.7"
    }
  }
}

provider "azurerm" {
  features {}

  # Fra azurerm 5.0 registreres ingen resource providers automatisk.
  resource_providers_to_register = [
    "Microsoft.Network",
  ]
}

# Navnekonvensjon (K3): <type>[-<rolle>]-<miljø>-<kortnavn>,
# f.eks. rg-nettverk-dev-aak og snet-web-dev-aak.
# Modulene får base_name og legger selv på type og rolle.
locals {
  base_name = lower(format("%s-%s", var.environment, var.name_prefix))
  rg_name   = format("rg-nettverk-%s", local.base_name)

  common_tags = {
    environment = var.environment
    owner       = var.owner
    stack       = "nettverk"
    managedby   = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source = "../../modules/network"

  rg_name       = azurerm_resource_group.rg.name
  location      = var.location
  base_name     = local.base_name
  address_space = var.address_space
  subnets       = var.subnets
  tags          = local.common_tags
}
