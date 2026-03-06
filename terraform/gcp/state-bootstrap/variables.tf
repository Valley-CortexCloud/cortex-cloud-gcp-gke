variable "region" {
  description = "The GCP region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Key/value pairs to assign to the resource."
  type        = map(string)
  default     = { environment = "prod", project = "terraform", purpose = "tf_state" }
}

variable "project_id" {
  type = string
  description = "GCP Project ID"
}