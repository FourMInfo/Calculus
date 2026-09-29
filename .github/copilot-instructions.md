# Copilot Instructions for Calculus

> **Note:** Context-specific instructions (docs, testing, source, notebooks) are in `.github/instructions/` and load automatically based on the file being edited.

## Project Overview

**Julia calculus study project** using a Julia workspace for reproducibility. Implements calculus topics (derivatives, integrals, limits, series, and applications) with comprehensive testing and cross-repository documentation deployment.

### Core Architecture

- **`src/Calculus.jl`**: Main module; uses `@reexport` to re-export `CalculusWithJuliaSquared` (which brings `LaTeXStrings` and the rest with it) — consumers get all exported names with a single `using Calculus`
- **`test/`**: Tests using `Calculus` and `Test` only — re-exported names are available via `@reexport`, no explicit `using` needed in test files
- **`docs/`**: Documenter.jl deploying to `https://fourm.info/calculus/` (cross-repo to `math_tech_study`)
- **`notebooks/`**: Jupyter notebooks for exploration (not tested in CI)

### What CalculusWithJuliaSquared Provides

[`CalculusWithJuliaSquared`](https://github.com/FourMInfo/CalculusWithJuliaSquared.jl) is a personal, pure-Julia (zero-Python) fork of `CalculusWithJulia.jl`. It's **unregistered**, so its GitHub URL is declared in `Project.toml`'s `[sources]` section — required because Manifests are gitignored here, and without `[sources]` a clean clone (e.g. CI) tries the General registry and fails. Keep that section intact. It reexports `Plots`, `Symbolics`, `Roots`, `LinearAlgebra`, `SpecialFunctions`, `IntervalSets`, and `LaTeXStrings`, and auto-configures the GR backend for headless CI at load time — so this repo needs **no direct `Plots` dependency and no GKS setup of its own**. Available after `using Calculus`:

- **Plotting recipes**: `plotif`, `trimplot`, `signchart`, `plot_parametric`(`!`), `plot_polar`(`!`), `implicit_plot`(`!`), `vectorfieldplot`(`3d`), `arrow`(`!`), `riemann_plot`(`!`), `newton_plot!`, `plot_implicit_surface`
- **Calculus utilities**: `riemann` (8 methods), `fubini`, `lim` (limit tables), `sign_chart`, `tangent`, `secant`, `D` and the `f'` prime notation (via ForwardDiff), `unzip`, `rangeclamp`, `const e`
- **Symbolic math** (pure Julia): `@variables` etc. via Symbolics, plus symbolic `gradient`/`divergence`/`curl` for `Symbolics.Num`; `∇`, `∇⋅`, `∇×` operators work numerically and symbolically
- **Root finding**: `fzero`/`fzeros` via Roots

To update to a newer CWJS commit: `julia --project=. -e 'using Pkg; Pkg.update("CalculusWithJuliaSquared")'` — **but first widen `[compat] CalculusWithJuliaSquared` in `Project.toml` to admit the new version, or that command silently does nothing.** Manifests are gitignored here, so the compat bound is the only thing pinning a version, and when it is too tight nothing errors: the resolver just keeps the old release and the new API is simply absent. That is how this repo sat on v0.5.2 from CWJS v0.6.0 through v0.7.0, with `symlim`/`tlim` invisible to `using Calculus` and missing from the published API docs — no error, no symptom beyond a function that "should exist" not existing. Bump it for **patch releases too**, not only minors. `"0.8"` *admits* 0.8.1 but does not *require* it: a fresh resolve picks the newest and is fine, while an existing checkout with its gitignored Manifest sits on 0.8.0 indefinitely, with nothing forcing it forward and no error. Pinning `"0.8.1"` makes 0.8.0 stop satisfying the bound, which is the only forcing function available — and a patch release is exactly when you want it, since patches exist to fix regressions. Useful side effect: `Project.toml` is in the path filter that triggers the docs deploy, so the same one-line bump both fixes resolution and republishes the API page. Never re-add `Plots`/`SymPy` directly here — plotting comes through CWJS, and CWJS's whole purpose is keeping Python out.

## Julia Workspace Layout

This repository uses a Julia workspace. The root `Project.toml` has a `[workspace]` table listing
member environments. Each member has its own `Project.toml` and `Manifest.toml`:

| Path | Purpose |
|---|---|
| `Project.toml` | Root package — defines `Calculus` as a library (uuid `dfd5a24e-f5d9-431d-8566-d266db9d2854`) |
| `test/Project.toml` | Test-only deps (`Calculus`, `Test`) — workspace member |
| `docs/Project.toml` | Docs deps (`Documenter`, `Dates`, `LiveServer`, `Calculus`) — workspace member; uses `Pkg.develop(path=".")`. `LiveServer` is for local live preview (see the `documenter-jl-conventions` skill) |
| `notebooks/Project.toml` | Notebook superset (`IJulia`, `Revise`, `Calculus`, `Latexify`) — **not** a workspace member |

The `notebooks/` environment is intentionally excluded from the workspace `projects` list because
it is a developer-only interactive environment, not a dependency of any other member.

All `Manifest.toml` files are gitignored. They are regenerated locally by `Pkg.instantiate()`.
The `notebooks/Manifest.toml` requires an additional one-time step — see [Notebook Setup](#notebook-setup) below.

### Adding a New Workspace Member

If you add a new subdirectory environment (e.g. `scripts/`):
1. Create `scripts/Project.toml` with a `name`, `uuid` (generated via `uuidgen`), and `[deps]`
2. Add `"scripts"` to the `projects` list in the root `Project.toml` `[workspace]` table
3. Never hard-code UUIDs — always generate them with `uuidgen` on the command line

### Project.toml Header Convention

Every named `Project.toml` (root and workspace members that are packages) must have:

```toml
name = "PackageName"
uuid = "<output of uuidgen>"
version = "0.1.0"
```

Non-package member environments (like `test/` and `docs/`) do not need `name`/`uuid`.

## Key Workflows

### Local Development

```bash
# Run tests (uses test/ workspace member environment)
julia --project=. -e 'using Pkg; Pkg.test()'

# Build documentation (uses docs/ workspace member environment)
julia --project=docs docs/make.jl
```

**IMPORTANT**: Always run `julia --project=docs docs/make.jl` after making changes to documentation files in `docs/src/`. This allows the user to preview changes in the browser immediately without running the build manually.

### Notebook Setup

`notebooks/` is not a workspace member, so `Calculus` is not auto-resolved. After cloning (or after removing `notebooks/Manifest.toml`), run once in the notebooks directory:

```julia-repl
# Start Julia with the notebooks project
julia --project=./notebooks

# Then in the REPL Pkg mode (press ])
pkg> dev ..
pkg> instantiate
```

This creates `notebooks/Manifest.toml` (gitignored) with `path = ".."` pointing at the root package. Subsequent `julia --project=./notebooks` invocations will resolve `Calculus` from the local source.

## Git Best Practices

- **Never use `git add .`** - Always stage files explicitly by name to avoid accidentally committing development files, notebooks, or temporary files
- Use `git add <specific-file-path>` to stage only the intended files for commit
- **Feature branch naming**: Use descriptive, purpose-driven names:
  - ✅ Good: `milestone/calculus-repo-setup-phase-1`, `fix/sidebar-center-alignment`
  - ❌ Avoid: `feature/update-content`, `fix/stuff`, `branch1`

### Pull Request Creation

- **ALWAYS check all commits on the branch first**: Run `git log main..HEAD --oneline` before writing the PR description
- **ALWAYS push changes first**: Use `git push origin BRANCH_NAME` before creating PR
- **`gh` works here** — `gh pr create --repo FourMInfo/Calculus` is the normal route (verified 2026-09-28). Always pass `--repo` explicitly; see the `phased-implementation-workflow` skill for the branch → PR → squash-merge → prune sequence
- **Fallback if `gh` is unavailable**: open the compare URL in a browser, with title and body as parameters
  ```
  https://github.com/FourMInfo/Calculus/compare/main...BRANCH_NAME?title=Your+PR+Title&body=Your+PR+Description
  ```
  Supply a separate copy-paste title and description as well, in case the URL parameters do not populate

## Communication Patterns

> **Copilot mirror.** Claude Code gets these rules from the global `~/.claude/CLAUDE.md`
> (canonical: `Dotfiles.Mac/Files/claude/CLAUDE.md`), which is the source of truth. Copilot has no
> global-instructions equivalent, so the essentials are restated here. Keep the two in step.

- No obsequiousness: no "happy to help", no praise of my work ("amazing", "awesome", "perfect", "flawless"), no emotional language
- Lay the problem out before proposing a fix, and never claim to have grasped an issue ("I see what the problem is") before that is confirmed
- Say when you need more information rather than guessing, and state any assumption you are working from
- Say immediately if you cannot read a file you were given — never substitute another file or infer its contents
- If you find yourself repeating steps, stop, explain why, and ask before repeating them
- Ask for confirmation before destructive actions or significant structural changes
