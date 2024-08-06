terraform {
  required_providers {
    equinix = {
      source  = "equinix/equinix"
    }
  }

  cloud {
    organization = "EQIX_projectX"

    workspaces {
      name = "metal-apac"
    }
  }
}

data "equinix_network_device" "vd_pri" {
  name       = "vd-${var.metro_code}-${var.username}-pre"
  depends_on = [module.ne]
}
data "equinix_network_device" "vd_sec" {
  name       = "vd-${var.sec_metro_code}-${var.username}-sec"
  depends_on = [module.ne]
}
data "equinix_metal_device" "terminal" {
  project_id = var.project_id
  hostname   = "metal-${var.metro_code}-node-1"
  lifecycle {
    precondition {
      condition     = "metal-${var.metro_code}-node-1" == "metal-${var.metro_code}-node-1"
      error_message = "You may want to provision metal instance before running this module"
    }
  }
}
data "terraform_remote_state" "bgp" {
  backend = "remote"

  config = {
    organization = "EQIX_projectX"
    workspaces = {
      name = "metal-apac"
    }
  }
}

module "ne" {
  source             = "github.com/Eqix-ProjectX/terraform-equinix-networkedge-vnf/"
  core_count         = var.core_count
  metro_code         = var.metro_code
  notifications      = var.notifications
  package_code       = var.package_code
  account_number     = var.account_number
  sec_account_number = var.sec_account_number
  sec_metro_code     = var.sec_metro_code
  type_code          = var.type_code
  ver                = var.ver
  username           = var.username
  key_name           = var.key_name
  acl_template_id    = var.acl_template_id
}

# netmiko portion for restconf readiness
locals {
  config = <<-EOF
  from netmiko import ConnectHandler

  pri = {
    'device_type': 'cisco_xe',
    'host'       : '${data.equinix_network_device.vd_pri.ssh_ip_address}',
    'username'   : '${var.username}',
    'password'   : '${data.equinix_network_device.vd_pri.vendor_configuration.adminPassword}'
  }

  sec = {
    'device_type': 'cisco_xe',
    'host'       : '${data.equinix_network_device.vd_sec.ssh_ip_address}',
    'username'   : '${var.username}',
    'password'   : '${data.equinix_network_device.vd_sec.vendor_configuration.adminPassword}'
  }

  ha = [pri, sec]

  for i in ha:
    net_connect = ConnectHandler(**i)
    config_commands = [
      'ip http secure-server',
      'restconf'
    ]
    output = net_connect.send_config_set(config_commands)
    print(output)
  EOF
}
locals {
  ssh_private_key = base64decode(var.private_key)
}

resource "null_resource" "cisco" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = local.ssh_private_key
      host        = data.equinix_metal_device.terminal.access_public_ipv4
    }

    inline = [
      "apt install python3-pip -y",
      "y",
      "pip install netmiko",
      "y",
      "cat << EOF > ~/restconf.py\n${local.config}\nEOF",
      "python3 restconf.py"
    ]
  }
}