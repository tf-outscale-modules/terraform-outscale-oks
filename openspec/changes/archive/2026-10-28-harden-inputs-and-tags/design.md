## Decisions
- **Tags** (`locals.tf`): `merge(var.tags, v.tags, { ManagedBy = "terraform", Name = v.name })`; `common_tags` local removed. A tag value only changes in place (`tags` argument update) for keys set both in `var.tags` and a resource.
- **Cross-variable validation**: `var.clusters` validates `contains(keys(var.projects), v.project_key)` and `var.node_pools` validates `contains(keys(var.clusters), v.cluster_key)`. Validation conditions may reference other variables since Terraform/OpenTofu 1.9; `required_version >= 1.10` already holds. The `lifecycle.precondition` blocks are removed (they could never be reached before the indexing error).
- **Autoscaling**: validation 1 requires `min_nodes` and `max_nodes`; validation 2 is `!enable_autoscaling || min == null || max == null || (min <= desired && desired <= max)` so a missing bound yields one error.
- **Version regex**: `^[0-9]+\.[0-9]+(\.[0-9]+)?$`, message unchanged.
- **Secret check** (`checks.tf`, new): `check "nodepool_extra_spec_no_secret"` asserts `!can(regex("(?i)(password|passwd|secret|token|credential|private[_-]?key|api[_-]?key)", yamlencode(v.extra_spec)))` for every node pool; yamlencode covers nested keys and values. A heuristic warning, not a guarantee. Plan-time only, no resource, no perpetual diff.
- No resource address changes, no `moved` blocks, no state migration. No provider call is added.
