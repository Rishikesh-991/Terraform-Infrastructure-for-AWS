output "cluster_endpoint" { value = try(aws_rds_cluster.this[0].endpoint, "") }
output "reader_endpoint" { value = try(aws_rds_cluster.this[0].reader_endpoint, "") }
