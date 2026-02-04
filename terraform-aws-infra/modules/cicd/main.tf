# CICD IAM role for pipelines (disabled by default)
resource "aws_iam_role" "cicd_role" {
  count = var.create ? 1 : 0
  name = "cicd-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.cicd_assume.json
  tags = var.tags
}

data "aws_iam_policy_document" "cicd_assume" {
  statement { actions = ["sts:AssumeRole"] principals { type = "Service" identifiers = ["codepipeline.amazonaws.com", "ecs-tasks.amazonaws.com", "lambda.amazonaws.com"] } }
}

resource "aws_iam_role_policy_attachment" "cicd_attach" {
  count = var.create ? 1 : 0
  role = aws_iam_role.cicd_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
