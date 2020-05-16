provider "azurerm" {
  subscription_id = "449bc4ca-78d3-448a-9c85-d171550b34d2"
  client_id       = "474b899a-0918-4a06-83fc-2e5eaf5b3917"
  client_secret   = ".X-KHKF6vP_jn62H/tqaea7bwToPWEfL"
  tenant_id       = "6f07aacc-435e-403d-9519-3e1236fdb2da"
  features {}
}

provider "google" {
  credentials = file("demo2ansible-4b5d43722b34.json")
  project     = "demo2ansible"
  region      = "europe-west3"
}

terraform {
  backend "gcs" {
    credentials = "demo2ansible-4b5d43722b34.json"
    bucket      = "terraform-cred-bucket"
    path        = "terraform.tfstate"
  }
}

module "azure_vpc" {
  source = "./modules/azure_vpc"
}

module "azure_gateway" {
  source = "./modules/azure_gateway"

  group_name        = module.azure_vpc.group_name
  group_location    = module.azure_vpc.group_location
  gateway_subnet_id = module.azure_vpc.gateway_subnet_id
  gcp_public_ip     = module.gcp_vpn_tunnel.gcp_public_ip
}

module "gcp_vpn_tunnel" {
  source = "./modules/gcp_vpn_tunnel"

  azure_public_ip = module.azure_gateway.azure_public_ip
}

module "database" {
  source = "./modules/database"
}

module "azure_vm" {
  source = "./modules/azure_vm"

  group_name     = module.azure_vpc.group_name
  group_location = module.azure_vpc.group_location
  subnet_id      = module.azure_vpc.subnet_id
}

module "azure_application_gateway" {
  source = "./modules/azure_application_gateway"

  group_name           = module.azure_vpc.group_name
  group_location       = module.azure_vpc.group_location
  virtual_network_name = module.azure_vpc.virtual_network_name
  vm_private_ip        = module.azure_vm.vm_private_ip
}
