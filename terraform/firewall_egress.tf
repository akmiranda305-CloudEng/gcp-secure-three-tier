# Cloud SQL sits outside our VPC, so ingress rules can't protect it.
# Block the web tier from reaching the Google-managed services range instead.
resource "google_compute_firewall" "deny_web_to_db_egress" {
  name      = "deny-web-to-db-egress"
  network   = google_compute_network.main.name
  direction = "EGRESS"
  priority  = 900

  destination_ranges = [
    "${google_compute_global_address.private_services_range.address}/${google_compute_global_address.private_services_range.prefix_length}"
  ]
  target_tags = ["web-tier"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
