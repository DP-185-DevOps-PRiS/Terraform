variable "network_selflink" {
  default = "https://www.googleapis.com/compute/v1/projects/fourthdemo-274718/global/networks/default"
}

variable "names_of_databases" {
  type    = list(string)
  default = ["identity", "messaging", "payment", "trip", "vehicle", "simulator"]
}
