resource "aws_route53_record" "route53-records-local" {
  count   = local.admin_chart.use_local_zone && length(local.admin_chart.route53_alias_records_to_add) > 0 ? length(local.admin_chart.route53_alias_records_to_add) : 0
  name    = local.admin_chart.route53_alias_records_to_add[count.index]
  type    = "A"
  zone_id = local.hosted_zone_id
}