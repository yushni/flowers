# SETUP NAT
resource "aws_launch_template" "nat" {
  name_prefix            = "${local.resource_prefix}-nat"
  image_id               = data.aws_ami.amzn-linux-2023-ami.id
  instance_type          = var.instance_type
  update_default_version = true

  vpc_security_group_ids = [
    aws_security_group.allow_all_to_all.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.nat.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.resource_prefix}-nat"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata/nat.sh", {
    ROUTE_TABLE_ID = aws_route_table.main_private.id,
    REGION         = var.aws_region,
  }))
}

resource "aws_lb_target_group" "nat" {
  name     = "${local.resource_prefix}-nat"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_group" "nat" {
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.main_public_1a.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  target_group_arns         = [aws_lb_target_group.nat.arn]


  tag {
    key                 = "Name"
    value               = "${local.resource_prefix}-nat"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
  }

  launch_template {
    id      = aws_launch_template.nat.id
    version = "$Latest"
  }
}

#SETUP APP
resource "aws_launch_template" "app" {
  name_prefix            = "${local.resource_prefix}-app"
  image_id               = data.aws_ami.amzn-linux-2023-ami.id
  instance_type          = var.instance_type
  update_default_version = true

  vpc_security_group_ids = [
    aws_security_group.allow_all_to_all.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.resource_prefix}-app"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata/app.sh", {
    REGION = var.aws_region,
  }))
}

resource "aws_lb_target_group" "app" {
  name     = "${local.resource_prefix}-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_group" "app" {
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.main_private_1a.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  target_group_arns         = [aws_lb_target_group.app.arn]
  depends_on                = [aws_autoscaling_group.nat]

  tag {
    key                 = "Name"
    value               = "${local.resource_prefix}-app"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    triggers = ["launch_template"]
  }

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
}
