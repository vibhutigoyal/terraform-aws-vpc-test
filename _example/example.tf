####--------------------------------------------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "us-west-1"
}


####------------------------------------------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
####------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source  = "../"

  name        = "vpc"
  environment = "example"
  label_order = ["name", "environment"]

  ipv4_primary_cidr_block = "192.168.0.0/24"
  ipv4_additional_cidr_block_associations = {
    "192.168.1.0/24" = {
      ipv4_cidr_block     = "192.168.1.0/24"
      ipv4_ipam_pool_id   = null
      ipv4_netmask_length = null
    }
  }
  assign_generated_ipv6_cidr_block = true

  default_security_group_deny_all = true
  default_route_table_no_routes   = false
  default_network_acl_deny_all    = false

  enable_flow_log                           = false
  enable_dhcp_options                       = false
  dhcp_options_domain_name                  = "service.consul"
  dhcp_options_domain_name_servers          = ["127.0.0.1", "10.10.0.2"]
  enabled_ipv6_egress_only_internet_gateway = true
}