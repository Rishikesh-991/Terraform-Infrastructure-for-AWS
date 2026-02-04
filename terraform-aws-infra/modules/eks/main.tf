# Minimal EKS skeleton (disabled by default)
resource "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0
  name = var.cluster_name
  role_arn = ""
  vpc_config { subnet_ids = var.subnet_ids }
  tags = var.tags
}
