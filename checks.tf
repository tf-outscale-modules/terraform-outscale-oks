# extra_spec is merged into the manifest, which lands in the plan, the state and the
# non-sensitive nodepool_manifests output. This is a heuristic guard, not a guarantee.
check "nodepool_extra_spec_no_secret" {
  assert {
    condition = alltrue([
      for k, v in var.node_pools :
      !can(regex("(?i)(password|passwd|secret|token|credential|private[_-]?key|api[_-]?key)", yamlencode(v.extra_spec)))
    ])
    error_message = "A node pool extra_spec contains a secret-looking key or value. It lands in plan, state and the nodepool_manifests output: never put secrets in extra_spec (see SECURITY.md)."
  }
}
