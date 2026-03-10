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
  # NEW: Inject your Cloud Shell SSH key on boot
  metadata = {
    ssh-keys = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDa+mVMhPscDLVX0acO6xJjPdasozTI6zH55GoqPtYFlNk/Z7XJqKC9+0icBd/dYSAc9OZ/XXcjtZExs/NI9OwOa2jvVcR2B820BARcYD55Y5Q8DlXsiXdcbJ6F93amVqquCgFzTkcEQ7HruJ1Rs64b8GtmXDMljzuksQ7W/3KiiTgnbOQiI117parS+AmqA1fiysbdWSZi8K8qkszxxMrdKLL22wIiWs/ddAsw65lv28261Mlhqd+DozyiaaNz9+DsY5BuwwxRJoMWwpjT/iVcY+ksFkWVeLg3fGMAxqXdyZAskUfwWMgZ30rfrAZ+xV8gEAZUXr1v9GtMg+CGj3Oa2SSoDE/+v0hupFpMd/NLBpV5/JhfVmKoaYDMYCRkJMXaktMUh5jM4X/tb/0J+czzK7zhkWWhbOLs2Jrbnij5asbHt2vSHd2fPRpO+kB18+MGobXNfgmn8iynnGvkkeza1WRtsp0LZ509rEPVVH2qi+OClDCQTrJuVCD+kao9lyk= jvalley@cs-641103618805-default"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }
}
