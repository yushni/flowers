resource "aws_launch_template" "app" {
  name_prefix            = "${var.resource_prefix}-app"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  update_default_version = true

  vpc_security_group_ids = [var.app_security_group_id]

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.resource_prefix}-app"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata/app.sh", {
    REGION = var.aws_region,
  }))
}

resource "aws_lb_target_group" "app" {
  name     = "${var.resource_prefix}-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_autoscaling_group" "app" {
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.app_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  target_group_arns         = [aws_lb_target_group.app.arn]

  tag {
    key                 = "Name"
    value               = "${var.resource_prefix}-app"
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


resource "aws_lb" "app" {
  name               = "${var.resource_prefix}-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets            = var.lb_subnet_ids

  tags = {
    Name = "${var.resource_prefix}-app"
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