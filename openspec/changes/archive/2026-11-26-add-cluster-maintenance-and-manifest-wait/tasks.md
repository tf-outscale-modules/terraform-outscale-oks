# Tasks

Standards applied: `terraform-versioning`, `terraform-variables`, `terraform-code-style`, `terraform-security`, `quality-simplicity`, `quality-efficiency`, `quality-security`, `quality-production-readiness`. Record any deviation as `# DEVIATION(<spec-id>): <reason>`.

## 1. Provider pin

- [x] 1.1 `versions.tf`: change `outscale/outscale` from `~> 1.8` to `~> 1.9` (`field_manager`, 1.9.0)
- [x] 1.2 README hand-written compatibility table and provider badge to `~> 1.9`; add an upgrade note (provider 1.8 users move to 1.9, no state migration); leave the terraform-docs block to the generator
- [x] 1.2a README "Upgrade notes" entry for v2.0.0 (provider floor raised to `~> 1.9`, why: `field_manager`; no state migration; no address change); the same text goes in the commit body and the MR description so the CHANGELOG/release note carries it
- [x] 1.3 `tofu init -backend=false -upgrade` to refresh `.terraform.lock.hcl` if the repository tracks it

## 2. Cluster inputs

- [x] 2.1 `variables.tf`: add `auto_maintenances`, `cp_subregions`, `admission_flags`, `cluster_dns` to the `clusters` object as `optional(...)` with no default (null); descriptions of `cp_subregions` and `cluster_dns` state "Changing this forces replacement of the cluster"
- [x] 2.2 `variables.tf`: validation blocks and exact error messages from `specs/clusters/spec.md` (weekday, hour, duration, tz, Subregions, DNS IPv4, empty plugin, enable/disable overlap), null-safe
- [x] 2.3 `cluster.tf`: pass the four attributes from `each.value`, placed with the optional arguments before `tags` (`terraform-code-style`)

## 3. Node pool inputs

- [x] 3.1 `variables.tf`: add `wait_for`, `enable_wait_on_delete`, `field_manager`, `skip_delete` to the `node_pools` object as `optional(...)` (null); `skip_delete` description names the orphan-on-destroy risk and "apply before removal"
- [x] 3.2 `variables.tf`: validation blocks and messages from `specs/node-pools/spec.md` (fields, key, timeout duration, field manager name), null-safe
- [x] 3.3 `nodepool.tf`: pass `wait_for`, `wait = enable_wait_on_delete`, `field_manager`, `skip_delete`; update the header comment (provider >= 1.9)

## 4. Tests (mock_provider, no server)

- [x] 4.1 `tests/main.tftest.hcl`: defaults leave the four cluster attributes null; each attribute is planned when set; one `expect_failures` run per validation scenario in `specs/clusters/spec.md`
- [x] 4.2 `tests/nodepool.tftest.hcl`: defaults leave the four options null; each option planned when set; `skip_delete` set on one pool only; one `expect_failures` run per validation scenario in `specs/node-pools/spec.md`
- [x] 4.3 Check that the manifest content tests still pass unchanged (`nodepool_manifests` is not modified)

## 5. Examples and docs

- [x] 5.1 `examples/basic` and `examples/complete`: provider pin `~> 1.9`; `examples/complete`: set the four cluster options and the node pool options (a `wait_for` readiness example, no secret); do not commit its `.tfstate` files; update `examples/complete/README.md`; confirm `examples/basic` still validates
- [x] 5.2 `SECURITY.md`: note that `skip_delete = true` leaves the NodePool in the cluster; the "what lands in state" table gains no secret
- [x] 5.3 README: document the forced replacement of `cp_subregions` / `cluster_dns` and the `skip_delete` orphan risk (outside the terraform-docs block)

## 6. Verification

- [x] 6.1 `tofu fmt -recursive`
- [x] 6.2 `tofu init -backend=false && tofu validate`
- [x] 6.3 `tflint --recursive`
- [x] 6.4 `tofu test`
- [x] 6.5 `mise run test:examples` does not exist in this repository's `mise.toml`; `tofu init -backend=false -upgrade && tofu validate` run in each example instead
- [x] 6.6 `pre-commit run -a` (regenerates the README terraform-docs block); report output as-is
- [x] 6.7 `mise run spec-validate`
- [x] 6.8 No `tofu apply` against a real account unless the user asks; flag the unverified Open Questions in `design.md` in the summary (live test skipped by decision: the account's OKS API requires an MFA OTP that the provider cannot send; covered by plan-mode tests only)

## 7. Commit

- [ ] 7.1 Commit subject reading as the CHANGELOG line, for example: `Add cluster maintenance windows, control plane Subregions, admission flags, cluster DNS and node pool wait, field manager and skip_delete options`; body: **major** per `terraform-versioning` (provider floor `~> 1.9`, v1.1.2 to v2.0.0), upgrade note (provider 1.8 users must bump to 1.9), replacement warning for `cp_subregions` / `cluster_dns`
- [x] 7.2 Archive with `/openspec-archive-change` after merge; summarize the changed main specs (`clusters`, `node-pools`, `module-contract`)
