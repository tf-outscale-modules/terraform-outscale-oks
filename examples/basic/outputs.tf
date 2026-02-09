output "project_id" {
  description = "ID of the OKS project"
  value       = module.oks.project_id
}

output "cluster_id" {
  description = "ID of the OKS cluster"
  value       = module.oks.cluster_id
}

output "kubeconfig" {
  description = "Kubeconfig for the OKS cluster"
  value       = module.oks.kubeconfig
  sensitive   = true
}
