resource "aws_launch_template" "nat" {
  name_prefix            = "${var.resource_prefix}-nat"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  update_default_version = true

  vpc_security_group_ids = [
    aws_security_group.nat.id,
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.nat.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.resource_prefix}-nat"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata/nat.sh", {
    ROUTE_TABLE_ID = var.route_table_id,
    REGION         = var.aws_region,
  }))
}

resource "aws_autoscaling_group" "nat" {
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]

  tag {
    key                 = "Name"
    value               = "${var.resource_prefix}-nat"
    propagate_at_launch = true
  }

  launch_template {
    id      = aws_launch_template.nat.id
    version = aws_launch_template.nat.default_version
  }
}
