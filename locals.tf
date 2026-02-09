locals {
  common_tags = merge(
    var.tags,
    { ManagedBy = "terraform" },
  )

  project_tags = merge(
    var.project_tags,
    local.common_tags,
    { Name = var.project_name },
  )

  cluster_tags = merge(
    var.cluster_tags,
    local.common_tags,
    { Name = var.cluster_name },
  )
}
