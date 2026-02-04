# RDS skeleton (disabled by default)
resource "aws_db_instance" "this" {
  count = var.create ? 1 : 0
  identifier = "db-${var.environment}"
  engine = var.engine
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  multi_az = var.multi_az
  db_subnet_group_name = var.subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot = true
  tags = var.tags
}

resource "aws_elasticache_cluster" "redis" {
  count = 0
}
