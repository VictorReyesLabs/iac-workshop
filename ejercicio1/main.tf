provider "azurerm" {
  features {}
  subscription_id = "7952a45c-f068-4cd6-82d2-658dcfd731be"
  tenant_id       = "0ee8eee4-3cdf-462b-bca3-972380180550"
}

resource "azurerm_resource_group" "rg" {
  name     = "iac-compliance-rg"
  location = "eastus"
}

resource "azurerm_storage_account" "storage" {
  name                     = "iaccompliancestorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}
