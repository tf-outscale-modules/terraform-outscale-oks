# Outscale OKS Terraform Module

[![Apache 2.0][apache-shield]][apache]
[![Terraform][terraform-badge]][terraform-url]
[![Outscale Provider][provider-badge]][provider-url]
[![Latest Release][release-badge]][release-url]

Terraform module for provisioning and managing Outscale Kubernetes Service (OKS) infrastructure.

## Features

- Multiple OKS projects and clusters via `map(object(...))` with `for_each`
- Cluster-to-project linking via `project_key` references
- Control plane sizing and multi-AZ deployment
- Admin API whitelist for secure access control
- Per-cluster kubeconfig retrieval with configurable TTL, plus `kubeconfig_attributes` (host, CA, client cert/key) to configure the kubernetes/helm providers
- Account quota monitoring
- API termination protection for production workloads
- Flexible tagging with common and per-resource tags (per-resource tags win over `tags`; `ManagedBy` and `Name` are module-owned)
- Native node pool management via `outscale_oks_manifest` (NodePool CRDs, no `oks-cli` needed)
- GPU/fGPU support via generic `extra_spec` pass-through (never put secrets in it, see [SECURITY.md](SECURITY.md))
- Node pool autoscaling and auto-healing configuration
- Custom volume attachments per node pool

## Requirements

| Name | Version |
|------|---------|
| Terraform / OpenTofu | >= 1.10 |
| Outscale Provider | ~> 1.8 |

## Usage

### Basic Example

```hcl
module "oks" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-oks.git?ref=v0.2.0"

  projects = {
    main = {
      name   = "my-project"
      cidr   = "10.0.0.0/16"
      region = "eu-west-2"
    }
  }

  clusters = {
    main = {
      name               = "my-cluster"
      project_key        = "main"
      kubernetes_version = "1.31"
      cidr_pods          = "10.91.0.0/16"
      cidr_service       = "10.92.0.0/16"
      admin_whitelist    = ["203.0.113.0/24"]
    }
  }
}
```

### Complete Example

