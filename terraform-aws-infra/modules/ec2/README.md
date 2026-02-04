# EC2 Module (Launch Template Wiring)

What it does
- Optional creation of a Launch Template using provided IAM instance profile and security groups.

Why it’s needed
- Separates instance configuration from infrastructure wiring; instance creation is disabled by default.

How to integrate
- Pass `instance_profile_name` from the `iam` module and `security_group_ids` from the `security-groups` module.

Example usage (no create):

```hcl
module "ec2" {
  source = "../../modules/ec2"
  environment = var.environment
  create_instance = false
  instance_profile_name = module.iam.ec2_instance_profile_name
  security_group_ids = [module.security_groups.app_sg_id]
}
```

Important: `create_instance` is false by default to avoid accidental resource creation in Phase 1.
