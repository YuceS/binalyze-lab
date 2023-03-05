resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(
    var.tags,
    {
      "Name"     = var.vpc_name
      Definition = "${var.prefix}"

    },
  )
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3_rt" {
  route_table_id  = aws_route_table.public.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}


resource "aws_s3_bucket" "flow_logs" {
  bucket              = format("%s-%s", "binalyze-air-lab-flow-logs", formatdate("YYYYMMDDhhmmss", timestamp()))
  object_lock_enabled = true
  force_destroy       = true
  acl    = "private"
  lifecycle {
    ignore_changes = [bucket]

  }
  tags = merge(
    var.tags,
    {
      "Name"     = var.vpc_name
      Definition = "${var.prefix}"

    },
  )
}
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      "Name"     = var.vpc_name
      Definition = "${var.prefix}"

    },
  )
}

resource "aws_internet_gateway" "public" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-public-igw"
      Definition = "${var.prefix}"
    },
  )

}

resource "aws_route_table" "public" {
  depends_on = [aws_vpc.main]
  vpc_id     = aws_vpc.main.id
  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-public-rt"
      Definition = "${var.prefix}"
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
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = element(local.azs, 1)
  tags = merge(
    var.tags,
    {
      "Name"     = "${var.prefix}-public-subnet"
      "Tier"     = "Public"
      Definition = "${var.prefix}"
    },
  )
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