```hcl
module "oks" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-oks.git?ref=v0.3.0"

  projects = {
    prod = {
      name        = "production"
      cidr        = "10.0.0.0/16"
      region      = "eu-west-2"
      description = "Production OKS environment"
      enable_api_termination_protection = true
      tags = { CostCenter = "infrastructure" }
    }
  }

  clusters = {
    prod = {
      name               = "prod-cluster"
      project_key        = "prod"
      kubernetes_version = "1.31"
      cidr_pods          = "10.91.0.0/16"
      cidr_service       = "10.92.0.0/16"
      admin_whitelist    = ["203.0.113.0/24", "198.51.100.10/32"]
      control_planes     = "cp.3.masters.medium"
      enable_cp_multi_az = true
      enable_admin_lbu   = true
      enable_api_termination_protection = true
      kubeconfig_ttl     = "24h"
      tags = { Team = "platform" }
    }
  }

  node_pools = {
    workers = {
      name               = "worker-pool"
      cluster_key        = "prod"
      node_type          = "tinav6.c2r4p3"
      desired_nodes      = 2
      zones              = ["eu-west-2a", "eu-west-2b"]
      enable_autoscaling = true
      min_nodes          = 2
      max_nodes          = 10
    }
    gpu = {
      name          = "gpu-pool"
      cluster_key   = "prod"
      node_type     = "tinav6.c2r4p3"
      desired_nodes = 1
      zones         = ["eu-west-2a"]
      extra_spec = {
        fgpu = {
          model          = "nvidia-p6"
          "k8s-operator" = true
        }
      }
    }
  }

  enable_quotas = true

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### Multiple Projects and Clusters

```hcl
module "oks" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-oks.git?ref=v0.2.0"

  projects = {
    dev  = { name = "dev-project",  cidr = "10.0.0.0/16", region = "eu-west-2" }
    prod = { name = "prod-project", cidr = "10.1.0.0/16", region = "eu-west-2" }
  }

  clusters = {
    dev = {
      name               = "dev-cluster"
      project_key        = "dev"
      kubernetes_version = "1.31"
      cidr_pods          = "10.91.0.0/16"
      cidr_service       = "10.92.0.0/16"
      admin_whitelist    = ["10.0.0.0/8"]
      enable_kubeconfig  = false
    }
    prod = {
      name               = "prod-cluster"
      project_key        = "prod"
      kubernetes_version = "1.31"
      cidr_pods          = "10.93.0.0/16"
      cidr_service       = "10.94.0.0/16"
      admin_whitelist    = ["203.0.113.0/24"]
    }
  }

  enable_quotas = true
}
```

## Security Considerations

1. Never use `0.0.0.0/0` in `admin_whitelist` for production environments
2. The `kubeconfigs` output is marked as `sensitive` to prevent accidental exposure
3. Enable API termination protection for production projects and clusters
4. State files contain kubeconfig in plaintext — use encrypted remote backends
5. See [SECURITY.md](SECURITY.md) for detailed security guidelines

## Known Limitations

1. The OKS API may still evolve
2. The module does not validate that `cidr`, `cidr_pods`, and `cidr_service` do not overlap
3. Node pools are applied with server-side apply; `terraform apply` returns once the NodePool object is accepted, not when its nodes are ready
4. OKS autoscaling is in beta — behavior may change

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_outscale"></a> [outscale](#requirement\_outscale) | ~> 1.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_outscale"></a> [outscale](#provider\_outscale) | ~> 1.8 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [outscale_oks_cluster.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/oks_cluster) | resource |
| [outscale_oks_manifest.nodepool](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/oks_manifest) | resource |
| [outscale_oks_project.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/oks_project) | resource |
| [outscale_oks_kubeconfig.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/data-sources/oks_kubeconfig) | data source |
| [outscale_oks_quotas.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/data-sources/oks_quotas) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Map of OKS clusters to create. Keys are logical identifiers. Each cluster references a project via project\_key | <pre>map(object({<br/>    name                              = string<br/>    project_key                       = string<br/>    kubernetes_version                = string<br/>    cidr_pods                         = string<br/>    cidr_service                      = string<br/>    admin_whitelist                   = list(string)<br/>    control_planes                    = optional(string, "cp.3.masters.small")<br/>    description                       = optional(string)<br/>    enable_cp_multi_az                = optional(bool, false)<br/>    enable_admin_lbu                  = optional(bool, false)<br/>    enable_api_termination_protection = optional(bool, false)<br/>    enable_kubeconfig                 = optional(bool, true)<br/>    kubeconfig_user                   = optional(string)<br/>    kubeconfig_group                  = optional(string)<br/>    kubeconfig_ttl                    = optional(string)<br/>    kubeconfig_x_encrypt_nacl         = optional(string)<br/>    tags                              = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_enable_quotas"></a> [enable\_quotas](#input\_enable\_quotas) | Enable retrieval of OKS account quotas data source | `bool` | `false` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Map of OKS node pools to create. Keys are logical identifiers. Each node pool references a cluster via cluster\_key | <pre>map(object({<br/>    name                = string<br/>    cluster_key         = string<br/>    node_type           = string<br/>    desired_nodes       = number<br/>    zones               = list(string)<br/>    min_nodes           = optional(number)<br/>    max_nodes           = optional(number)<br/>    enable_autoscaling  = optional(bool, false)<br/>    enable_auto_healing = optional(bool, false)<br/>    volumes = optional(list(object({<br/>      device = string<br/>      type   = string<br/>      size   = number<br/>      iops   = optional(number)<br/>      dir    = optional(string)<br/>    })), [])<br/>    extra_spec = optional(any, {})<br/>  }))</pre> | `{}` | no |
| <a name="input_projects"></a> [projects](#input\_projects) | Map of OKS projects to create. Keys are logical identifiers used to reference projects from clusters | <pre>map(object({<br/>    name                              = string<br/>    cidr                              = string<br/>    region                            = string<br/>    description                       = optional(string)<br/>    enable_api_termination_protection = optional(bool, false)<br/>    tags                              = optional(map(string), {})<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all OKS resources. Merged with module-managed tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_cni"></a> [cluster\_cni](#output\_cluster\_cni) | Map of cluster keys to their CNI plugins |
| <a name="output_cluster_dns"></a> [cluster\_dns](#output\_cluster\_dns) | Map of cluster keys to their DNS endpoints |
| <a name="output_cluster_ids"></a> [cluster\_ids](#output\_cluster\_ids) | Map of cluster keys to their IDs |
| <a name="output_cluster_names"></a> [cluster\_names](#output\_cluster\_names) | Map of cluster keys to their names |
| <a name="output_cluster_statuses"></a> [cluster\_statuses](#output\_cluster\_statuses) | Map of cluster keys to their current statuses |
| <a name="output_cluster_versions"></a> [cluster\_versions](#output\_cluster\_versions) | Map of cluster keys to their Kubernetes versions |
| <a name="output_kubeconfig_attributes"></a> [kubeconfig\_attributes](#output\_kubeconfig\_attributes) | Map of cluster keys to their API access attributes (host, cluster\_ca\_certificate, client\_certificate, client\_key) to configure the kubernetes/helm providers (only for clusters with enable\_kubeconfig = true) |
| <a name="output_kubeconfigs"></a> [kubeconfigs](#output\_kubeconfigs) | Map of cluster keys to their kubeconfig contents (only for clusters with enable\_kubeconfig = true) |
| <a name="output_nodepool_manifests"></a> [nodepool\_manifests](#output\_nodepool\_manifests) | Map of node pool keys to their generated YAML manifests |
| <a name="output_nodepool_names"></a> [nodepool\_names](#output\_nodepool\_names) | Map of node pool keys to their names |
| <a name="output_project_created_at"></a> [project\_created\_at](#output\_project\_created\_at) | Map of project keys to their creation timestamps |
| <a name="output_project_ids"></a> [project\_ids](#output\_project\_ids) | Map of project keys to their IDs |
| <a name="output_project_names"></a> [project\_names](#output\_project\_names) | Map of project keys to their names |
| <a name="output_project_statuses"></a> [project\_statuses](#output\_project\_statuses) | Map of project keys to their current statuses |
| <a name="output_project_updated_at"></a> [project\_updated\_at](#output\_project\_updated\_at) | Map of project keys to their last update timestamps |
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

Contributions are welcome. Changes are planned with [OpenSpec](https://github.com/Fission-AI/OpenSpec): `openspec/specs/` is the module's current contract and [AGENTS.md](AGENTS.md) routes to the engineering standards. Behaviour changes, new inputs, outputs or resources go through a change proposal (`/openspec-propose`) before any code. Run `mise run spec-setup` once per machine to register the standards stores. Please ensure your changes:

1. Pass `tofu fmt -check -recursive`
2. Pass `tofu validate`
3. Pass `tflint --recursive`
4. Pass `tofu test`
5. Pass `mise run spec-validate`
6. Include tests for new features
7. Update documentation as needed

## License

Apache 2.0 — see [LICENSE](LICENSE) for details.

## Disclaimer

This module is provided "as is" without warranty of any kind. Use at your own risk.

[apache]: https://opensource.org/licenses/Apache-2.0
[apache-shield]: https://img.shields.io/badge/License-Apache%202.0-blue.svg

[terraform-badge]: https://img.shields.io/badge/Terraform-%3E%3D1.10-623CE4
[terraform-url]: https://www.terraform.io

[provider-badge]: https://img.shields.io/badge/Outscale%20Provider-~%3E1.8-orange
[provider-url]: https://registry.terraform.io/providers/outscale/outscale/latest

[release-badge]: https://img.shields.io/gitlab/v/release/leminnov/terraform/modules/outscale-oks?include_prereleases&sort=semver
[release-url]: https://gitlab.com/leminnov/terraform/modules/outscale-oks/-/releases
