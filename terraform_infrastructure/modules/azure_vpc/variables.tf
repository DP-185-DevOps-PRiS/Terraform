variable "vn_address_space" {
  default = ["172.16.0.0/16"]
}

variable "subnet_address_space" {
  default = "172.16.0.0/24"
}

variable "gw_subnet_address_space" {
  default = "172.16.10.0/24"
}
