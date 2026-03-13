output "project_id" {
  description = "ID of the OKS project"
  value       = module.oks.project_ids["main"]
}

output "cluster_id" {
  description = "ID of the OKS cluster"
  value       = module.oks.cluster_ids["main"]
}

output "kubeconfig" {
  description = "Kubeconfig for the OKS cluster"
  value       = try(module.oks.kubeconfigs["main"], null)
  sensitive   = true
}
