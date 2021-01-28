#Configure the Azure Provider
provider "azurerm" {
  version = "=2.43.0"
  client_id       =   var.client_id
  client_secret   =   var.client_secret
  subscription_id =   var.subscription_id
  tenant_id       =   var.tenant_id
  use_msi = true
  features {}
}
#Create Resource Group
resource "azurerm_resource_group" "azure-rg" {
  name = "${var.app_name}-${var.app_environment}-rg"
  location = var.rg_location
}
#Create a virtual network
resource "azurerm_virtual_network" "azure-vnet" {
  name = "${var.app_name}-${var.app_environment}-vnet"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location = var.rg_location
  address_space = [var.azure_vnet_cidr]
  tags = {
    environment = var.app_environment
  }
}

#Create a subnet frontend
resource "azurerm_subnet" "azure-subnetfrontend" {
  name = "${var.app_name}-${var.app_environment}-subnetfrontend"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = azurerm_virtual_network.azure-vnet.name
  address_prefix = var.azure_subnet_cidr_frontend
}

#Create a subnet backend
resource "azurerm_subnet" "azure-subnetbackend" {
  name = "${var.app_name}-${var.app_environment}-subnetbackend"
  resource_group_name  = azurerm_resource_group.azure-rg.name
  virtual_network_name = azurerm_virtual_network.azure-vnet.name
  address_prefix = var.azure_subnet_cidr_backend
}


# # #Get a Static Public IP
resource "azurerm_public_ip" "azure-web-ip" {
  name = "${var.app_name}-${var.app_environment}-web-ip"
  location = azurerm_resource_group.azure-rg.location
  resource_group_name = azurerm_resource_group.azure-rg.name
  allocation_method = "Dynamic"
  tags = {
    environment = var.app_environment
  }
}

###Azure load Blacker####


# resource "azurerm_lb" "vmss" {
#   name                = "${var.app_name}-${var.app_environment}-vmss-lb"
#   location            = azurerm_resource_group.azure-rg.location
#   resource_group_name = azurerm_resource_group.azure-rg.name

#   frontend_ip_configuration {
#     name                 = "PublicIPAddress"
#     public_ip_address_id = azurerm_public_ip.azure-web-ip.id
#   }

#   tags = {
#     environment = var.app_environment
#   }
# }

# resource "azurerm_lb_backend_address_pool" "bpepool" {
#   resource_group_name = azurerm_resource_group.azure-rg.name
#   loadbalancer_id     = azurerm_lb.vmss.id
#   name                = "BackEndAddressPool"
# }

###application loadbalancer###


#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.azure-vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.azure-vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.azure-vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.azure-vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.azure-vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.azure-vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.azure-vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "${var.app_name}-${var.app_environment}-appgateway"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = var.rg_location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "${var.app_name}-${var.app_environment}-gateway-ip-configuration"
    subnet_id = azurerm_subnet.azure-subnetfrontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.azure-web-ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

# resource "azurerm_lb_probe" "vmss" {
#   resource_group_name = azurerm_resource_group.azure-rg.name
#   loadbalancer_id     = azurerm_lb.vmss.id
#   name                = "ssh-running-probe"
#   port                = var.application_port
# }

# resource "azurerm_lb_rule" "lbnatrule" {
#   resource_group_name            = azurerm_resource_group.azure-rg.name
#   loadbalancer_id                = azurerm_lb.vmss.id
#   name                           = "http"
#   protocol                       = "Tcp"
#   frontend_port                  = var.application_port
#   backend_port                   = var.application_port
#   backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
#   frontend_ip_configuration_name = "PublicIPAddress"
#   probe_id                       = azurerm_lb_probe.vmss.id
# }

###vm scale set##

data "azurerm_resource_group" "image" {
  name = "myResourceGroup"
}

data "azurerm_image" "image" {
  name                = "dev-azure-ui-1611723142"
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "${var.app_name}-${var.app_environment}-vmscaleset"
  location            = var.rg_location
  resource_group_name = azurerm_resource_group.azure-rg.name
  upgrade_policy_mode = "Manual"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 1
  }

  storage_profile_image_reference {
    id=data.azurerm_image.image.id
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun          = 0
    caching        = "ReadWrite"
    create_option  = "Empty"
    disk_size_gb   = 10
  }

  os_profile {
    computer_name_prefix = var.linux_vm_hostname
    admin_username       = var.linux_admin_user
    admin_password       = var.linux_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/tfadmin/.ssh/authorized_keys"
      key_data = file("~/id_rsa.pub")
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.azure-subnetbackend.id
      application_gateway_backend_address_pool_ids =["${azurerm_application_gateway.network.backend_address_pool[0].id}"]
      #load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      primary = true
    }
  }
  
  tags = {
    environment = var.app_environment
  }
}

###autoscalling monitor####
resource "azurerm_monitor_autoscale_setting" "vmss" {
  name                = "${var.app_name}-${var.app_environment}-myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.azure-rg.name
  location            = var.rg_location
  target_resource_id  = azurerm_virtual_machine_scale_set.vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 70
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["pankaj.kumar3@genpact.digital"]
    }
  }
}




#Output
output "azure-web-server-external-ip" {
  value = azurerm_public_ip.azure-web-ip.ip_address
}