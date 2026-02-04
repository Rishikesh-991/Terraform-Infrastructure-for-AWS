# ASG Module (Auto Scaling Group)

**Purpose:** Creates Auto Scaling Groups to automatically scale EC2 instances based on demand.

## What It Creates

- **Auto Scaling Group:** Manages EC2 instance count
- **Scaling Policies:** Target tracking or step scaling
- **Lifecycle Hooks:** For custom actions during scaling
- **CloudWatch Metrics:** Monitoring ASG health
- **Termination Policies:** Graceful instance termination

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable ASG creation |
| `name` | string | - | ASG name |
| `launch_template_id` | string | - | Launch template ID |
| `launch_template_version` | string | `$Latest` | Launch template version |
| `min_size` | number | `1` | Minimum instances |
| `max_size` | number | `3` | Maximum instances |
| `desired_capacity` | number | `2` | Desired instance count |
| `health_check_type` | string | `ELB` | ELB or EC2 |
| `health_check_grace_period` | number | `300` | Warmup period (seconds) |
| `vpc_zone_identifier` | list(string) | `[]` | Subnet IDs |
| `target_group_arns` | list(string) | `[]` | ALB/NLB target group ARNs |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `asg_name` | ASG name |
| `asg_arn` | ASG ARN |
| `asg_desired_capacity` | Desired instance count |

## Usage Example

```hcl
module "asg" {
  source = "../../modules/asg"

  create                    = true
  name                      = "my-app-asg"
  launch_template_id        = module.ec2.launch_template_id
  launch_template_version   = module.ec2.launch_template_latest_version
  min_size                  = 2
  max_size                  = 10
  desired_capacity          = 3
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = module.vpc.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]

  tags = {
    Environment = "prod"
  }
}

# Add scaling policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  autoscaling_group_name = module.asg.asg_name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
}
```

## Phase

**Phase 2** — Auto Scaling
