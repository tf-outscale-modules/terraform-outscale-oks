# module-contract Specification

## Purpose
Toolchain and provider constraints, input and output set, tag handling and sensitive outputs of the module as a whole.

## Requirements

### Requirement: Tooling and provider constraints
The module SHALL declare `required_version = ">= 1.10"` and the `outscale/outscale` provider with version constraint `~> 1.8` in `versions.tf`.

#### Scenario: Supported toolchain
- **WHEN** the module is used with OpenTofu or Terraform 1.10 or later and an `outscale/outscale` provider 1.8.x or later 1.x
- **THEN** initialization and planning succeed

#### Scenario: Older toolchain
- **WHEN** the module is used with a Terraform or OpenTofu version older than 1.10
- **THEN** initialization fails on the `required_version` constraint

### Requirement: No provider or backend configuration
The module SHALL NOT contain `provider` or `backend` blocks; the caller configures the Outscale provider and the state backend.

#### Scenario: Caller configures the provider
- **WHEN** the module is called from a root module that configures the `outscale` provider
- **THEN** every resource and data source of the module uses that configuration

### Requirement: Input set
The module SHALL expose exactly these inputs: `projects` (required, no default), `clusters` (default `{}`), `node_pools` (default `{}`), `enable_quotas` (`bool`, default `false`) and `tags` (`map(string)`, default `{}`). `projects`, `clusters` and `node_pools` SHALL be maps of objects whose keys are logical identifiers used for cross references and as output keys.

#### Scenario: Minimal call
- **WHEN** only `projects` is set with one project
- **THEN** the plan creates that project, no cluster, no node pool and no quotas data source

#### Scenario: Missing projects
- **WHEN** `projects` is not set
- **THEN** the plan fails because the required variable has no value

#### Scenario: Empty projects
- **WHEN** `projects = {}`
- **THEN** the plan fails with the error "At least one project must be defined."

### Requirement: Module-managed tags
The module SHALL merge `var.tags`, the tags of the individual project or cluster and the tag `ManagedBy = "terraform"` into the tags of every project and cluster. A `Name` tag equal to the resource name SHALL be set on every project and cluster. On a key conflict the `Name` tag wins over `ManagedBy`, which wins over the tags of the individual project or cluster, which win over `var.tags`.

#### Scenario: Common tags
- **WHEN** `tags = { Environment = "production" }`
- **THEN** every project and every cluster carries `Environment = "production"` and `ManagedBy = "terraform"`

#### Scenario: Resource tag overrides common tag
- **WHEN** `tags = { Team = "platform" }` and a project sets `tags = { Team = "data" }`
- **THEN** that project carries `Team = "data"` and the other projects and clusters carry `Team = "platform"`

#### Scenario: Caller tries to override ManagedBy
- **WHEN** `tags = { ManagedBy = "manual" }`, or a project or cluster sets `tags = { ManagedBy = "manual" }`
- **THEN** projects and clusters carry `ManagedBy = "terraform"`

#### Scenario: Caller tries to override Name
- **WHEN** a project sets `tags = { Name = "other" }`
- **THEN** that project carries `Name` equal to its `name` attribute

### Requirement: Output set
The module SHALL expose these outputs: `project_ids`, `project_names`, `project_statuses`, `project_created_at`, `project_updated_at`, `cluster_ids`, `cluster_names`, `cluster_versions`, `cluster_statuses`, `cluster_dns`, `cluster_cni`, `kubeconfigs`, `kubeconfig_attributes`, `nodepool_manifests`, `nodepool_names` and `quotas`. Each map output SHALL be keyed by the logical key of its input map.

#### Scenario: Keys follow inputs
- **WHEN** `projects = { main = {...} }`
- **THEN** `project_ids` and `project_names` are maps with the single key `main`

### Requirement: Sensitive outputs
The outputs `kubeconfigs` and `kubeconfig_attributes` SHALL be marked `sensitive`. No other output SHALL be sensitive.

#### Scenario: Kubeconfig not printed
- **WHEN** a cluster has `enable_kubeconfig = true` and the root module outputs `kubeconfigs`
- **THEN** the value is redacted in the plan and apply output
