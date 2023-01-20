

variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "subnet" {}
variable "address_space_vn" {}
variable "address_prefix_subnet" {}
variable "location" {}
variable "nic" {}


provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}

resource "azurerm_resource_group" "my_rg" {
  location = var.location
  name     = var.resource_group_name
}


resource "azurerm_virtual_network" "my_vin" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = [var.address_space_vn]

}
resource "azurerm_subnet" "my_subnet" {
  name                 = var.subnet
  resource_group_name  = azurerm_resource_group.my_rg.location
  virtual_network_name = azurerm_virtual_network.my_vin.name
  address_prefixes     = [var.address_prefix_subnet]

}


resource "azurerm_network_interface" "example" {
  name                = var.nic
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


output "virtual_network_id" { value = azurerm_virtual_network.my_vin.id }