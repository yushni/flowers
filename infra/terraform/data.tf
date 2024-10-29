data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-06801a226628c00ce"]
  }
}

data "aws_acm_certificate" "semycvitka" {
  domain = "semycvitka.com"
}