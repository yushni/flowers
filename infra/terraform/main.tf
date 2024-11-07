terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  aws_region      = var.aws_region
  resource_prefix = local.resource_prefix
}

module "nat" {
  source = "./modules/nat"
  depends_on = [module.network]

  aws_region        = var.aws_region
  instance_type     = var.instance_type
  resource_prefix   = local.resource_prefix
  ami_id            = data.aws_ami.amzn-linux-2023-ami.id
  route_table_id    = module.network.private_route_table_id
  security_group_id = module.network.allow_all_to_all_sg_id
  subnet_id         = module.network.public_subnet_1a_id
}

module "rds" {
  source = "./modules/rds"
  depends_on = [module.network]

  resource_prefix = local.resource_prefix
  env             = var.env
  subnet_ids = [
    module.network.public_subnet_1a_id,
    module.network.public_subnet_1b_id,
  ]
  vpc_id = module.network.vpc_id
}

module "app" {
  source = "./modules/app"
  depends_on = [module.rds, module.nat]

  ami_id                = data.aws_ami.amzn-linux-2023-ami.id
  app_security_group_id = module.network.allow_all_to_all_sg_id
  app_subnet_ids = [
    module.network.private_subnet_1a_id,
    module.network.private_subnet_1b_id,
  ]
  aws_region           = var.aws_region
  instance_type        = var.instance_type
  lb_security_group_id = module.network.allow_all_to_all_sg_id
  lb_subnet_ids = [
    module.network.public_subnet_1a_id,
    module.network.public_subnet_1b_id,
  ]
  resource_prefix = local.resource_prefix
  vpc_id          = module.network.vpc_id
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-06801a226628c00ce"]
  }
}