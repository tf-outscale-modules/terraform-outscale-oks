# Phase 1 MVP: OKS Terraform Module — Shaping Notes

## Scope

Building the Phase 1 MVP from the product roadmap: a complete Terraform module for Outscale Kubernetes Service (OKS) that provisions projects, clusters, and retrieves credentials and quotas.

## Decisions

- Single flat module (not sub-modules) — Project and Cluster are tightly coupled
- Domain-split files following terraform-outscale-networking patterns
- Provider version pinned to ~> 1.3 (OKS introduced in v1.3.0-alpha.1)
- Kubeconfig output marked sensitive
- Quotas data source opt-in (default disabled)
- Boolean flags use `enable_*` prefix per naming standard
- Tag merging follows common_tags + resource-specific tags pattern
- Tests use `command = plan` only (no real infrastructure)

## Context

- **Visuals:** None
- **References:** terraform-outscale-networking module (GitHub)
- **Product alignment:** Directly implements Phase 1 MVP from `agent-os/product/roadmap.md`
- **OKS API docs:** https://docs.outscale.com/oks.html

## Standards Applied

- All 14 standards from agent-os/standards/ apply (greenfield module)
- See standards.md for full references
