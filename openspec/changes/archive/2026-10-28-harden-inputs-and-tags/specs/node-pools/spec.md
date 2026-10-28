## MODIFIED Requirements
### Requirement: Node pool cluster reference
Each node pool SHALL reference a cluster declared in `clusters` through `cluster_key`. An unknown `cluster_key` SHALL be rejected by the validation of `node_pools`.

#### Scenario: Unknown cluster key
- **WHEN** a node pool has `cluster_key = "nonexistent"` and `clusters` has no such key
- **THEN** the plan fails with "Each node pool cluster_key must match a key of var.clusters."

### Requirement: Autoscaling bounds validation
When `enable_autoscaling` is `true`, `min_nodes` and `max_nodes` SHALL be set and `min_nodes <= desired_nodes <= max_nodes`. A missing bound SHALL produce only the "required" error.

#### Scenario: Missing bounds
- **WHEN** a node pool sets `enable_autoscaling = true` without `min_nodes` and `max_nodes`
- **THEN** the plan fails with "Node pool min_nodes and max_nodes are required when enable_autoscaling is true." and no ordering error

#### Scenario: Minimum above desired
- **WHEN** a node pool sets `enable_autoscaling = true`, `min_nodes = 5`, `desired_nodes = 2` and `max_nodes = 10`
- **THEN** the plan fails with "Node pool autoscaling requires min_nodes <= desired_nodes <= max_nodes."

#### Scenario: Desired above maximum
- **WHEN** a node pool sets `enable_autoscaling = true`, `min_nodes = 1`, `desired_nodes = 8` and `max_nodes = 5`
- **THEN** the plan fails with the same error

## ADDED Requirements
### Requirement: No secret in extra_spec
`extra_spec` is merged into the manifest, which lands in the plan, the state and the non-sensitive `nodepool_manifests` output. A `check` block SHALL warn when the `extra_spec` of a node pool contains a key or value that looks like a secret (password, secret, token, credential, private key, api key). `SECURITY.md` SHALL document that `extra_spec` must never carry secrets.

#### Scenario: Secret-looking extra_spec
- **WHEN** a node pool sets `extra_spec = { registryToken = "abc" }`
- **THEN** the plan emits a warning from `check.nodepool_extra_spec_no_secret` naming the node pool

#### Scenario: Regular extra_spec
- **WHEN** a node pool sets `extra_spec = { fgpu = { model = "nvidia-p6" } }`
- **THEN** no warning is emitted
