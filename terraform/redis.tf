resource "google_project_service" "redis" {
  project = var.project_id
  service = "redis.googleapis.com"
}

resource "google_redis_instance" "redis_instance" {
  name           = "redis-instance"
  tier           = "BASIC"
  memory_size_gb = 1
  region         = var.region
  redis_version  = "REDIS_7_2"

  authorized_network = google_compute_network.main.id
  depends_on         = [google_project_service.redis]
}
