output "vpc_cidr" {
  value = module.vpc.vpc_cidr_block
   description = "The primary IPv4 CIDR block"
}

output "additional_cidr_blocks" {
  value       = module.vpc.additional_cidr_blocks
  description = "A list of the additional IPv4 CIDR blocks associated with the VPC"
}

output "additional_cidr_blocks_to_association_ids" {
  value       = module.vpc.additional_cidr_blocks_to_association_ids
  description = "A map of the additional IPv4 CIDR blocks to VPC CIDR association IDs"
}

output "vpc_ipv6_association_id" {
  value       = module.vpc.vpc_ipv6_association_id
  description = "The association ID for the primary IPv6 CIDR block"
}

output "vpc_ipv6_cidr_block" {
  value       = module.vpc.vpc_ipv6_cidr_block
  description = "The primary IPv6 CIDR block"
}

output "ipv6_cidr_block_network_border_group" {
  value       = module.vpc.ipv6_cidr_block_network_border_group
  description = "The Network Border Group Zone name"
}