variable "azure_public_ip" {}

variable "network_selflink" {
  default = "https://www.googleapis.com/compute/v1/projects/fourthdemo-274718/global/networks/default"
}

variable "shared_secret_key" {
  default = "123456789"
}

variable "az_traffic_selector" {
  default = ["172.16.0.0/16"]
}

variable "gcp_traffic_selector" {
  default = ["10.128.0.0/20", "10.142.0.0/20", "172.22.208.0/24"]
}

variable "dest_range" {
  default = "172.16.0.0/16"
}
