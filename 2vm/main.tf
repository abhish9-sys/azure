

variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "subnet_one" {}
variable "subnet_two" {}
variable "address_space_vn" {}
variable "address_prefix_subnet_one" {}
variable "address_prefix_subnet_two" {}
variable "location_one" {}
variable "nic_one" {}
variable "nic_two" {}
variable "location_two" {}
variable "name_two" {}
variable "name_one" {}



provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "my_rg" {
  location = var.location_one
  name     = var.resource_group_name
}


resource "azurerm_virtual_network" "my_vin" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = [var.address_space_vn]

}
resource "azurerm_subnet" "my_subnet_one" {
  name                 = var.subnet_one
  resource_group_name  = azurerm_resource_group.my_rg.location
  virtual_network_name = azurerm_virtual_network.my_vin.name
  address_prefixes     = [var.address_prefix_subnet_one]

}

resource "azurerm_subnet" "my_subnet_two" {
  name                 = var.subnet_two
  resource_group_name  = azurerm_resource_group.my_rg.location
  virtual_network_name = var.location_two
  address_prefixes     = [var.address_prefix_subnet_two]

}


resource "azurerm_network_interface" "nic-1" {
  name                = var.nic_one
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet_one.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_network_interface" "nic-2" {
  name                = var.nic_two
  location            = var.location_two
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet_two.id
    private_ip_address_allocation = "Dynamic"
  }
}




resource "azurerm_linux_virtual_machine" "vm_one" {
  name                = var.name_one
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = var.location_one
  size                = "Standard_F2"
  admin_username      = "admin"
  network_interface_ids = [
    azurerm_network_interface.nic-2.id,
  ]

  admin_ssh_key {
    username   = "admin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm_two" {
  name                = var.name_two
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = var.location_two
  size                = "Standard_F2"
  admin_username      = "admin"
  network_interface_ids = [
    azurerm_network_interface.nic-2.id,
  ]

  admin_ssh_key {
    username   = "admin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}