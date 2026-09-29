---
applyTo: 'src/**'
---
# Source Code Conventions

This file is **shared**: copied unchanged into every math study repo from the hub
(`FourMInfo/math_tech_study`, `project_resources/instructions/`) and byte-identical everywhere.
This repo's module name, file layout, dependencies, function catalogue and conventions specific
to its subject are in `project.instructions.md` — read it before editing `src/`.

## Module Structure & Exports

The main module (`src/<Package>.jl`) uses `@reexport`, so that `using <Package>` alone gives
notebooks, tests and docs everything they need, and it exports every public function:

```julia
module MyPackage
using Reexport
@reexport using Plots, Symbolics, LaTeXStrings   # this repo's list: project.instructions.md

# Pure computational functions (no plotting dependencies)
export calculate_something
# Integrated plotting functions (computation + visualization)
export plot_something

include("mypackage_basic.jl")
end
```

- **Always export new public functions** from the main module.
- Keep `export` lines grouped by the two categories below, with a comment heading each.

## Headless Plotting

Tests set `ENV["GKSwstype"] = "100"` **before** loading the package (see
`testing.instructions.md`). Where a module configures the GR backend itself at load time, it
follows the canonical pattern in the `julia-coding-conventions` skill;
`project.instructions.md` says which applies here.

## Separate Computation from Plotting

Every plotted result has a pure computational function underneath it:

```julia
# Pure computational function (no plotting dependencies)
function calculate_something(args...)
    # ... mathematics only; errors here are real errors
    return result
end

# Integrated plotting function (computation + visualization)
function plot_something(args...)
    result = calculate_something(args...)
    try
        plot!(result)
    catch e
        !haskey(ENV, "CI") && @warn "Plotting failed: $e"
    end
    return result
end
```

- `calculate_*` functions have no plotting dependency and are tested directly.
- `plot_*` functions call the computational function, wrap only the plotting in `try`/`catch`,
  and return the computed result so tests can check it.
- How a plotting function should return and display its figure is covered by the
  `julia-figure-authoring` skill.

## Naming

- **Computational**: `calculate_*`; **plotting**: `plot_*`
- Descriptive suffixes for families of functions (e.g. `_matrix`, `_line`, `_roots`)
- `_symbolic` variants where a function has both a symbolic and a numeric form
- Parameter names follow standard mathematical notation (`θ` for angles, `v`/`w` for vectors,
  `p`/`q` for points, `f` for functions); Unicode names are welcome

## Documentation & Comments

- Every exported function has a docstring; the `documenter-jl-conventions` skill covers
  signature lines, LaTeX in docstrings and `@autodocs`
- Explain the mathematics in comments: the concept, the formula, and any convention a caller
  could get wrong (degrees vs radians, orientation, domain restrictions)
- Keep notation consistent with the repo's `docs/src/` pages
