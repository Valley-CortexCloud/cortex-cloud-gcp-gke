output "service_account_email" {
  value       = google_service_account.service_account.email
  description = "The email address of the created service account."
}

output "service_account_unique_id" {
  value       = google_service_account.service_account.unique_id
  description = "The unique numeric ID of the service account."
}