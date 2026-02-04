output "cluster_id" { value = try(aws_ecs_cluster.this[0].id, "") }
