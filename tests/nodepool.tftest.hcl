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

# ─── Default Values Tests ────────────────────────────────────────────

run "nodepool_defaults_empty" {
  command = plan

  assert {
    condition     = length(var.node_pools) == 0
    error_message = "node_pools should default to empty map"
  }
}

run "nodepool_output_empty_by_default" {
  command = plan

  assert {
    condition     = length(output.nodepool_names) == 0
    error_message = "nodepool_names output should be empty when no node pools defined"
  }

  assert {
    condition     = length(output.nodepool_manifests) == 0
    error_message = "nodepool_manifests output should be empty when no node pools defined"
  }
}

# ─── Basic Node Pool Tests ──────────────────────────────────────────

run "nodepool_manifest_generated" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  assert {
    condition     = contains(keys(output.nodepool_manifests), "workers")
    error_message = "nodepool_manifests should contain the 'workers' key"
  }

  assert {
    condition     = output.nodepool_names["workers"] == "worker-pool"
    error_message = "nodepool_names should return the pool name"
  }
}

run "nodepool_manifest_contains_required_fields" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  assert {
    condition     = can(regex("apiVersion.*oks.dev/v1beta2", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain apiVersion oks.dev/v1beta2"
  }

  assert {
    condition     = can(regex("kind.*NodePool", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain kind NodePool"
  }

  assert {
    condition     = can(regex("name.*worker-pool", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain node pool name"
  }

  assert {
    condition     = can(regex("nodeType.*tinav6.c2r4p3", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain nodeType"
  }

  assert {
    condition     = can(regex("desiredNodes.*2", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain desiredNodes"
  }
}

# ─── Autoscaling Tests ──────────────────────────────────────────────

run "nodepool_autoscaling_in_manifest" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name               = "worker-pool"
        cluster_key        = "cluster"
        node_type          = "tinav6.c2r4p3"
        desired_nodes      = 3
        zones              = ["eu-west-2a"]
        enable_autoscaling = true
        min_nodes          = 2
        max_nodes          = 10
      }
    }
  }

  assert {
    condition     = can(regex("autoscaling", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain autoscaling section when enabled"
  }

  assert {
    condition     = can(regex("minNodes.*2", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain minNodes"
  }

  assert {
    condition     = can(regex("maxNodes.*10", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain maxNodes"
  }
}

run "nodepool_no_autoscaling_by_default" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  assert {
    condition     = !can(regex("autoscaling", output.nodepool_manifests["workers"]))
    error_message = "Manifest should not contain autoscaling when disabled"
  }
}

# ─── Auto Healing Tests ─────────────────────────────────────────────

run "nodepool_auto_healing_in_manifest" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name                = "worker-pool"
        cluster_key         = "cluster"
        node_type           = "tinav6.c2r4p3"
        desired_nodes       = 2
        zones               = ["eu-west-2a"]
        enable_auto_healing = true
      }
    }
  }

  assert {
    condition     = can(regex("autoHealing.*true", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain autoHealing when enabled"
  }
}

# ─── Volumes Tests ──────────────────────────────────────────────────

run "nodepool_volumes_in_manifest" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
        volumes = [{
          device = "/dev/sda1"
          type   = "gp2"
          size   = 50
        }]
      }
    }
  }

  assert {
    condition     = can(regex("volumes", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain volumes section"
  }

  assert {
    condition     = can(regex("/dev/sda1", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain the volume device"
  }
}

run "nodepool_volume_io1_with_iops" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
        volumes = [{
          device = "/dev/sda1"
          type   = "io1"
          size   = 100
          iops   = 3000
        }]
      }
    }
  }

  assert {
    condition     = can(regex("iops.*3000", output.nodepool_manifests["workers"]))
    error_message = "Manifest should contain iops for io1 volume"
  }
}

# ─── GPU / extra_spec Tests ─────────────────────────────────────────

run "nodepool_extra_spec_passthrough" {
  command = plan

  variables {
    node_pools = {
      gpu = {
        name          = "gpu-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 1
        zones         = ["eu-west-2a"]
        extra_spec = {
          fgpu = {
            model          = "nvidia-p6"
            "k8s-operator" = true
          }
        }
      }
    }
  }

  assert {
    condition     = can(regex("fgpu", output.nodepool_manifests["gpu"]))
    error_message = "Manifest should contain fgpu from extra_spec"
  }

  assert {
    condition     = can(regex("nvidia-p6", output.nodepool_manifests["gpu"]))
    error_message = "Manifest should contain GPU model from extra_spec"
  }
}

run "nodepool_extra_spec_empty_by_default" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  assert {
    condition     = !can(regex("fgpu", output.nodepool_manifests["workers"]))
    error_message = "Manifest should not contain fgpu when extra_spec is empty"
  }
}

# ─── Multiple Node Pools Test ───────────────────────────────────────

run "multiple_node_pools" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a", "eu-west-2b"]
      }
      gpu = {
        name          = "gpu-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 1
        zones         = ["eu-west-2a"]
      }
    }
  }

  assert {
    condition     = length(output.nodepool_names) == 2
    error_message = "Should create two node pool entries"
  }

  assert {
    condition     = output.nodepool_names["workers"] == "worker-pool"
    error_message = "Workers pool name should match"
  }

  assert {
    condition     = output.nodepool_names["gpu"] == "gpu-pool"
    error_message = "GPU pool name should match"
  }

  assert {
    condition     = length(output.nodepool_manifests) == 2
    error_message = "Should generate two manifests"
  }
}

