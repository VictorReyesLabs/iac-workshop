terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.6"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "ad1c7261-a22e-4e76-ae4b-84f4b3782f47"
  client_id       = ""
  client_secret   = ""
  tenant_id       = "0ee8eee4-3cdf-462b-bca3-972380180550"
}

# Generar sufijo aleatorio
resource "random_string" "suffix" {
  length  = 2
  upper   = false
  special = false
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "iac-compliance-rg-${random_string.suffix.result}"
  location = var.location
}

# VNet + Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "iac-vnet-${random_string.suffix.result}"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "iac-subnet-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

# NIC para la VM permitida
resource "azurerm_network_interface" "nic_allowed" {
  name                = "iac-nic-allowed-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# NIC para la VM no permitida
resource "azurerm_network_interface" "nic_denied" {
  name                = "iac-nic-denied-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# VM con tamaño permitido 
resource "azurerm_windows_virtual_machine" "vm_allowed" {
  name                = "vm${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # permitido
  admin_username      = "azureuser"
  admin_password      = "P@ssword1234!"
  network_interface_ids = [azurerm_network_interface.nic_allowed.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# VM con tamaño NO permitido 
resource "azurerm_windows_virtual_machine" "vm_denied" {
  name                = "vm${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3" # NO permitido
  admin_username      = "azureuser"
  admin_password      = "P@ssword1234!"
  network_interface_ids = [azurerm_network_interface.nic_denied.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
