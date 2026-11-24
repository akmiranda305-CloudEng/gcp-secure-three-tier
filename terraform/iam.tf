# One service account per tier instead of the default Compute account
resource "google_service_account" "web" {
  account_id   = "web-tier-sa"
  display_name = "Web tier VM"
}

resource "google_service_account" "app" {
  account_id   = "app-tier-sa"
  display_name = "App tier VM"
}

# Least privilege: the app tier can read this one secret and nothing else
resource "google_secret_manager_secret_iam_member" "app_reads_db_password" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.app.email}"
}
