resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "redis_firewall" {
  name    = "allow-redis"
  network = google_compute_network.main.id
  allow {
    protocol = "tcp"
    ports    = ["6379"]
  }
  source_ranges = ["0.0.0.0/0"]
}