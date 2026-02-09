# Shape: Migrate from pipx to uv for oks-cli installation

## Appetite

Small batch — a targeted config change in `mise.toml`.

## Problem

The project uses `pipx` and an explicit `python = '3.13'` dependency in `mise.toml` to install `oks-cli`. This adds unnecessary weight:
- `python` is only needed as a runtime for pipx/oks-cli, not for project code
- `pipx` is slower than `uv` for package installation
- Two extra tools to manage when one (`uv`) can replace both

## Solution

Replace `python` + `pipx` with `uv` in `mise.toml`. Mise's `pipx:` backend already defaults to using `uvx` (from uv) when uv is installed, so the `"pipx:oks-cli"` entry stays as-is.

## Scope

### In scope
- Remove `python = '3.13'` from `mise.toml`
- Remove `pipx = 'latest'` from `mise.toml`
- Add `uv = 'latest'` to `mise.toml`
- Update the comment on the oks-cli line

### Out of scope
- CI pipeline changes (they use `mise install --yes` which adapts automatically)
- Changes to `pre-commit` setup (uses system python, unrelated)
- Any application code changes

## Decisions

1. **Keep `pipx:` backend prefix** — This is mise's backend identifier, not the actual tool. It automatically delegates to `uvx` when uv is available.
2. **Remove python entirely** — uv manages its own Python runtime; no separate python tool needed for oks-cli.
3. **Use `uv = 'latest'`** — Matches the project's pattern of using `latest` for tooling that should stay current.

## Risks

- Low risk: If a developer doesn't have uv and doesn't run `mise install`, the `pipx:` backend may fall back to pipx (which won't be installed). Mitigation: `mise install --yes` handles this automatically.
