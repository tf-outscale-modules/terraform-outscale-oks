## ADDED Requirements

### Requirement: Node pools from the node_pools map
The module SHALL create one OKS manifest per entry of `node_pools` (default `{}`), keyed by the map key, applied to the cluster selected by `cluster_key`. Required attributes are `name`, `cluster_key`, `node_type`, `desired_nodes` and `zones`. Optional attributes SHALL default as follows: `min_nodes` and `max_nodes` `null`, `enable_autoscaling` `false`, `enable_auto_healing` `false`, `volumes` `[]`, `extra_spec` `{}`. No CLI or `kubectl` SHALL be needed on the machine running the module.

#### Scenario: No node pools
- **WHEN** `node_pools` is not set
- **THEN** no manifest is planned and `nodepool_manifests` is an empty map

#### Scenario: One node pool
- **WHEN** a node pool `workers` references an existing cluster key
- **THEN** one manifest resource is planned for `workers` on that cluster

#### Scenario: Several node pools
- **WHEN** `node_pools` has two entries
- **THEN** two manifest resources are planned, one per key

### Requirement: Node pool cluster reference
Each node pool SHALL reference a cluster declared in `clusters` through `cluster_key`.

#### Scenario: Unknown cluster key
- **WHEN** a node pool has `cluster_key = "nonexistent"` and `clusters` has no such key
- **THEN** the plan fails on the node pool manifest resource

### Requirement: NodePool manifest content
The manifest of a node pool SHALL be a YAML document with `apiVersion: oks.dev/v1beta2`, `kind: NodePool`, `metadata.name` equal to the node pool `name`, and a `spec` containing `nodeType`, `desiredNodes` and `zones`. The module SHALL expose the manifests as `nodepool_manifests` and the node pool names as `nodepool_names`, both keyed by node pool key.

#### Scenario: Basic manifest
- **WHEN** a node pool has `name = "worker-pool"`, `node_type = "tinav6.c2r4p3"`, `desired_nodes = 2` and `zones = ["eu-west-2a"]`
- **THEN** its manifest contains `apiVersion`, `kind: NodePool`, the name `worker-pool`, `nodeType`, `desiredNodes` and `zones`, and no `autoscaling`, `autoHealing` or `volumes`

### Requirement: Optional NodePool manifest sections
When `enable_autoscaling` is `true` the spec SHALL contain `autoscaling` with `minNodes` and `maxNodes`; when `enable_auto_healing` is `true` it SHALL contain `autoHealing: true`; when `volumes` is not empty it SHALL contain `volumes` where each entry has `device`, `type` and `size`, plus `iops` and `dir` only when set. The attributes of `extra_spec` SHALL be merged into the spec last.

#### Scenario: Autoscaling
- **WHEN** a node pool sets `enable_autoscaling = true`, `min_nodes = 2`, `desired_nodes = 3` and `max_nodes = 10`
- **THEN** its manifest contains `autoscaling` with `minNodes: 2` and `maxNodes: 10`

#### Scenario: Auto healing
- **WHEN** a node pool sets `enable_auto_healing = true`
- **THEN** its manifest contains `autoHealing: true`

#### Scenario: Volumes
- **WHEN** a node pool has a volume `{ device = "/dev/xvdb", type = "io1", size = 100, iops = 3000 }`
- **THEN** its manifest lists that volume with `device`, `type`, `size` and `iops`, and without `dir`

#### Scenario: Extra spec pass-through
- **WHEN** a node pool sets `extra_spec = { fgpu = { model = "nvidia-p6" } }`
- **THEN** its manifest spec contains the `fgpu` attribute with that content

### Requirement: Node pool name validation
A node pool `name` SHALL be 2 to 40 characters, lowercase alphanumeric characters and hyphens, start with a letter and end with a letter or a digit.

#### Scenario: Uppercase name
- **WHEN** a node pool has `name = "Worker-Pool"`
- **THEN** the plan fails with "Node pool names must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."

#### Scenario: Trailing hyphen
- **WHEN** a node pool has `name = "workers-"`
- **THEN** the plan fails with the same error

#### Scenario: Too long
- **WHEN** a node pool name has 41 characters
- **THEN** the plan fails with the same error

### Requirement: Node pool size and zones validation
`desired_nodes` SHALL be at least 1 and `zones` SHALL contain at least one entry.

#### Scenario: Zero desired nodes
- **WHEN** a node pool has `desired_nodes = 0`
- **THEN** the plan fails with "Node pool desired_nodes must be at least 1."

#### Scenario: No zone
- **WHEN** a node pool has `zones = []`
- **THEN** the plan fails with "Node pool zones must contain at least one availability zone."

### Requirement: Autoscaling bounds validation
When `enable_autoscaling` is `true`, `min_nodes` and `max_nodes` SHALL be set and `min_nodes <= desired_nodes <= max_nodes`.

#### Scenario: Missing bounds
- **WHEN** a node pool sets `enable_autoscaling = true` without `min_nodes` and `max_nodes`
- **THEN** the plan fails with "Node pool min_nodes and max_nodes are required when enable_autoscaling is true."

#### Scenario: Minimum above desired
- **WHEN** a node pool sets `enable_autoscaling = true`, `min_nodes = 5`, `desired_nodes = 2` and `max_nodes = 10`
- **THEN** the plan fails with "Node pool autoscaling requires min_nodes <= desired_nodes <= max_nodes."

#### Scenario: Desired above maximum
- **WHEN** a node pool sets `enable_autoscaling = true`, `min_nodes = 1`, `desired_nodes = 8` and `max_nodes = 5`
- **THEN** the plan fails with the same error

### Requirement: Volume validation
A volume `type` SHALL be one of `standard`, `gp2` or `io1`, and `iops` SHALL be set when the type is `io1`.

#### Scenario: Unknown volume type
- **WHEN** a node pool has a volume with `type = "ssd"`
- **THEN** the plan fails with "Node pool volume type must be one of: standard, gp2, io1."

#### Scenario: io1 without iops
- **WHEN** a node pool has a volume with `type = "io1"` and no `iops`
- **THEN** the plan fails with "Node pool volume iops is required when volume type is io1."
