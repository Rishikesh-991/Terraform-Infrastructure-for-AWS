# Security Groups Module

What it does
- Creates three security groups: `bastion`, `app`, `db` with secure defaults.

Why it's needed
- Centralizes network access rules for environments and enforces least privilege.

How to integrate
- Provide `vpc_id` and tag map. Consume outputs `bastion_sg_id`, `app_sg_id`, `db_sg_id` in other modules.

How to deploy
- Called from environment module, do not create resources directly at root.

Production use cases
- Restrict SSH to management CIDRs for bastion
- Restrict DB access to application SG only

Variables
- `management_cidrs`: list of allowed SSH CIDRs
- `alb_allowed_cidrs`: list of CIDRs allowed to talk to app (usually ALB CIDR or 0.0.0.0/0)
