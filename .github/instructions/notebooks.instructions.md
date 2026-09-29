---
applyTo: 'notebooks/**'
---
# Notebook Conventions

This file is **shared**: copied unchanged into every math study repo from the hub
(`FourMInfo/math_tech_study`, `project_resources/instructions/`) and byte-identical everywhere.
This repo's exact setup cell and any notebook-only display packages are in
`project.instructions.md`.

## Setup Pattern

Every notebook starts with a setup cell of this shape:

```julia
using Revise
using MyPackage
```

`using <Package>` provides everything the module reexports (plotting, symbolic maths,
`LaTeXStrings` and the `L"..."` macro, …). A package that lives **only** in
`notebooks/Project.toml` is not reexported by the module and needs its own `using` line in the
setup cell — `project.instructions.md` lists any this repo has.

## Notebook Environment

- The `notebooks/` environment is **not** a workspace member — run `pkg> dev ..` +
  `pkg> instantiate` once after cloning. See the `julia-coding-conventions` skill for the full
  pattern. Do not commit `notebooks/Manifest.toml`.
- Notebooks are for exploration and study; they are not tested in CI.

## Notebook Guidelines

- Use `println()` for output, so results stay clear when cells are re-run
- Include explanatory markdown cells between code cells
- Use Unicode variable names consistent with the source code (e.g. `v₁`, `θ`, `λ`)
- Reference the documentation sections being studied

## Plotting in Notebooks

- Plots render inline; no headless configuration is needed
- Use the package's own plotting functions (`plot_*`) before writing new plotting code
- How figures display in notebooks, docs and the REPL alike is covered by the
  `julia-figure-authoring` skill

## Math Rendering: KaTeX, not MathJax

Jupyter renders math with **KaTeX**, which supports `\tag{...}` but **not** `\label{...}`. Never
emit `\label` in notebook output — it produces a parse error. `\label` is valid only where the
math is rendered by full LaTeX or MathJax (e.g. Documenter.jl docs).

## Julia Kernel Gotchas

See the `julia-coding-conventions` skill (stale variable slot, building a matrix from row
vectors).
