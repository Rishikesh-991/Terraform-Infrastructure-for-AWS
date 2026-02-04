# Example environment variables for deployment
aws_region     = "us-east-1"
environment    = "dev"
project_name   = "my-app"
vpc_cidr_block = "10.0.0.0/16"

common_tags = {
  Environment = "dev"
  Project     = "my-app"
  Owner       = "your-email@example.com"
  CostCenter  = "engineering"
  CreatedAt   = "2026-02-04"
}

# Additional example configurations per module can be added here
