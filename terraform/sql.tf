resource "google_compute_global_address" "postgres_private_ip_address" {
  name          = "postgres-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
  project       = var.project_id
}

resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_service_networking_connection" "postgres_private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.postgres_private_ip_address.name]
}

resource "google_sql_database_instance" "postgres_instance" {
  name                = "postgres-instance"
  project             = var.project_id
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = false

  settings {
    tier = var.db_instance_tier

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.main.id
      enable_private_path_for_google_cloud_services = true
    }
  }

  depends_on = [
    google_project_service.servicenetworking,
    google_service_networking_connection.postgres_private_vpc_connection
  ]
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.postgres_instance.name
  password = var.postgres_root_password
}

resource "google_sql_database" "judge0" {
  name     = "judge0"
  instance = google_sql_database_instance.postgres_instance.name
  project  = var.project_id
}