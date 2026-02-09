resource "outscale_oks_cluster" "this" {
  for_each = var.clusters

  name       = each.value.name
  project_id = outscale_oks_project.this[each.value.project_key].id
  version    = each.value.kubernetes_version

  cidr_pods       = each.value.cidr_pods
  cidr_service    = each.value.cidr_service
  admin_whitelist = each.value.admin_whitelist

  control_planes          = each.value.control_planes
  cp_multi_az             = each.value.enable_cp_multi_az
  admin_lbu               = each.value.enable_admin_lbu
  description             = each.value.description
  disable_api_termination = each.value.enable_api_termination_protection

  tags = local.cluster_tags[each.key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.projects), each.value.project_key)
      error_message = "Cluster '${each.key}' references project_key '${each.value.project_key}' which does not exist in var.projects."
    }
  }
}
