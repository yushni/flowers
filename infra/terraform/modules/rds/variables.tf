variable "vpc_id" {
  description = "The VPC ID"
  type        = string

}
variable "resource_prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs"
  type        = list(string)
}

variable "env" {
  description = "The environment"
  type        = string
}