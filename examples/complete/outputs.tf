output "project_id" {
  description = "ID of the OKS project"
  value       = module.oks.project_id
}

output "cluster_id" {
  description = "ID of the OKS cluster"
  value       = module.oks.cluster_id
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = module.oks.cluster_version
}

output "kubeconfig" {
  description = "Kubeconfig for the OKS cluster"
  value       = module.oks.kubeconfig
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
