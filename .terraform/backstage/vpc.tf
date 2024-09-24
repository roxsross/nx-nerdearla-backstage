# data "aws_availability_zones" "azs" {
#   state = "available"
# }

# locals {
#   vpc_name = "${local.project_prefix}-vpc"
# }

# resource "aws_vpc" "main" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = merge(
#     {
#       "Name" = local.vpc_name
#     },
#     var.default_tags
#   )
# }

# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     "Name" = "${local.vpc_name}-igw"
#   }
# }

# ##########################################
# # Public Subnet Resources
# ##########################################
# resource "aws_subnet" "public_1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.public_1_cidr
#   map_public_ip_on_launch = true
#   availability_zone       = element(data.aws_availability_zones.azs.names, 0)

#   tags = {
#     "Name" = "${local.vpc_name}-public-subnet-1"
#   }
# }

# resource "aws_subnet" "public_2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.public_2_cidr
#   map_public_ip_on_launch = true
#   availability_zone       = element(data.aws_availability_zones.azs.names, 1)

#   tags = {
#     "Name" = "${local.vpc_name}-public-subnet-1"
#   }
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   lifecycle {
#     ignore_changes = all
#   }

#   tags = {
#     "Name" = "${local.vpc_name}-public-rt"
#   }
# }

# resource "aws_route_table_association" "public_1" {
#   subnet_id      = aws_subnet.public_1.id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_route_table_association" "public_2" {
#   subnet_id      = aws_subnet.public_2.id
#   route_table_id = aws_route_table.public.id
# }

# ##########################################
# # Private Subnet Resources
# ##########################################
# resource "aws_subnet" "private_1" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.private_1_cidr
#   map_public_ip_on_launch = false
#   availability_zone       = element(data.aws_availability_zones.azs.names, 0)

#   tags = {
#     "Name" = "${local.vpc_name}-private-subnet-1"
#   }
# }

# resource "aws_subnet" "private_2" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = var.private_2_cidr
#   map_public_ip_on_launch = false
#   availability_zone       = element(data.aws_availability_zones.azs.names, 1)

#   tags = {
#     "Name" = "${local.vpc_name}-private-subnet-2"
#   }
# }
