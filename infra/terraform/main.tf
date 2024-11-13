module "network" {
  source = "./modules/network"

  aws_region      = var.aws_region
  resource_prefix = local.resource_prefix
}

module "nat" {
  source = "./modules/nat"

  aws_region      = var.aws_region
  instance_type   = var.instance_type
  resource_prefix = local.resource_prefix
  ami_id          = data.aws_ami.amzn-linux-2023-ami.id
  route_table_id  = module.network.private_route_table_id
  subnet_ids      = local.public_subnet_ids
  vpc_id          = module.network.vpc_id
}

module "rds" {
  source = "./modules/rds"

  env             = var.env
  resource_prefix = local.resource_prefix
  subnet_ids      = local.public_subnet_ids
  vpc_id          = module.network.vpc_id
}

module "app" {
  source     = "./modules/app"
  depends_on = [module.rds, module.nat]

  ami_id                = data.aws_ami.amzn-linux-2023-ami.id
  app_subnet_ids        = local.private_subnet_ids
  aws_region            = var.aws_region
  instance_type         = var.instance_type
  lb_subnet_ids         = local.public_subnet_ids
  resource_prefix       = local.resource_prefix
  vpc_id                = module.network.vpc_id
}
