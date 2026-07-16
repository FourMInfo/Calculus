---
applyTo: 'src/**'
---
# Source Code Conventions

## Module Structure & Exports

All code uses `@reexport` pattern and exports both computational + plotting functions:

```julia
# Main module uses @reexport for clean interface
using Reexport
@reexport using CalculusWithJuliaSquared, LaTeXStrings

# Pure computational functions (no plotting dependencies)
export calculate_derivative, calculate_integral

# Integrated plotting functions (computation + visualization)
export plot_function, plot_derivative
```

`CalculusWithJuliaSquared` brings `Plots`, `Symbolics`, `Roots`, `LinearAlgebra`, `SpecialFunctions`, and `IntervalSets` with it, plus ready-made calculus utilities and plotting recipes (see the "What CalculusWithJuliaSquared Provides" section in `copilot-instructions.md`). **Check there before writing a new function — it may already exist** (e.g. `riemann_plot`, `plotif`, `tangent`, `lim`).

## CI/Interactive Detection

Handled by `CalculusWithJuliaSquared` at its own load time (the canonical `GKSwstype` pattern from the `julia-coding-conventions` skill lives there now). This module needs no GKS configuration of its own.

## Julia Coding Standards

### Function Design Pattern

```julia
# Pure computational function (no plotting dependencies)
function calculate_derivative(f, x; h=1e-7)
    return (f(x + h) - f(x - h)) / (2h)
end

# Integrated plotting function (computation + visualization)
function plot_derivative(f, a, b; n=200)
    xs = range(a, b, length=n)
    ys = [calculate_derivative(f, x) for x in xs]
    try
        plot!(xs, ys)
    catch e
        !haskey(ENV, "CI") && @warn "Plotting failed: $e"
    end
    return ys
end
```

### General Coding Standards
1. Always export new functions in the main module
2. Separate pure computational logic from plotting — `calculate_*` functions have no Plots dependency
3. Plotting functions wrap computation with a try/catch for CI compatibility
4. Use clear parameter naming consistent with standard calculus notation
5. Document mathematical definitions and notation in docstrings

### Function Categories
- **Differentiation**: Derivatives, partial derivatives, gradients
- **Integration**: Definite/indefinite integrals, numerical methods
- **Limits**: Numerical limit evaluation
- **Series**: Taylor series, convergence

### Function Naming Patterns
- **Computational**: `calculate_*` (e.g., `calculate_derivative`, `calculate_integral`)
- **Plotting**: `plot_*` (e.g., `plot_function`, `plot_tangent`)

## Dependencies & Libraries

**Main Dependencies**: CalculusWithJuliaSquared (unregistered, installed by GitHub URL), LaTeXStrings, Reexport

### Libraries Used
- **CalculusWithJuliaSquared.jl**: calculus utilities, plotting recipes, and the full reexport chain (Plots, Symbolics, Roots, LinearAlgebra, SpecialFunctions, IntervalSets) — pure Julia, zero Python by design; never add `Plots` or `SymPy` directly here
- **LaTeXStrings.jl**: For `L"..."` string macro
- **Reexport.jl**: For `@reexport` clean module interface
