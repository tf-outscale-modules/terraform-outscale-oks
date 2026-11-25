# Proposal

## Why

The module cannot set the OKS auto-maintenance windows, the control plane Subregions, the admission plugins or the cluster DNS IP, although the provider exposes them on `outscale_oks_cluster`. Node pools are applied without waiting for readiness, so anything that depends on the pool (workloads, outputs consumed downstream) races the nodes, and the manifest resource offers no way to keep a NodePool when its Terraform resource is removed. Provider 1.9.0 adds the server-side-apply `field_manager` and manifest import, which complete the picture.

## What Changes

All new inputs are optional with a `null` default and are sent to the provider only when set, so existing callers see no diff and a second plan stays empty.

- `clusters[*]` gains `auto_maintenances`, `cp_subregions`, `admission_flags` and `cluster_dns` (all `optional`, default `null`).
- `node_pools[*]` gains `wait_for`, `enable_wait_on_delete`, `field_manager` and `skip_delete` (all `optional`, default `null`).
- `versions.tf` raises the provider pin from `~> 1.8` to `~> 1.9` (needed for `outscale_oks_manifest.field_manager`; everything else exists in 1.8.0). README compatibility table and badge follow.
- **BREAKING (provider floor)**: consumers on outscale provider 1.8.x must upgrade to 1.9.x.
- **Forces replacement when set or changed on an existing cluster**: `cp_subregions` and `cluster_dns` (provider `RequiresReplace`, same as the existing `enable_cp_multi_az`). Documented in the variable description, `design.md` and the README. Setting them on a cluster whose server-side values already match is a no-op (see design).

Semver classification (`terraform-versioning`): the rule lists "a raised `required_version` or provider floor" as **major** and its scenario "Provider floor raised" (`~> 5.10` to `~> 5.12` to use a new argument) is exactly this case, so the release is **major**. Latest tag is `v1.1.2` (`git tag`), so the next version is **v2.0.0**. No deviation is recorded. The commit body and README carry the upgrade note (bump provider to 1.9, no state migration).

Alternative considered and rejected (maintainer decision): keep `~> 1.8` and defer `field_manager`, the only 1.9-only argument, which would make the release minor (v1.2.0). `field_manager` is in scope, so the release is v2.0.0.

Inputs whose type, default or meaning changes: none. New inputs only.

State: nothing secret is added. `kubeconfig` handling is untouched. The new inputs carry configuration only (windows, zones, plugin names, an IP, JSONPath field expectations). `wait_for.fields` values are regular expressions matched against the NodePool object, not credentials; `SECURITY.md` "what lands in state" is unchanged except one note that `skip_delete` leaves the NodePool object running in the cluster. No `*_wo` argument is involved.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `clusters`: new optional cluster attributes `auto_maintenances`, `cp_subregions`, `admission_flags`, `cluster_dns`, their validation and replacement semantics.
- `node-pools`: new optional node pool attributes `wait_for`, `enable_wait_on_delete`, `field_manager`, `skip_delete` and their validation.
- `module-contract`: provider constraint becomes `~> 1.9`.

## Impact

- Code: `versions.tf`, `variables.tf` (clusters, node_pools objects and validations), `cluster.tf`, `nodepool.tf`; no change to `locals.tf` manifests, outputs or `checks.tf`.
- Tests: `tests/main.tftest.hcl` (clusters, validation), `tests/nodepool.tftest.hcl` (node pools).
- Docs: README (generated block via terraform-docs; hand-written compatibility table and badge), `examples/complete`, `SECURITY.md` note, `TESTING.md` if test counts are listed.
- Consumers: provider 1.9.x required; no state migration; no resource address change.
