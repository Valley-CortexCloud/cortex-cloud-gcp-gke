# ------------------------------------------------------------------------------
# Google Compute Engine VM Instance
# ------------------------------------------------------------------------------
locals {
  # These are the labels you want applied to every instance created by this module
  default_labels = {
    managed_by    = "palo_alto_networks"
    terraform     = true
    owner         = "palo_alto_networks_domain_consultant"
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = var.tags
  labels       = merge(local.default_labels, var.labels)

  boot_disk {
    initialize_params {
      image   = var.image
      size    = 20
      labels  = merge(local.default_labels, var.labels)
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {}
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = [ "cloud-platform" ]
  }

  metadata = {
    "startup-script" = file("${path.module}/scripts/install.sh")
  }


  allow_stopping_for_update = true
  description = "A general purpose compute instance"
}