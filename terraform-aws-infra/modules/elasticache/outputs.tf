output "elasticache_id" { value = try(aws_elasticache_cluster.redis[0].id, "") }
