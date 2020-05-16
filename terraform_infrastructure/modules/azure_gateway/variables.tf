variable "group_name" {}

variable "group_location" {}

variable "gateway_subnet_id" {}

variable "gcp_public_ip" {}

variable "address_space_local_nw_gw" {
  default = ["10.128.0.0/20", "172.22.208.0/24"]
}

variable "shared_secret_key" {
  default = "123456789"
}
