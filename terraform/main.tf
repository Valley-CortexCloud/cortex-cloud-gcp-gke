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

module "network-hub" {
  source = "./gcp/network-hub"

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

module "gke" {
  source = "./gcp/gke"

  cluster_name          = "${var.project_name}-gke-cluster"
  network_name          = module.network-hub.vpc_network_name
  subnet_name           = module.network-hub.public_subnet_name
  service_account_email = module.sa-k8s.service_account_email
  machine_type          = "e2-standard-2"
  labels = {
    environment = "prod"
    project     = var.project_name
  }
}

module "vm01" {
  source     = "./gcp/compute-instance"
  depends_on = [module.network-hub]

  instance_name         = "${var.project_name}-protected"
  network_name          = module.network-hub.vpc_network_name
  subnet_name           = module.network-hub.public_subnet_name
  service_account_email = module.sa-instance.service_account_email
  labels = {
    environment            = "prod"
    project                = var.project_name
    require_security_agent = true
  }
}

module "vm02" {
  source     = "./gcp/compute-instance"
  depends_on = [module.network-hub]

  instance_name         = "${var.project_name}-unprotected"
  network_name          = module.network-hub.vpc_network_name
  subnet_name           = module.network-hub.public_subnet_name
  service_account_email = module.sa-instance.service_account_email
  labels = {
    environment            = "prod"
    project                = var.project_name
    require_security_agent = true
  }
}
