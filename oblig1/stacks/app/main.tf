# Consumer stack: leser nettverkets subnett-ID fra remote state og lager VM-en.
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
    "Microsoft.Compute",
  ]
}

# Navnekonvensjon (K3): <type>[-<rolle>]-<miljø>-<kortnavn>,
# f.eks. rg-app-dev-aak og vm-dev-aak.
locals {
  base_name = lower(format("%s-%s", var.environment, var.name_prefix))
  rg_name   = format("rg-app-%s", local.base_name)

  # Samme mønster som workflowen bruker i -backend-config="key=...".
  nettverk_state_key = format("%s/nettverk.tfstate", var.environment)

  common_tags = {
    environment = var.environment
    owner       = var.owner
    stack       = "app"
    managedby   = "terraform"
  }
}

# Leser den ANDRE stackens state (K9). key peker på nettverk, ikke på app.
# Adressen til state-kontoen kommer fra shared/backend.hcl via TF_VAR_backend_*.
data "terraform_remote_state" "nettverk" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = local.nettverk_state_key
    use_azuread_auth     = true
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  rg_name        = azurerm_resource_group.rg.name
  location       = var.location
  base_name      = local.base_name
  vm_size        = var.vm_size
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key
  tags           = local.common_tags

  subnet_id = data.terraform_remote_state.nettverk.outputs.subnet_ids[var.vm_subnet_key]
}
