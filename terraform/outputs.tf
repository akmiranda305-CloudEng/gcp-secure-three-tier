output "db_instance_name" {
  value = google_sql_database_instance.main.name
}

output "db_private_ip" {
  value = google_sql_database_instance.main.private_ip_address
}

output "app_server_internal_ip" {
  value = google_compute_instance.app.network_interface[0].network_ip
}

output "web_server_external_ip" {
  value = google_compute_instance.web.network_interface[0].access_config[0].nat_ip
}
