resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  tags         = ["web-tier"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web.id
    access_config {} # temporary external IP for the demo
  }

  # The web tier has no IAM roles; scopes allow only logging and metrics
  service_account {
    email = google_service_account.web.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  metadata_startup_script = templatefile("${path.module}/scripts/web-startup.sh.tpl", {
    app_ip = google_compute_instance.app.network_interface[0].network_ip
  })
}
