variable "region" {
  description = "The GCP region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "repository_id" {
  type        = string
  description = "The unique ID for the Artifact Registry repository."
  default     = "raygun-repo"
}

variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

variable "labels" {
  description = "Key/value pairs to assign to the resource."
  type        = map(string)
  default     = { environment = "prod", project = "raygun" }
}