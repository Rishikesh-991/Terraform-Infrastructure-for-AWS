resource "aws_rds_cluster" "this" {
  count = var.create ? 1 : 0
  engine = var.engine
  db_subnet_group_name = var.subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot = true
  tags = var.tags
}

resource "aws_rds_cluster_instance" "instance" {
  count = var.create ? 1 : 0
  identifier = "aurora-${var.environment}-instance"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class = var.instance_class
}
