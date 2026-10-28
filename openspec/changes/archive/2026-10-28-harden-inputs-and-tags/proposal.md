## Why
A review of the released module found security, precedence and validation gaps. All are fixed without a breaking change (`terraform-versioning`), so the release is a **patch**.

## What Changes
| # | Issue | Decision | Breaking |
|---|-------|----------|----------|
| 1 | `node_pools.extra_spec` is `any` and `nodepool_manifests` is not sensitive: anything in `extra_spec` reaches the manifest, the plan, the state and the output | **Doc + `check`**. Marking the output `sensitive` would break every consumer that re-exports it without `sensitive = true`, and a NodePool spec carries no secret by design. A `check "nodepool_extra_spec_no_secret"` warns when `extra_spec` contains a secret-looking key (password, secret, token, credential, private key, api key); `SECURITY.md` gets a "what lands in state" table and tells callers never to put secrets in `extra_spec`. The `any` type is kept (arbitrary provider pass-through, changing it breaks callers): `DEVIATION(terraform-variables)` comment. Future major: type `extra_spec` or make the output sensitive. | No |
| 2 | `var.tags` and `ManagedBy` overrode the tags of a project or cluster on the same key | **Code fix**. Precedence becomes `var.tags` < project/cluster `tags` < `ManagedBy` < `Name`: the more specific tag wins, `ManagedBy` and `Name` stay module-owned. Only configs that set the same key at both levels see an in-place tag update. | No (patch, tags values only on conflicting keys) |
| 3 | The two autoscaling validations both fire on missing bounds | **Code fix**. The ordering validation only checks bounds that are set. | No |
| 4 | `project_key` / `cluster_key` preconditions run after the failing index expression | **Code fix**. Variable validations (cross-variable, supported since 1.9, floor is 1.10) with the readable message replace the unreachable preconditions. Rejects only configs that already failed. | No |
| 5 | `kubernetes_version` regex only anchors the start (`1.31abc` passes) | **Code fix**. `^[0-9]+\.[0-9]+(\.[0-9]+)?$`. Rejects only values the API cannot accept. | No |
| 6 | Test comment claims `quotas_enabled` needs credentials | **Doc fix** in the test (mock provider), comment corrected. | No |

State: no new secret-bearing input. `extra_spec` content already lands in the state through the manifest; it is now documented in `SECURITY.md`.

## Capabilities
Modified: `module-contract` (tag precedence, no-secret check), `clusters` (project reference, version), `node-pools` (cluster reference, bounds, no-secret check).
