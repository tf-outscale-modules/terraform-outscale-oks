# ─── Project Outputs ─────────────────────────────────────────────────

output "project_id" {
  description = "ID of the OKS project"
  value       = outscale_oks_project.this.id
}

output "project_name" {
  description = "Name of the OKS project"
  value       = outscale_oks_project.this.name
}

output "project_status" {
  description = "Current status of the OKS project"
  value       = try(outscale_oks_project.this.status, null)
}

# ─── Cluster Outputs ─────────────────────────────────────────────────

output "cluster_id" {
  description = "ID of the OKS cluster"
  value       = outscale_oks_cluster.this.id
}

output "cluster_name" {
  description = "Name of the OKS cluster"
  value       = outscale_oks_cluster.this.name
}

output "cluster_version" {
  description = "Kubernetes version deployed on the cluster"
  value       = outscale_oks_cluster.this.version
}

output "cluster_statuses" {
  description = "Current statuses of the OKS cluster"
  value       = outscale_oks_cluster.this.statuses
}

# ─── Kubeconfig Outputs ─────────────────────────────────────────────

output "kubeconfig" {
  description = "Kubeconfig file content for accessing the OKS cluster. Contains sensitive credentials"
  value       = try(data.outscale_oks_kubeconfig.this[0].kubeconfig, null)
  sensitive   = true
}

# ─── Quotas Outputs ──────────────────────────────────────────────────

output "quotas" {
  description = "OKS account quotas (null when enable_quotas is false)"
  value       = try(data.outscale_oks_quotas.this[0], null)
}
