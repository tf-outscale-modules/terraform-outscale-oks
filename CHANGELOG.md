# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - Phase 2: Node Pools & GPU

### Added
- `var.node_pools` — `map(object(...))` variable for declaring node pools with `for_each`
- Node pool CRUD via `terraform_data` + `local-exec` provisioners using `oks-cli`
- GPU/fGPU support via generic `extra_spec` pass-through map
- Node pool autoscaling configuration (`enable_autoscaling`, `min_nodes`, `max_nodes`)
- Node pool auto-healing configuration (`enable_auto_healing`)
- Custom volume attachments per node pool (`volumes` list)
- `nodepool_manifests` output — generated YAML manifests for debugging/manual use
- `nodepool_names` output — map of node pool keys to their names
- Comprehensive node pool tests (`tests/nodepool.tftest.hcl`)
- Node pool examples in `examples/complete/`

### Changed
- Updated README with node pool features, usage examples, and known limitations
