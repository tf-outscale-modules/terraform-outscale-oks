resource "outscale_oks_cluster" "this" {
  name       = var.cluster_name
  project_id = outscale_oks_project.this.id
  version    = var.kubernetes_version

  cidr_pods       = var.cidr_pods
  cidr_service    = var.cidr_service
  admin_whitelist = var.admin_whitelist

  control_planes          = var.control_planes
  cp_multi_az             = var.enable_cp_multi_az
  admin_lbu               = var.enable_admin_lbu
  description             = var.cluster_description
  disable_api_termination = var.enable_cluster_api_termination_protection

  tags = local.cluster_tags
}
