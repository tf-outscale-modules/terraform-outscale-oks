# ─── Common Test Variables ────────────────────────────────────────────

variables {
  project_name       = "test-project"
  project_cidr       = "10.0.0.0/16"
  region             = "eu-west-2"
  cluster_name       = "test-cluster"
  kubernetes_version = "1.31"
  cidr_pods          = "10.91.0.0/16"
  cidr_service       = "10.92.0.0/16"
  admin_whitelist    = ["10.0.0.0/8"]
}

# ─── Project Resource Tests ──────────────────────────────────────────

run "project_created_with_required_vars" {
  command = plan

  assert {
    condition     = outscale_oks_project.this.name == "test-project"
    error_message = "Project name should be 'test-project'"
  }

  assert {
    condition     = outscale_oks_project.this.cidr == "10.0.0.0/16"
    error_message = "Project CIDR should be '10.0.0.0/16'"
  }

  assert {
    condition     = outscale_oks_project.this.region == "eu-west-2"
    error_message = "Project region should be 'eu-west-2'"
  }
}

run "project_description_applied" {
  command = plan

  variables {
    project_description = "Test project description"
  }

  assert {
    condition     = outscale_oks_project.this.description == "Test project description"
    error_message = "Project description should be set"
  }
}

run "project_api_termination_protection" {
  command = plan

  variables {
    enable_project_api_termination_protection = true
  }

  assert {
    condition     = outscale_oks_project.this.disable_api_termination == true
    error_message = "Project API termination protection should be enabled"
  }
}

run "project_api_termination_protection_default_disabled" {
  command = plan

  assert {
    condition     = outscale_oks_project.this.disable_api_termination == false
    error_message = "Project API termination protection should be disabled by default"
  }
}

# ─── Cluster Resource Tests ──────────────────────────────────────────

run "cluster_created_with_required_vars" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this.name == "test-cluster"
    error_message = "Cluster name should be 'test-cluster'"
  }

  assert {
    condition     = outscale_oks_cluster.this.version == "1.31"
    error_message = "Cluster version should be '1.31'"
  }

  assert {
    condition     = outscale_oks_cluster.this.cidr_pods == "10.91.0.0/16"
    error_message = "Cluster pod CIDR should be '10.91.0.0/16'"
  }

  assert {
    condition     = outscale_oks_cluster.this.cidr_service == "10.92.0.0/16"
    error_message = "Cluster service CIDR should be '10.92.0.0/16'"
  }

  assert {
    condition     = outscale_oks_cluster.this.admin_whitelist == tolist(["10.0.0.0/8"])
    error_message = "Cluster admin whitelist should contain '10.0.0.0/8'"
  }
}

run "cluster_default_control_planes" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this.control_planes == "cp.3.masters.small"
    error_message = "Default control planes should be 'cp.3.masters.small'"
  }
}

run "cluster_custom_control_planes" {
  command = plan

  variables {
    control_planes = "cp.3.masters.medium"
  }

  assert {
    condition     = outscale_oks_cluster.this.control_planes == "cp.3.masters.medium"
    error_message = "Custom control planes should be applied"
  }
}

run "cluster_multi_az_enabled" {
  command = plan

  variables {
    enable_cp_multi_az = true
  }

  assert {
    condition     = outscale_oks_cluster.this.cp_multi_az == true
    error_message = "Multi-AZ should be enabled"
  }
}

run "cluster_multi_az_default_disabled" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this.cp_multi_az == false
    error_message = "Multi-AZ should be disabled by default"
  }
}

run "cluster_admin_lbu_enabled" {
  command = plan

  variables {
    enable_admin_lbu = true
  }

  assert {
    condition     = outscale_oks_cluster.this.admin_lbu == true
    error_message = "Admin LBU should be enabled"
  }
}

run "cluster_admin_lbu_default_disabled" {
  command = plan

  assert {
    condition     = outscale_oks_cluster.this.admin_lbu == false
    error_message = "Admin LBU should be disabled by default"
  }
}

run "cluster_api_termination_protection" {
  command = plan

  variables {
    enable_cluster_api_termination_protection = true
  }

  assert {
    condition     = outscale_oks_cluster.this.disable_api_termination == true
    error_message = "Cluster API termination protection should be enabled"
  }
}

