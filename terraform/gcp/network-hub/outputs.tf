output "vpc_network_name" {
  value       = google_compute_network.vpc_network.name
  description = "The name of the created VPC network."
}

output "public_subnet_name" {
  value       = google_compute_subnetwork.public_subnet.name
  description = "The name of the public subnet."
}

output "private_subnet_name" {
  value       = google_compute_subnetwork.private_subnet.name
  description = "The name of the private subnet."
}

output "nat_gateway_name" {
  value       = google_compute_router_nat.nat_gateway.name
  description = "The name of the NAT Gateway."
}