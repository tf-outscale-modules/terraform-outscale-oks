## MODIFIED Requirements
### Requirement: Cluster project reference
Each cluster SHALL reference a project declared in `projects` through `project_key`, and the cluster SHALL be created with the ID of that project. An unknown `project_key` SHALL be rejected by the validation of `clusters`.

#### Scenario: Cluster in a project
- **WHEN** `clusters = { main = { project_key = "main", ... } }` and `projects` has the key `main`
- **THEN** the cluster is created in project `main`

#### Scenario: Unknown project key
- **WHEN** a cluster has `project_key = "missing"` and `projects` has no such key
- **THEN** the plan fails with "Each cluster project_key must match a key of var.projects."

### Requirement: Cluster Kubernetes version validation
A cluster `kubernetes_version` SHALL be a major and a minor number separated by a dot, optionally followed by a dot and a patch number, and nothing else.

#### Scenario: Invalid version
- **WHEN** a cluster has `kubernetes_version = "latest"`
- **THEN** the plan fails with "Cluster kubernetes_version must be a valid version string (e.g., '1.31')."

#### Scenario: Trailing characters
- **WHEN** a cluster has `kubernetes_version = "1.31abc"`
- **THEN** the plan fails with the same error
