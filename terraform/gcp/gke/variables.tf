variable "region" {
  description = "The GCP region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  type        = string
  description = "The name for the GKE cluster."
  default     = "raygun-gke-cluster"
}

variable "machine_type" {
  description = "The machine type for the VM."
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "The boot disk image for the VM."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "network_name" {
  description = "The name of the VPC network to connect the VM to."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnetwork to connect the VM to."
  type        = string
}

variable "tags" {
  description = "A list of network tags to apply to the instance."
  type        = list(string)
  default     = ["ssh-allowed", "webserver"]
}

variable "labels" {
  description = "Key/value pairs to assign to the resource."
  type        = map(string)
  default     = { environment = "prod", project = "raygun", terraform = true }
}

variable "initial_node_count" {
  type        = number
  description = "The initial number of nodes for the GKE cluster's default node pool."
  default     = 1
}

variable "service_account_email" {
  type        = string
}