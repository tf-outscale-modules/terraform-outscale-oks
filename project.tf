resource "outscale_oks_project" "this" {
  name   = var.project_name
  cidr   = var.project_cidr
  region = var.region

  description             = var.project_description
  disable_api_termination = var.enable_project_api_termination_protection

  tags = local.project_tags
}
