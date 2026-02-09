# Plan: Migrate from pipx to uv for oks-cli installation

## Context

The project currently uses `pipx` (via mise) to install `oks-cli`. The user wants to switch to `uv` as the Python package installer, which is faster and can manage its own Python runtime. This also allows removing the explicit `python` dependency from `mise.toml`.

**Key finding:** Mise's `pipx:` backend [already defaults to using `uvx`](https://mise.jdx.dev/dev-tools/backends/pipx.html) if `uv` is installed. The `pipx:` prefix in mise.toml is the **backend name**, not the actual tool — so we keep `"pipx:oks-cli"` but replace the underlying installer from `pipx` to `uv`.

## Changes

### Task 1: Save Spec Documentation

Create `agent-os/specs/2026-02-09-1900-pipx-to-uv-migration/` with:
- `plan.md` — This plan
- `shape.md` — Shaping notes (scope, decisions, context)
- `references.md` — Pointers to reference implementations
- `standards.md` — Relevant standards (none specific to this change)

### Task 2: Update mise.toml

**File:** `mise.toml`

Replace the pipx/python tool entries:

```toml
# Before (lines 14-17):
python = '3.13'
pipx = 'latest'
# Install oks-cli via pipx
"pipx:oks-cli" = "latest"

# After:
uv = 'latest'
# Install oks-cli via uv (mise's pipx backend uses uvx when uv is available)
"pipx:oks-cli" = "latest"
```

Key changes:
- Remove `python = '3.13'` — uv manages its own Python, no longer needed for oks-cli
- Remove `pipx = 'latest'` — replaced by uv
- Add `uv = 'latest'` — mise has native support for uv as a tool
- Keep `"pipx:oks-cli" = "latest"` — the `pipx:` backend prefix automatically uses `uvx` when uv is available (this is mise's default behavior, controlled by `pipx.uvx` setting which defaults to `true`)

### Task 3: Verify — no other file changes needed

- **CI pipelines** (`.gitlab/pre-commit.yml`, `.gitlab/release.yml`): Use `mise install --yes` which automatically picks up the new config. No changes needed.
- **`mise.local.toml`**: Only contains env vars and commented oks-cli usage examples. No pipx references.
- **`pre-commit.yml`** still installs `python3 python3-pip` via apt-get — this is for `pre-commit` itself, not for oks-cli.

## Files Modified

| File | Action |
|------|--------|
| `mise.toml` | Remove python/pipx, add uv |
| `agent-os/specs/2026-02-09-1900-pipx-to-uv-migration/` | Create spec documentation |

## Verification

1. Run `mise install --yes` locally to confirm uv and oks-cli install correctly
2. Run `oks-cli --help` to verify the tool is available
3. Optionally run the CI pipeline to ensure it passes
