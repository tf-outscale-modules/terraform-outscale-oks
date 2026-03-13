data "outscale_oks_kubeconfig" "this" {
  for_each = local.kubeconfig_clusters

  cluster_id = outscale_oks_cluster.this[each.key].id

  user           = each.value.kubeconfig_user
  group          = each.value.kubeconfig_group
  ttl            = each.value.kubeconfig_ttl
  x_encrypt_nacl = each.value.kubeconfig_x_encrypt_nacl
}

data "outscale_oks_quotas" "this" {
  count = var.enable_quotas ? 1 : 0
}
