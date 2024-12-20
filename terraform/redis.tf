resource "google_redis_instance" "redis_instance" {
  name           = "redis-instance"
  region         = var.region
  tier           = "STANDARD_HA"
  memory_size_gb = 1 

  authorized_network = google_compute_network.main.id

  redis_version = "REDIS_7_0"  # Specify Redis version
}

