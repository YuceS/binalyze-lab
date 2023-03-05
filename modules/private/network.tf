resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.tags,
    {
      "Name" = var.vpc_name
    },
  )
}


resource "aws_s3_bucket" "flow_logs" {
  bucket              = format("%s-%s", "binalyze-air-lab-flow-logs", formatdate("YYYYMMDDhhmmss", timestamp()))
  object_lock_enabled = true
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [bucket]
  }
}
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}



resource "aws_internet_gateway" "public" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-public-igw"
    },
  )
}

resource "aws_route_table" "public" {
  depends_on = [aws_vpc.main]
  vpc_id     = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-public-rt"
    },
  )
}

resource "aws_route" "public" {

  depends_on = [
    aws_internet_gateway.public,
    aws_route_table.public,
  ]
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.public.id
  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_subnet" "public" {
  #  count                   = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  # cidr_block            _subnet  = var.public_subnet_cidrs[count.index]
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = element(local.azs, 1)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.tags,
    {
      #"Name" = "${var.name_prefix}-public-subnet-${count.index + 1}"
      "Name" = "${var.name_prefix}-public-subnet"
      "Tier" = "Public"
    },
  )
}

resource "aws_route_table_association" "public" {
  #count          = length(var.public_subnet_cidrs)
  #subnet_id      = aws_subnet.public[count.index].id
  #route_table_id = aws_route_table.public[0].id
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  depends_on = [aws_vpc.main]

  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-private-rt"
    },
  )
}

resource "aws_route" "private" {
  depends_on = [
    aws_nat_gateway.private,
    aws_route_table.private,
  ]
  #count                  = local.nat_gateway_count > 0 ? length(var.private_subnet_cidrs) : 0
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.private.id
  destination_cidr_block = "0.0.0.0/0"
}



resource "aws_subnet" "private" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = element(local.azs, 0)
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-private-subnet"
      "Tier" = "Private"
    },
  )
}

resource "aws_route_table_association" "private" {

  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
resource "aws_eip" "nat_gateway_public_ip" {}
resource "aws_nat_gateway" "private" {
  depends_on = [
    aws_internet_gateway.public,
  ]
  allocation_id = aws_eip.nat_gateway_public_ip.allocation_id
  subnet_id     = aws_subnet.public.id
  tags = merge(
    var.tags,
    {
      "Name" = "${var.name_prefix}-nat-gateway"
    },
  )
}