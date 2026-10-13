# Azure Virtual Network and Server Module

This module creates a resource group, virtual network, subnet, network security group, public IP, network interface, and Ubuntu 22.04 Linux virtual machine. Cloud-init installs and starts NGINX at first boot. Inbound HTTP is disabled unless `allowed_http_cidr` is set; SSH requires a single `/32` administrator address. Outbound internet traffic is limited to TCP ports 80 and 443.

## Requirements

- Terraform 1.5 or later.
- AzureRM provider 4.x and an authenticated Azure subscription with permission to create resource groups, networking resources, public IPs, and Linux virtual machines.
- A region with the selected VM size and Ubuntu image available, plus quota for a public IP and VM.
- An SSH public key and administrator public IPv4 CIDR. Do not supply or commit the private key.

The calling root module must configure Azure authentication and the provider. For example:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

module "web_server" {
  source = "./modules/azure-vnet-server"

  name                 = "demo-web"
  location             = "East US"
  admin_ssh_public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
  allowed_ssh_cidr     = "203.0.113.10/32"
  allowed_http_cidr    = "203.0.113.10/32"

  tags = {
    Environment = "demo"
  }
}

output "web_url" {
  value = module.web_server.web_url
}
```

Replace the example subscription ID and SSH CIDR with your values. The AzureRM provider can also obtain the subscription ID and credentials from its supported environment or CLI authentication settings.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | `iac-demo` | Lowercase prefix of 1 to 20 letters, numbers, or hyphens. |
| `location` | `string` | Required | Azure region for resources. |
| `address_space` | `string` | `10.20.0.0/16` | Virtual network IPv4 range. |
| `subnet_prefix` | `string` | `10.20.1.0/24` | Subnet range; must be contained in the virtual network range. |
| `vm_size` | `string` | `Standard_B1s` | Azure VM size; availability depends on region and subscription quota. |
| `admin_username` | `string` | `azureuser` | Linux administrator username. |
| `admin_ssh_public_key` | `string` | Required | Public key installed for SSH. Terraform masks it in normal output, but stores it in state. |
| `allowed_ssh_cidr` | `string` | Required | One administrator IPv4 address in `/32` form. |
| `allowed_http_cidr` | `string` | `null` | Optional IPv4 CIDR allowed to use HTTP; unset disables inbound HTTP. Use `0.0.0.0/0` only when public access is intentional. |
| `tags` | `map(string)` | `{}` | Tags applied to supported resources. |

## Outputs

| Name | Description |
| --- | --- |
| `resource_group_name` | Resource group containing the resources. |
| `public_ip` | Server static public IPv4 address. |
| `web_url` | NGINX page URL. |
| `ssh_command` | Example SSH command; add `-i <private-key-path>` if required. |

## Security Notes

The VM still receives a public IPv4 address, but no inbound HTTP rule is created unless an allowed CIDR is supplied. SSH accepts only a single `/32` address. Outbound internet traffic is limited to TCP/80 and TCP/443 for package updates and web traffic; Azure virtual-network traffic remains governed by Azure's default rules. Terraform state contains the public IP, SSH public key, and cloud resource identifiers; a public key may identify its owner. Never commit state or plan files, use encrypted access-controlled remote state, use a dedicated key rather than a personal key, and do not provide a private key or put personal details in resource tags.

## Deploy and Clean Up

From the calling root configuration directory:

```sh
terraform init
terraform plan
terraform apply
terraform output web_url
terraform destroy
```

Review the plan before applying. The VM, managed disk, and public IP may incur charges while allocated. The module does not create HTTPS, backups, monitoring, or production-grade high availability. Destroy resources when they are no longer needed.