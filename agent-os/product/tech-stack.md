# Tech Stack

## Infrastructure as Code

- Terraform (HCL)
- OpenTofu compatible

## Providers

- [outscale/outscale](https://registry.terraform.io/providers/outscale/outscale/latest) — pin version with pessimistic constraint (`~>`)
- Minimum provider version: v1.3.0 (OKS support)

## Testing

- Terraform native test framework (`*.tftest.hcl`)
- `terraform validate` and `terraform fmt` in CI

## Documentation

- terraform-docs for auto-generated module docs

## CI/CD

- GitLab CI (per repository conventions)

## Dependencies

- [terraform-outscale-networking](https://github.com/tf-outscale-modules/terraform-outscale-networking) — used in examples for VPC/subnet provisioning
