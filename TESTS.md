Tests
- Local validation: `./scripts/local/validate_all.sh`
- CI: `.github/workflows/ci-checks.yml` runs fmt + validate on push/PR.
- Integration: create backend (S3/DynamoDB) and run `terraform init` normally, then `terraform plan` in the target environment.

No Terraform apply is performed by these checks.
