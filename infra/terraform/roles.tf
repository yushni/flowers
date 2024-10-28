# NAT INSTANCE ROLE
resource "aws_iam_role" "nat" {
  name = "NatRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.resource_prefix}-nat-role"
  }
}

resource "aws_iam_policy" "nat" {
  name        = "nat-policy"
  path        = "/"
  description = "Allow EC2 to create and replace routes"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1730125970996",
        "Action" : [
          "ec2:CreateRoute",
          "ec2:ReplaceRoute"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "Stmt1730128162079",
        "Action" : [
          "ec2:ModifyInstanceAttribute"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach_nat" {
  role       = aws_iam_role.nat.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "nat_attach" {
  role       = aws_iam_role.nat.name
  policy_arn = aws_iam_policy.nat.arn
}

resource "aws_iam_instance_profile" "nat" {
  name = "${local.resource_prefix}-nat-profile"
  role = aws_iam_role.nat.name
}

# APP INSTANCE ROLE
resource "aws_iam_role" "app" {
  name = "AppRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.resource_prefix}-app-role"
  }
}

resource "aws_iam_policy" "app" {
  name        = "app-policy"
  path        = "/"
  description = "Allow EC2 to create and replace routes"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Stmt1730125970996",
        "Action" : [
          "ssm:GetParametersByPath",
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach_app" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.resource_prefix}-app-profile"
  role = aws_iam_role.app.name
}
