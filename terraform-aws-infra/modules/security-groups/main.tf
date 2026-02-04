# Security Groups module - creates common environment security groups
resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion-sg"
  description = "Bastion host security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from management CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.management_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-bastion-sg" })
}

resource "aws_security_group" "app" {
  name        = "${var.environment}-app-sg"
  description = "Application security group (frontend)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_allowed_cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.alb_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-app-sg" })
}

resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Database security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow DB access from application SG"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.environment}-db-sg" })
}
