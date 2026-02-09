# Phase 1 MVP: OKS Terraform Module — Plan

## Scope

Full OKS stack with production-ready defaults:
- OKS Project (`outscale_oks_project`) with configurable name, CIDR, region, description, tags
- OKS Cluster (`outscale_oks_cluster`) with Kubernetes version, pod/service CIDRs, admin whitelist, control plane sizing, multi-AZ
- Kubeconfig (`outscale_oks_kubeconfig` data source) for cluster credentials
- Quotas (`outscale_oks_quotas` data source) for account quota visibility
- Complete example using terraform-outscale-networking for VPC/subnet provisioning

## Design Decisions

1. **Single flat module** — Project and Cluster tightly coupled; reference module uses same approach
2. **Domain-split files** — project.tf, cluster.tf, data.tf instead of monolithic main.tf
3. **Provider ~> 1.3** — OKS requires provider >= 1.3.0 (introduced in v1.3.0-alpha.1)
4. **Kubeconfig sensitive** — `sensitive = true` on kubeconfig output
5. **Quotas opt-in** — `enable_quotas = false` by default

## OKS API Resource Schemas

### outscale_oks_project
- name (required): 1-40 chars, pattern ^[a-z][a-z0-9-]*[a-z0-9]$
- cidr (required): CIDR block for associated Net
- region (required): Deployment region
- description (optional)
- tags (optional)
- disable_api_termination (optional, default false)

### outscale_oks_cluster
- name (required): 1-40 chars, pattern ^[a-z][a-z0-9-]*[a-z0-9]$
- project_id (required)
- version (required): Kubernetes version
- cidr_pods (required): Pod network CIDR
- cidr_service (required): Service network CIDR
- admin_whitelist (required): CIDR blocks/IPs for K8s API access
- control_planes (optional, default "cp.3.masters.small")
- cp_multi_az (optional, default false)
- admin_lbu (optional, default false)
- tags (optional)
- disable_api_termination (optional, default false)
- description (optional)

### outscale_oks_kubeconfig (data source)
- cluster_id (required)
- user, group, ttl (optional)

### outscale_oks_quotas (data source)
- Account-level quota retrieval

## File Manifest

31 files total — see full plan at `.claude/plans/iterative-exploring-ripple.md`

## Tasks

1. Save spec documentation
2. Create repository configuration files
3. Create GitLab CI pipeline
4. Create license and documentation shells
5. Create module core (versions.tf, locals.tf, main.tf)
6. Create variables.tf (18 variables)
7. Create resource files (project.tf, cluster.tf, data.tf)
8. Create outputs.tf (9 outputs)
9. Create examples/basic/
10. Create examples/complete/
11. Create tests/main.tftest.hcl (~23 tests)
12. Create README.md

## Known Risks

- Provider alpha: OKS resources from v1.3.0-alpha.1; attribute names may differ
- Test credentials: Plan-based tests may still require provider credentials
- CIDR overlap: Module does not validate non-overlap between CIDRs
