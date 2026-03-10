terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  container_files = fileset("../${path.module}/containers", "*/Dockerfile")
  container_names = toset([for f in local.container_files : dirname(f)])
}

module "sa-instance" {
  source = "./gcp/service-account"

  account_id   = "instance-storage-access"
  display_name = "Instance Storage Account Access"
  project_id   = var.project_id
  roles = [
    "roles/storage.admin",
    "roles/compute.admin",
    "roles/iam.serviceAccountUser"
  ]
}
module "network_hub" {
  source       = "./gcp/network-hub"
  project_name = var.project_name
  region       = var.region
}
module "sa-k8s" {
  source = "./gcp/service-account"

  account_id   = "k8s-artifact-access"
  display_name = "K8s Node Permissions"
  project_id   = var.project_id
  roles = [
    "roles/artifactregistry.reader",
    "roles/storage.admin",
    "roles/container.defaultNodeServiceAccount"
  ]
}

module "storage" {
  source = "./gcp/storage-account"

  name   = var.project_name
  region = var.region
  labels = {
    environment = "prod"
    project     = var.project_name
  }

}

resource "google_storage_bucket_object" "file1" {
  source = "./gcp/sample-data/credit-cards.csv"
  
  bucket = module.storage.name
  name   = "credit-cards.csv"
}

module "container-repos" {
  for_each = local.container_names
  source   = "./gcp/container-repo"

  region        = var.region
  project_id    = var.project_id
  repository_id = each.key
  labels = {
    environment = "prod"
    project     = var.project_name
  }
}

# -------------------------------------------------------------------------
# NEW: Create a dedicated GKE Subnet inside the Torque Trust VPC
# This solves the /28 IP exhaustion issue while keeping traffic routed to the FW
# -------------------------------------------------------------------------
resource "google_compute_subnetwork" "gke_subnet" {
  name                     = "gke-trust-subnet"
  ip_cidr_range            = "10.10.100.0/24"
  region                   = var.region
  network                  = "projects/prod-wdfirpnd3bws/global/networks/jvalley-trust-vpc"
  private_ip_google_access = true

  # GKE requires secondary IP ranges for Pods and Services
  secondary_ip_range {
    range_name    = "gke-pod-range"
    ip_cidr_range = "10.11.0.0/20"
  }
  secondary_ip_range {
    range_name    = "gke-service-range"
    ip_cidr_range = "10.12.0.0/20"
  }
}

# -------------------------------------------------------------------------
# UPDATED: GKE Module Call
# -------------------------------------------------------------------------
module "gke" {
  source = "./gcp/gke"

  cluster_name          = "${var.project_name}-gke-cluster"
  network_name          = google_compute_network.trust_vpc.name
  subnet_name           = google_compute_subnetwork.trust_subnet.name
  service_account_email = module.sa-k8s.service_account_email
  machine_type          = "e2-standard-2"
  labels = {
    environment = "prod"
    project     = var.project_name
  }
}
# -------------------------------------------------------------------------
# NEW: VM-Series Firewall Module Call
# -------------------------------------------------------------------------
module "firewall" {
  source = "./gcp/firewall"

  project_name          = var.project_name
  zone                  = var.zone
  service_account_email = module.sa-instance.service_account_email

  # Pass the network outputs from network.tf into the firewall module
  mgmt_vpc_id       = google_compute_network.mgmt_vpc.id
  mgmt_subnet_id    = google_compute_subnetwork.mgmt_subnet.id
  
  untrust_vpc_id    = google_compute_network.untrust_vpc.id
  untrust_subnet_id = google_compute_subnetwork.untrust_subnet.id
  
  trust_vpc_id      = google_compute_network.trust_vpc.id
  trust_subnet_id   = google_compute_subnetwork.trust_subnet.id
}
# -------------------------------------------------------------------------
# UPDATED: VM Module Calls
# -------------------------------------------------------------------------
module "vm01" {
  source                = "./gcp/compute-instance"
  instance_name         = "${var.project_name}-protected"
  
  # Placed INSIDE the firewall (Trust)
  network_name          = google_compute_network.trust_vpc.name
  subnet_name           = google_compute_subnetwork.trust_subnet.name
  
  service_account_email = module.sa-instance.service_account_email
  labels = {
    environment            = "prod"
    project                = var.project_name
    require_security_agent = true
  }
}

module "vm02" {
  source                = "./gcp/compute-instance"
  instance_name         = "${var.project_name}-unprotected"
  
  # Placed OUTSIDE the firewall (Untrust) - acts as internet/attacker box
  network_name          = google_compute_network.untrust_vpc.name
  subnet_name           = google_compute_subnetwork.untrust_subnet.name
  
  service_account_email = module.sa-instance.service_account_email
  labels = {
    environment            = "prod"
    project                = var.project_name
    require_security_agent = true
  }
}
