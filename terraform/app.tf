resource "google_compute_instance" "app" {
  name         = "app-server"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  tags         = ["app-tier"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 10
      type  = "pd-standard"
    }
  }

  # No access_config block means no external IP
  network_interface {
    subnetwork = google_compute_subnetwork.app.id
  }

  service_account {
    email  = google_service_account.app.email
    scopes = ["cloud-platform"] # actual access is limited by IAM roles
  }

  metadata_startup_script = templatefile("${path.module}/scripts/app-startup.sh.tpl", {
    project_id = var.project_id
    secret_id  = google_secret_manager_secret.db_password.secret_id
    db_host    = google_sql_database_instance.main.private_ip_address
    db_name    = google_sql_database.app.name
    db_user    = google_sql_user.app.name
  })

  depends_on = [
    google_compute_router_nat.main,
    google_secret_manager_secret_version.db_password,
    google_secret_manager_secret_iam_member.app_reads_db_password,
  ]
}
