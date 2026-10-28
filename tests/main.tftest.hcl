mock_provider "outscale" {}

# ─── Common Test Variables ────────────────────────────────────────────

variables {
  projects = {
    proj = {
      name   = "test-project"
      cidr   = "10.0.0.0/16"
      region = "eu-west-2"
    }
  }
  clusters = {
    cluster = {
      name               = "test-cluster"
      project_key        = "proj"
      kubernetes_version = "1.31"
      cidr_pods          = "10.91.0.0/16"
      cidr_service       = "10.92.0.0/16"
      admin_whitelist    = ["10.0.0.0/8"]
    }
  }
}

# ─── Project Resource Tests ──────────────────────────────────────────

run "project_created_with_required_vars" {
  command = plan

  assert {
    condition     = outscale_oks_project.this["proj"].name == "test-project"
    error_message = "Project name should be 'test-project'"
  }

  assert {
    condition     = outscale_oks_project.this["proj"].cidr == "10.0.0.0/16"
    error_message = "Project CIDR should be '10.0.0.0/16'"
  }

  assert {
    condition     = outscale_oks_project.this["proj"].region == "eu-west-2"
    error_message = "Project region should be 'eu-west-2'"
  }
}

run "project_description_applied" {
  command = plan

  variables {
    projects = {
      proj = {
        name        = "test-project"
        cidr        = "10.0.0.0/16"
        region      = "eu-west-2"
        description = "Test project description"
      }
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].description == "Test project description"
    error_message = "Project description should be set"
  }
}

run "project_description_default_null" {
  command = plan

  assert {
    condition     = try(var.projects["proj"].description, null) == null
    error_message = "Project description should default to null"
  }
}

run "project_api_termination_protection_enabled" {
  command = plan

  variables {
    projects = {
      proj = {
        name                              = "test-project"
        cidr                              = "10.0.0.0/16"
        region                            = "eu-west-2"
        enable_api_termination_protection = true
      }
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].disable_api_termination == true
    error_message = "Project API termination protection should be enabled"
  }
}

run "project_api_termination_protection_default_disabled" {
  command = plan

  assert {
    condition     = outscale_oks_project.this["proj"].disable_api_termination == false
    error_message = "Project API termination protection should be disabled by default"
  }
}

# ─── Multiple Projects Test ──────────────────────────────────────────

run "multiple_projects_created" {
  command = plan

  variables {
    projects = {
      alpha = {
        name   = "project-alpha"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
      beta = {
        name   = "project-beta"
        cidr   = "10.1.0.0/16"
        region = "eu-west-2"
      }
    }
    clusters = {}
  }

  assert {
    condition     = outscale_oks_project.this["alpha"].name == "project-alpha"
    error_message = "Project alpha should be created"
  }

  assert {
    condition     = outscale_oks_project.this["beta"].name == "project-beta"
    error_message = "Project beta should be created"
  }
}

# ─── Cluster Resource Tests ──────────────────────────────────────────

run "cluster_created_with_required_vars" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this["cluster"].name == "test-cluster"
    error_message = "Cluster name should be 'test-cluster'"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].version == "1.31"
    error_message = "Cluster version should be '1.31'"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].cidr_pods == "10.91.0.0/16"
    error_message = "Cluster pod CIDR should be '10.91.0.0/16'"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].cidr_service == "10.92.0.0/16"
    error_message = "Cluster service CIDR should be '10.92.0.0/16'"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].admin_whitelist == toset(["10.0.0.0/8"])
    error_message = "Cluster admin whitelist should contain '10.0.0.0/8'"
  }
}

run "cluster_references_project_key" {
  command = plan

  assert {
    condition     = var.clusters["cluster"].project_key == "proj"
    error_message = "Cluster should reference the 'proj' project key"
  }

  assert {
    condition     = contains(keys(var.projects), var.clusters["cluster"].project_key)
    error_message = "Cluster project_key should exist in projects map"
  }
}

run "cluster_default_control_planes" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this["cluster"].control_planes == "cp.3.masters.small"
    error_message = "Default control planes should be 'cp.3.masters.small'"
  }
}

