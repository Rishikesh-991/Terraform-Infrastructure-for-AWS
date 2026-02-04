resource "aws_elasticache_cluster" "redis" {
  count = var.create ? 1 : 0
  cluster_id = "redis-${var.environment}"
  engine = "redis"
  node_type = var.node_type
  num_cache_nodes = var.num_cache_nodes
  subnet_group_name = var.subnet_group_name
  security_group_ids = var.security_group_ids
  tags = var.tags
}
