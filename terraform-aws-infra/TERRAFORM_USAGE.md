Terraform Usage
- Validate:
  cd terraform-aws-infra/environments/dev
  terraform init -backend=false
  terraform validate
  terraform plan -out=tfplan
- To enable resources, set module `create = true` in the environment vars and provide necessary ARNs/IDs.
