## ADDED Requirements

### Requirement: Optional account quotas
The module SHALL read the OKS account quotas data source only when `enable_quotas` is `true`; `enable_quotas` SHALL default to `false`.

#### Scenario: Disabled by default
- **WHEN** `enable_quotas` is not set
- **THEN** no quotas data source is planned

#### Scenario: Enabled
- **WHEN** `enable_quotas = true`
- **THEN** one quotas data source is planned

### Requirement: Quotas output
The module SHALL expose the `quotas` output as the quotas data source, or `null` when `enable_quotas` is `false`.

#### Scenario: Null when disabled
- **WHEN** `enable_quotas = false`
- **THEN** the `quotas` output is `null`
