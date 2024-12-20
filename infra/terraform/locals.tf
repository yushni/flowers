locals {
  short_regions_map = {
    "eu-central-1" = "euc1"
    "eu-west-1"    = "euw1"
    "us-east-1"    = "use1"
  }

  short_region_name = lookup(local.short_regions_map, var.aws_region)
  resource_prefix   = "${local.short_region_name}-${var.env}"

  public_subnet_ids = [
    module.network.public_subnet_1a_id,
    module.network.public_subnet_1b_id,
  ]
  private_subnet_ids = [
    module.network.private_subnet_1a_id,
    module.network.private_subnet_1b_id,
  ]
}