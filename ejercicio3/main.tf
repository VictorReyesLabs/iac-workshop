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

# ============================
# Random Suffix para evitar conflictos
# ============================
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# ============================
# Resource Group
# ============================
resource "azurerm_resource_group" "rg" {
  name     = "iac-compliance-rg-${random_string.suffix.result}"
  location = "eastus"

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}

# ============================
# Network Security Group (NSG)
# ============================
resource "azurerm_network_security_group" "nsg" {
  name                = "iac-nsg-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Deny-Internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"         
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

# ============================
# Virtual Network & Subnet
# ============================
resource "azurerm_virtual_network" "vnet" {
  name                = "iac-vnet-${random_string.suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "iac-subnet-${random_string.suffix.result}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ============================
# Network Interface
# ============================
resource "azurerm_network_interface" "nic" {
  name                = "iac-nic-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# ============================
# Virtual Machine
# ============================
resource "azurerm_windows_virtual_machine" "vm" {
  name                = "iac-vm-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "P@ssword1234!"
  network_interface_ids = [azurerm_network_interface.nic.id]

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

  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}