run "cluster_custom_control_planes" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        control_planes     = "cp.3.masters.medium"
      }
    }
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].control_planes == "cp.3.masters.medium"
    error_message = "Custom control planes should be applied"
  }
}

run "cluster_multi_az_enabled" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        enable_cp_multi_az = true
      }
    }
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].cp_multi_az == true
    error_message = "Multi-AZ should be enabled"
  }
}

run "cluster_multi_az_default_disabled" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this["cluster"].cp_multi_az == false
    error_message = "Multi-AZ should be disabled by default"
  }
}

run "cluster_admin_lbu_enabled" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        enable_admin_lbu   = true
      }
    }
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].admin_lbu == true
    error_message = "Admin LBU should be enabled"
  }
}

run "cluster_admin_lbu_default_disabled" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this["cluster"].admin_lbu == false
    error_message = "Admin LBU should be disabled by default"
  }
}

run "cluster_api_termination_protection_enabled" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name                              = "test-cluster"
        project_key                       = "proj"
        kubernetes_version                = "1.31"
        cidr_pods                         = "10.91.0.0/16"
        cidr_service                      = "10.92.0.0/16"
        admin_whitelist                   = ["10.0.0.0/8"]
        enable_api_termination_protection = true
      }
    }
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].disable_api_termination == true
    error_message = "Cluster API termination protection should be enabled"
  }
}

run "cluster_description_applied" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        description        = "Test cluster description"
      }
    }
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].description == "Test cluster description"
    error_message = "Cluster description should be set"
  }
}

run "cluster_description_default_null" {
  command = plan

  assert {
    condition     = try(var.clusters["cluster"].description, null) == null
    error_message = "Cluster description should default to null"
  }
}

# ─── Multiple Clusters Across Projects ───────────────────────────────

run "multiple_clusters_across_projects" {
  command = plan

  variables {
    projects = {
      proj-a = {
        name   = "project-a"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
      proj-b = {
        name   = "project-b"
        cidr   = "10.1.0.0/16"
        region = "eu-west-2"
      }
    }
    clusters = {
      cluster-a = {
        name               = "cluster-a"
        project_key        = "proj-a"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
      cluster-b = {
        name               = "cluster-b"
        project_key        = "proj-b"
        kubernetes_version = "1.31"
        cidr_pods          = "10.93.0.0/16"
        cidr_service       = "10.94.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  assert {
    condition     = var.clusters["cluster-a"].project_key == "proj-a"
    error_message = "Cluster A should reference project key proj-a"
  }

  assert {
    condition     = var.clusters["cluster-b"].project_key == "proj-b"
    error_message = "Cluster B should reference project key proj-b"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster-a"].name == "cluster-a"
    error_message = "Cluster A should be created"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster-b"].name == "cluster-b"
    error_message = "Cluster B should be created"
  }
}

# ─── Project Without Clusters ────────────────────────────────────────

run "project_without_clusters" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
    }
    clusters = {}
  }

  assert {
    condition     = outscale_oks_project.this["proj"].name == "test-project"
    error_message = "Project should be created even without clusters"
  }

  assert {
    condition     = length(outscale_oks_cluster.this) == 0
    error_message = "No clusters should be created"
  }
}

# ─── Data Source Tests ────────────────────────────────────────────────

run "kubeconfig_enabled_by_default" {
  command = plan

  assert {
    condition     = length(data.outscale_oks_kubeconfig.this) == 1
    error_message = "Kubeconfig data source should be enabled by default"
  }
}

run "kubeconfig_disabled" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        enable_kubeconfig  = false
      }
    }
  }

  assert {
    condition     = length(data.outscale_oks_kubeconfig.this) == 0
    error_message = "Kubeconfig data source should be skipped when disabled"
  }
}

run "kubeconfig_custom_user" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        kubeconfig_user    = "admin"
      }
    }
  }

  assert {
    condition     = data.outscale_oks_kubeconfig.this["cluster"].user == "admin"
    error_message = "Kubeconfig user should be set to 'admin'"
  }
}

