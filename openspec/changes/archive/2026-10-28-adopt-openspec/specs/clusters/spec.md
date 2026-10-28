## ADDED Requirements

### Requirement: Clusters from the clusters map
The module SHALL create one OKS cluster per entry of `clusters` (default `{}`), keyed by the map key, in the project selected by `project_key`. Required attributes are `name`, `project_key`, `kubernetes_version`, `cidr_pods`, `cidr_service` and `admin_whitelist`.

#### Scenario: Required attributes only
- **WHEN** a cluster sets only the required attributes
- **THEN** the plan creates one cluster named after `name`, in the referenced project

### Requirement: Cluster options and timeouts
Optional cluster attributes SHALL default as follows: `control_planes` `"cp.3.masters.small"`, `description` `null`, `enable_cp_multi_az` `false`, `enable_admin_lbu` `false`, `enable_api_termination_protection` `false`, `tags` `{}`. `enable_cp_multi_az` SHALL be sent as the cluster's `cp_multi_az`, `enable_admin_lbu` as `admin_lbu` and `enable_api_termination_protection` as `disable_api_termination`. Create, update and delete timeouts SHALL be 18, 15 and 15 minutes.

#### Scenario: Defaults
- **WHEN** a cluster sets only the required attributes
- **THEN** it is planned with control planes `cp.3.masters.small`, multi-AZ off, admin load balancer off and termination protection off

#### Scenario: Custom sizing and options
- **WHEN** a cluster sets `control_planes = "cp.3.masters.medium"`, `enable_cp_multi_az = true` and `enable_admin_lbu = true`
- **THEN** the cluster is planned with that control plane size, `cp_multi_az = true` and `admin_lbu = true`

### Requirement: Cluster project reference
Each cluster SHALL reference a project declared in `projects` through `project_key`, and the cluster SHALL be created with the ID of that project.

#### Scenario: Cluster in a project
- **WHEN** `clusters = { main = { project_key = "main", ... } }` and `projects` has the key `main`
- **THEN** the cluster is created in project `main`

#### Scenario: Unknown project key
- **WHEN** a cluster has `project_key = "missing"` and `projects` has no such key
- **THEN** the plan fails on the cluster resource

### Requirement: Cluster name validation
A cluster `name` SHALL be 2 to 40 characters, lowercase alphanumeric characters and hyphens, start with a letter and end with a letter or a digit.

#### Scenario: Uppercase name
- **WHEN** a cluster has `name = "My-Cluster"`
- **THEN** the plan fails with "Cluster names must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."

#### Scenario: Trailing hyphen
- **WHEN** a cluster has `name = "cluster-"`
- **THEN** the plan fails with the same error

#### Scenario: Too long
- **WHEN** a cluster name has 41 characters
- **THEN** the plan fails with the same error

### Requirement: Cluster Kubernetes version validation
A cluster `kubernetes_version` SHALL start with a major and a minor number separated by a dot.

#### Scenario: Invalid version
- **WHEN** a cluster has `kubernetes_version = "latest"`
- **THEN** the plan fails with "Cluster kubernetes_version must be a valid version string (e.g., '1.31')."

### Requirement: Cluster CIDR validation
`cidr_pods` and `cidr_service` SHALL be valid CIDR notation. The module SHALL NOT check that they do not overlap each other or the project CIDR.

#### Scenario: Invalid pod CIDR
- **WHEN** a cluster has `cidr_pods = "10.91.0.0"`
- **THEN** the plan fails with "Cluster cidr_pods must be valid CIDR notation (e.g., '10.91.0.0/16')."

#### Scenario: Invalid service CIDR
- **WHEN** a cluster has `cidr_service = "invalid"`
- **THEN** the plan fails with "Cluster cidr_service must be valid CIDR notation (e.g., '10.92.0.0/16')."

### Requirement: Admin whitelist validation
`admin_whitelist` SHALL contain at least one entry, and each entry SHALL be an IP address or a CIDR block.

#### Scenario: Empty whitelist
- **WHEN** a cluster has `admin_whitelist = []`
- **THEN** the plan fails with "Cluster admin_whitelist must contain at least one CIDR block."

#### Scenario: Entry that is not an address
- **WHEN** a cluster has `admin_whitelist = ["not-an-ip"]`
- **THEN** the plan fails with "Each item in cluster admin_whitelist must be an IP address or a CIDR block (e.g., '203.0.113.10' or '203.0.113.0/24')."

#### Scenario: Single IP accepted
- **WHEN** a cluster has `admin_whitelist = ["203.0.113.10"]`
- **THEN** the input is accepted

### Requirement: Cluster outputs
The module SHALL expose `cluster_ids`, `cluster_names`, `cluster_versions` and `cluster_statuses` (maps of cluster key to the cluster attribute), and `cluster_dns` and `cluster_cni` (maps of cluster key to the attribute, `null` when it is unavailable).

#### Scenario: Versions
- **WHEN** a cluster `main` has `kubernetes_version = "1.31"`
- **THEN** `cluster_versions["main"]` is the version of the cluster resource
