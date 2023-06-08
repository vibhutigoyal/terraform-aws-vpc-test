#Module      : LABEL
#Description : Terraform label module variables.
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-vpc"
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'"
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

#Module      : VPC
#Description : Terraform VPC module variables.

variable "vpc_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the vpc creation."
}

variable "ipv4_primary_cidr_block" {
  type        = string
  default     = null
  description = "IPv4 CIDR for the VPC."
}
variable "ipv6_cidr_block" {
  type        = string
  default     = null
  description = "IPv6 CIDR for the VPC."
}


variable "ipv4_additional_cidr_block_associations" {
  type = map(object({
    ipv4_cidr_block     = string
    ipv4_ipam_pool_id   = string
    ipv4_netmask_length = number
  }))
  default     = {}
  description = "IPv4 CIDR blocks to assign to the VPC."
}

variable "assign_generated_ipv6_cidr_block" {
  type        = bool
  default     = true
  description = "When `true`, assign AWS generated IPv6 CIDR block to the VPC." 
}


variable "ipv6_additional_cidr_block_associations" {
  type = map(object({
    ipv6_cidr_block     = string
    ipv6_ipam_pool_id   = string
    ipv6_netmask_length = number
  }))
  default     = {}
  description = "IPv6 CIDR blocks to assign to the VPC."
}


variable "ipv6_cidr_block_network_border_group" {
  type        = string
  default     = null
  description = "Set this to restrict advertisement of public addresses to a specific Network Border Group such as a LocalZone."
}

variable "instance_tenancy" {
  type        = string
  default     = "default"
  description = "A tenancy option for instances launched into the VPC."
}

variable "dns_hostnames_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "dns_support_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC."
}

variable "default_network_acl_deny_all" {
  type        = bool
  default     = false
   description = <<-EOT
    When `true`, manage the default network acl and remove all rules, disabling all ingress and egress.
    When `false`, do not mange the default networking acl, allowing it to be managed by another component.
    EOT
}


variable "internet_gateway_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable INTERNET GATEWAY in the VPC."
}
variable "aws_default_route_table_enabled" {
  type        = bool
  default     = true
   description = "A boolean flag to enable/disable Default Route Table in the VPC."
}

variable "ipv6_egress_only_internet_gateway_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable EGRESS ONLY INTERNET GATEWAY in the VPC."
}
variable "default_security_group_deny_all" {
  type        = bool
  default     = true
  description = <<-EOT
    When `true`, manage the default security group and remove all rules, disabling all ingress and egress.
    When `false`, do not manage the default security group, allowing it to be managed by another component.
    EOT
}

variable "default_route_table_no_routes" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, manage the default route table and remove all routes, disabling all ingress and egress.
    When `false`, do not mange the default route table, allowing it to be managed by another component.
    EOT
}


variable "enable_dhcp_options" {
  type        = bool
  default     = false
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
}

variable "dhcp_options_domain_name" {
  type        = string
  default     = ""
  description = "Specifies DNS name for DHCP options set (requires enable_dhcp_options set to true)"
}

variable "dhcp_options_domain_name_servers" {
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
}

variable "dhcp_options_ntp_servers" {
  type        = list(string)
  default     = []
  description = "Specify a list of NTP servers for DHCP options set (requires enable_dhcp_options set to true)"
}

variable "dhcp_options_netbios_name_servers" {
  type        = list(string)
  default     = []
  description = "Specify a list of netbios servers for DHCP options set (requires enable_dhcp_options set to true)"
}

variable "dhcp_options_netbios_node_type" {
  type        = string
  default     = ""
  description = "Specify netbios node_type for DHCP options set (requires enable_dhcp_options set to true)"
}


variable "enabled_ipv6_egress_only_internet_gateway" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable IPv6 Egress-Only Internet Gateway creation"
}

variable "restrict_default_sg" {
  type        = bool
  default     = true
  description = "Flag to control the restrict default sg creation."
}

variable "default_security_group_ingress" {
  type        = list(map(string))
  default     = []
  description = "List of maps of ingress rules to set on the default security group"
}

variable "default_security_group_egress" {
  type        = list(map(string))
  default     = []
  description = "List of maps of egress rules to set on the default security group"
}
#Module      : FLOW LOG
#Description : Terraform flow log module variables.

variable "enable_flow_log" {
  type        = bool
  default     = false
  description = "Enable vpc_flow_log logs."
}

variable "s3_bucket_arn" {
  type        = string
  default     = ""
  description = "S3 ARN for vpc logs."
  sensitive   = true
}

variable "traffic_type" {
  type        = string
  default     = "ALL"
  description = "Type of traffic to capture. Valid values: ACCEPT,REJECT, ALL."
}


