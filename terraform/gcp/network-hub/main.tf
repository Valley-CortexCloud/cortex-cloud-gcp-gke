# ------------------------------------------------------------------------------
# VPC Network
# ------------------------------------------------------------------------------
resource "google_compute_network" "vpc_network" {
  name                    = "${var.network_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "Main VPC for the network hub"
}

# ------------------------------------------------------------------------------
# Subnets
# ------------------------------------------------------------------------------

# Public Subnet
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.network_name}-public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  description   = "Public subnet for instances with external IPs"
  log_config {
    flow_sampling        = 0.5
    aggregation_interval = "INTERVAL_1_MIN"
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Private Subnet
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "${var.network_name}-private-subnet"
  ip_cidr_range            = "10.0.2.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  private_ip_google_access = true
  description              = "Private subnet for instances without external IPs"
  log_config {
    flow_sampling        = 0.5
    aggregation_interval = "INTERVAL_1_MIN"
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ------------------------------------------------------------------------------
# Cloud Router & NAT Gateway
# ------------------------------------------------------------------------------

# A Cloud Router is required for Cloud NAT
resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc_network.id
  bgp {
    asn = 64514
  }
}

# Cloud NAT for private subnet outbound traffic
resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${var.network_name}-nat-gateway"
  router                             = google_compute_router.router.name
  region                             = var.region
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "AUTO_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ------------------------------------------------------------------------------
# Firewall Rules
# ------------------------------------------------------------------------------

# Allow internal traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "all"
  }
  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
  description   = "Allow all traffic between subnets"
}

# Allow SSH traffic from anywhere to the public subnet
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"] # Apply this tag to VMs you want to SSH into
  description   = "Allow SSH from the internet to tagged instances"
}

# Allow HTTP/HTTPS traffic from anywhere to the public subnet
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.network_name}-allow-http-https"
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webserver"] # Apply this tag to your web servers
  description   = "Allow HTTP/HTTPS from the internet to tagged instances"
}
