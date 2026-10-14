# Node pools are OKS NodePool CRDs applied natively by the provider (>= 1.7),
# no oks-cli/kubectl needed on the machine running Terraform.
resource "outscale_oks_manifest" "nodepool" {
  for_each = var.node_pools

  cluster_id = outscale_oks_cluster.this[each.value.cluster_key].id
  manifest   = local.nodepool_manifests[each.key]

  lifecycle {
    precondition {
      condition     = contains(keys(var.clusters), each.value.cluster_key)
      error_message = "Node pool '${each.key}' references cluster_key '${each.value.cluster_key}' which does not exist in var.clusters."
    }
  }
}
