resource "google_compute_global_address" "postgres_private_ip_address" {
  provider      = google
  name          = "postgres-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
  project       = "agh-project-443322"
}

resource "google_service_networking_connection" "postgres_private_vpc_connection" {
  provider                = google
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.postgres_private_ip_address.name]
}


resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_sql_database_instance" "postgres_instance" {
  name                = "postgres-instance"
  project             = "agh-project-443322"
  database_version    = "POSTGRES_15"
  region              = "europe-central2"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = true
    }
  }
  depends_on = [google_project_service.servicenetworking, google_service_networking_connection.postgres_private_vpc_connection]
}

resource "random_password" "root_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.postgres_instance.name
  password = random_password.root_password.result
}