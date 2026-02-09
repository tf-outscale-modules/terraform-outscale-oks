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

  projects = {
    main = {
      name                              = "complete-example"
      cidr                              = "10.0.0.0/16"
      region                            = "eu-west-2"
      description                       = "Production OKS with full features"
      enable_api_termination_protection = true
      tags = {
        CostCenter = "infrastructure"
      }
    }
  }

  clusters = {
    main = {
      name                              = "complete-cluster"
      project_key                       = "main"
      kubernetes_version                = "1.31"
      cidr_pods                         = "10.91.0.0/16"
      cidr_service                      = "10.92.0.0/16"
      admin_whitelist                   = ["203.0.113.0/24", "198.51.100.10/32"]
      control_planes                    = "cp.3.masters.medium"
      description                       = "Multi-AZ production cluster"
      enable_cp_multi_az                = true
      enable_admin_lbu                  = true
      enable_api_termination_protection = true
      kubeconfig_ttl                    = "24h"
      tags = {
        Team = "platform"
      }
    }
  }

  enable_quotas = true

  tags = {
    Project     = "complete-example"
    Environment = "staging"
  }
}
