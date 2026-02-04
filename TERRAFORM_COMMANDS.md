# Safe Terraform commands (no apply)

# 1) Validate dev environment without remote backend
cd terraform-aws-infra/environments/dev
terraform init -backend=false
terraform validate
terraform plan -out=tfplan

# 2) If backend has been created (backend module applied) - initialize normally
cd terraform-aws-infra/environments/dev
terraform init
terraform validate
terraform plan -out=tfplan

# 3) Example: create/select workspace
terraform workspace new dev
terraform workspace select dev

# 4) To destroy local state only (careful)
terraform plan -destroy -out=tfplan-destroy
# review then do NOT run apply unless intended

