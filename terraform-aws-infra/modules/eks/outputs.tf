output "cluster_name" { value = try(aws_eks_cluster.this[0].name, "") }
output "cluster_endpoint" { value = try(aws_eks_cluster.this[0].endpoint, "") }
