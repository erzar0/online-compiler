resource "google_project_service" "redis" {
  project = var.project_id
  service = "redis.googleapis.com"
}

resource "google_redis_instance" "redis_instance" {
  name           = "redis-instance"
  region         = var.region
  tier           = "STANDARD_HA"
  memory_size_gb = 1 
  auth_enabled = true

  authorized_network = google_compute_network.main.id

  redis_version = "REDIS_7_0"
  depends_on = [ google_project_service.redis ]
}

