# Design

## Context

`cluster.tf` sends `control_planes`, `cp_multi_az`, `admin_lbu`, `disable_api_termination` and tags to `outscale_oks_cluster`. `nodepool.tf` sends only `cluster_id` and `manifest` to `outscale_oks_manifest`. Schemas inspected: provider 1.8.0 and 1.9.0 (`schema.json`) and the 1.9.0 provider source/docs. See proposal.md for motivation.

Provider facts (1.9.0 source and docs):

| Argument | Shape | Introduced | Plan behaviour |
|---|---|---|---|
| `outscale_oks_cluster.auto_maintenances` | object `{minor_upgrade_maintenance, patch_upgrade_maintenance}`, each `{enabled, duration_hours, start_hour, tz, week_day}` (all optional) | 1.8.0 | Optional+Computed; in-place update. `*_actual` siblings are computed read-backs |
| `outscale_oks_cluster.admission_flags` | object `{enable_admission_plugins, disable_admission_plugins}` (sets of string) | 1.8.0 | Optional+Computed; in-place update. Unset sets default to `[]` |
| `outscale_oks_cluster.cp_subregions` | set(string) | 1.8.0 | Optional+Computed, **`RequiresReplace`**, `UseStateForUnknown` |
| `outscale_oks_cluster.cluster_dns` | string, IP validated by provider | 1.8.0 | Optional+Computed, **`RequiresReplace`**, `UseStateForUnknown` |
| `outscale_oks_manifest.wait_for` | object `{fields = map(string), timeout = optional string}` | 1.8.0 | Optional; waits after apply until every JSONPath key matches its regex value |
| `outscale_oks_manifest.wait` | bool | 1.8.0 | Optional+Computed; **waits for the Kubernetes object to be deleted during destroy** (not a readiness wait) |
| `outscale_oks_manifest.skip_delete` | bool | 1.8.0 | Optional+Computed; destroy only drops state, the object stays in the cluster |
| `outscale_oks_manifest.field_manager` | object `{name, force_conflicts}` | **1.9.0** | Optional+Computed; defaults `terraform-provider-outscale` / `false` |

Correction to the original brief: `wait` is not a readiness wait. Readiness is `wait_for`; `wait` is a destroy-time deletion wait. Both are exposed, with distinct names.

`quirks` stays out: the module has no need for it and it is not read back by the provider.

## Goals / Non-Goals

**Goals:**
- Expose the four cluster and four node pool options as opt-in, validated inputs.
- Zero diff for existing callers; empty second plan.
- Make the replacement and orphan risks explicit where callers read them (variable descriptions, README, this file).

**Non-Goals:**
- `quirks`; manifest import support in the module (`terraform import` is a caller operation); a module-level `nodepool` readiness output; new outputs.
- Validating `cluster_dns` is inside `cidr_service` or that `cp_subregions` are inside the project region (not verifiable offline, the API rejects them; see Open Questions).

## Decisions

