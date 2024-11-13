resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.resource_prefix}-main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.resource_prefix}-main"
  }
}

resource "aws_subnet" "main_public_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_prefix}-main-public-1a"
  }
}

resource "aws_subnet" "main_public_1b" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.resource_prefix}-main-public-1b"
  }
}

resource "aws_subnet" "main_private_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "${var.resource_prefix}-main-private-1a"
  }
}

resource "aws_subnet" "main_private_1b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}b"
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "${var.resource_prefix}-main-private-1b"
  }
}

resource "aws_default_route_table" "main_public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.resource_prefix}-main-public"
  }
}

resource "aws_route_table_association" "main_public_1a" {
  subnet_id      = aws_subnet.main_public_1a.id
  route_table_id = aws_default_route_table.main_public.id
}

resource "aws_route_table_association" "main_public_1b" {
  subnet_id      = aws_subnet.main_public_1b.id
  route_table_id = aws_default_route_table.main_public.id
}

resource "aws_route_table" "main_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.resource_prefix}-main-private"
  }
}

resource "aws_route_table_association" "main_private_1a" {
  subnet_id      = aws_subnet.main_private_1a.id
  route_table_id = aws_route_table.main_private.id
}

resource "aws_route_table_association" "main_private_1b" {
  subnet_id      = aws_subnet.main_private_1b.id
  route_table_id = aws_route_table.main_private.id
}
