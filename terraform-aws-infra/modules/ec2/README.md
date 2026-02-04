# EC2 Module

**Purpose:** Creates EC2 instances with launch templates, auto-healing, and proper IAM integration.

## What It Creates

- **Launch Template:** Specifies AMI, instance type, security groups, user data
- **EC2 Instances:** One or more instances (can be managed via ASG)
- **Elastic IPs:** Optional static IPs for instances
- **Detailed Monitoring:** CloudWatch enhanced metrics
- **EBS Volumes:** Root and additional volumes with encryption

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable EC2 creation |
| `environment` | string | - | Environment name (dev/stage/prod) |
| `instance_type` | string | `t3.micro` | EC2 instance type |
| `ami_id` | string | - | AMI ID (Amazon Linux 2, Ubuntu, etc.) |
| `subnet_id` | string | - | Subnet ID for instance |
| `security_group_ids` | list(string) | `[]` | Security group IDs |
| `iam_instance_profile` | string | - | IAM instance profile name |
| `key_name` | string | - | EC2 Key Pair name (optional, use SSM) |
| `user_data` | string | `` | Bootstrap script (base64 encoded) |
| `associate_public_ip` | bool | `false` | Assign public IP |
| `root_volume_size` | number | `30` | Root volume size (GB) |
| `root_volume_type` | string | `gp3` | Root volume type |
| `enable_monitoring` | bool | `true` | Enable CloudWatch detailed monitoring |
| `enable_ebs_optimization` | bool | `false` | Enable EBS optimization |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `launch_template_id` | Launch template ID |
| `launch_template_latest_version` | Latest version of launch template |
| `instance_ids` | List of EC2 instance IDs |
| `private_ips` | List of private IPs |
| `public_ips` | List of public IPs (if assigned) |

## Usage Example

```hcl
# Get AMI ID for latest Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

module "ec2" {
  source = "../../modules/ec2"

  create                = true
  environment           = "prod"
  instance_type         = "t3.medium"
  ami_id                = data.aws_ami.amazon_linux_2.id
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_ids    = [module.security_groups.app_sg_id]
  iam_instance_profile  = "app-instance-profile"
  associate_public_ip   = true
  root_volume_size      = 50
  enable_monitoring     = true
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y aws-cli
    # Install your application
    EOF
  )

  tags = {
    Environment = "prod"
    Project     = "my-app"
  }
}

# Use in Auto Scaling Group
module "asg" {
  launch_template_id      = module.ec2.launch_template_id
  launch_template_version = module.ec2.launch_template_latest_version
}
```

## Best Practices

✅ **Use Launch Templates:** More flexible than launch configurations  
✅ **SSM Session Manager:** Avoid SSH key pairs, use IAM + SSM  
✅ **Monitoring:** Enable detailed CloudWatch metrics  
✅ **EBS Optimization:** Recommended for production workloads  
✅ **Encryption:** Enable EBS encryption for security  

## Phase

**Phase 2** — Compute
