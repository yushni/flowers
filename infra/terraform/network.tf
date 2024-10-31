resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${local.resource_prefix}-main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.resource_prefix}-main"
  }
}

resource "aws_subnet" "main_public_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.resource_prefix}-main-public-1a"
  }
}

resource "aws_subnet" "main_public_1b" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "${var.aws_region}b"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.resource_prefix}-main-public-1b"
  }
}

resource "aws_subnet" "main_private_1a" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}a"
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "${local.resource_prefix}-main-private-1a"
  }
}

resource "aws_subnet" "main_private_1b" {
  vpc_id            = aws_vpc.main.id
  availability_zone = "${var.aws_region}b"
  cidr_block        = "10.0.4.0/24"

  tags = {
    Name = "${local.resource_prefix}-main-private-1b"
  }
}

resource "aws_default_route_table" "main_public" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${local.resource_prefix}-main-public"
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
    Name = "${local.resource_prefix}-main-private"
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

resource "aws_lb" "app" {
  name               = "${local.resource_prefix}-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_all_to_all.id]
  subnets            = [aws_subnet.main_public_1a.id, aws_subnet.main_public_1b.id]

  tags = {
    Name = "${local.resource_prefix}-app"
  }
}

resource "aws_lb_listener" "app-http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_listener" "app-https" {
  load_balancer_arn = aws_lb.app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.semycvitka.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

output "app_lb_dns" {
  value = aws_lb.app.dns_name
}