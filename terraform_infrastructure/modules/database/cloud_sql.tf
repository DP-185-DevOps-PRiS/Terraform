resource "google_sql_database_instance" "database_instance" {
  #  provider = google-beta

  name             = "vpn-db-instance-5"
  region           = "us-central1"
  database_version = "POSTGRES_11"

  settings {
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_selflink
    }
  }
}

resource "local_file" "db_ip" {
  content  = google_sql_database_instance.database_instance.private_ip_address
  filename = "db_ip.txt"
}

resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.database_instance.name
  password = "123456"
}

resource "google_sql_database" "databases" {
  for_each = toset(var.names_of_databases)
  name     = each.value
  instance = google_sql_database_instance.database_instance.name
}
