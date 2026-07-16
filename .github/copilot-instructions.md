# Copilot Instructions for Calculus

> **Note:** Context-specific instructions (docs, testing, source, notebooks) are in `.github/instructions/` and load automatically based on the file being edited.

## Project Overview

**Julia calculus study project** using a Julia workspace for reproducibility. Implements calculus topics (derivatives, integrals, limits, series, and applications) with comprehensive testing and cross-repository documentation deployment.

### Core Architecture

- **`src/Calculus.jl`**: Main module; uses `@reexport` to re-export `CalculusWithJuliaSquared` and `LaTeXStrings` — consumers get all exported names with a single `using Calculus`
- **`test/`**: Tests using `Calculus` and `Test` only — re-exported names are available via `@reexport`, no explicit `using` needed in test files
- **`docs/`**: Documenter.jl deploying to `https://study.fourm.info/calculus/` (cross-repo to `math_tech_study`)
- **`notebooks/`**: Jupyter notebooks for exploration (not tested in CI)

### What CalculusWithJuliaSquared Provides

[`CalculusWithJuliaSquared`](https://github.com/FourMInfo/CalculusWithJuliaSquared.jl) is a personal, pure-Julia (zero-Python) fork of `CalculusWithJulia.jl`, installed **from its GitHub URL** (it's unregistered — the Manifest pins `repo-url`, tracking `master`). It reexports `Plots`, `Symbolics`, `Roots`, `LinearAlgebra`, `SpecialFunctions`, and `IntervalSets`, and auto-configures the GR backend for headless CI at load time — so this repo needs **no direct `Plots` dependency and no GKS setup of its own**. Available after `using Calculus`:

- **Plotting recipes**: `plotif`, `trimplot`, `signchart`, `plot_parametric`(`!`), `plot_polar`(`!`), `implicit_plot`(`!`), `vectorfieldplot`(`3d`), `arrow`(`!`), `riemann_plot`(`!`), `newton_plot!`, `plot_implicit_surface`
- **Calculus utilities**: `riemann` (8 methods), `fubini`, `lim` (limit tables), `sign_chart`, `tangent`, `secant`, `D` and the `f'` prime notation (via ForwardDiff), `unzip`, `rangeclamp`, `const e`
- **Symbolic math** (pure Julia): `@variables` etc. via Symbolics, plus symbolic `gradient`/`divergence`/`curl` for `Symbolics.Num`; `∇`, `∇⋅`, `∇×` operators work numerically and symbolically
- **Root finding**: `fzero`/`fzeros` via Roots

To update to a newer CWJS commit: `julia --project=. -e 'using Pkg; Pkg.update("CalculusWithJuliaSquared")'`. Never re-add `Plots`/`SymPy` directly here — plotting comes through CWJS, and CWJS's whole purpose is keeping Python out.

## Julia Workspace Layout

This repository uses a Julia workspace. The root `Project.toml` has a `[workspace]` table listing
member environments. Each member has its own `Project.toml` and `Manifest.toml`:

| Path | Purpose |
|---|---|
| `Project.toml` | Root package — defines `Calculus` as a library (uuid `dfd5a24e-f5d9-431d-8566-d266db9d2854`) |
| `test/Project.toml` | Test-only deps (`Calculus`, `Test`) — workspace member |
| `docs/Project.toml` | Docs deps (`Documenter`, `Dates`, `LiveServer`, `Calculus`) — workspace member; uses `Pkg.develop(path=".")`. `LiveServer` is for local live preview (see the `documenter-jl-conventions` skill) |
| `notebooks/Project.toml` | Notebook superset (`IJulia`, `Revise`, `Calculus`) — **not** a workspace member |

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

## Julia Compilation Considerations

- **Be Patient with First Runs**: Julia often needs to precompile packages on first run; allow 15–30 seconds before tests actually start
- **Example Expected Output**: `Precompiling Calculus... N dependencies successfully precompiled in 17 seconds`
- **Subsequent Runs**: Much faster once cache is built
- **Don't Cancel Early**: Allow time for compilation to complete

## Git Best Practices

- **Never use `git add .`** - Always stage files explicitly by name to avoid accidentally committing development files, notebooks, or temporary files
- Use `git add <specific-file-path>` to stage only the intended files for commit
- **Feature branch naming**: Use descriptive, purpose-driven names:
  - ✅ Good: `milestone/calculus-repo-setup-phase-1`, `fix/sidebar-center-alignment`
  - ❌ Avoid: `feature/update-content`, `fix/stuff`, `branch1`

### Pull Request Creation

- **ALWAYS check all commits on the branch first**: Run `git log main..HEAD --oneline` before writing the PR description
- **ALWAYS push changes first**: Use `git push origin BRANCH_NAME` before creating PR
- **Do NOT use `gh pr create`** - The GitHub CLI command doesn't work properly in this environment
- **Use GitHub web interface with URL parameters**:
  ```
  https://github.com/FourMInfo/Calculus/compare/main...BRANCH_NAME?title=Your+PR+Title&body=Your+PR+Description
  ```
- **Always provide fallback copy-paste content**: Include separate, copyable title and description in case URL parameters don't work

## Azure Integration

- Use Azure Best Practices: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your `azure_development-get_best_practices` tool if available

## Communication Patterns

- Avoid being overly obsequious in responses
    - do not tell me "I am happy to help" or similar phrases
    - do not tell me how amazing I am or how great my work is
    - do not say something is "awesome" or "fantastic" unless it is truly exceptional
    - do not use overly emotional language
    - do not use words like "wonderful" or "great" to describe my work
    - do not use words like "perfect" or "flawless" to describe my work
- When asked to analyze a bug or problem first lay out the problem clearly, then suggest potential solutions or debugging steps and let the user decide on the next steps
- Never say "I see what the problem is" or similar phrases that imply you have fully understood the issue without further discussion and confirmation that you have understood the issue
- Always provide clear, actionable suggestions for next steps in debugging or implementation
    - Acknowledge when you need more information or clarification before proceeding
    - Summarize the current understanding of the issue before discussing potential solutions
    - Document any assumptions made during the analysis
    - Identify any knowledge gaps or areas requiring further investigation
- Notify user immediately if you cannot read a file they provided (e.g., PDFs, binary files) instead of silently substituting other files or faking understanding of the content
- If you are unsure about a solution, clearly state that more information is needed or that further investigation is required
- When providing code examples, ensure they are clear, concise, and directly relevant to the problem at hand
    - Avoid unnecessary complexity in code examples
    - Use comments to explain key parts of the code where necessary
    - Ensure code examples are formatted correctly for readability
- If you find yourself repeating steps stop and explain why you are repeating them and ask if the user would like to proceed with the same steps again
- Always ask for confirmation before proceeding with potentially destructive actions, such as deleting files or making significant changes to the codebase
- When discussing code changes, clearly outline the impact of those changes on the overall project
    - Discuss how changes align with project goals and coding standards
    - Highlight any potential risks or trade-offs associated with the changes
- If you encounter a situation where you need to make assumptions, clearly state those assumptions and their implications
- When discussing project architecture or design decisions, provide a rationale for each decision made
- If you need to reference external resources or documentation, provide clear links and context for their relevance
- Always strive for clarity and precision in communication, especially when discussing technical details
- If you need to ask for clarification, do so in a way that encourages open dialogue and collaboration
- When providing feedback on code or design, focus on constructive criticism that helps improve the overall quality
