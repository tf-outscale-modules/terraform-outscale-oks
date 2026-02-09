resource "terraform_data" "nodepool" {
  for_each = var.node_pools

  # Trigger replacement when immutable fields change
  triggers_replace = {
    name        = each.value.name
    cluster_key = each.value.cluster_key
  }

  # Track mutable fields for update detection; store destroy-time values
  input = {
    manifest     = local.nodepool_manifests[each.key]
    name         = each.value.name
    project_name = outscale_oks_project.this[var.clusters[each.value.cluster_key].project_key].name
    cluster_name = outscale_oks_cluster.this[each.value.cluster_key].name
  }

  lifecycle {
    precondition {
      condition     = contains(keys(var.clusters), each.value.cluster_key)
      error_message = "Node pool '${each.key}' references cluster_key '${each.value.cluster_key}' which does not exist in var.clusters."
    }
  }

  # Create: use oks-cli to create the node pool from the generated manifest
  provisioner "local-exec" {
    command = <<-EOT
      echo '${local.nodepool_manifests[each.key]}' | \
        oks-cli cluster kubectl \
          -p '${outscale_oks_project.this[var.clusters[each.value.cluster_key].project_key].name}' \
          -c '${outscale_oks_cluster.this[each.value.cluster_key].name}' \
          -- apply -f -
    EOT
  }

  # Destroy: use oks-cli to delete the node pool
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      oks-cli cluster kubectl \
        -p '${self.input.project_name}' \
        -c '${self.input.cluster_name}' \
        -- delete nodepool '${self.input.name}' --ignore-not-found
    EOT
  }
}

# Update: apply manifest changes when mutable fields change
resource "terraform_data" "nodepool_update" {
  for_each = var.node_pools

  # Re-run when the manifest content changes
  input = local.nodepool_manifests[each.key]

  provisioner "local-exec" {
    command = <<-EOT
      echo '${local.nodepool_manifests[each.key]}' | \
        oks-cli cluster kubectl \
          -p '${outscale_oks_project.this[var.clusters[each.value.cluster_key].project_key].name}' \
          -c '${outscale_oks_cluster.this[each.value.cluster_key].name}' \
          -- apply -f -
    EOT
  }

  depends_on = [terraform_data.nodepool]
}
