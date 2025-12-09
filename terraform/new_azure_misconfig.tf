# Azure Storage Account without logging and public access enabled
resource "azurerm_storage_account" "public_storage" {
  name                     = "publicstorageacct"
  resource_group_name      = "rg"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true # Violates: Public access enabled
}

# Azure VM with public IP
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "vm-public-ip"
  resource_group_name = "rg"
  location            = "eastus"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "insecure_nsg" {
  name                = "insecure-nsg"
  resource_group_name = "rg"
  location            = "eastus"

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Azure AD Sign-In Logs not enabled (no diagnostic settings)
