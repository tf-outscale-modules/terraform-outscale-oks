# Complete Example

Production-grade OKS deployment demonstrating all module features with the [terraform-outscale-networking](https://github.com/tf-outscale-modules/terraform-outscale-networking) module for VPC provisioning.

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.10 or [Terraform](https://www.terraform.io/) >= 1.10
- An Outscale account with OKS access enabled
- Outscale credentials configured via environment variables or `~/.osc/config.json`

### Credentials

Set the following environment variables before running:

```bash
export OUTSCALE_ACCESSKEYID="your-access-key"
export OUTSCALE_SECRETKEYID="your-secret-key"
export OUTSCALE_REGION="eu-west-2"
```

Or use an [Outscale CLI configuration file](https://docs.outscale.com/en/userguide/Installing-and-Configuring-OSC-CLI.html).

## What This Creates

- 1 VPC with 2 private subnets across 2 availability zones (via networking module)
- 1 OKS Project with API termination protection
- 1 OKS Cluster with:
  - Medium control plane sizing (`cp.3.masters.medium`)
  - Multi-AZ deployment
  - Admin load balancer
  - API termination protection
  - 24h kubeconfig TTL
- Account quota retrieval
- Custom tags per resource (global, project-specific, and cluster-specific)

## Usage

```bash
tofu init
tofu plan
tofu apply
```

## Access the Cluster

```bash
tofu output -raw kubeconfig > kubeconfig.yaml
chmod 600 kubeconfig.yaml
export KUBECONFIG=kubeconfig.yaml
kubectl get nodes
```

> **Security note:** The kubeconfig file contains sensitive credentials. Never commit it to version control. Add `kubeconfig.yaml` to your `.gitignore`.

## Disabling Termination Protection for Destroy

API termination protection is enabled in this example. To destroy, first disable it:

```bash
tofu apply -var='enable_project_api_termination_protection=false' -var='enable_cluster_api_termination_protection=false'
tofu destroy
```

## Clean Up

```bash
rm -f kubeconfig.yaml
tofu destroy
```
