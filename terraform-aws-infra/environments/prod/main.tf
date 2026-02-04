# PROD ENVIRONMENT - same wiring as dev
module "vpc" { source = "../../modules/vpc" 
  environment = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  number_of_availability_zones = var.number_of_availability_zones
  public_subnet_bits = var.public_subnet_bits
  private_subnet_bits = var.private_subnet_bits
  vpc_flow_logs_retention = var.vpc_flow_logs_retention
  vpc_flow_logs_traffic_type = var.vpc_flow_logs_traffic_type
  create_s3_endpoint = var.create_s3_endpoint
  create_dynamodb_endpoint = var.create_dynamodb_endpoint
  tags = merge(var.common_tags, { Module = "vpc" })
}

module "iam" { source = "../../modules/iam"
  environment = var.environment
  create_cross_env_role = var.create_cross_env_role
  create_cross_account_role = var.create_cross_account_role
  trusted_account_id = var.trusted_account_id
  external_id = var.external_id
  tags = merge(var.common_tags, { Module = "iam" })
}

module "security_groups" { source = "../../modules/security-groups"
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  management_cidrs = ["0.0.0.0/0"]
  alb_allowed_cidrs = ["0.0.0.0/0"]
  db_port = 5432
  tags = merge(var.common_tags, { Module = "security-groups" })
}

module "route_tables" { source = "../../modules/route-tables"
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  internet_gateway_id = module.vpc.internet_gateway_id
  nat_gateway_ids = module.vpc.nat_gateway_ids
  create_public_route_table = true
  tags = merge(var.common_tags, { Module = "route-tables" })
}

module "ec2" { source = "../../modules/ec2"
  environment = var.environment
  create_instance = false
  instance_profile_name = module.iam.ec2_instance_profile_name
  security_group_ids = [module.security_groups.app_sg_id]
  tags = merge(var.common_tags, { Module = "ec2" })
}
