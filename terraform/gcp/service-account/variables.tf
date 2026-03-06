variable "account_id" {
  description = "The unique ID for the service account (e.g., 'storage-manager-sa')."
  type        = string
}

variable "display_name" {
  description = "The human-readable display name for the service account."
  type        = string
}

variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "roles" {
  type        = list(string)
  description = "A list of IAM roles to assign to the service account"
  default     = []
}