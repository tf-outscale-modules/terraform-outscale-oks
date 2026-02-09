output "project_id" {
  description = "ID of the OKS project"
  value       = module.oks.project_ids["main"]
}

output "cluster_id" {
  description = "ID of the OKS cluster"
  value       = module.oks.cluster_ids["main"]
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = module.oks.cluster_versions["main"]
}

output "kubeconfig" {
  description = "Kubeconfig for the OKS cluster"
  value       = try(module.oks.kubeconfigs["main"], null)
  sensitive   = true
}

output "quotas" {
  description = "OKS account quotas"
  value       = module.oks.quotas
}

output "net_id" {
  description = "ID of the networking module VPC"
  value       = module.networking.net_id
}
