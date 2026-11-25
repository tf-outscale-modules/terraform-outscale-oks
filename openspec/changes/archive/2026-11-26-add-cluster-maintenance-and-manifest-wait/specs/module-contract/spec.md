## MODIFIED Requirements

### Requirement: Tooling and provider constraints
The module SHALL declare `required_version = ">= 1.10"` and the `outscale/outscale` provider with version constraint `~> 1.9` in `versions.tf`.

#### Scenario: Supported toolchain
- **WHEN** the module is used with OpenTofu or Terraform 1.10 or later and an `outscale/outscale` provider 1.9.x or later 1.x
- **THEN** initialization and planning succeed

#### Scenario: Older toolchain
- **WHEN** the module is used with a Terraform or OpenTofu version older than 1.10
- **THEN** initialization fails on the `required_version` constraint

#### Scenario: Provider 1.8
- **WHEN** the module is used with an `outscale/outscale` provider 1.8.x
- **THEN** initialization fails on the provider version constraint
