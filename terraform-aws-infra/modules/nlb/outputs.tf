output "nlb_arn" { value = try(aws_lb.nlb[0].arn, "") }
output "nlb_dns_name" { value = try(aws_lb.nlb[0].dns_name, "") }
