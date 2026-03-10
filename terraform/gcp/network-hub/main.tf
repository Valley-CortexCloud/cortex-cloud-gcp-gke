# ------------------------------------------------------------------------------
# 1. The Three VPCs
# ------------------------------------------------------------------------------
resource "google_compute_network" "mgmt_vpc" {
  name                    = "${var.project_name}-mgmt-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_network" "untrust_vpc" {
  name                    = "${var.project_name}-untrust-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_network" "trust_vpc" {
  name                    = "${var.project_name}-trust-vpc"
  auto_create_subnetworks = false
}

# ------------------------------------------------------------------------------
# 2. The Subnets
# ------------------------------------------------------------------------------
resource "google_compute_subnetwork" "mgmt_subnet" {
  name          = "${var.project_name}-mgmt-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.mgmt_vpc.id
}

resource "google_compute_subnetwork" "untrust_subnet" {
  name          = "${var.project_name}-untrust-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.untrust_vpc.id
}

# GKE Trust Subnet (Moved here from your main.tf to keep networking central)
resource "google_compute_subnetwork" "trust_subnet" {
  name                     = "${var.project_name}-trust-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.trust_vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pod-range"
    ip_cidr_range = "10.11.0.0/20"
  }
  secondary_ip_range {
    range_name    = "gke-service-range"
    ip_cidr_range = "10.12.0.0/20"
  }
}

# ------------------------------------------------------------------------------
# 3. The Magic Route (Forcing GKE through the Firewall)
# ------------------------------------------------------------------------------
resource "google_compute_route" "default_trust_route" {
  name             = "${var.project_name}-trust-to-fw"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.trust_vpc.name
  next_hop_ip      = "10.0.2.10" 
  priority         = 100

  # NEW: Force Terraform to wait for the subnet to finish building first!
  depends_on = [google_compute_subnetwork.trust_subnet]
}

# Allow external access to Mgmt and Untrust
resource "google_compute_firewall" "allow_mgmt" {
  name          = "${var.project_name}-allow-mgmt"
  network       = google_compute_network.mgmt_vpc.name
  source_ranges = ["0.0.0.0/0"]
  
  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }
}
