terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "7952a45c-f068-4cd6-82d2-658dcfd731be"
  tenant_id       = "0ee8eee4-3cdf-462b-bca3-972380180550"
}

resource "azurerm_resource_group" "rg" {
  name     = "iac-compliance-rg-storage"
  location = "eastus"
}

resource "azurerm_storage_account" "storage" {
  name                     = "iacstor${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "workshop"
  }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}