run "kubeconfig_custom_group" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        kubeconfig_group   = "system:masters"
      }
    }
  }

  assert {
    condition     = data.outscale_oks_kubeconfig.this["cluster"].group == "system:masters"
    error_message = "Kubeconfig group should be set to 'system:masters'"
  }
}

run "kubeconfig_custom_ttl" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        kubeconfig_ttl     = "24h"
      }
    }
  }

  assert {
    condition     = data.outscale_oks_kubeconfig.this["cluster"].ttl == "24h"
    error_message = "Kubeconfig TTL should be set to '24h'"
  }
}

run "quotas_disabled_by_default" {
  command = plan

  assert {
    condition     = length(data.outscale_oks_quotas.this) == 0
    error_message = "Quotas data source should be disabled by default"
  }
}

# ─── Output Tests ─────────────────────────────────────────────────────

run "output_project_ids_set" {
  command = plan

  assert {
    condition     = contains(keys(output.project_ids), "proj")
    error_message = "project_ids output should contain 'proj' key"
  }
}

run "output_project_names_match" {
  command = plan

  assert {
    condition     = output.project_names["proj"] == "test-project"
    error_message = "project_names output should match input"
  }
}

run "output_cluster_names_match" {
  command = plan

  assert {
    condition     = output.cluster_names["cluster"] == "test-cluster"
    error_message = "cluster_names output should match input"
  }
}

run "output_cluster_versions_match" {
  command = plan

  assert {
    condition     = output.cluster_versions["cluster"] == "1.31"
    error_message = "cluster_versions output should match input"
  }
}

run "output_kubeconfigs_empty_when_disabled" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        enable_kubeconfig  = false
      }
    }
  }

  assert {
    condition     = length(output.kubeconfigs) == 0
    error_message = "kubeconfigs output should be empty when all clusters have kubeconfig disabled"
  }
}

run "output_quotas_null_when_disabled" {
  command = plan

  assert {
    condition     = output.quotas == null
    error_message = "quotas output should be null when disabled by default"
  }
}

# ─── Tag Tests ────────────────────────────────────────────────────────

run "managed_by_tag_always_present" {
  command = plan

  assert {
    condition     = outscale_oks_project.this["proj"].tags["ManagedBy"] == "terraform"
    error_message = "Project should always have ManagedBy=terraform tag"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].tags["ManagedBy"] == "terraform"
    error_message = "Cluster should always have ManagedBy=terraform tag"
  }
}

run "name_tag_matches_resource_name" {
  command = plan

  assert {
    condition     = outscale_oks_project.this["proj"].tags["Name"] == "test-project"
    error_message = "Project Name tag should match project name"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].tags["Name"] == "test-cluster"
    error_message = "Cluster Name tag should match cluster name"
  }
}

run "common_tags_applied" {
  command = plan

  variables {
    tags = {
      Environment = "test"
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["Environment"] == "test"
    error_message = "Project should have common tags"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].tags["Environment"] == "test"
    error_message = "Cluster should have common tags"
  }
}

run "resource_specific_tags_merged" {
  command = plan

  variables {
    tags = {
      Global = "tag"
    }
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
        tags = {
          ProjectOnly = "true"
        }
      }
    }
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
        tags = {
          ClusterOnly = "true"
        }
      }
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["Global"] == "tag"
    error_message = "Project should have global tags"
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["ProjectOnly"] == "true"
    error_message = "Project should have project-specific tags"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].tags["Global"] == "tag"
    error_message = "Cluster should have global tags"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].tags["ClusterOnly"] == "true"
    error_message = "Cluster should have cluster-specific tags"
  }
}

run "managed_by_cannot_be_overridden" {
  command = plan

  variables {
    tags = {
      ManagedBy = "manual"
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag must not be overridable by user tags"
  }
}

run "name_tag_cannot_be_overridden" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
        tags = {
          Name = "custom-name"
        }
      }
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["Name"] == "test-project"
    error_message = "Name tag must not be overridable by resource-specific tags"
  }
}

