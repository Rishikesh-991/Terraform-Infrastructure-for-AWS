# Security Policy

## Reporting Security Vulnerabilities

**Please do NOT open a public issue for security vulnerabilities.**

To report a security vulnerability, email security@example.com with:

* Description of the vulnerability
* Steps to reproduce
* Potential impact
* Suggested fix (if any)

We appreciate responsible disclosure and will:

* Acknowledge receipt within 48 hours
* Provide updates every 5 days
* Release a fix in a timely manner
* Credit the reporter (if desired)

## Security Best Practices for This Project

### State Management
- Store Terraform state in remote backend (S3 + DynamoDB) with encryption
- Enable versioning on S3 bucket
- Use IAM policies to restrict access

### Secrets
- Never commit secrets to Git
- Use AWS Secrets Manager for sensitive data
- Use SSM Parameter Store for non-sensitive config

### IAM
- Always use least-privilege policies
- Enable MFA for AWS root account
- Regular IAM access reviews

### Networking
- Use security groups to restrict traffic
- Enable VPC Flow Logs
- Use NACLs for additional network isolation

### Monitoring
- Enable CloudTrail for audit logs
- Configure CloudWatch alarms
- Use GuardDuty for threat detection

## Dependencies

Keep Terraform and AWS provider updated:
```bash
terraform init -upgrade
```

Monitor dependency vulnerabilities regularly.