1. **Provider pin `~> 1.9`** (`versions.tf`): `field_manager` exists only from 1.9.0. Per `terraform-versioning` raising the provider floor is a major bump; the alternative (pin `~> 1.8`, defer `field_manager`, release v1.2.0) is rejected by the maintainer. Also picks up the 1.9.0 manifest default-namespace fix (PR #866).

2. **Cluster inputs are `optional(object)` with `null` default and null leaves.** Mapped 1:1 with snake_case names matching the provider:
   - `auto_maintenances = optional(object({ minor_upgrade_maintenance = optional(object({ enabled, duration_hours, start_hour, tz, week_day })), patch_upgrade_maintenance = optional(...) }))`; each leaf `optional()` with no invented default (`terraform-variables`: `null` = provider/server default; the server defaults are `enabled = true`, `start_hour = 12`, `tz = "UTC"`, `week_day = "Tue"`, `duration_hours = 0`).
   - `admission_flags = optional(object({ enable_admission_plugins = optional(set(string)), disable_admission_plugins = optional(set(string)) }))`.
   - `cp_subregions = optional(set(string))`, `cluster_dns = optional(string)`.
   The resource receives `each.value.<attr>` directly. Null in config on a Computed attribute keeps the state value, so no diff. For the two object attributes the provider keeps the user-set sub-objects in state and refreshes only the `*_actual` fields, so a second plan after apply is empty.

3. **Forced replacement is documented, not blocked.** `cp_subregions` and `cluster_dns` are `RequiresReplace` in the provider. Because they are Computed, leaving them `null` never forces replacement, and setting them to the value the server already reports (for example the current `cp_subregions`) does not either. Setting a different value on an existing cluster destroys and recreates it (new kubeconfig, new node pools applied on the new cluster). The variable description states "Changing this forces replacement of the cluster". No `lifecycle` guard: the module already exposes `enable_api_termination_protection`, and the provider surfaces the replace in the plan. A `check` block was considered and rejected: it cannot see prior state.

4. **Node pool inputs:**
   - `wait_for = optional(object({ fields = map(string), timeout = optional(string) }))`, passed straight to `wait_for`. Example in the example: `{ fields = { "status.progress.ready" = "1" } }` (shape taken from the provider docs; the module does not guess status fields, the caller supplies them).
   - `enable_wait_on_delete = optional(bool)` mapped to `wait`; boolean prefix per `terraform-variables`.
   - `field_manager = optional(object({ name = optional(string), force_conflicts = optional(bool) }))`.
   - `skip_delete = optional(bool)`, **per node pool** (not module-wide): a caller keeps one pool on purpose (for example an imported or hand-tuned pool) without freezing the others. Module-wide is expressible by setting it on every pool.
   All four are sent as `try`-free direct references; `null` leaves the provider default.

5. **`skip_delete` orphan-on-destroy risk (documented).** With `skip_delete = true`, removing the pool from `node_pools` or destroying it drops only Terraform state; the NodePool object (and its billed VMs) remains in the cluster. Re-adding the same `name` then conflicts unless imported (`<cluster_id>,oks.dev/v1beta2,NodePool,<name>`, manifest import is new in 1.9.0). The flag must be applied (an in-place update) **before** the removal, otherwise the destroy deletes the object. If the cluster itself is destroyed the NodePool goes with it. Variable description and README say so.

6. **Validation** (each with a unit test): `week_day` in `Mon..Sun`; `start_hour` 0..23; `duration_hours >= 0`; `tz` non-empty; `cp_subregions` non-empty when set and each entry matching `^[a-z][a-z0-9-]+[a-z]$` (Outscale subregion shape, e.g. `eu-west-2a`); `cluster_dns` a valid IPv4 (`can(cidrhost("${v}/32", 0))`); `admission_flags` sets contain no empty string and `enable` and `disable` do not overlap; `wait_for.fields` non-empty with non-empty keys; `wait_for.timeout` a Go duration (`^([0-9]+(\.[0-9]+)?(ns|us|ms|s|m|h))+$`); `field_manager.name` non-empty when set; `skip_delete` and `enable_wait_on_delete` need no validation. Messages name the accepted values.

7. **No perpetual diff.** Nothing is defaulted in the module; the provider's `*_actual` read-backs do not appear in config. `wait_for` and `skip_delete` are client-side behaviour with no server read-back; `field_manager` is Optional+Computed with provider defaults, so `null` is stable.

8. **No new resource, no `moved` block, no `provider`/`backend`, no CLI.** Existing addresses are unchanged.

## Risks / Trade-offs

- Provider floor 1.9 is a major bump for consumers still on 1.8; mitigated by the upgrade note.
- A replacing change to `cp_subregions` / `cluster_dns` destroys the cluster and node pools; mitigated by the description, README note and `enable_api_termination_protection`.
- `wait_for` can hang until its timeout if the caller's field expression never matches; the `timeout` input bounds it and falls back to the manifest create timeout.
- `skip_delete` orphan risk (Decision 5).
- `admission_flags` and `auto_maintenances` are not re-verified by the provider after import; its own import warning applies, no module action.

## Open Questions

Still open, left documented, no cross-validation added:


1. ~~Semver~~ Resolved by the maintainer: major (v1.1.2 to v2.0.0) with `field_manager` and `~> 1.9`; deferring `field_manager` to stay on `~> 1.8` (minor, v1.2.0) is rejected.
1. Whether `cp_subregions` requires `enable_cp_multi_az = true` is not documented by the provider; no cross-validation is added. Verify against a real account during apply or tell the module to add one.
2. Whether `cluster_dns` must lie inside `cidr_service` is not documented; no validation is added (the API will reject).
