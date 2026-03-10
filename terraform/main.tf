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
# NEW: Network Hub Module Call (Builds Mgmt, Trust, and Untrust VPCs)
# -------------------------------------------------------------------------
module "network_hub" {
  source       = "./gcp/network-hub"
  project_name = var.project_name
  region       = var.region
}

# -------------------------------------------------------------------------
# UPDATED: GKE Module Call
# -------------------------------------------------------------------------
module "gke" {
  source = "./gcp/gke"

  cluster_name          = "${var.project_name}-gke-cluster"
  
  # References the outputs from the network_hub module
  network_name          = module.network_hub.trust_vpc_name
  subnet_name           = module.network_hub.trust_subnet_name
  
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

  # References the outputs from the network_hub module
  mgmt_vpc_id       = module.network_hub.mgmt_vpc_id
  mgmt_subnet_id    = module.network_hub.mgmt_subnet_id
  
  untrust_vpc_id    = module.network_hub.untrust_vpc_id
  untrust_subnet_id = module.network_hub.untrust_subnet_id
  
  trust_vpc_id      = module.network_hub.trust_vpc_id
  trust_subnet_id   = module.network_hub.trust_subnet_id
}

# -------------------------------------------------------------------------
# UPDATED: VM Module Calls
# -------------------------------------------------------------------------
module "vm01" {
  source                = "./gcp/compute-instance"
  instance_name         = "${var.project_name}-protected"
  
  # Placed INSIDE the firewall (Trust)
  network_name          = module.network_hub.trust_vpc_name
  subnet_name           = module.network_hub.trust_subnet_name
  
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
  network_name          = module.network_hub.untrust_vpc_name
  subnet_name           = module.network_hub.untrust_subnet_name
  
  service_account_email = module.sa-instance.service_account_email
  labels = {
    environment            = "prod"
    project                = var.project_name
    require_security_agent = true
  }
}
