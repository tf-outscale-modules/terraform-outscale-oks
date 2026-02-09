data "outscale_oks_kubeconfig" "this" {
  count = var.enable_kubeconfig ? 1 : 0

  cluster_id = outscale_oks_cluster.this.id

  user           = var.kubeconfig_user
  group          = var.kubeconfig_group
  ttl            = var.kubeconfig_ttl
  x_encrypt_nacl = var.kubeconfig_x_encrypt_nacl
}

data "outscale_oks_quotas" "this" {
  count = var.enable_quotas ? 1 : 0
}
