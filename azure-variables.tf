variable "client_id" {
    description =   "Client ID (APP ID) of the application"
    type        =   string
}

variable "client_secret" {
    description =   "Client Secret (Password) of the application"
    type        =   string
}

variable "subscription_id" {
    description =   "Subscription ID"
    type        =   string
}

variable "tenant_id" {
    description =   "Tenant ID"
    type        =   string
}
#Define application name
variable "app_name" {
  type = string
  description = "Application name"
  default = "DevOpsCloud"
}#Define application environment
variable "app_environment" {
  type = string
  description = "Application environment"
  default = "demo"
}

#Location Resource Group
variable "rg_location" {
  type = string
  description = "Location of Resource Group"
  default = "West US"
}#VNET CIDR
variable "azure_vnet_cidr" {
  type = string
  description = "Vnet CIDR"
  default = "10.2.0.0/16"
}
#Subnet CIDR frontend
variable "azure_subnet_cidr_frontend" {
  type = string
  description = "Subnet CIDR"
  default = "10.2.1.0/24"
}
#Subnet CIDR backend
variable "azure_subnet_cidr_backend" {
  type = string
  description = "Subnet CIDR"
  default = "10.2.2.0/24"
}

#Linux VM Admin User
variable "linux_admin_user" {
  type = string
  description = "Linux  VM Admin User"
  default = "tfadmin"
}#Linux VM Admin Password
variable "linux_admin_password" {
  type = string
  description = "Linux VM Admin Password"
  default = "S3cr3tP@ssw0rd"
}#Linux VM Hostname
variable "linux_vm_hostname" {
  type = string
  description = "Linux VM Hostname"
  default = "azwebserver1"
}#Ubuntu Linux Publisher used to build VMs
variable "ubuntu-linux-publisher" {
  type = string
  description = "Ubuntu Linux Publisher used to build VMs"
  default = "Canonical"
}#Ubuntu Linux Offer used to build VMs
variable "ubuntu-linux-offer" {
  type = string
  description = "Ubuntu Linux Offer used to build VMs"
  default = "UbuntuServer"
}#Ubuntu Linux 18.x SKU used to build VMs
variable "ubuntu-linux-18-sku" {
  type = string
  description = "Ubuntu Linux Server SKU used to build VMs"
  default = "18.04-LTS"
}

#application port
variable "application_port" {
    description = "The port that you want to expose to the external load balancer"
    default     = 80
}