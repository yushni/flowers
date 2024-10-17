resource "aws_instance" "public_1a" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_public_1a.id
  associate_public_ip_address = true
  security_groups = [
    aws_security_group.allow_all_to_all.id
  ]

  tags = {
    Name = "${local.resource_prefix}-public-1a"
  }
}

resource "aws_instance" "private_1a" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_private_1a.id
  associate_public_ip_address = false
  security_groups = [
    aws_security_group.allow_all_to_all.id
  ]

  tags = {
    Name = "${local.resource_prefix}-private-1a"
  }
}