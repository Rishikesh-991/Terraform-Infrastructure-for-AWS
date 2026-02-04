# Route Tables Module

What it does
- Creates public and private route tables and associates them with provided subnets.

Why it’s needed
- Provides refined, auditable routing configuration separate from VPC creation.

How to integrate
- Pass `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `internet_gateway_id`, and `nat_gateway_ids`.

How to deploy
- Call from an environment root module. By default it creates one public RT and private RTs per private subnet.

Notes
- The `vpc` module already created route tables; use this module if you want to replace or extend routing logic.
