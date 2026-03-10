resource "google_compute_instance" "vmseries" {
  name           = "${var.project_name}-fw-01"
  machine_type   = "e2-standard-4" 
  zone           = var.zone
  can_ip_forward = true 

  boot_disk {
    initialize_params {
      image = "projects/paloaltonetworksgcp-public/global/images/vmseries-flex-byol-1112"
    }
  }

  # Interface 0: Management
  network_interface {
    network    = var.mgmt_vpc_id
    subnetwork = var.mgmt_subnet_id
    network_ip = "10.0.0.10"
    access_config {} 
  }

  # Interface 1: Untrust / Public
  network_interface {
    network    = var.untrust_vpc_id
    subnetwork = var.untrust_subnet_id
    network_ip = "10.0.1.10"
    access_config {} 
  }

  # Interface 2: Trust / Internal
  network_interface {
    network    = var.trust_vpc_id
    subnetwork = var.trust_subnet_id
    network_ip = "10.0.2.10" 
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
}
