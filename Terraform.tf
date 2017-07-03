provider "azurerm" {
subscription_id = "0ced39cc-d447-4684-8b46-51678e6373de"
client_id = "279f0d98-206d-410b-ac1b-73de27a2663c"
client_secret = "fL2wy7sxhBkxrvRwIQrNTqlEIdom4yuNteyPwQBjP4M="
#client_id	="TwapXCV5oE1UOwsGNuGnReOkJQM4lThNuxOl9dQtui0="
tenant_id = "affe6091-e67b-4cbe-8408-4d3024cd87e5"
}

resource "azurerm_resource_group" "JumpHost2" {
  name      = "JumpHost2"
  location  = "Australia East"
}

resource "azurerm_virtual_network" "vNetTerraform" {
  name                = "vNetTerraform"
  address_space       = ["10.1.0.0/16"]
  location            = "${azurerm_resource_group.JumpHost2.location}"
  resource_group_name = "${azurerm_resource_group.JumpHost2.name}"
}

resource "azurerm_subnet" "Mng_subnet" {
  name                 = "MngSub"
  resource_group_name  = "${azurerm_resource_group.JumpHost2.name}"
  virtual_network_name = "${azurerm_virtual_network.vNetTerraform.name}"
  address_prefix       = "10.1.3.0/24"
}

resource "azurerm_subnet" "Fsub" {
  name                 = "FrontendSub"
  resource_group_name  = "${azurerm_resource_group.JumpHost2.name}"
  virtual_network_name = "${azurerm_virtual_network.vNetTerraform.name}"
  address_prefix       = "10.1.1.0/24"
}
resource "azurerm_subnet" "Bsub" {
  name                 = "BackendSub"
  resource_group_name  = "${azurerm_resource_group.JumpHost2.name}"
  virtual_network_name = "${azurerm_virtual_network.vNetTerraform.name}"
  address_prefix       = "10.1.2.0/24"
}
