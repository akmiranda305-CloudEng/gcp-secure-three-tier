
# Create the public web server
resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  # Attach the web-tier network tag
  tags = ["web-tier"]

  # Create a 10 GB standard boot disk
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 10
      type  = "pd-standard"
    }
  }

  # Connect the VM to our web subnet
  network_interface {
    subnetwork = google_compute_subnetwork.web.id

    # Assign a temporary public IPv4 address
    access_config {}
  }

  # Install and configure Nginx automatically
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -eux

    apt-get update
    apt-get install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>GCP Three-Tier Architecture</title>
    </head>
    <body>
      <h1>It Works!</h1>
      <h2>Google Cloud Three-Tier Architecture</h2>
      <p>Nginx is running successfully on the web tier.</p>
      <p>Infrastructure deployed using Terraform.</p>
    </body>
    </html>
    HTML
  EOF
}
