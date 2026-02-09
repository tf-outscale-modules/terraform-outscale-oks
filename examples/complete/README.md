# Complete Example

Production-grade OKS deployment demonstrating all module features with the [terraform-outscale-networking](https://github.com/tf-outscale-modules/terraform-outscale-networking) module for VPC provisioning.

## What This Creates

- 1 VPC with 2 private subnets across 2 availability zones (via networking module)
- 1 OKS Project with API termination protection
- 1 OKS Cluster with:
  - Medium control plane sizing
  - Multi-AZ deployment
  - Admin load balancer
  - API termination protection
  - 24h kubeconfig TTL
- Account quota retrieval
- Custom tags per resource

## Prerequisites

- Outscale account with OKS access
- Outscale provider credentials configured

## Usage

```bash
tofu init
tofu plan
tofu apply
```

## Access the Cluster

```bash
tofu output -raw kubeconfig > kubeconfig.yaml
export KUBECONFIG=kubeconfig.yaml
kubectl get nodes
```

## Clean Up

```bash
tofu destroy
```
