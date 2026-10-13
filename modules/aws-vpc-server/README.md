# AWS VPC and Server Module

This module creates an AWS VPC, one public subnet, an internet gateway and route, a security group, an SSH key pair, and an Ubuntu 22.04 EC2 instance. The instance installs and starts NGINX at first boot. Inbound HTTP is disabled unless `allowed_http_cidrs` is set; SSH requires a single `/32` administrator address. Outbound traffic is limited to TCP ports 80 and 443.

## Requirements

- Terraform 1.5 or later.
- AWS provider 5.x and credentials with permission to manage VPC, EC2, security group, route, and key-pair resources.
- An AWS region with the selected instance type and Ubuntu image available.
- An SSH public key and the administrator's public IPv4 CIDR. Do not supply or commit the private key.

The calling root module must configure the AWS provider and credentials. For example:

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

  name             = "demo-web"
  ssh_public_key   = file(pathexpand("~/.ssh/id_ed25519.pub"))
  allowed_ssh_cidr = "203.0.113.10/32"
  allowed_http_cidrs = ["203.0.113.10/32"]

  tags = {
    Environment = "demo"
  }
}

output "web_url" {
  value = module.web_server.web_url
}
```

The example assumes the calling configuration is in the repository root. Replace the example SSH CIDR with your own public IPv4 address and keep the matching private key on your machine.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | `iac-demo` | Resource name prefix. |
| `vpc_cidr` | `string` | `10.0.0.0/16` | VPC IPv4 range. |
| `subnet_cidr` | `string` | `10.0.1.0/24` | Public subnet range; must be contained in the VPC range. |
| `instance_type` | `string` | `t3.micro` | EC2 instance type. |
| `ssh_public_key` | `string` | Required | Public key installed for SSH access. Terraform masks it in normal output, but stores it in state. |
| `allowed_ssh_cidr` | `string` | Required | One administrator IPv4 address in `/32` form. |
| `allowed_http_cidrs` | `list(string)` | `[]` | IPv4 CIDRs allowed to use HTTP. Empty disables inbound HTTP; add `0.0.0.0/0` only when public access is intentional. |
| `tags` | `map(string)` | `{}` | Tags applied to supported resources. |

## Outputs

| Name | Description |
| --- | --- |
| `instance_id` | EC2 instance ID. |
| `public_ip` | Server public IPv4 address. |
| `web_url` | NGINX page URL. |
| `ssh_command` | Example SSH command; add `-i <private-key-path>` if required. |

## Security Notes

The module still assigns a public IPv4 address and a default route, but no inbound HTTP rule is created unless an allowed CIDR is supplied. SSH accepts only a single `/32` address. Egress is limited to TCP/80 and TCP/443 for package updates and web traffic. Terraform state contains the public IP, SSH public key, and cloud resource identifiers; a public key may identify its owner. Never commit state or plan files, use encrypted access-controlled remote state, use a dedicated key rather than a personal key, and do not provide a private key or put personal details in resource tags.

## Deploy and Clean Up

From the calling root configuration directory:

```sh
terraform init
terraform plan
terraform apply
terraform output web_url
terraform destroy
```

Review the plan before applying. A public IPv4 address, EC2 instance, and related AWS resources may incur charges. The module does not create HTTPS, backups, monitoring, or production-grade high availability. Destroy resources when they are no longer needed.