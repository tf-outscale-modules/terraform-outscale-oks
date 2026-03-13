# References for Phase 1 MVP: OKS Terraform Module

## Similar Implementations

### terraform-outscale-networking

- **Location:** https://github.com/tf-outscale-modules/terraform-outscale-networking
- **Relevance:** Primary reference for module structure, variable patterns, output patterns, testing approach, and CI/CD pipeline
- **Key patterns:**
  - Domain-split files (core.tf, connectivity.tf, routing.tf, services.tf) instead of monolithic main.tf
  - enable_* boolean flags for optional features
  - Map-based variables with for_each loops
  - common_tags local merged with resource-specific tags
  - Conditional outputs using try()
  - Terraform native tests (.tftest.hcl) with plan command
  - examples/basic/ and examples/complete/ structure
  - GitLab CI with pre-commit, validate, tflint, and release stages

## API Documentation

### OKS API v1.0

- **Location:** https://docs.outscale.com/oks.html
- **Relevance:** Definitive source for OKS resource schemas (projects, clusters, kubeconfig, quotas)
- **Key details:**
  - Projects are containers for clusters with CIDR and region
  - Clusters require project_id, kubernetes version, pod/service CIDRs, admin whitelist
  - Kubeconfig supports user, group, ttl parameters
  - Base URLs: api.eu-west-2.oks.outscale.com/api/v2

### Outscale Terraform Provider

- **Location:** https://github.com/outscale/terraform-provider-outscale
- **Relevance:** OKS resources introduced in v1.3.0-alpha.1
- **Key details:**
  - Resources: outscale_oks_project, outscale_oks_cluster
  - Data sources: outscale_oks_kubeconfig, outscale_oks_quotas
