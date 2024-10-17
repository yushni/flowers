terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main_public_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-central-1a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "main_public_1a"
  }
}

resource "aws_subnet" "main_public_1b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-central-1b"
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "main_public_1b"
  }
}

resource "aws_subnet" "main_private_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-central-1a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "main_private_1a"
  }
}

resource "aws_subnet" "main_private_1b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "eu-central-1b"
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "main_private_1b"
  }
}

resource "aws_default_route_table" "main_public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main-public"
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
    Name = "main-private"
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


data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "allow_all_to_all" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "public_1a" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main_public_1a.id
  associate_public_ip_address = true
  security_groups             = [
    aws_security_group.allow_all_to_all.id
  ]

  tags = {
    Name = "public_1a"
  }
}

resource "aws_instance" "private_1a" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.main_private_1a.id
  associate_public_ip_address = false
  security_groups             = [
    aws_security_group.allow_all_to_all.id
  ]

  tags = {
    Name = "private_1a"
  }
}