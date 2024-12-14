resource "google_compute_subnetwork" "private" {
  name                     = "private"
  ip_cidr_range            = var.subnet_private_ip_range
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "k8s-pod-range"
    ip_cidr_range = var.subnet_pod_range
  }

  secondary_ip_range {
    range_name    = "k8s-service-range"
    ip_cidr_range = var.subnet_service_range
  }
}