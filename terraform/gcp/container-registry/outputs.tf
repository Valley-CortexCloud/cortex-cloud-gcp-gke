output "repository_name" {
  description = "The full name of the Artifact Registry repository."
  value       = google_artifact_registry_repository.my_repo.name
}

output "repository_url" {
  description = "The full URL of the Docker repository to use for push/pull."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}