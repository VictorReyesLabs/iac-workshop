provider "azurerm" {
  features {}
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
