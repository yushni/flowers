resource "aws_ssm_parameter" "db-password" {
  name        = "/db/password"
  description = "The password for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-3.password

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-username" {
  name        = "/db/username"
  description = "The username for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-3.username

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-host" {
  name        = "/db/host"
  description = "The host for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-3.address

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-port" {
  name        = "/db/port"
  description = "The port for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-3.port

  tags = {
    environment = var.env
  }
}

resource "aws_ssm_parameter" "db-name" {
  name        = "/db/name"
  description = "The name for the database"
  type        = "SecureString"
  value       = aws_db_instance.app-3.db_name

  tags = {
    environment = var.env
  }
}