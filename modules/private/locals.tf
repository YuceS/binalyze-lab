locals {
  azs               = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.main.names
  nat_gateway_count = var.create_nat_gateways ? min(length(local.azs), length(var.public_subnet_cidrs), length(var.private_subnet_cidrs)) : 0

  internet_gateway_count = (var.create_internet_gateway && length(var.public_subnet_cidrs) > 0) ? 1 : 0
  account_id             = aws_vpc.main.owner_id

}

