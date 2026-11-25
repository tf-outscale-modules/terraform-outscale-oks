# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-11-25
- Add cluster maintenance windows, control plane Subregions, admission flags, cluster DNS and node pool wait, field manager and skip_delete options

Clusters gain the optional auto_maintenances, cp_subregions,
admission_flags and cluster_dns inputs, and node pools gain wait_for,
enable_wait_on_delete, field_manager and skip_delete. Every new input
defaults to null and is only sent to the provider when set, so existing
configurations plan without a diff. Validation rejects bad weekdays,
hours, durations, Subregion names, DNS addresses, admission plugin
conflicts and malformed wait or field manager settings.

Upgrade notes (major, v2.0.0): the outscale/outscale provider constraint
is raised from ~> 1.8 to ~> 1.9, required by the field_manager argument
of outscale_oks_manifest. Bump the provider to 1.9.x and run
tofu init -upgrade; no input, output or address changes and no state
migration. Changing cp_subregions or cluster_dns on an existing cluster
forces its replacement (and its node pools); leaving them unset never
does. skip_delete = true leaves the NodePool and its nodes running in the
cluster when the pool is removed from Terraform: apply it before removal.
- Fix node pool and cluster validation and tag precedence, document extra_spec exposure

Per-resource tags now win over tags, while ManagedBy and Name stay
module-owned. Unknown project_key or cluster_key and malformed
kubernetes_version fail with a clear message, and the autoscaling
validations no longer overlap. A check warns on secret-looking
extra_spec content and SECURITY.md documents what lands in state.
Upgrade: a tag key set both in tags and on a project or cluster now
takes the per-resource value (in-place tag update).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
- Move from Agent OS to OpenSpec and publish the baseline specs

Planning moves from Agent OS to OpenSpec: agent-os/ is removed and the
engineering standards now come from the quality, repository and terraform
OpenSpec stores. openspec/config.yaml follows the terraform-module profile
(stores pinned at quality v1.2.6, repository v4.1.0, terraform v1.2.6) and
AGENTS.md, imported by CLAUDE.md, routes to them. openspec/specs/ holds the
baseline specification of the module as released, produced by the archived
adopt-openspec change. The openspec-* skills are installed for Claude Code
and OpenCode, openspec 1.14.3 and node are pinned in mise.toml with the
spec-validate and spec-setup tasks, and the validate:specs CI job runs
openspec validate --all --strict.

CI: mise 2026.10.17 resolves tools through mise-versions.jdx.dev instead of
the rate-limited api.github.com, and the pre-commit caches are keyed on the
toolchain files instead of the branch, so a toolchain change starts a fresh
cache. The module contract is unchanged.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
- feat: manage node pools natively with outscale_oks_manifest

- Restore node_pools, applied as NodePool CRDs by outscale_oks_manifest
  (provider >= 1.7): no oks-cli or local-exec needed.
- Add the kubeconfig_attributes output (host, CA, client cert/key) to
  configure the kubernetes/helm providers.
- admin_whitelist accepts IP addresses or CIDR blocks and rejects other
  values.
- Bump the outscale provider constraint to ~> 1.8; docs use the OSC_*
  environment variables (OUTSCALE_* are ignored since provider 1.6).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
- Updates README to reflect node pool removal

Updates the README documentation to reflect the removal of node pool resources, inputs, and outputs. This also updates the Outscale provider requirement to ~> 1.4 and cleans up provider definitions.
- Renames module to Outscale OKS

Updates the README documentation, module source paths, and example configurations to reflect the renaming from "Outscale Cloud Native" to "Outscale OKS".
- Adjusts OKS resource timeouts

Adds update and delete timeouts for OKS clusters and removes the explicit creation timeout for OKS projects.
- Removes node pool management and adds resource timeouts

Removes the custom node pool implementation that relied on `terraform_data` and `oks-cli` local-exec provisioners.

This change also introduces creation timeouts for OKS projects and clusters, updates the Outscale provider requirement to `~> 1.4`, and removes CIDR-specific validation for the admin whitelist to allow individual IP addresses.
- Allows any type for extra_spec variable

Allows the extra_spec variable to accept any type.

Removes the comment from the region attribute in the provider configuration.

These changes provide more flexibility and simplify the provider configuration.
- Adds Agent OS standards index

Adds a YAML file containing an index of Agent OS standards.

This index provides descriptions for different aspects of the Agent OS,
including global standards, Terraform-specific standards, and testing standards.
- Adds node pool management

Introduces node pool management to the module, enabling users to create, update, and delete node pools via `terraform_data` and `oks-cli`.

This change provides the ability to configure autoscaling, auto-healing, custom volume attachments and GPU/fGPU support.

Updates documentation with node pool features and limitations.
- Adds example Outscale provider configuration

Adds example Outscale provider configuration with commented-out
credentials and region. This allows users to quickly configure
the provider by uncommenting and filling in their credentials.
- Disables quotas for OKS module

Disables quotas for the OKS module in the complete example.

This change simplifies the example configuration by removing the requirement for quota management.
- Refactors module for multiple OKS clusters

Changes the module to support multiple OKS projects and clusters via `map(object(...))` with `for_each`, improving flexibility and scalability.

Adds the ability to link clusters to projects via `project_key` references.
- Migrates oks-cli installation to uv

Switches from pipx to uv for installing oks-cli, leveraging mise's built-in uvx support.

This change removes the explicit python and pipx dependencies from `mise.toml`, as uv manages its own Python runtime, simplifying tool management and improving installation speed.

Adds specification documentation for the migration plan.
- Adds pipx and oks-cli installation

Ensures consistent development environments by adding pipx
as a tool installer and configures oks-cli for installation via pipx.
- Adds validation to project description

Adds a validation rule to limit the project description
length to 40 characters. This change ensures that the
description does not exceed the maximum allowed length,
preventing potential issues with the OKS project.
Updates example project description to align with new limit.
- Improves OKS module with enhancements and fixes

Enhances the Outscale Kubernetes Service (OKS) module by adding new features, validation rules, and documentation improvements.

Adds project creation timestamp to output and cluster DNS endpoint and CNI plugin.

Improves validation for project and cluster names, CIDR blocks, and Kubernetes versions.

Updates example configurations and documentation for clarity and completeness.

Refactors tag management for better consistency and control.

Fixes a bug where default values for descriptions were not being properly handled.
- Adds initial Terraform module for Outscale OKS

This commit introduces the foundational structure and resources for managing Outscale Kubernetes Service (OKS) deployments using Terraform.

It includes:
- Core module files, resource definitions (project, cluster), data sources (kubeconfig, quotas)
- Basic and complete examples for demonstration and usage
- Comprehensive testing framework with plan-based validations
- Initial documentation covering setup, usage, security, and testing
- Configuration files for pre-commit hooks, CI pipeline, and code formatting
- Licensing and standardization documents

This initial implementation aims to provide a production-ready foundation for managing OKS infrastructure, adhering to established standards for code style, documentation, and security.
- Adds agent-os commands and product documentation

Introduces new commands for discovering standards, indexing standards, injecting standards, and planning product features.

Includes initial product documentation (mission, roadmap, tech stack) and standardizes Terraform module repository structure and configuration.

The goal is to facilitate consistent project setup, documentation, and best practices across Terraform module development.
- Initial commit

