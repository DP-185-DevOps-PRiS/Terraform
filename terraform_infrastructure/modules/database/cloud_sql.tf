resource "google_sql_database_instance" "database_instance" {
  #  provider = google-beta

  name             = "vpn-db-instance"
  region           = "europe-west3"
  database_version = "POSTGRES_11"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_selflink
    }
  }
}

#output "ip" {
#  value = google_sql_database_instance.database_instance.private_ip_address
#}

resource "local_file" "db_ip" {
  content  = google_sql_database_instance.database_instance.private_ip_address
  filename = "ip.txt"
}

resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.database_instance.name
  password = "postgres"
}
