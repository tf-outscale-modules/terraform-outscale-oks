# Testing

## Overview

This module uses the [Terraform native test framework](https://developer.hashicorp.com/terraform/language/tests) with `.tftest.hcl` files in the `tests/` directory.

## Running Tests

```bash
tofu test
```

## Test Categories

### Project Resource Tests

Validates that the OKS project resource is created correctly with required variables, descriptions, and API termination protection settings.

### Cluster Resource Tests

Validates that the OKS cluster resource is created with correct Kubernetes version, CIDRs, control plane sizing, multi-AZ configuration, and admin LBU settings.

### Data Source Tests

Validates conditional creation of kubeconfig and quotas data sources based on `enable_kubeconfig` and `enable_quotas` flags.

### Output Tests

Validates that module outputs contain expected values and that conditional outputs return `null` when their data sources are disabled.

### Validation Tests

Validates that input validation rules correctly reject invalid values for project names, cluster names, Kubernetes versions, project and cluster references, CIDR blocks, and empty admin whitelists, plus the `nodepool_extra_spec_no_secret` check.

### Tag Tests

Validates that common tags, project-specific tags, and cluster-specific tags are merged correctly (project and cluster tags win over `tags`; `ManagedBy` and `Name` always win).

## Test Strategy

All tests use `command = plan` to validate configuration without provisioning real infrastructure. This keeps tests fast and eliminates the need for cloud credentials during development.

## CI Integration

Tests are validated in CI via the following pipeline steps:

1. `tofu fmt -check -recursive` - Formatting validation
2. `tofu validate` - Configuration validation
3. `tflint --recursive` - Linting validation

Full `tofu test` execution requires Outscale provider credentials and is intended for integration testing environments.

## Examples as Tests

Each example in `examples/` should be independently runnable. CI validates examples with:

```bash
cd examples/basic && tofu init && tofu validate
cd examples/complete && tofu init && tofu validate
```
