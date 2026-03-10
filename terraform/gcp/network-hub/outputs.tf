output "mgmt_vpc_id" { value = google_compute_network.mgmt_vpc.id }
output "mgmt_subnet_id" { value = google_compute_subnetwork.mgmt_subnet.id }

output "untrust_vpc_id" { value = google_compute_network.untrust_vpc.id }
output "untrust_vpc_name" { value = google_compute_network.untrust_vpc.name }
output "untrust_subnet_id" { value = google_compute_subnetwork.untrust_subnet.id }
output "untrust_subnet_name" { value = google_compute_subnetwork.untrust_subnet.name }

output "trust_vpc_id" { value = google_compute_network.trust_vpc.id }
output "trust_vpc_name" { value = google_compute_network.trust_vpc.name }
output "trust_subnet_id" { value = google_compute_subnetwork.trust_subnet.id }
output "trust_subnet_name" { value = google_compute_subnetwork.trust_subnet.name }
