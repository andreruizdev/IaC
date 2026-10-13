variable "name" {
  description = "Lowercase resource name prefix; use 1 to 20 letters, numbers, or hyphens."
  type        = string
  default     = "iac-demo"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.name))
    error_message = "name must be 1 to 20 lowercase letters, numbers, or hyphens."
  }
}

variable "location" {
  description = "Azure region for the resource group and server."
  type        = string
}

variable "address_space" {
  description = "IPv4 address space for the virtual network."
  type        = string
  default     = "10.20.0.0/16"
}

variable "subnet_prefix" {
  description = "IPv4 prefix for the server subnet; it must be within address_space."
  type        = string
  default     = "10.20.1.0/24"
}

variable "vm_size" {
  description = "Azure virtual machine size available in the selected region."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key installed for the Linux administrator. Keep the corresponding private key locally."
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

variable "allowed_http_cidr" {
  description = "Optional IPv4 CIDR allowed to connect to HTTP. Leave unset to disable inbound HTTP."
  type        = string
  default     = null

  validation {
    condition     = var.allowed_http_cidr == null || can(cidrnetmask(var.allowed_http_cidr))
    error_message = "allowed_http_cidr must be a valid IPv4 CIDR block when set."
  }
}

variable "tags" {
  description = "Tags applied to supported Azure resources."
  type        = map(string)
  default     = {}
}