## ADDED Requirements

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
