---
applyTo: '**'
---
# Calculus — Repository-Specific Instructions

This file is **this repo's own**: it holds everything specific to this repository and is never
overwritten by propagation from the hub. It can be as detailed as the repo needs. The shared
conventions every study repo follows are in the other files in `.github/instructions/`
(`ecosystem`, `source`, `testing`, `docs`, `notebooks`), which are copied unchanged from
`FourMInfo/math_tech_study/project_resources/instructions/` and must never be edited here. A
learning that holds for every study repo goes into those hub templates, not into this file.

## This Repository

| | |
|---|---|
| GitHub | `FourMInfo/Calculus` |
| Deployed at | `https://fourm.info/calculus/` |
| `dirname` in `docs/make.jl` | `"calculus"` |
| Subject | Calculus: derivatives, integrals, limits, series and applications |

## Package and Module

- **Main module**: `src/Calculus.jl`
- **Source files**: `src/calculus_basic.jl` (not yet populated or included)
- **Reexported packages**: `CalculusWithJuliaSquared` (CWJS) only. CWJS in turn reexports
  `Plots`, `Symbolics`, `Roots`, `LinearAlgebra`, `SpecialFunctions`, `IntervalSets` and
  `LaTeXStrings`, so `using Calculus` brings all of them. What CWJS itself provides, how it is
  installed and how to update it: "What CalculusWithJuliaSquared Provides" in
  `.github/copilot-instructions.md`.
- **Headless plotting**: CWJS configures the GR backend at its own load time (the canonical
  `julia-coding-conventions` pattern lives there), so this module does no GR configuration.
  Tests still set `GKSwstype` before loading, as the shared testing conventions say.

## Dependencies

- **Never add `Plots` or `SymPy` directly** — plotting and symbolic maths come through CWJS,
  which exists to keep Python out.
- CWJS is unregistered and installed by GitHub URL through `[sources]` in `Project.toml`; keep that
  section intact.
- **Check CWJS before writing a new function** — it may already exist (`riemann_plot`, `plotif`,
  `tangent`, `lim`, …).

## Subject-Specific Conventions

### Function Categories (planned)

- **Differentiation**: derivatives, partial derivatives, gradients
- **Integration**: definite and indefinite integrals, numerical methods
- **Limits**: numerical limit evaluation
- **Series**: Taylor series, convergence

### Naming

Parameter names follow standard calculus notation (`f` for functions, `a`, `b` for interval
endpoints, `h` for step size, `n` for sample counts).

## Tests

- **Test files**: `test_calculus_basics.jl` — currently a placeholder, to be replaced as functions
  are implemented

## Notebooks

Setup cell for this repo:

```julia
using Revise
using Calculus
```

- Prefer CWJS's ready-made plotting recipes (`plotif`, `riemann_plot`, `plot_parametric`,
  `vectorfieldplot`, …) and this package's own plotting functions before writing new ones.
- `notebooks/Project.toml` also lists **Latexify**. `using Calculus` already loads it (CWJS
  depends on it), which activates Symbolics' `SymbolicsLatexifyExt`, so symbolic output is
  typeset with no extra line. Add `using Latexify` only to call `latexify(...)` by name.
