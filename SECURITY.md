# Security

## Kubeconfig Credentials

The kubeconfig output contains sensitive cluster credentials (tokens, certificates). This module marks the `kubeconfig` output as `sensitive = true` to prevent accidental exposure in logs and terminal output.

- Never log or display kubeconfig content in CI/CD pipelines
- Access kubeconfig via `terraform output -raw kubeconfig` only when needed
- Rotate kubeconfig credentials regularly using the `kubeconfig_ttl` variable

## Admin Whitelist

The `admin_whitelist` variable controls which CIDR blocks can access the Kubernetes API server.

- Never use `0.0.0.0/0` in production environments
- Restrict to known IP ranges (office, VPN, CI/CD runners)
- Review and update the whitelist regularly

## API Termination Protection

For production clusters, enable API termination protection to prevent accidental deletion:

```hcl
enable_project_api_termination_protection = true
enable_cluster_api_termination_protection = true
```

## State Security

Terraform state files contain the kubeconfig in plaintext when `enable_kubeconfig = true`.

- Always use encrypted remote backends for state storage
- Restrict access to state storage (S3 bucket policies, IAM roles)
- Never commit `.tfstate` or `.tfstate.backup` files to version control
- Consider setting `enable_kubeconfig = false` and retrieving credentials separately if state security is a concern

## What lands in state

| Data | Where | Mitigation |
|------|-------|------------|
| Kubeconfig (tokens, certificates) | `data.outscale_oks_kubeconfig` in state, sensitive `kubeconfigs` and `kubeconfig_attributes` outputs | Encrypted remote backend; `enable_kubeconfig = false` |
| `node_pools[*].extra_spec` | NodePool manifest in plan and state, **non-sensitive** `nodepool_manifests` output | Never put a password, token or key in `extra_spec`; a `check` warns on secret-looking keys or values (heuristic, not a guarantee) |

`nodepool_manifests` is intentionally not sensitive (a NodePool spec carries no secret, and marking it sensitive would break consumers that re-export it). Treat everything passed in `extra_spec` as public to anyone who can read the plan, the state or the module outputs.

## Reporting Vulnerabilities

If you discover a security vulnerability, please report it responsibly by contacting the maintainers directly rather than opening a public issue.
