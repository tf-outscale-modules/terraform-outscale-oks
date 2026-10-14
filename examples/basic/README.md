# Basic Example

Single OKS project and cluster with minimal configuration.

## Prerequisites

- [OpenTofu](https://opentofu.org/) >= 1.10 or [Terraform](https://www.terraform.io/) >= 1.10
- An Outscale account with OKS access enabled
- Outscale credentials configured via environment variables or `~/.osc/config.json`

### Credentials

Set the following environment variables before running:

```bash
export OSC_ACCESS_KEY="your-access-key"
export OSC_SECRET_KEY="your-secret-key"
export OSC_REGION="eu-west-2"
```

Or use an [Outscale CLI configuration file](https://docs.outscale.com/en/userguide/Installing-and-Configuring-OSC-CLI.html).

## What This Creates

- 1 OKS Project with a `/16` network
- 1 OKS Cluster with default control plane sizing (`cp.3.masters.small`)
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
chmod 600 kubeconfig.yaml
export KUBECONFIG=kubeconfig.yaml
kubectl get nodes
```

> **Security note:** The kubeconfig file contains sensitive credentials. Never commit it to version control. Add `kubeconfig.yaml` to your `.gitignore`.

## Clean Up

```bash
rm -f kubeconfig.yaml
tofu destroy
```
