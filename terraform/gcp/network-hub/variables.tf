variable "region" {
  description = "The GCP region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "A name prefix for the network resources."
  type        = string
  default     = "network-hub"
}

variable "labels" {
  description = "Key/value pairs to assign to the resource."
  type        = map(string)
  default     = { environment = "prod", project = "infrastructure", shared = true, terraform = true }
}