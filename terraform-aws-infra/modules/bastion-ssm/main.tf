# Bastion + SSM (safe defaults: create_bastion = false)
resource "aws_iam_role" "bastion_ssm_role" {
  count = var.create_bastion ? 1 : 0
  name = "bastion-ssm-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume.json
  tags = var.tags
}

data "aws_iam_policy_document" "bastion_assume" {
  statement { actions = ["sts:AssumeRole"] principals { type = "Service" identifiers = ["ec2.amazonaws.com"] } }
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  count = var.create_bastion ? 1 : 0
  role = aws_iam_role.bastion_ssm_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  count = var.create_bastion ? 1 : 0
  name = "bastion-profile-${var.environment}"
  role = aws_iam_role.bastion_ssm_role[0].name
}

resource "aws_launch_template" "bastion_lt" {
  count = var.create_bastion ? 1 : 0
  name_prefix = "bastion-${var.environment}-"
  image_id = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile { name = aws_iam_instance_profile.bastion_profile[0].name }
  tag_specifications { resource_type = "instance" tags = var.tags }
}
