resource "google_compute_instance" "vmseries" {
  name         = "${var.project_name}-fw-01"
  machine_type = "e2-standard-4" # Palo Alto recommends at least 4 vCPUs for PAN-OS 11.x
  zone         = var.zone
  can_ip_forward = true # CRITICAL: Allows firewall to route traffic

  boot_disk {
    initialize_params {
      # Use a modern PAN-OS 11.1 Flex BYOL image
      image = "projects/paloaltonetworks-sg/global/images/vmseries-flex-byol-1112"
    }
  }

  # Interface 0: Management (eth0)
  network_interface {
    network    = google_compute_network.mgmt_vpc.id
    subnetwork = google_compute_subnetwork.mgmt_subnet.id
    network_ip = "10.0.0.10"
    access_config {} # Gives Mgmt a Public IP so you can access the Web UI
  }

  # Interface 1: Untrust / Public (eth1)
  network_interface {
    network    = google_compute_network.untrust_vpc.id
    subnetwork = google_compute_subnetwork.untrust_subnet.id
    network_ip = "10.0.1.10"
    access_config {} # Gives Untrust a Public IP for outbound internet
  }

  # Interface 2: Trust / Internal (eth2)
  network_interface {
    network    = google_compute_network.trust_vpc.id
    subnetwork = google_compute_subnetwork.trust_subnet.id
    network_ip = "10.0.2.10" # Matches the next_hop_address in our route!
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
}
