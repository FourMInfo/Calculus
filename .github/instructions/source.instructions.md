---
applyTo: 'src/**'
---
# Source Code Conventions

## Module Structure & Exports

All code uses `@reexport` pattern and exports both computational + plotting functions:

```julia
# Main module uses @reexport for clean interface
using Reexport
@reexport using Plots, BlockArrays, LAlatex, LaTeXStrings

# Pure computational functions (no plotting dependencies)
export calculate_derivative, calculate_integral

# Integrated plotting functions (computation + visualization)
export plot_function, plot_derivative
```

## CI/Interactive Detection

Module auto-configures at load time using `GKSwstype`. See the `julia-coding-conventions` skill for the canonical pattern. The check goes in the main module file (`Calculus.jl`) after the `@reexport` block.

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

**Main Dependencies**: Plots, BlockArrays, LAlatex, LaTeXStrings, Reexport, DrWatson

### Libraries Used
- **Plots.jl**: For visualization functions
- **BlockArrays.jl**: For block-structured arrays
- **LAlatex.jl**: For LaTeX rendering in notebooks
- **LaTeXStrings.jl**: For `L"..."` string macro
- **Reexport.jl**: For `@reexport` clean module interface
