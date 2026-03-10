variable "project_name" { type = string }
variable "zone" { type = string }
variable "service_account_email" { type = string }

variable "mgmt_vpc_id" { type = string }
variable "mgmt_subnet_id" { type = string }

variable "untrust_vpc_id" { type = string }
variable "untrust_subnet_id" { type = string }

variable "trust_vpc_id" { type = string }
variable "trust_subnet_id" { type = string }
