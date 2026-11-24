# Reserve an internal IP range for Google-managed services (Cloud SQL lives here)
resource "google_compute_global_address" "private_services_range" {
  name          = "google-managed-services-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.100.0.0"
  prefix_length = 16
  network       = google_compute_network.main.id
}

# Peer our VPC with Google's service network so Cloud SQL gets a private IP
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_range.name]
}

# Instance names can't be reused right after deletion, so add a random suffix
resource "random_id" "db_suffix" {
  byte_length = 3
}

resource "google_sql_database_instance" "main" {
  name                = "three-tier-db-${random_id.db_suffix.hex}"
  region              = var.region
  database_version    = "POSTGRES_15"
  deletion_protection = false # portfolio project: lets terraform destroy work

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = "db-f1-micro"
    edition           = "ENTERPRISE"
    availability_type = "ZONAL"
    disk_size         = 10

    ip_configuration {
      ipv4_enabled    = false # no public IP
      private_network = google_compute_network.main.id
    }

    backup_configuration {
      enabled = false # cost saving for a demo; enable in production
    }
  }
}

resource "google_sql_database" "app" {
  name     = "appdb"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  name     = "appuser"
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}
