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
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  security_groups = [
    aws_security_group.allow_all_to_all.id
  ]

  tags = {
    Name = "${local.resource_prefix}-private-1a"
  }
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.main_public_1a.id
  associate_public_ip_address = true
  source_dest_check           = false
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  security_groups = [
    aws_security_group.allow_all_to_all.id
  ]

  user_data = file("${path.module}/userdata/nat.sh")

  tags = {
    Name = "${local.resource_prefix}-nat"
  }
}