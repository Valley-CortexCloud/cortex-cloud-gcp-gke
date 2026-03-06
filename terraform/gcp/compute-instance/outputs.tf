output "instance_name" {
  value       = google_compute_instance.vm_instance.name
  description = "The name of the created VM instance."
}

output "internal_ip" {
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
  description = "The internal IP address of the VM instance."
}

output "external_ip" {
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
  description = "The external IP address of the VM instance."
}