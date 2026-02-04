# ECS Module (Elastic Container Service)

**Purpose:** Creates ECS clusters for running containerized applications on EC2 or Fargate.

## What It Creates

- **ECS Cluster:** Container orchestration platform
- **Capacity Providers:** EC2 or Fargate
- **Cluster Settings:** CloudWatch Container Insights
- **Service Mesh:** Optional AWS App Mesh integration

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create` | bool | `false` | Enable/disable ECS cluster |
| `cluster_name` | string | - | ECS cluster name |
| `capacity_providers` | list(string) | `["FARGATE"]` | FARGATE, EC2, or FARGATE_SPOT |
| `enable_container_insights` | bool | `true` | Enable CloudWatch monitoring |
| `tags` | map(string) | `{}` | Tags for all resources |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | ECS cluster ID |
| `cluster_arn` | ECS cluster ARN |
| `cluster_name` | ECS cluster name |

## Usage Example

```hcl
module "ecs" {
  source = "../../modules/ecs"

  create                      = true
  cluster_name                = "my-app-cluster"
  capacity_providers          = ["FARGATE", "FARGATE_SPOT"]
  enable_container_insights   = true

  tags = {
    Environment = "prod"
  }
}

# Create ECS service (in separate resource)
resource "aws_ecs_service" "app" {
  name            = "my-app-service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnet_ids
    security_groups = [module.security_groups.app_sg_id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_app.arn
    container_name   = "app"
    container_port   = 8080
  }
}
```

## Phase

**Phase 3** — Containers
