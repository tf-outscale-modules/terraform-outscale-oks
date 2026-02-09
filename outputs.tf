# ─── Project Outputs ─────────────────────────────────────────────────

output "project_ids" {
  description = "Map of project keys to their IDs"
  value       = { for k, v in outscale_oks_project.this : k => v.id }
}

output "project_names" {
  description = "Map of project keys to their names"
  value       = { for k, v in outscale_oks_project.this : k => v.name }
}

output "project_statuses" {
  description = "Map of project keys to their current statuses"
  value       = { for k, v in outscale_oks_project.this : k => try(v.status, null) }
}

output "project_created_at" {
  description = "Map of project keys to their creation timestamps"
  value       = { for k, v in outscale_oks_project.this : k => try(v.created_at, null) }
}

output "project_updated_at" {
  description = "Map of project keys to their last update timestamps"
  value       = { for k, v in outscale_oks_project.this : k => try(v.updated_at, null) }
}

# ─── Cluster Outputs ─────────────────────────────────────────────────

output "cluster_ids" {
  description = "Map of cluster keys to their IDs"
  value       = { for k, v in outscale_oks_cluster.this : k => v.id }
}

output "cluster_names" {
  description = "Map of cluster keys to their names"
  value       = { for k, v in outscale_oks_cluster.this : k => v.name }
}

output "cluster_versions" {
  description = "Map of cluster keys to their Kubernetes versions"
  value       = { for k, v in outscale_oks_cluster.this : k => v.version }
}

output "cluster_statuses" {
  description = "Map of cluster keys to their current statuses"
  value       = { for k, v in outscale_oks_cluster.this : k => v.statuses }
}

output "cluster_dns" {
  description = "Map of cluster keys to their DNS endpoints"
  value       = { for k, v in outscale_oks_cluster.this : k => try(v.cluster_dns, null) }
}

output "cluster_cni" {
  description = "Map of cluster keys to their CNI plugins"
  value       = { for k, v in outscale_oks_cluster.this : k => try(v.cni, null) }
}

# ─── Kubeconfig Outputs ─────────────────────────────────────────────

output "kubeconfigs" {
  description = "Map of cluster keys to their kubeconfig contents (only for clusters with enable_kubeconfig = true)"
  value       = { for k, v in data.outscale_oks_kubeconfig.this : k => v.kubeconfig }
  sensitive   = true
}

# ─── Node Pool Outputs ──────────────────────────────────────────────

output "nodepool_manifests" {
  description = "Map of node pool keys to their generated YAML manifests"
  value       = local.nodepool_manifests
}

output "nodepool_names" {
  description = "Map of node pool keys to their names"
  value       = { for k, v in var.node_pools : k => v.name }
}

# ─── Quotas Outputs ──────────────────────────────────────────────────

output "quotas" {
  description = "OKS account quotas (null when enable_quotas is false)"
  value       = try(data.outscale_oks_quotas.this[0], null)
}
