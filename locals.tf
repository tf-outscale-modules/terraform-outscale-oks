locals {
  common_tags = merge(
    var.tags,
    { ManagedBy = "terraform" },
  )

  project_tags = {
    for k, v in var.projects : k => merge(v.tags, local.common_tags, { Name = v.name })
  }

  cluster_tags = {
    for k, v in var.clusters : k => merge(v.tags, local.common_tags, { Name = v.name })
  }

  kubeconfig_clusters = {
    for k, v in var.clusters : k => v if v.enable_kubeconfig
  }
}
