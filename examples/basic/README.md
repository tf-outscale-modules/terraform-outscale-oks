# Basic Example

Single OKS project and cluster with minimal configuration.

## What This Creates

- 1 OKS Project with a `/16` network
- 1 OKS Cluster with default control plane sizing
- 1 Kubeconfig retrieval for cluster access

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
