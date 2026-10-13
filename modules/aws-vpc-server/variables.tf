variable "name" {
  description = "Prefix used for resource names."
  type        = string
  default     = "iac-demo"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "IPv4 CIDR block for the public subnet; it must be within vpc_cidr."
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type. Availability and cost depend on the selected region."
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "SSH public key text used to create the EC2 key pair. Keep the corresponding private key locally."
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "Single IPv4 CIDR allowed to connect to SSH, ideally your public IP with a /32 mask."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.allowed_ssh_cidr)) && can(regex("/32$", var.allowed_ssh_cidr))
    error_message = "allowed_ssh_cidr must be a valid IPv4 /32 CIDR block."
  }
}

variable "allowed_http_cidrs" {
  description = "IPv4 CIDRs allowed to connect to HTTP. Leave empty to disable inbound HTTP."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_http_cidrs : can(cidrnetmask(cidr))])
    error_message = "allowed_http_cidrs must contain only valid IPv4 CIDR blocks."
  }
}

variable "tags" {
  description = "Tags applied to supported AWS resources."
  type        = map(string)
  default     = {}
}