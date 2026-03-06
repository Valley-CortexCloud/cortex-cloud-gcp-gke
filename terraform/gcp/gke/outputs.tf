output "cluster_name" {
  description = "The name of the created GKE cluster."
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the GKE cluster's master."
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
}

output "kubeconfig_command" {
  description = "The gcloud command to run to configure kubectl."
  value = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region}"
}