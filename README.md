Repository root: run Terraform from the `terraform-aws-infra` folder.

Key notes:
- Do NOT run `terraform apply` until you deploy the backend (see backend/).
- Use the environment folders: `terraform-aws-infra/environments/dev` etc.

Common safe workflows (no apply):

1) Validate modules locally without remote backend:

```bash
cd terraform-aws-infra/environments/dev
# Initialize without configuring remote backend (safe local init)
terraform init -backend=false
terraform validate
terraform plan -out=tfplan
```

2) Initialize with remote backend AFTER you deploy `backend/` module and copy outputs:

```bash
# After running terraform in terraform-aws-infra/backend and copying values
cd terraform-aws-infra/environments/dev
terraform init
terraform validate
terraform plan -out=tfplan
# DO NOT terraform apply unless you understand costs and have approved actions
```

3) Workspace commands (examples):

```bash
terraform workspace new dev
terraform workspace select dev
terraform workspace list
```

Why you saw "No configuration files":
- You ran `terraform plan` in `/home/ubuntu/AWS-terraform` which had no `.tf` files previously.
- I added a minimal placeholder `main.tf` at repo root to avoid that specific error.

Next steps:
- Run the safe workflow above in `terraform-aws-infra/environments/dev` to validate Phase 1 modules.
- If you want, I can run `terraform validate` in `environments/dev` now (no apply). Say so and I'll run it.
