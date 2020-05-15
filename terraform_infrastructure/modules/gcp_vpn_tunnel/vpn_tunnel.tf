resource "google_compute_address" "gcp_public_ip" {
  name = "gcp-public-ip"
}

resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "az-gcp-vpn-gateway"
  network = var.network_selflink
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.gcp_public_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.gcp_public_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.gcp_public_ip.address
  target      = google_compute_vpn_gateway.target_gateway.self_link
}

resource "google_compute_vpn_tunnel" "az_gcp_vpn_tunnel" {
  name          = "az-gcp-vpn-tunnel"
  peer_ip       = var.azure_public_ip
  shared_secret = var.shared_secret_key
  ike_version   = "2"

  target_vpn_gateway      = google_compute_vpn_gateway.target_gateway.self_link
  remote_traffic_selector = var.az_traffic_selector
  local_traffic_selector  = var.gcp_traffic_selector

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_route" "route" {
  name       = "route"
  network    = "default"
  dest_range = var.dest_range
  priority   = 1000

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.az_gcp_vpn_tunnel.self_link
}
