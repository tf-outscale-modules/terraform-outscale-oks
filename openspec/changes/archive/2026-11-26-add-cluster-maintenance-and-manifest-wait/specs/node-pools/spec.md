## ADDED Requirements

### Requirement: Opt-in manifest apply and wait options
Each node pool SHALL accept the optional attributes `wait_for` (readiness fields and timeout), `enable_wait_on_delete`, `field_manager` (name and force_conflicts) and `skip_delete`, all defaulting to `null`. A `null` attribute SHALL NOT be sent to the provider, so existing node pools plan unchanged and a second plan after apply is empty.

#### Scenario: Not set
- **WHEN** a node pool sets only its existing attributes
- **THEN** its manifest resource is planned with none of the four options configured

#### Scenario: Readiness wait
- **WHEN** a node pool sets `wait_for = { fields = { "status.progress.ready" = "1" }, timeout = "20m" }`
- **THEN** its manifest resource is planned with that wait and timeout

#### Scenario: Field manager
- **WHEN** a node pool sets `field_manager = { name = "platform-team", force_conflicts = true }`
- **THEN** its manifest resource is planned with that field manager

#### Scenario: Wait on delete
- **WHEN** a node pool sets `enable_wait_on_delete = true`
- **THEN** its manifest resource is planned to wait for deletion on destroy

### Requirement: Keep a NodePool on removal
When a node pool sets `skip_delete = true`, removing it from `node_pools` or destroying it SHALL delete only the Terraform resource and leave the NodePool object, and its nodes, in the cluster. The variable description and the README SHALL state that the object is orphaned and that the flag must be applied before the pool is removed.

#### Scenario: Skip delete set
- **WHEN** a node pool sets `skip_delete = true`
- **THEN** its manifest resource is planned with `skip_delete = true`, and the documentation names the orphan risk

#### Scenario: Per node pool
- **WHEN** one of two node pools sets `skip_delete = true`
- **THEN** only that pool's manifest resource has it set

### Requirement: Wait and field manager validation
`wait_for.fields` SHALL contain at least one entry, each key SHALL NOT be empty, and `wait_for.timeout` SHALL be a duration made of numbers and unit suffixes (`ns`, `us`, `ms`, `s`, `m`, `h`). `field_manager.name` SHALL NOT be empty when set.

#### Scenario: No fields
- **WHEN** a node pool sets `wait_for = { fields = {} }`
- **THEN** the plan fails with "Node pool wait_for fields must contain at least one entry with a non-empty key."

#### Scenario: Empty field key
- **WHEN** a node pool sets `wait_for = { fields = { "" = "1" } }`
- **THEN** the plan fails with the same error

#### Scenario: Invalid timeout
- **WHEN** a node pool sets `wait_for = { fields = { "status.progress.ready" = "1" }, timeout = "soon" }`
- **THEN** the plan fails with "Node pool wait_for timeout must be a duration such as '15m' or '1h30m'."

#### Scenario: Empty field manager name
- **WHEN** a node pool sets `field_manager = { name = "" }`
- **THEN** the plan fails with "Node pool field_manager name must not be empty."
