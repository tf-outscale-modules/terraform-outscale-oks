# Node pools are OKS NodePool CRDs applied natively by the provider (>= 1.7),
# no oks-cli/kubectl needed on the machine running Terraform.
resource "outscale_oks_manifest" "nodepool" {
  for_each = var.node_pools

  cluster_id = outscale_oks_cluster.this[each.value.cluster_key].id
  manifest   = local.nodepool_manifests[each.key]
}
