# ------------------------------------------------------------------------------
# Google Kubernetes Engine (GKE) Cluster
# ------------------------------------------------------------------------------
locals {
  # These are the labels you want applied to every instance created by this module
  default_labels = {
    managed_by = "palo_alto_networks"
    terraform  = true
    owner      = "palo_alto_networks_domain_consultant"
  }
}

resource "google_container_cluster" "primary" {
  name            = var.cluster_name
  location        = var.region
  resource_labels = merge(local.default_labels, var.labels)

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnet_name

  network_policy {
    enabled = true
    provider = "CALICO"
  }

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]
  }

  deletion_protection = false

}

# Create the primary node pool for the GKE cluster
resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.initial_node_count

  node_config {
    machine_type = var.machine_type
    labels       = merge(local.default_labels, var.labels)

    service_account = var.service_account_email

    # Standard OAuth scopes for GKE nodes
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
