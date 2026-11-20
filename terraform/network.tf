# Create a custom VPC network
resource "google_compute_network" "main" {
  name                    = "three-tier-vpc"
  auto_create_subnetworks = false
}

# Web tier subnet
resource "google_compute_subnetwork" "web" {
  name                     = "web-subnet"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = "10.10.0.0/24"
  private_ip_google_access = true
}

# Application tier subnet
resource "google_compute_subnetwork" "app" {
  name                     = "app-subnet"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = "10.20.0.0/24"
  private_ip_google_access = true
}

# Database tier subnet
resource "google_compute_subnetwork" "db" {
  name                     = "db-subnet"
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = "10.30.0.0/24"
  private_ip_google_access = true
}
