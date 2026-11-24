resource "google_compute_router" "main" {
  name    = "three-tier-router"
  region  = var.region
  network = google_compute_network.main.id
}

# Outbound internet for the app subnet only
resource "google_compute_router_nat" "main" {
  name                               = "three-tier-nat"
  router                             = google_compute_router.main.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.app.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
