module "vpc" {
  source = "../../modules/vpc"

  name               = "dev"
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  nat_gateway_mode   = "single"
  enable_flow_logs   = false

  tags = {
    Environment = "dev"
  }
}
