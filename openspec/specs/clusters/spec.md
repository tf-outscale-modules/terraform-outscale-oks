# clusters Specification

## Purpose
OKS clusters the module creates in those projects, their options, validation and outputs.

## Requirements

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
Each cluster SHALL reference a project declared in `projects` through `project_key`, and the cluster SHALL be created with the ID of that project. An unknown `project_key` SHALL be rejected by the validation of `clusters`.

#### Scenario: Cluster in a project
- **WHEN** `clusters = { main = { project_key = "main", ... } }` and `projects` has the key `main`
- **THEN** the cluster is created in project `main`

#### Scenario: Unknown project key
- **WHEN** a cluster has `project_key = "missing"` and `projects` has no such key
- **THEN** the plan fails with "Each cluster project_key must match a key of var.projects."

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
A cluster `kubernetes_version` SHALL be a major and a minor number separated by a dot, optionally followed by a dot and a patch number, and nothing else.

#### Scenario: Invalid version
- **WHEN** a cluster has `kubernetes_version = "latest"`
- **THEN** the plan fails with "Cluster kubernetes_version must be a valid version string (e.g., '1.31')."

#### Scenario: Trailing characters
- **WHEN** a cluster has `kubernetes_version = "1.31abc"`
- **THEN** the plan fails with the same error

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

### Requirement: Opt-in cluster maintenance, control plane and admission options
Each cluster SHALL accept the optional attributes `auto_maintenances` (minor and patch upgrade windows), `cp_subregions`, `admission_flags` (enabled and disabled plugin sets) and `cluster_dns`, all defaulting to `null`. A `null` attribute SHALL NOT be sent to the provider, so existing configurations plan unchanged and a second plan after apply is empty.

#### Scenario: Not set
- **WHEN** a cluster sets only the required attributes
- **THEN** the cluster is planned with none of the four attributes configured

#### Scenario: Patch window
- **WHEN** a cluster sets `auto_maintenances = { patch_upgrade_maintenance = { week_day = "Sun", start_hour = 3, duration_hours = 2, tz = "Europe/Paris" } }`
- **THEN** the cluster is planned with that patch window and no minor window

#### Scenario: Admission plugins
- **WHEN** a cluster sets `admission_flags = { enable_admission_plugins = ["NodeRestriction"] }`
- **THEN** the cluster is planned with that plugin enabled and no disabled plugin

#### Scenario: Control plane Subregions and DNS
- **WHEN** a cluster sets `enable_cp_multi_az = true`, `cp_subregions = ["eu-west-2a", "eu-west-2b"]` and `cluster_dns = "10.92.0.10"`
- **THEN** the cluster is planned with those Subregions and that DNS address

### Requirement: Replacement semantics of cp_subregions and cluster_dns
Changing `cp_subregions` or `cluster_dns` on an existing cluster to a value different from the one the cluster has SHALL force replacement of the cluster; leaving them `null` SHALL never do so. The descriptions of both attributes SHALL state that changing them forces replacement of the cluster.

#### Scenario: Left null on an existing cluster
- **WHEN** an existing cluster keeps `cp_subregions = null` and `cluster_dns = null`
- **THEN** the plan shows no change for those attributes

#### Scenario: Changed on an existing cluster
- **WHEN** an existing cluster's `cluster_dns` changes to a different address
- **THEN** the plan replaces the cluster, and the variable description documents it

### Requirement: Maintenance window validation
In `auto_maintenances`, `week_day` SHALL be one of `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`, `Sun`; `start_hour` SHALL be an integer from 0 to 23; `duration_hours` SHALL be 0 or more; `tz` SHALL NOT be empty.

#### Scenario: Unknown weekday
- **WHEN** a window sets `week_day = "Sunday"`
- **THEN** the plan fails with "Cluster auto_maintenances week_day must be one of: Mon, Tue, Wed, Thu, Fri, Sat, Sun."

#### Scenario: Hour out of range
- **WHEN** a window sets `start_hour = 24`
- **THEN** the plan fails with "Cluster auto_maintenances start_hour must be between 0 and 23."

#### Scenario: Negative duration
- **WHEN** a window sets `duration_hours = -1`
- **THEN** the plan fails with "Cluster auto_maintenances duration_hours must be 0 or more."

#### Scenario: Empty timezone
- **WHEN** a window sets `tz = ""`
- **THEN** the plan fails with "Cluster auto_maintenances tz must not be empty."

### Requirement: Control plane Subregions and DNS validation
When set, `cp_subregions` SHALL contain at least one Subregion name made of lowercase letters, digits and hyphens ending in a letter (for example `eu-west-2a`), and `cluster_dns` SHALL be a valid IPv4 address. The module SHALL NOT check that the Subregions belong to the project region or that the address is inside `cidr_service`.

#### Scenario: Empty Subregions
- **WHEN** a cluster sets `cp_subregions = []`
- **THEN** the plan fails with "Cluster cp_subregions must contain at least one Subregion name (e.g., 'eu-west-2a')."

#### Scenario: Malformed Subregion
- **WHEN** a cluster sets `cp_subregions = ["EU_WEST_2A"]`
- **THEN** the plan fails with the same error

#### Scenario: Invalid DNS address
- **WHEN** a cluster sets `cluster_dns = "not-an-ip"`
- **THEN** the plan fails with "Cluster cluster_dns must be a valid IPv4 address (e.g., '10.92.0.10')."

### Requirement: Admission plugin validation
In `admission_flags`, plugin names SHALL NOT be empty and a plugin SHALL NOT appear in both `enable_admission_plugins` and `disable_admission_plugins`.

#### Scenario: Empty plugin name
- **WHEN** a cluster sets `admission_flags = { enable_admission_plugins = [""] }`
- **THEN** the plan fails with "Cluster admission_flags plugin names must not be empty."

#### Scenario: Plugin both enabled and disabled
- **WHEN** a cluster enables and disables `"PodSecurity"`
- **THEN** the plan fails with "Cluster admission_flags must not enable and disable the same plugin."
