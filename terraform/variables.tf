variable "project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
}

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

variable "zone" {
  description = "The GCP zone to deploy the VM into (e.g., 'us-central1-a')."
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "The name of the virtual machine."
  type        = string
  default     = "gcp-vm-instance-1"
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

variable "subnet_name" {
  description = "The name of the subnetwork to connect the VM to."
  type        = string
  default     = "network-hub-public-subnet"
}

variable "tags" {
  description = "A list of network tags to apply to the instance."
  type        = list(string)
  default     = ["ssh-allowed", "webserver"]
}

variable "assign_public_ip" {
  description = "Set to true to assign a public IP address, false for private IP only."
  type        = bool
  default     = true
}

variable "storage_name" {
  description = "A name prefix for a storage account."
  type        = string
  default     = "raygun-data"
}

variable "labels" {
  description = "Key/value pairs to assign to the resource."
  type        = map(string)
  default     = { 
    environment     = "prod"
    project         = "raygun"
    }
}

variable "project_name" {
  type      = string
}