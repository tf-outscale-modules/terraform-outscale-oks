## 1. Code
- [x] 1.1 Tag precedence in `locals.tf`; remove `common_tags`
- [x] 1.2 Cross-variable validations for `project_key` and `cluster_key`; remove the preconditions
- [x] 1.3 Autoscaling validation overlap; `kubernetes_version` regex
- [x] 1.4 `checks.tf` with `nodepool_extra_spec_no_secret`; DEVIATION comment on `extra_spec`
## 2. Tests, docs, examples
- [x] 2.1 Tests in `tests/main.tftest.hcl` and `tests/nodepool.tftest.hcl`; fix quotas comment
- [x] 2.2 `SECURITY.md` (what lands in state, extra_spec), `TESTING.md` if counts change, README note, `examples/complete`
## 3. Verify
- [x] 3.1 `tofu fmt -recursive`, `tofu validate`, `tflint --recursive`, `tofu test`, `pre-commit run -a`
