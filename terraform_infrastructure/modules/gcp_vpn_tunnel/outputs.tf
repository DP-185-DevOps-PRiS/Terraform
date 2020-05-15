output "gcp_public_ip" {
  value = google_compute_address.gcp_public_ip.address
}
