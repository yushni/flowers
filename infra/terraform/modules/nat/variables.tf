variable "aws_region" {
  description = "The AWS region"
  type        = string
}

variable "resource_prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID"
  type        = string
}

variable "route_table_id" {
  description = "The Route Table ID"
  type        = string
}

variable "security_group_id" {
  description = "The Security Group ID"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID"
  type        = string
}
