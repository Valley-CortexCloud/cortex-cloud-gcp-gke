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

variable "assign_public_ip" {
  description = "Set to true to assign a public IP address, false for private IP only."
  type        = bool
  default     = true
}

variable "service_account_email" {
  type        = string
}