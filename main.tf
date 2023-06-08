# Managed By : CloudDrove
# Description : This Script is used to create VPC, Internet Gateway and Flow log.
# Copyright @ CloudDrove. All Right Reserved.

#Module      : labels
#Description : This terraform module is designed to generate consistent label names and tags
#              for resources. You can use terraform-labels to implement a strict naming
#              convention.module "labels" {
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}
#Module      : VPC
#Description : Terraform module to create VPC resource on AWS.

resource "aws_vpc" "default" {
  count = var.vpc_enabled ? 1 : 0
  cidr_block          = var.ipv4_primary_cidr_block
  ipv4_ipam_pool_id   = try(var.ipv4_additional_cidr_block_associations.ipv4_ipam_pool_id, null)
  ipv4_netmask_length = try(var.ipv4_additional_cidr_block_associations.ipv4_netmask_length, null)

  ipv6_cidr_block     = var.ipv6_cidr_block
  ipv6_ipam_pool_id   = try(var.ipv6_additional_cidr_block_associations.ipv6_ipam_pool_id, null)
  ipv6_netmask_length = try(var.ipv6_additional_cidr_block_associations.ipv6_netmask_length, null)

  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.dns_hostnames_enabled
  enable_dns_support               = var.dns_support_enabled
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  tags                             = module.labels.tags
  lifecycle {
    # Ignore tags added by kubernetes
    ignore_changes = [
      tags,
      tags["kubernetes.io"],
      tags["SubnetType"],
    ]
  }
}

#Module       :VPC IPV4 CIDR BLOCK ASSOCIATION 
#Description  :Provides a resource to associate additional IPv4 CIDR blocks with a VPC.

resource "aws_vpc_ipv4_cidr_block_association" "default" {
  for_each = var.ipv4_additional_cidr_block_associations

  cidr_block          = each.value.ipv4_cidr_block
  ipv4_ipam_pool_id   = each.value.ipv4_ipam_pool_id
  ipv4_netmask_length = each.value.ipv4_netmask_length

  vpc_id = aws_vpc.default[0].id

}

#Module       :VPC IPV6 CIDR BLOCK ASSOCIATION    
#Description  :Provides a resource to associate additional IPv6 CIDR blocks with a VPC.

resource "aws_vpc_ipv6_cidr_block_association" "default" {
  for_each = var.ipv6_additional_cidr_block_associations 

  ipv6_cidr_block     = each.value.ipv6_cidr_block
  ipv6_ipam_pool_id   = each.value.ipv6_ipam_pool_id
  ipv6_netmask_length = each.value.ipv6_netmask_length

  vpc_id = aws_vpc.default[0].id
}

#Module      : INTERNET GATEWAY
#Description : Terraform module which creates Internet Geteway resources on AWS

resource "aws_internet_gateway" "default" {
  count = var.internet_gateway_enabled ? 1 : 0

  vpc_id = aws_vpc.default[0].id
  tags   = module.labels.tags
}


#Module      : EGRESS ONLY INTERNET GATEWAY
#Description : Terraform module which creates EGRESS ONLY INTERNET GATEWAY resources on AWS

resource "aws_egress_only_internet_gateway" "default" {
  count = var.vpc_enabled && var.enabled_ipv6_egress_only_internet_gateway ? 1 : 0

  vpc_id = join("", aws_vpc.default.*.id)
  tags   = module.labels.tags
}

#Module      : Default Security Group
#Description : Ensure the default security group of every VPC restricts all traffic.

resource "aws_default_security_group" "default" {
  count = var.vpc_enabled && var.restrict_default_sg == true ? 1 : 0

  vpc_id = join("", aws_vpc.default.*.id)

  dynamic "ingress" {
    for_each = var.default_security_group_ingress
    content {
      self             = lookup(ingress.value, "self", true)
      cidr_blocks      = compact(split(",", lookup(ingress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(ingress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(ingress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(ingress.value, "security_groups", "")))
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", 0)
      to_port          = lookup(ingress.value, "to_port", 0)
      protocol         = lookup(ingress.value, "protocol", "-1")
    }
  }

  dynamic "egress" {
    for_each = var.default_security_group_egress
    content {
      self             = lookup(egress.value, "self", true)
      cidr_blocks      = compact(split(",", lookup(egress.value, "cidr_blocks", "")))
      ipv6_cidr_blocks = compact(split(",", lookup(egress.value, "ipv6_cidr_blocks", "")))
      prefix_list_ids  = compact(split(",", lookup(egress.value, "prefix_list_ids", "")))
      security_groups  = compact(split(",", lookup(egress.value, "security_groups", "")))
      description      = lookup(egress.value, "description", null)
      from_port        = lookup(egress.value, "from_port", 0)
      to_port          = lookup(egress.value, "to_port", 0)
      protocol         = lookup(egress.value, "protocol", "-1")
    }
  }

  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-default-sg", module.labels.id)
    }
  )
}
#Module      : DEFAULT ROUTE TABLE
#Description : Provides a resource to manage a default route table of a VPC.
#              This resource can manage the default route table of the default or a non-default VPC.
resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.default[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default[0].id
  }
  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.default[0].id
  }
    tags = merge(
      module.labels.tags,
    {
        "Name" = format("%s-default_rt", module.labels.id)
    }
  )

  
}
#Module      : VPC DHCP Option
#Description : Provides a VPC DHCP Options resource.

resource "aws_vpc_dhcp_options" "vpc_dhcp" {
  count = var.vpc_enabled && var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-vpc_dhcp", module.labels.id)
    }
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.vpc_enabled && var.enable_dhcp_options ? 1 : 0

  vpc_id          = join("", aws_vpc.default.*.id)
  dhcp_options_id = join("", aws_vpc_dhcp_options.vpc_dhcp.*.id)
}

#Module      : FLOW LOG
#Description : Provides a VPC/Subnet/ENI Flow Log to capture IP traffic for a
#              specific network interface, subnet, or VPC. Logs are sent to S3 Bucket.
resource "aws_flow_log" "vpc_flow_log" {
  count = var.vpc_enabled && var.enable_flow_log == true ? 1 : 0

  log_destination      = var.s3_bucket_arn
  log_destination_type = "s3"
  traffic_type         = var.traffic_type
  vpc_id               = join("", aws_vpc.default.*.id)
  tags                 = module.labels.tags
}

#Module        : DEFAULT NETWORK ACL
#Description   : Provides a resource to manage a VPC's default network ACL.
#                This resource can manage the default network ACL of the default or a non-default VPC.
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.default[0].default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-vpc_dhcp", module.labels.id)
    }
  )
}