run "cluster_description_applied" {
  command = plan

  variables {
    cluster_description = "Test cluster description"
  }

  assert {
    condition     = outscale_oks_cluster.this.description == "Test cluster description"
    error_message = "Cluster description should be set"
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
    enable_kubeconfig = false
  }

  assert {
    condition     = length(data.outscale_oks_kubeconfig.this) == 0
    error_message = "Kubeconfig data source should be skipped when disabled"
  }
}

run "quotas_disabled_by_default" {
  command = plan

  assert {
    condition     = length(data.outscale_oks_quotas.this) == 0
    error_message = "Quotas data source should be disabled by default"
  }
}

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

# ─── Tag Tests ────────────────────────────────────────────────────────

run "common_tags_applied_to_project" {
  command = plan

  variables {
    tags = {
      Project = "test"
    }
  }

  assert {
    condition     = outscale_oks_project.this.tags["ManagedBy"] == "terraform"
    error_message = "Project should have ManagedBy=terraform tag"
  }

  assert {
    condition     = outscale_oks_project.this.tags["Project"] == "test"
    error_message = "Project should have custom tags"
  }

  assert {
    condition     = outscale_oks_project.this.tags["Name"] == "test-project"
    error_message = "Project should have Name tag matching project_name"
  }
}

run "common_tags_applied_to_cluster" {
  command = plan

  variables {
    tags = {
      Project = "test"
    }
  }

  assert {
    condition     = outscale_oks_cluster.this.tags["ManagedBy"] == "terraform"
    error_message = "Cluster should have ManagedBy=terraform tag"
  }

  assert {
    condition     = outscale_oks_cluster.this.tags["Project"] == "test"
    error_message = "Cluster should have custom tags"
  }

  assert {
    condition     = outscale_oks_cluster.this.tags["Name"] == "test-cluster"
    error_message = "Cluster should have Name tag matching cluster_name"
  }
}

run "resource_specific_tags_merged" {
  command = plan

  variables {
    tags = {
      Global = "tag"
    }
    project_tags = {
      ProjectOnly = "true"
    }
    cluster_tags = {
      ClusterOnly = "true"
    }
  }

  assert {
    condition     = outscale_oks_project.this.tags["Global"] == "tag"
    error_message = "Project should have global tags"
  }

  assert {
    condition     = outscale_oks_project.this.tags["ProjectOnly"] == "true"
    error_message = "Project should have project-specific tags"
  }

  assert {
    condition     = outscale_oks_cluster.this.tags["Global"] == "tag"
    error_message = "Cluster should have global tags"
  }

  assert {
    condition     = outscale_oks_cluster.this.tags["ClusterOnly"] == "true"
    error_message = "Cluster should have cluster-specific tags"
  }
}

# ─── Validation Tests ─────────────────────────────────────────────────

run "invalid_project_name_uppercase" {
  command = plan

  variables {
    project_name = "INVALID"
  }

  expect_failures = [
    var.project_name,
  ]
}

run "invalid_project_name_starts_with_number" {
  command = plan

  variables {
    project_name = "1invalid"
  }

  expect_failures = [
    var.project_name,
  ]
}

run "invalid_project_cidr" {
  command = plan

  variables {
    project_cidr = "not-a-cidr"
  }

  expect_failures = [
    var.project_cidr,
  ]
}

run "invalid_cluster_name" {
  command = plan

  variables {
    cluster_name = "INVALID-CLUSTER"
  }

  expect_failures = [
    var.cluster_name,
  ]
}

run "invalid_cidr_pods" {
  command = plan

  variables {
    cidr_pods = "not-a-cidr"
  }

  expect_failures = [
    var.cidr_pods,
  ]
}

run "invalid_cidr_service" {
  command = plan

  variables {
    cidr_service = "not-a-cidr"
  }

  expect_failures = [
    var.cidr_service,
  ]
}

run "empty_admin_whitelist" {
  command = plan

  variables {
    admin_whitelist = []
  }

  expect_failures = [
    var.admin_whitelist,
  ]
}
