# Terraform AWS and Azure Examples

This repository contains two independent Terraform modules. Each provisions a small public network and an Ubuntu Linux web server that serves the default NGINX page:

- [AWS VPC and server module](modules/aws-vpc-server/README.md)
- [Azure virtual network and server module](modules/azure-vnet-server/README.md)

The modules are provider-specific because AWS and Azure have different networking and compute resources. Use the module for your target cloud; you can use either module in a larger Terraform configuration.

## Prerequisites

- Terraform CLI 1.5 or later; both modules were validated with Terraform 1.13.0.
- An AWS account and credentials configured through the AWS provider's normal credential chain to use the AWS module.
- An Azure subscription and AzureRM credentials configured through the provider's normal authentication methods to use the Azure module.
- An SSH public key and the public IPv4 CIDR from which you will connect (for example, `203.0.113.10/32`). The private key stays on your machine.

Each module configures its provider requirement but does not configure credentials or a provider block. Configure the provider in the calling root module.

## AWS Quick Start

Create a root configuration and call the module:

```hcl
terraform {
	required_providers {
		aws = {
			source  = "hashicorp/aws"
			version = "~> 5.0"
		}
	}
}

provider "aws" {
	region = "us-east-1"
}

module "web_server" {
	source = "./modules/aws-vpc-server"

	name              = "demo-web"
	ssh_public_key    = file(pathexpand("~/.ssh/id_ed25519.pub"))
	allowed_ssh_cidr  = "203.0.113.10/32"
	allowed_http_cidrs = ["203.0.113.10/32"]
}

output "web_url" {
	value = module.web_server.web_url
}
```

Run `terraform init`, `terraform plan`, and `terraform apply` from the root configuration directory. Open the resulting URL to view the NGINX page. See the [AWS module README](modules/aws-vpc-server/README.md) for all inputs and outputs.

## Azure Quick Start

Create a root configuration and call the module:

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

	name                  = "demo-web"
	location              = "East US"
	admin_ssh_public_key  = file(pathexpand("~/.ssh/id_ed25519.pub"))
	allowed_ssh_cidr      = "203.0.113.10/32"
	allowed_http_cidr     = "203.0.113.10/32"
}

output "web_url" {
	value = module.web_server.web_url
}
```

Set `subscription_id` to your subscription ID, or provide it through your AzureRM provider configuration. Run `terraform init`, `terraform plan`, and `terraform apply` from the root configuration directory. See the [Azure module README](modules/azure-vnet-server/README.md) for all inputs and outputs.

## Security and Cost

Inbound HTTP (TCP/80) is disabled by default; configure an HTTP source CIDR to enable it. Use a narrow CIDR for private access, and set `0.0.0.0/0` only when public web access is intentional. SSH is restricted to one required administrator IPv4 address in `/32` form. The examples use documentation-only TEST-NET addresses, not real endpoints. AWS outbound traffic is limited to TCP/80 and TCP/443; Azure outbound internet traffic is limited to the same ports. The modules still create public IPs and internet routes as part of the example architecture. Terraform state can contain public IPs, SSH public keys, and cloud resource identifiers; never commit state or plan files, encrypt remote state, and restrict access. Public keys can identify their owner, so use a dedicated key rather than a personal key and do not put personal data in resource tags. The modules do not create TLS certificates, a load balancer, or production hardening.

Cloud resources can incur charges while running. Review the plan before applying and destroy resources when finished:

```sh
terraform destroy
```

Run destroy from the same root configuration and workspace used to create the resources.