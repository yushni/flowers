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

variable "ami_id" {
  description = "The AMI ID"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "app_subnet_ids" {
  description = "The Subnet IDs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The Security Group ID"
  type        = string
}

variable "lb_security_group_id" {
  description = "The Security Group ID"
  type        = string
}

variable "lb_subnet_ids" {
  description = "The Subnet IDs"
  type        = list(string)
}
