output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "nat_gateway_ids" { value = module.vpc.nat_gateway_ids }
output "public_route_table_id" { value = module.route_tables.public_route_table_id }
output "private_route_table_ids" { value = module.route_tables.private_route_table_ids }
output "app_security_group_id" { value = module.security_groups.app_sg_id }
output "db_security_group_id" { value = module.security_groups.db_sg_id }
output "bastion_security_group_id" { value = module.security_groups.bastion_sg_id }
output "ec2_launch_template_id" { value = module.ec2.launch_template_id }
output "ec2_instance_profile_name" { value = module.iam.ec2_instance_profile_name }

# Phase2 outputs
output "bastion_launch_template_id" { value = try(module.bastion.launch_template_id, "") }
output "bastion_instance_profile_name" { value = try(module.bastion.instance_profile_name, "") }
output "monitoring_log_group" { value = try(module.monitoring.log_group_name, "") }
output "cicd_role_name" { value = try(module.cicd.cicd_role_name, "") }

# Phase3 outputs
output "ecs_cluster_id" { value = try(module.ecs.cluster_id, "") }
output "eks_cluster_name" { value = try(module.eks.cluster_name, "") }
output "rds_endpoint" { value = try(module.databases.rds_endpoint, "") }
output "storage_bucket_id" { value = try(module.storage.bucket_id, "") }

# Phase4 outputs
output "guardduty_detector_id" { value = try(module.security_governance.guardduty_detector_id, "") }
output "config_recorder_name" { value = try(module.security_governance.config_recorder_name, "") }
output "transit_gateway_id" { value = try(module.transit_gateway.transit_gateway_id, "") }

# Phase5 outputs
output "observability_log_group" { value = try(module.observability.log_group_name, "") }
output "budgets" { value = try(module.cost.budgets, []) }

# Remaining services outputs
output "alb_dns" { value = try(module.alb.alb_dns_name, "") }
output "asg_id" { value = try(module.asg.asg_id, "") }
output "aurora_cluster_endpoint" { value = try(module.aurora.cluster_endpoint, "") }
output "dynamodb_table" { value = try(module.dynamodb.table_name, "") }
output "elasticache_id" { value = try(module.elasticache.elasticache_id, "") }
output "kms_key_id_extra" { value = try(module.kms.kms_key_id, "") }
output "lambda_arn_extra" { value = try(module.lambda.lambda_arn, "") }
output "nlb_dns" { value = try(module.nlb.nlb_dns_name, "") }
output "route53_zone_id" { value = try(module.route53_extra.zone_id, "") }
output "ssm_documents" { value = try(module.ssm_extra.documents, []) }
