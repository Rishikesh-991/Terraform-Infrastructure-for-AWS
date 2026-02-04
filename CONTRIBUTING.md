Contributing
- Run `pre-commit install` to enable local hooks.
- Run `./scripts/local/validate_all.sh` to validate all environment configs locally (no remote backend required).
- Use `terraform init -backend=false` before `terraform validate` for local checks.
