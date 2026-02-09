terraform {
  required_version = ">= 1.10"

  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = "~> 1.3"
    }
  }
}

provider "outscale" {}

module "networking" {
  source = "git::https://github.com/tf-outscale-modules/terraform-outscale-networking.git?ref=v1.0.0"

  name     = "oks-network"
  ip_range = "10.0.0.0/16"

  subnets = {
    private_a = {
      ip_range       = "10.0.1.0/24"
      subregion_name = "eu-west-2a"
    }
    private_b = {
      ip_range       = "10.0.2.0/24"
      subregion_name = "eu-west-2b"
    }
  }

  tags = {
    Project     = "complete-example"
    Environment = "staging"
  }
}

module "oks" {
  source = "../../"

  # Project
  project_name        = "complete-example"
  project_cidr        = "10.0.0.0/16"
  region              = "eu-west-2"
  project_description = "Production-grade OKS deployment with full features"

  enable_project_api_termination_protection = true

  # Cluster
  cluster_name       = "complete-cluster"
  kubernetes_version = "1.31"
  cidr_pods          = "10.91.0.0/16"
  cidr_service       = "10.92.0.0/16"
  admin_whitelist    = ["203.0.113.0/24", "198.51.100.10/32"]

  control_planes      = "cp.3.masters.medium"
  enable_cp_multi_az  = true
  enable_admin_lbu    = true
  cluster_description = "Multi-AZ production cluster"

  enable_cluster_api_termination_protection = true

  # Kubeconfig
  enable_kubeconfig = true
  kubeconfig_ttl    = "24h"

  # Quotas
  enable_quotas = true

  # Tags
  tags = {
    Project     = "complete-example"
    Environment = "staging"
  }

  project_tags = {
    CostCenter = "infrastructure"
  }

  cluster_tags = {
    Team = "platform"
  }
}
