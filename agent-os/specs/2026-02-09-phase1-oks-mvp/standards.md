# Standards for Phase 1 MVP: OKS Terraform Module

The following standards apply to this work.

## Root Standards

- @agent-os/standards/global.md — Pre-commit, license, mise, README template, gitignore, tflint, git-cliff, editorconfig, GitLab CI
- @agent-os/standards/repo-structure.md — Repository organization and configuration files

## Global Standards

- @agent-os/standards/global/code-style.md — HCL formatting, block ordering, expressions, comments, lifecycle
- @agent-os/standards/global/documentation.md — README structure, terraform-docs markers, variable descriptions, examples
- @agent-os/standards/global/security.md — Secrets handling, state security, least privilege, network defaults
- @agent-os/standards/global/versioning.md — Semver, git tags, pre-1.0 conventions

## Terraform Standards

- @agent-os/standards/terraform/module-structure.md — File layout, versions.tf, examples/, tests/
- @agent-os/standards/terraform/naming.md — snake_case, this for single resources, common_tags
- @agent-os/standards/terraform/outputs.md — Output naming, descriptions, sensitive marking, grouping
- @agent-os/standards/terraform/providers.md — Version constraints, no provider blocks in modules
- @agent-os/standards/terraform/state.md — Remote backends, no backend in reusable modules
- @agent-os/standards/terraform/tech-stack.md — Terraform/OpenTofu, provider pinning, testing, docs
- @agent-os/standards/terraform/variables.md — Naming, declarations, validation, ordering

## Testing Standards

- @agent-os/standards/testing/terraform-tests.md — Native .tftest.hcl, plan-based tests, validation testing
