## ADDED Requirements

### Requirement: Projects from the projects map
The module SHALL create one OKS project per entry of `projects`, keyed by the map key, with the entry's `name`, `cidr` and `region`. The optional `description` SHALL default to `null` and `enable_api_termination_protection` SHALL default to `false` and be sent as the project's `disable_api_termination`. The optional `tags` SHALL default to `{}`.

#### Scenario: Required attributes only
- **WHEN** `projects = { main = { name = "my-project", cidr = "10.0.0.0/16", region = "eu-west-2" } }`
- **THEN** the plan creates one project named `my-project` with no description and termination protection off

#### Scenario: Termination protection
- **WHEN** a project sets `enable_api_termination_protection = true`
- **THEN** the project is planned with `disable_api_termination = true`

#### Scenario: Several projects
- **WHEN** `projects` has two entries `dev` and `prod`
- **THEN** the plan creates two projects, one per key

### Requirement: Project name validation
A project `name` SHALL be 2 to 40 characters, lowercase alphanumeric characters and hyphens, start with a letter and end with a letter or a digit.

#### Scenario: Uppercase name
- **WHEN** a project has `name = "My-Project"`
- **THEN** the plan fails with "Project names must be 2-40 characters, lowercase alphanumeric and hyphens, start with a letter and end with a letter or number."

#### Scenario: Starts with a digit
- **WHEN** a project has `name = "1project"`
- **THEN** the plan fails with the same error

#### Scenario: Trailing hyphen
- **WHEN** a project has `name = "project-"`
- **THEN** the plan fails with the same error

#### Scenario: Too long
- **WHEN** a project name has 41 characters
- **THEN** the plan fails with the same error

### Requirement: Project CIDR validation
A project `cidr` SHALL be valid CIDR notation.

#### Scenario: Invalid CIDR
- **WHEN** a project has `cidr = "not-a-cidr"`
- **THEN** the plan fails with "Project CIDRs must be valid CIDR notation (e.g., '10.0.0.0/16')."

### Requirement: Project region validation
A project `region` SHALL match `^[a-z][a-z0-9-]+$`.

#### Scenario: Invalid region
- **WHEN** a project has `region = "EU_WEST_2"`
- **THEN** the plan fails with "Project regions must be valid Outscale region identifiers (e.g., 'eu-west-2')."

### Requirement: Project description length
A project `description`, when set, SHALL be 40 characters or fewer.

#### Scenario: Description too long
- **WHEN** a project has a `description` of 41 characters
- **THEN** the plan fails with "Project descriptions must be 40 characters or fewer."

### Requirement: Project outputs
The module SHALL expose `project_ids` and `project_names` (maps of project key to ID and name), and `project_statuses`, `project_created_at` and `project_updated_at` (maps of project key to the provider attribute, `null` when the attribute is unavailable).

#### Scenario: Names match
- **WHEN** a project `main` is named `my-project`
- **THEN** `project_names["main"]` is `my-project`
