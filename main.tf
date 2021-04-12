############## Creacion grupo de recursos grupo 1 #############################
resource "azurerm_resource_group" "resourcegroup" {
  name = var.name
  location = var.location
  tags = {
    "diplomado" = "rg-grupo1-mjs"
  }
}


####################### configuraciones de red #############################

######################## creacion ip publica #####################
resource "azurerm_public_ip" "publicip-grupo1" {
  name = "publicip-grupo1"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
  allocation_method = "Static"
}

######################## creacion virtual network #####################
resource "azurerm_virtual_network" "virtualnet-grupo1" {
  name = "aks-vn-grupo1-mjs"
  address_space = [ "24.0.0.0/16" ]
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
}

######################## creacion subnet #####################
resource "azurerm_subnet" "subnet-grupo1" {
  name = "internal-grupo1"
  address_prefixes = [ "24.0.0.0/24" ]
  resource_group_name = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.virtualnet-grupo1.name
}

######################## creacion interfaz de red #####################
resource "azurerm_network_interface" "networkinterface-grupo1" {
  name = "networkinterface-grupo1"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
  ip_configuration {
    name = "grupo1-internal"
    subnet_id = azurerm_subnet.subnet-grupo1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.publicip-grupo1.id
  }
}

####################### fin configuraciones de red #################


######################## creacion VM linux #####################
resource "azurerm_linux_virtual_machine" "vm-grupo1" {
  name = "vm-grupo1"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
  size = "Standard_B1s"
  network_interface_ids = [
    azurerm_network_interface.networkinterface-grupo1.id    
  ]
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }

  computer_name = "hostname"
  admin_username = "adminuser"
  admin_password = "Password1234!"

  disable_password_authentication = false

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

######################## fin creacion VM linux #####################


######################## configuraciones cluster K8 #####################

######################## creacion cluster kubernete #####################
resource "azurerm_kubernetes_cluster" "aks-grupo1-mjs" {
  name = "aks-grupo1-mjs"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location = azurerm_resource_group.resourcegroup.location
  dns_prefix = "aksgrupo1mjs"
  kubernetes_version = "1.19.6"
  
  ######################## configurar nodo por defecto #####################
  default_node_pool {
    name = "default"
    node_count = 1
    vm_size = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.subnet-grupo1.id
    enable_auto_scaling = true
    min_count = 1
    max_count = 3
    max_pods = 80
  }

  ######################## configurar red y politicas de azure #####################
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  ######################## habilitar rbac #####################
  role_based_access_control {
    enabled = true
  }

  ######################## configuraciones principales (aca se puede habilitar active directory)#####################
  service_principal {
    client_id = "3aae846a-bd37-4552-8859-e75397b929c4"
    client_secret = "SFx~R_-oswoY3M.NbCYr915-p6-rp17-6G"

  }
}

######################## configurar nodo kubernetes adicional #####################
resource "azurerm_kubernetes_cluster_node_pool" "aks-rep-grupo1-mjs" {
  name = "adicional"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-grupo1-mjs.id
  node_count = 1
  vm_size = "Standard_D2_v2"
  enable_auto_scaling = true
  min_count = 1
  max_count = 3
  max_pods = 80

  tags = {
    "node-description" = "adicional"
  }
}

######################## fin configuraciones cluster K8 #####################

variable "name" {
  
}
variable "location" {
  
}