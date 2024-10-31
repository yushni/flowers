// todo: add the RDS module here
//   use: dbsubnet-group



### DATABASE
resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
#   vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.resource_prefix}-app"
  }
}

resource "aws_db_subnet_group" "app" {
  name = "my-db-subnet-group"
  subnet_ids = [
    // temporary solution
    aws_subnet.main_public_1a.id,
    aws_subnet.main_public_1b.id,

#     aws_subnet.main_private_1a.id,
#     aws_subnet.main_private_1b.id
  ]

}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "username" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "app-2" {
  allocated_storage   = 10
  db_name             = random_password.db.result
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  username            = random_password.username.result
  password            = random_password.password.result
  skip_final_snapshot = true
  identifier          = "app-2"
  publicly_accessible = true

#   db_subnet_group_name   = aws_db_subnet_group.app.name
#   vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name = "${local.resource_prefix}-app"
  }
}

resource "aws_ssm_parameter" "db-password" {
  name        = "/db/password"
  description = "The password for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-2.password

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-username" {
  name        = "/db/username"
  description = "The username for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-2.username

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-host" {
  name        = "/db/host"
  description = "The host for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-2.address

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-port" {
  name        = "/db/port"
  description = "The port for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-2.port

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-name" {
  name        = "/db/name"
  description = "The name for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-2.db_name

  tags = {
    environment = var.env
  }
}