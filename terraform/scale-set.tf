resource "azurerm_subnet" "subnet_app" {
  name                 = "subnet_app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss_app" {
  name                = "g2-vmss"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "superman"

  admin_ssh_key {
    username   = "superman"
    disable_password_authentication = true
    public_key = azurerm_ssh_public_key.ssh_key.public_key
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }

  custom_data = data.cloudinit_config.cloud-init.rendered


  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nicss"
    primary = true

    ip_configuration {
      name      = "nic_app_config"
      primary   = true
      subnet_id = azurerm_subnet.subnet_app.id
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "mon_auto_scl" {
  name                = "myAutoscaleSetting"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss_app.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss_app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

  }

  notification {
    email {
      custom_emails                         = ["sarais.gabriel@gmail.com"]
      custom_emails                         = ["alain.caupin@gmail.com"]
      custom_emails                         = ["bstewart.ext@simplon.co"]
      custom_emails                         = ["asawaya.ext@simplon.co"]

    }
  }
}