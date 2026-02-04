Runbooks
- Create backend once: follow terraform-aws-infra/backend/README.md
- Use `terraform init -backend=false` and `terraform validate` to validate locally
- Backups: store state in S3, enable DynamoDB locking
