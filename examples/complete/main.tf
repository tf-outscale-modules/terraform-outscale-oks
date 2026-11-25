terraform {
  required_version = ">= 1.10"

  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = "~> 1.9"
    }
  }
}

provider "outscale" {
  oks {
    # access_key_id   = ""
    # secret_key_id   = ""
    endpoint = "https://api.eu-west-2.oks.outscale.com/api/v2"
    region   = "eu-west-2"
  }
}

# module "networking" {
#   source = "git::https://github.com/tf-outscale-modules/terraform-outscale-networking.git?ref=v1.0.0"

#   name     = "oks-network"
#   ip_range = "10.0.0.0/16"

#   subnets = {
#     private_a = {
#       ip_range       = "10.0.1.0/24"
#       subregion_name = "eu-west-2a"
#     }
#     private_b = {
#       ip_range       = "10.0.2.0/24"
#       subregion_name = "eu-west-2b"
#     }
#   }

#   tags = {
#     Project     = "oks-complete-example"
#     Environment = "staging"
#   }
# }

module "oks" {
  source = "../../"

  projects = {
    main = {
      name                              = "oks-complete-example"
      cidr                              = "10.0.0.0/16"
      region                            = "eu-west-2"
      description                       = "Production OKS with full features"
      enable_api_termination_protection = false
      tags = {
        CostCenter = "infrastructure"
        # Per-resource tags win over the module-level `tags` below
        Environment = "production"
      }
    }
  }

  clusters = {
    main = {
      name                              = "oks-complete-cluster"
      project_key                       = "main"
      kubernetes_version                = "1.31"
      cidr_pods                         = "10.91.0.0/16"
      cidr_service                      = "10.92.0.0/16"
      admin_whitelist                   = ["203.1.113.1", "204.51.100.10"]
      control_planes                    = "cp.3.masters.medium"
      description                       = "Multi-AZ production cluster"
      enable_cp_multi_az                = true
      enable_admin_lbu                  = true
      enable_api_termination_protection = false
      kubeconfig_ttl                    = "24h"

      # Opt-in options; cp_subregions and cluster_dns force replacement of the cluster when changed
      auto_maintenances = {
        patch_upgrade_maintenance = { week_day = "Sun", start_hour = 3, duration_hours = 2, tz = "Europe/Paris" }
      }
      cp_subregions   = ["eu-west-2a", "eu-west-2b"]
      cluster_dns     = "10.92.0.10"
      admission_flags = { enable_admission_plugins = ["NodeRestriction"] }
      tags = {
        Team = "platform"
      }
    }
  }

  node_pools = {
    workers = {
      name                = "worker-pool"
      cluster_key         = "main"
      node_type           = "tinav6.c2r4p3"
      desired_nodes       = 2
      zones               = ["eu-west-2a", "eu-west-2b"]
      enable_autoscaling  = true
      min_nodes           = 2
      max_nodes           = 5
      enable_auto_healing = true

      wait_for = {
        fields  = { "status.progress.ready" = "2" }
        timeout = "20m"
      }
      enable_wait_on_delete = true
      field_manager         = { name = "platform-team" }
      # skip_delete = true would leave the NodePool running in the cluster when removed from Terraform
    }
  }

  enable_quotas = false

  tags = {
    Project     = "oks-complete-example"
    Environment = "staging"
  }
}
