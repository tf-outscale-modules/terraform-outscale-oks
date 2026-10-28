## MODIFIED Requirements
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
