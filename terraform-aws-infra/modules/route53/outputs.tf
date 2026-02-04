output "zone_id" { value = try(aws_route53_zone.zone[0].zone_id, "") }
output "zone_name" { value = try(aws_route53_zone.zone[0].name, "") }
