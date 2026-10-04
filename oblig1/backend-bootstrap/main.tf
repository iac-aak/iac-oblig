# Bootstrap-stack for state-backend og Key Vault (keyVault.tf). Ingen backend-blokk: state er lokal.
# Allerede rullet ut i øving 5 (state ligger lokalt der). Ligger her for å vise hvor backend-en kommer fra.
# Rolletildelingene til pipeline-identiteten ligger her og i keyVault.tf.

provider "azurerm" {
  features {}

  resource_providers_to_register = [
    "Microsoft.Storage",
    "Microsoft.Authorization",
    "Microsoft.KeyVault",
  ]
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {}

locals {
  tags = {
    keep      = "true" # freder ressursgruppa mot nattlig sletting
    purpose   = "terraform-backend"
    owner     = var.shortname
    managedby = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = format("rg-tfstate-%s", var.shortname)
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "sa" {
  name                            = lower(format("satfstate%s", var.shortname)) # globalt unikt
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  shared_access_key_enabled       = false # kun Entra ID-tilgang
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false

  blob_properties { # versjonering og soft delete på state
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "blob_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "pipeline_blob_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.pipeline_principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_storage_account.sa,
    azurerm_storage_container.tfstate
  ]
}