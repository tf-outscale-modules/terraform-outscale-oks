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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_outscale"></a> [outscale](#requirement\_outscale) | ~> 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_outscale"></a> [outscale](#provider\_outscale) | 1.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [outscale_oks_cluster.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/oks_cluster) | resource |
| [outscale_oks_project.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/oks_project) | resource |
| [outscale_oks_kubeconfig.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/data-sources/oks_kubeconfig) | data source |
| [outscale_oks_quotas.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/data-sources/oks_quotas) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_whitelist"></a> [admin\_whitelist](#input\_admin\_whitelist) | List of CIDR blocks allowed to access the Kubernetes API server. Use specific ranges, never '0.0.0.0/0' in production | `list(string)` | n/a | yes |
| <a name="input_cidr_pods"></a> [cidr\_pods](#input\_cidr\_pods) | CIDR block for the pod network (e.g., '10.91.0.0/16'). Must not overlap with project CIDR or service CIDR | `string` | n/a | yes |
| <a name="input_cidr_service"></a> [cidr\_service](#input\_cidr\_service) | CIDR block for the service network (e.g., '10.92.0.0/16'). Must not overlap with project CIDR or pod CIDR | `string` | n/a | yes |
| <a name="input_cluster_description"></a> [cluster\_description](#input\_cluster\_description) | Description of the OKS cluster | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the OKS cluster (2-40 chars, lowercase alphanumeric and hyphens, must start with letter and end with letter or number) | `string` | n/a | yes |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Additional tags to apply only to the OKS cluster. Merged with common tags | `map(string)` | `{}` | no |
| <a name="input_control_planes"></a> [control\_planes](#input\_control\_planes) | Control plane sizing specification (e.g., 'cp.3.masters.small', 'cp.3.masters.medium') | `string` | `"cp.3.masters.small"` | no |
| <a name="input_enable_admin_lbu"></a> [enable\_admin\_lbu](#input\_enable\_admin\_lbu) | Enable load balancer for Kubernetes API administration | `bool` | `false` | no |
| <a name="input_enable_cluster_api_termination_protection"></a> [enable\_cluster\_api\_termination\_protection](#input\_enable\_cluster\_api\_termination\_protection) | Enable API termination protection for the OKS cluster. Set to true for production | `bool` | `false` | no |
| <a name="input_enable_cp_multi_az"></a> [enable\_cp\_multi\_az](#input\_enable\_cp\_multi\_az) | Enable multi-AZ deployment for the control plane. Recommended for production workloads | `bool` | `false` | no |
| <a name="input_enable_kubeconfig"></a> [enable\_kubeconfig](#input\_enable\_kubeconfig) | Enable retrieval of the kubeconfig data source for the cluster | `bool` | `true` | no |
| <a name="input_enable_project_api_termination_protection"></a> [enable\_project\_api\_termination\_protection](#input\_enable\_project\_api\_termination\_protection) | Enable API termination protection for the OKS project. Set to true for production | `bool` | `false` | no |
| <a name="input_enable_quotas"></a> [enable\_quotas](#input\_enable\_quotas) | Enable retrieval of OKS account quotas data source | `bool` | `false` | no |
| <a name="input_kubeconfig_group"></a> [kubeconfig\_group](#input\_kubeconfig\_group) | Group for the kubeconfig credential | `string` | `null` | no |
| <a name="input_kubeconfig_ttl"></a> [kubeconfig\_ttl](#input\_kubeconfig\_ttl) | Time-to-live for the kubeconfig token (e.g., '24h') | `string` | `null` | no |
| <a name="input_kubeconfig_user"></a> [kubeconfig\_user](#input\_kubeconfig\_user) | User name for the kubeconfig credential | `string` | `null` | no |
| <a name="input_kubeconfig_x_encrypt_nacl"></a> [kubeconfig\_x\_encrypt\_nacl](#input\_kubeconfig\_x\_encrypt\_nacl) | NaCl public key for encrypting the kubeconfig. When set, the kubeconfig is returned encrypted | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to deploy for the OKS cluster (e.g., '1.31'). Use outscale\_oks\_quotas data source to list available versions | `string` | n/a | yes |
| <a name="input_project_cidr"></a> [project\_cidr](#input\_project\_cidr) | CIDR block to associate with the Net of the OKS project (e.g., '10.0.0.0/16') | `string` | n/a | yes |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Description of the OKS project | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the OKS project (2-40 chars, lowercase alphanumeric and hyphens, must start with letter and end with letter or number) | `string` | n/a | yes |
| <a name="input_project_tags"></a> [project\_tags](#input\_project\_tags) | Additional tags to apply only to the OKS project. Merged with common tags | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Outscale region for the OKS project deployment (e.g., 'eu-west-2', 'cloudgouv-eu-west-1') | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all OKS resources. Merged with module-managed tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_cni"></a> [cluster\_cni](#output\_cluster\_cni) | Container Network Interface (CNI) plugin used by the cluster |
| <a name="output_cluster_dns"></a> [cluster\_dns](#output\_cluster\_dns) | DNS endpoint of the OKS cluster API server |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the OKS cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the OKS cluster |
| <a name="output_cluster_statuses"></a> [cluster\_statuses](#output\_cluster\_statuses) | Current statuses of the OKS cluster |
| <a name="output_cluster_version"></a> [cluster\_version](#output\_cluster\_version) | Kubernetes version deployed on the cluster |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig file content for accessing the OKS cluster. Contains sensitive credentials |
| <a name="output_project_created_at"></a> [project\_created\_at](#output\_project\_created\_at) | Creation timestamp of the OKS project |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the OKS project |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Name of the OKS project |
| <a name="output_project_status"></a> [project\_status](#output\_project\_status) | Current status of the OKS project |
| <a name="output_project_updated_at"></a> [project\_updated\_at](#output\_project\_updated\_at) | Last update timestamp of the OKS project |
| <a name="output_quotas"></a> [quotas](#output\_quotas) | OKS account quotas (null when enable\_quotas is false) |
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
