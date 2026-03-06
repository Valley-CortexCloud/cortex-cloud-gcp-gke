locals {
  # These are the labels you want applied to every instance created by this module
  default_labels = {
    managed_by    = "palo_alto_networks"
    terraform     = true
    owner         = "palo_alto_networks_domain_consultant"
    purpose       = "tf_state"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "storage" {
  name      = "terraform-state-${random_id.bucket_suffix.hex}"
  location  = var.region
  labels    = local.default_labels
}