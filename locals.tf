locals {
  project_tags = {
    for k, v in var.projects : k => merge(var.tags, v.tags, { ManagedBy = "terraform", Name = v.name })
  }

  cluster_tags = {
    for k, v in var.clusters : k => merge(var.tags, v.tags, { ManagedBy = "terraform", Name = v.name })
  }

  kubeconfig_clusters = {
    for k, v in var.clusters : k => v if v.enable_kubeconfig
  }

  # ─── Node Pool Manifests ──────────────────────────────────────────
  nodepool_manifests = {
    for k, v in var.node_pools : k => yamlencode(merge(
      {
        apiVersion = "oks.dev/v1beta2"
        kind       = "NodePool"
        metadata = {
          name = v.name
        }
        spec = merge(
          {
            nodeType     = v.node_type
            desiredNodes = v.desired_nodes
            zones        = v.zones
          },
          v.enable_autoscaling ? {
            autoscaling = {
              minNodes = v.min_nodes
              maxNodes = v.max_nodes
            }
          } : {},
          v.enable_auto_healing ? {
            autoHealing = true
          } : {},
          length(v.volumes) > 0 ? {
            volumes = [
              for vol in v.volumes : merge(
                {
                  device = vol.device
                  type   = vol.type
                  size   = vol.size
                },
                vol.iops != null ? { iops = vol.iops } : {},
                vol.dir != null ? { dir = vol.dir } : {},
              )
            ]
          } : {},
          v.extra_spec,
        )
      },
    ))
  }
}
