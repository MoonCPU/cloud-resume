output "hosted_zone_id" {
  value = module.zones.route53_zone_zone_id[var.domain_name]
}