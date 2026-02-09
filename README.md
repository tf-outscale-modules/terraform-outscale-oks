# Outscale Cloud Native Terraform Module

[![Apache 2.0][apache-shield]][apache]
[![Terraform][terraform-badge]][terraform-url]
[![Outscale Provider][provider-badge]][provider-url]
[![Latest Release][release-badge]][release-url]

Terraform module for provisioning and managing Outscale Kubernetes Service (OKS) infrastructure.

## Features

- OKS project management with configurable CIDR and region
- Kubernetes cluster provisioning with version selection
- Control plane sizing and multi-AZ deployment
- Admin API whitelist for secure access control
- Kubeconfig retrieval with configurable TTL
- Account quota monitoring
- API termination protection for production workloads
- Flexible tagging with common and resource-specific tags

## Requirements

| Name | Version |
|------|---------|
| Terraform / OpenTofu | >= 1.10 |
| Outscale Provider | ~> 1.3 |

## Usage

### Basic Example

```hcl
module "oks" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-cloud-native.git?ref=v0.1.0"

  project_name = "my-project"
  project_cidr = "10.0.0.0/16"
  region       = "eu-west-2"

  cluster_name       = "my-cluster"
  kubernetes_version = "1.31"
  cidr_pods          = "10.91.0.0/16"
  cidr_service       = "10.92.0.0/16"
  admin_whitelist    = ["203.0.113.0/24"]
}
```

### Complete Example

```hcl
module "oks" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-cloud-native.git?ref=v0.1.0"

  # Project
  project_name        = "production"
  project_cidr        = "10.0.0.0/16"
  region              = "eu-west-2"
  project_description = "Production OKS environment"

  enable_project_api_termination_protection = true

  # Cluster
  cluster_name       = "prod-cluster"
  kubernetes_version = "1.31"
  cidr_pods          = "10.91.0.0/16"
  cidr_service       = "10.92.0.0/16"
  admin_whitelist    = ["203.0.113.0/24", "198.51.100.10/32"]

  control_planes     = "cp.3.masters.medium"
  enable_cp_multi_az = true
  enable_admin_lbu   = true

  enable_cluster_api_termination_protection = true

  # Kubeconfig
  enable_kubeconfig = true
  kubeconfig_ttl    = "24h"

  # Quotas
  enable_quotas = true

  # Tags
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Conditional Creation

```hcl
module "oks" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-cloud-native.git?ref=v0.1.0"

  project_name = "my-project"
  project_cidr = "10.0.0.0/16"
  region       = "eu-west-2"

  cluster_name       = "my-cluster"
  kubernetes_version = "1.31"
  cidr_pods          = "10.91.0.0/16"
  cidr_service       = "10.92.0.0/16"
  admin_whitelist    = ["10.0.0.0/8"]

  # Disable kubeconfig retrieval (manage credentials separately)
  enable_kubeconfig = false

  # Enable quota monitoring
  enable_quotas = true
}
```

## Security Considerations

1. Never use `0.0.0.0/0` in `admin_whitelist` for production environments
2. The `kubeconfig` output is marked as `sensitive` to prevent accidental exposure
3. Enable API termination protection for production projects and clusters
4. State files contain kubeconfig in plaintext — use encrypted remote backends
5. See [SECURITY.md](SECURITY.md) for detailed security guidelines

## Known Limitations

1. The Outscale provider OKS resources are from v1.3.0-alpha.1 — the API may evolve
2. The module does not validate that `project_cidr`, `cidr_pods`, and `cidr_service` do not overlap
3. Node pool management is not yet supported (planned for Phase 2)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | This file |
| [SECURITY.md](SECURITY.md) | Security guidelines and best practices |
| [TESTING.md](TESTING.md) | Testing strategy and instructions |
| [CHANGELOG.md](CHANGELOG.md) | Release history |

## Contributing

Contributions are welcome. Please ensure your changes:

1. Pass `tofu fmt -check -recursive`
2. Pass `tofu validate`
3. Pass `tflint --recursive`
4. Include tests for new features
5. Update documentation as needed

## License

Apache 2.0 — see [LICENSE](LICENSE) for details.

## Disclaimer

This module is provided "as is" without warranty of any kind. Use at your own risk.

[apache]: https://opensource.org/licenses/Apache-2.0
[apache-shield]: https://img.shields.io/badge/License-Apache%202.0-blue.svg

[terraform-badge]: https://img.shields.io/badge/Terraform-%3E%3D1.10-623CE4
[terraform-url]: https://www.terraform.io

[provider-badge]: https://img.shields.io/badge/Outscale%20Provider-~%3E1.3-orange
[provider-url]: https://registry.terraform.io/providers/outscale/outscale/latest

[release-badge]: https://img.shields.io/gitlab/v/release/leminnov/terraform/modules/outscale-cloud-native?include_prereleases&sort=semver
[release-url]: https://gitlab.com/leminnov/terraform/modules/outscale-cloud-native/-/releases
