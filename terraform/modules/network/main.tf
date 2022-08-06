resource "aws_vpc" "main" {
  # The network will be IPv6 only, so CIDR blocks can overlap with other VPCs
  cidr_block                       = "172.31.0.0/16"
  assign_generated_ipv6_cidr_block = true

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.region}${var.suffix}"
  }
}

data "aws_availability_zones" "all" {
}

resource "aws_subnet" "private" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id = aws_vpc.main.id

  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index * 2)
  ipv6_native                     = true
  assign_ipv6_address_on_creation = true

  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true

  tags = {
    Name = "private-subnet-${data.aws_availability_zones.all.names[count.index]}${var.suffix}"
  }
}

resource "aws_egress_only_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "egress-only-internet-gateway-${var.region}"
  }
}

resource "aws_subnet" "public" {
  count = length(data.aws_availability_zones.all.names)

  vpc_id = aws_vpc.main.id


  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, (count.index * 2) + 1)
  ipv6_native                     = true
  assign_ipv6_address_on_creation = true

  enable_dns64                                   = true
  enable_resource_name_dns_aaaa_record_on_launch = true

  tags = {
    Name = "public-subnet-${data.aws_availability_zones.all.names[count.index]}${var.suffix}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet-gateway-${var.region}"
  }
}
