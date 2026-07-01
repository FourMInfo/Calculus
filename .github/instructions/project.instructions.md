---
applyTo: '**'
---
# Project Ecosystem Context

<!-- All values updated for Calculus repo -->

## What This Repository Is

This is **one subrepository** in a multi-repository Julia math study project. Understanding the broader ecosystem is essential before making changes, especially to CI, documentation configuration, or project structure.

## The Math & Tech Study Hub

The main website lives at **https://study.fourm.info** and is built with:
- **Franklin.jl** (Lanyon template) in a separate GitHub repository: `FourMInfo/math_tech_study`
- The main site handles the top-level domain, navigation, and study guides

Current subrepositories and their deployed URLs:
| Repository | Deployed URL |
|---|---|
| `FourMInfo/Linear_Algebra` | https://study.fourm.info/linear_algebra/ |
| `FourMInfo/Math_Foundations` | https://study.fourm.info/math_foundations/ |

Additional subrepositories (Calculus, etc.) will be added in the future following the same pattern.

## How This Repository Deploys

This repo uses **DrWatson.jl** for project structure and **Documenter.jl** for documentation.

### Deployment Flow

```
Push to main
    → CI.yml runs deploy-docs job
    → docs/make.jl builds Documenter site
    → deploydocs() cross-deploys to FourMInfo/math_tech_study (gh-pages branch)
    → Appears at study.fourm.info/calculus/
```

Key facts about `docs/make.jl`:
- `ENV["GITHUB_REPOSITORY"]` is **deliberately overridden** to `"FourMInfo/math_tech_study"` — this is what causes cross-repository deployment. Do NOT remove or change this.
- `dirname = "calculus"` in `deploydocs()` sets the subdirectory path. Do NOT change this.
- The `DOCUMENTER_KEY` secret is a deploy key for the `math_tech_study` repository (not this one).

### CI Behaviour

The `.github/workflows/CI.yml` has three jobs:
1. **test** — runs only on PRs and manual triggers (`workflow_dispatch`), not on pushes to main
2. **docs-build** — builds (but does not deploy) docs on PRs where `src/` or `docs/` changed
3. **deploy-docs** — runs on push to main or manual trigger; this is the job that deploys to the site

**CRITICAL**: The `workflow_dispatch` trigger on CI.yml must be preserved. When the Franklin main site redeploys, it can overwrite all subdirectory documentation. The manual trigger allows recovery by redeploying this repo's docs without a code change.

## Why DrWatson

DrWatson is used for **project reproducibility and structure**, not primarily for data management. It provides:
- `Project.toml` / `Manifest.toml` for exact Julia environment pinning
- Standard directory layout (`src/`, `test/`, `docs/`, `notebooks/`, `scripts/`, `data/`, `papers/`, `plots/`)
- `quickactivate` integration in notebooks and scripts

Do NOT remove DrWatson or restructure the directory layout — the CI and docs build depend on it.

## Critical Constraints — Do NOT Do These

| Action | Why It Is Dangerous |
|---|---|
| Enable GitHub Pages on this repository | Only `math_tech_study` may have GitHub Pages with the custom domain. Enabling it here will break the domain |
| Change or remove the `ENV["GITHUB_REPOSITORY"]` override in `docs/make.jl` | Deployment will target the wrong repository |
| Change `dirname` in `deploydocs()` | The subdirectory path on the live site will break |
| Remove `workflow_dispatch` from CI.yml | Loses ability to manually recover docs after Franklin site redeploy |
| Change the `DOCUMENTER_KEY` secret value without also updating the deploy key in `math_tech_study` | Deployment will fail with authentication errors |
| Reorder or remove jobs in CI.yml without understanding the `needs: test` dependency | Deploy job depends on test passing |

## Relationship to the Main Franklin Site

The main `math_tech_study` repo's GitHub Actions workflow has a **backup/restore mechanism** that preserves subdirectory docs when the Franklin site redeploys. If you add a new subrepository to the ecosystem in the future, the Franklin workflow in `math_tech_study` must be updated to include the new subdirectory name in both its backup and restore steps.

## Local Documentation Preview

```bash
# Build docs locally (does not deploy)
julia --project=. docs/make.jl

# The built site is in docs/build/ — open docs/build/index.html in a browser
```
