# Product Roadmap

## Phase 1: MVP

Full OKS stack with production-ready defaults:

- **OKS Project** — `outscale_oks_project` resource with configurable name, CIDR, region, description, and tags
- **OKS Cluster** — `outscale_oks_cluster` resource with Kubernetes version selection, pod/service CIDRs, admin whitelist, control plane sizing, and multi-AZ support
- **Kubeconfig output** — `outscale_oks_kubeconfig` data source for retrieving cluster credentials
- **Quotas data source** — `outscale_oks_quotas` data source for account quota visibility
- **Example with networking** — Complete example using [terraform-outscale-networking](https://github.com/tf-outscale-modules/terraform-outscale-networking) module for VPC/subnet provisioning

## Phase 2: Node Pools & GPU

- Node pool management with configurable instance types and scaling
- GPU (fGU) support for ML/AI workloads
- Auto-scaling configuration

## Phase 3: Advanced Networking

- Network peering between OKS projects and existing VPCs
- IP pool management
- Load balancer integration within OKS clusters

## Phase 4: Operations

- Cluster upgrade automation
- Cluster logging configuration
- Maintenance window scheduling
- Admission controller configuration
