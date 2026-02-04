output "alb_arn" { value = try(aws_lb.alb[0].arn, "") }
output "alb_dns_name" { value = try(aws_lb.alb[0].dns_name, "") }
