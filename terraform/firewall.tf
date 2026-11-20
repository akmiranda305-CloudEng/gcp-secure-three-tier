# Allow public HTTP and HTTPS traffic to web servers only
resource "google_compute_firewall" "allow_web" {
  name    = "allow-web-http-https"
  network = google_compute_network.main.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-tier"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# Allow web servers to communicate with application servers
resource "google_compute_firewall" "web_to_app" {
  name    = "allow-web-to-app"
  network = google_compute_network.main.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["10.10.0.0/24"]
  target_tags   = ["app-tier"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}

# Allow application servers to communicate with PostgreSQL
resource "google_compute_firewall" "app_to_db" {
  name    = "allow-app-to-db"
  network = google_compute_network.main.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["10.20.0.0/24"]
  target_tags   = ["db-tier"]

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
}

# Allow SSH administration through Identity-Aware Proxy (IAP)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = google_compute_network.main.name

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["web-tier", "app-tier", "db-tier"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
