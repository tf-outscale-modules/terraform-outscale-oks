locals {
  common_tags = merge(
    { ManagedBy = "terraform" },
    var.tags,
  )

  project_tags = merge(
    local.common_tags,
    { Name = var.project_name },
    var.project_tags,
  )

  cluster_tags = merge(
    local.common_tags,
    { Name = var.cluster_name },
    var.cluster_tags,
  )
}
