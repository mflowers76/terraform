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
resource "azurerm_network_interface" "JumpNic1" 
{
  name                = "Jump_Nic"
  location            = "${azurerm_resource_group.JumpHost2.location}"
  resource_group_name = "${azurerm_resource_group.JumpHost2.name}"

  ip_configuration 
	{
    name                          = "JumpConfiguration1"
	subnet_id						= "${azurerm_subnet.Mng_subnet.id}"
    private_ip_address_allocation = "dynamic"
	public_ip_address_id          = "${azurerm_public_ip.jh01.id}"
	}
}
resource "azurerm_public_ip" "jh01" 
	{
	name = "jh01_pubip"
	location = "${azurerm_resource_group.JumpHost2.location}"
	resource_group_name = "${azurerm_resource_group.JumpHost2.name}"
	public_ip_address_allocation = "dynamic"
	}

### STORAGE
##################
resource "azurerm_storage_account" "JumpHost2" {
  name                = "TerraJump1976"
  resource_group_name = "${azurerm_resource_group.JumpHost2.name}"
  location            = "${azurerm_resource_group.JumpHost2.location}"
  account_type        = "Standard_LRS"

  tags {
    environment = "JumpHost2"
	Deployment = "Jenkins_Terra"
	DeploymentTime = "1/07/2017"
  }
}

### VIRTUAL MACHINE
##################
resource "azurerm_storage_container" "JumpHost2" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.JumpHost2.name}"
  storage_account_name  = "${azurerm_storage_account.JumpHost2.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "JumpHost2" {
  name                  = "JumpHost2VM1"
  location              = "${azurerm_resource_group.JumpHost2.location}"
  resource_group_name   = "${azurerm_resource_group.JumpHost2.name}"
  network_interface_ids = ["${azurerm_network_interface.JumpNic1.id}"]
  vm_size               = "Standard_A1"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.JumpHost2.primary_blob_endpoint}${azurerm_storage_container.JumpHost2.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "JumpHost2"
    admin_username = "vmadmin"
    admin_password = "Password1234!"
  }

  tags {
    environment = "JumpHost2"
	Deployment = "Jenkins_Terra"
	DeploymentTime = "1/07/2017"
  }
}