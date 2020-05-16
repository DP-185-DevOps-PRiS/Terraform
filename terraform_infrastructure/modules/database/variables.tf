variable "network_selflink" {
  default = "https://www.googleapis.com/compute/v1/projects/demo2ansible/global/networks/default"
}

variable "names_of_databases" {
  type    = list(string)
  default = ["identity", "messaging", "payment", "trip", "vehicle", "simulator"]
}