run "resource_tags_override_common_tags" {
  command = plan

  variables {
    tags = {
      Team = "platform"
    }
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
        tags = {
          Team = "data"
        }
      }
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["Team"] == "data"
    error_message = "Project tags must win over var.tags"
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].tags["Team"] == "platform"
    error_message = "var.tags must apply to a cluster that does not set the key"
  }
}

run "managed_by_cannot_be_overridden_by_resource_tags" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
        tags = {
          ManagedBy = "manual"
        }
      }
    }
  }

  assert {
    condition     = outscale_oks_project.this["proj"].tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag must not be overridable by resource-specific tags"
  }
}

# ─── Validation Tests: Project Name ──────────────────────────────────

run "invalid_project_name_uppercase" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "INVALID"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
    }
  }

  expect_failures = [
    var.projects,
  ]
}

run "invalid_project_name_starts_with_number" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "1invalid"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
    }
  }

  expect_failures = [
    var.projects,
  ]
}

run "invalid_project_name_trailing_hyphen" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "test-"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
    }
  }

  expect_failures = [
    var.projects,
  ]
}

run "invalid_project_name_too_long" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "abcdefghijklmnopqrstuvwxyz0123456789abcde"
        cidr   = "10.0.0.0/16"
        region = "eu-west-2"
      }
    }
  }

  expect_failures = [
    var.projects,
  ]
}

# ─── Validation Tests: Cluster Name ──────────────────────────────────

run "invalid_cluster_name_uppercase" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "INVALID-CLUSTER"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

run "invalid_cluster_name_trailing_hyphen" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "cluster-"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

run "invalid_cluster_name_too_long" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "abcdefghijklmnopqrstuvwxyz0123456789abcde"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

# ─── Validation Tests: CIDR Blocks ───────────────────────────────────

run "invalid_project_cidr" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "not-a-cidr"
        region = "eu-west-2"
      }
    }
  }

  expect_failures = [
    var.projects,
  ]
}

run "invalid_cidr_pods" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "not-a-cidr"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

run "invalid_cidr_service" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "not-a-cidr"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

# ─── Validation Tests: Admin Whitelist ────────────────────────────────

run "empty_admin_whitelist" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = []
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

run "invalid_cidr_in_admin_whitelist" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["not-a-cidr"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

# ─── Validation Tests: Kubernetes Version ─────────────────────────────

run "invalid_kubernetes_version_format" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "not-a-version"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

run "invalid_kubernetes_version_trailing_characters" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31abc"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

run "kubernetes_version_with_patch_accepted" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "proj"
        kubernetes_version = "1.31.2"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  assert {
    condition     = outscale_oks_cluster.this["cluster"].version == "1.31.2"
    error_message = "A major.minor.patch version must be accepted"
  }
}

run "invalid_cluster_project_key" {
  command = plan

  variables {
    clusters = {
      cluster = {
        name               = "test-cluster"
        project_key        = "missing"
        kubernetes_version = "1.31"
        cidr_pods          = "10.91.0.0/16"
        cidr_service       = "10.92.0.0/16"
        admin_whitelist    = ["10.0.0.0/8"]
      }
    }
  }

  expect_failures = [
    var.clusters,
  ]
}

# ─── Validation Tests: Region ─────────────────────────────────────────

run "invalid_region_format" {
  command = plan

  variables {
    projects = {
      proj = {
        name   = "test-project"
        cidr   = "10.0.0.0/16"
        region = "INVALID REGION"
      }
    }
  }

  expect_failures = [
    var.projects,
  ]
}

# ─── Validation Tests: Empty Projects ─────────────────────────────────

run "empty_projects_rejected" {
  command = plan

  variables {
    projects = {}
  }

  expect_failures = [
    var.projects,
  ]
}

# ─── Data Source Tests (mocked provider, no credentials needed) ──────

run "quotas_enabled" {
  command = plan

  variables {
    enable_quotas = true
  }

  assert {
    condition     = length(data.outscale_oks_quotas.this) == 1
    error_message = "Quotas data source should be enabled when requested"
  }
}