# ─── Cross-Variable Validation Tests ────────────────────────────────

run "nodepool_invalid_cluster_key" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "nonexistent"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  expect_failures = [
    terraform_data.nodepool,
  ]
}

# ─── Validation Tests: Node Pool Name ───────────────────────────────

run "invalid_nodepool_name_uppercase" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "INVALID"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

run "invalid_nodepool_name_trailing_hyphen" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "pool-"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

run "invalid_nodepool_name_too_long" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "abcdefghijklmnopqrstuvwxyz0123456789abcde"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

# ─── Validation Tests: desired_nodes ────────────────────────────────

run "invalid_nodepool_desired_nodes_zero" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 0
        zones         = ["eu-west-2a"]
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

# ─── Validation Tests: zones ────────────────────────────────────────

run "invalid_nodepool_empty_zones" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = []
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

# ─── Validation Tests: autoscaling ──────────────────────────────────

run "invalid_nodepool_autoscaling_without_min_max" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name               = "worker-pool"
        cluster_key        = "cluster"
        node_type          = "tinav6.c2r4p3"
        desired_nodes      = 2
        zones              = ["eu-west-2a"]
        enable_autoscaling = true
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

run "invalid_nodepool_autoscaling_min_greater_than_desired" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name               = "worker-pool"
        cluster_key        = "cluster"
        node_type          = "tinav6.c2r4p3"
        desired_nodes      = 2
        zones              = ["eu-west-2a"]
        enable_autoscaling = true
        min_nodes          = 5
        max_nodes          = 10
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

run "invalid_nodepool_autoscaling_desired_greater_than_max" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name               = "worker-pool"
        cluster_key        = "cluster"
        node_type          = "tinav6.c2r4p3"
        desired_nodes      = 15
        zones              = ["eu-west-2a"]
        enable_autoscaling = true
        min_nodes          = 2
        max_nodes          = 10
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

# ─── Validation Tests: volume type ──────────────────────────────────

run "invalid_nodepool_volume_type" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
        volumes = [{
          device = "/dev/sda1"
          type   = "invalid-type"
          size   = 50
        }]
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}

# ─── Validation Tests: volume iops ──────────────────────────────────

run "invalid_nodepool_io1_without_iops" {
  command = plan

  variables {
    node_pools = {
      workers = {
        name          = "worker-pool"
        cluster_key   = "cluster"
        node_type     = "tinav6.c2r4p3"
        desired_nodes = 2
        zones         = ["eu-west-2a"]
        volumes = [{
          device = "/dev/sda1"
          type   = "io1"
          size   = 100
        }]
      }
    }
  }

  expect_failures = [
    var.node_pools,
  ]
}
