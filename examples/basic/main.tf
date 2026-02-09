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

module "oks" {
  source = "../../"

  # Project
  project_name = "basic-example"
  project_cidr = "10.0.0.0/16"
  region       = "eu-west-2"

  # Cluster
  cluster_name       = "basic-cluster"
  kubernetes_version = "1.31"
  cidr_pods          = "10.91.0.0/16"
  cidr_service       = "10.92.0.0/16"
  admin_whitelist    = ["203.0.113.0/24"]

  tags = {
    Project     = "basic-example"
    Environment = "dev"
  }
}
