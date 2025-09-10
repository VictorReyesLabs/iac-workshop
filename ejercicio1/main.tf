
provider "azurerm" {
  features {}

  subscription_id = "ad1c7261-a22e-4e76-ae4b-84f4b3782f47"
  client_id       = ""
  client_secret   = ""
  tenant_id       = "0ee8eee4-3cdf-462b-bca3-972380180550"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = "iac-compliance-rg-${random_string.suffix.result}"
  location = "eastus"
}

resource "azurerm_storage_account" "storage" {
  name                     = "iaccompliancestg${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}
