resource "outscale_oks_project" "this" {
  for_each = var.projects

  name   = each.value.name
  cidr   = each.value.cidr
  region = each.value.region

  description             = each.value.description
  disable_api_termination = each.value.enable_api_termination_protection

  tags = local.project_tags[each.key]
}
