# ALB Module (Application Load Balancer)

**Purpose:** Creates a production-grade Application Load Balancer for distributing HTTP/HTTPS traffic.

## What It Creates

- **Application Load Balancer:** For Layer 7 (application) traffic routing
- **Target Groups:** For routing rules based on path, hostname, method
- **Listeners:** HTTP and HTTPS listeners
- **Security Groups:** For ALB inbound/outbound rules
- **Access Logs:** To S3 for compliance
- **CloudWatch Alarms:** For monitoring

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable ALB creation |
| `environment` | string | - | Environment name |
| `name` | string | - | ALB name |
| `vpc_id` | string | - | VPC ID |
| `subnets` | list(string) | `[]` | Subnet IDs (minimum 2) |
| `security_group_ids` | list(string) | `[]` | Security group IDs |
| `enable_https` | bool | `true` | Create HTTPS listener |
| `certificate_arn` | string | - | ACM certificate ARN for HTTPS |
| `enable_deletion_protection` | bool | `false` | Prevent accidental deletion |
| `enable_access_logs` | bool | `false` | Log requests to S3 |
| `access_logs_s3_bucket` | string | - | S3 bucket for logs |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `alb_id` | ALB ID |
| `alb_arn` | ALB ARN |
| `alb_dns_name` | ALB DNS name (CNAME to Route53) |
| `alb_zone_id` | ALB zone ID (for Route53 alias) |
| `target_group_arns` | ARNs of target groups |

## Usage Example

```hcl
module "alb" {
  source = "../../modules/alb"

  create              = true
  environment         = "prod"
  name                = "my-app-alb"
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.public_subnet_ids
  security_group_ids  = [module.security_groups.alb_sg_id]
  enable_https        = true
  certificate_arn     = "arn:aws:acm:us-east-1:ACCOUNT:certificate/UUID"
  enable_access_logs  = true
  access_logs_s3_bucket = aws_s3_bucket.alb_logs.id

  tags = {
    Environment = "prod"
  }
}

# Create target group
resource "aws_lb_target_group" "app" {
  name        = "my-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200-299"
  }
}

# Register targets
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = module.ec2.instance_ids[0]
  port             = 80
}
```

## Key Features

✅ **Layer 7 Routing:** Route by path, hostname, HTTP method  
✅ **HTTPS Support:** ACM certificate integration  
✅ **Access Logs:** Track all requests  
✅ **Health Checks:** Automatic instance removal on failure  
✅ **Multi-AZ:** High availability across availability zones  

## Phase

**Phase 2** — Load Balancing
