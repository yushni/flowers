// Common
variable "env" {
  description = "The environment to deploy"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "Invalid environment"
  }
}

variable "aws_region" {
  default = "eu-central-1"
}

// EC2
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}
