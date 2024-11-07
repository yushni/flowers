resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
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
    Name = "${var.resource_prefix}-app"
  }
}

resource "aws_db_subnet_group" "app" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_instance" "app-3" {
  allocated_storage   = 10
  db_name             = "app"
  engine              = "postgres"
  engine_version      = "16.3"
  instance_class      = "db.t3.micro"
  username            = "app_user"
  password            = random_password.password.result
  skip_final_snapshot = true
  identifier          = "app-3"
  publicly_accessible = true
  apply_immediately   = true

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name = "${var.resource_prefix}-app"
  }
}