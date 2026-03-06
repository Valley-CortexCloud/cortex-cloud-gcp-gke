locals {
  # These are the labels you want applied to every instance created by this module
  default_labels = {
    managed_by    = "palo_alto_networks"
    terraform     = true
    owner         = "palo_alto_networks_domain_consultant"
  }
}

resource "google_artifact_registry_repository" "my_repo" {
 
  location      = var.region
  repository_id = var.repository_id
  description   = "Docker container registry created with Terraform"
  format        = "DOCKER"
  labels        = merge(local.default_labels, var.labels)

}