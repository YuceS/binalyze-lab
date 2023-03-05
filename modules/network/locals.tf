locals {
  azs                    = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.main.names
  internet_gateway_count = (var.create_internet_gateway && length(var.public_subnet_cidrs) > 0) ? 1 : 0
  account_id             = aws_vpc.main.owner_id

}

