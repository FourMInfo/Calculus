module Calculus
using Reexport
# CalculusWithJuliaSquared reexports Plots, Symbolics, Roots, LinearAlgebra,
# SpecialFunctions, and IntervalSets, and auto-configures the GR backend for
# CI/interactive use at load time — no separate `using Plots` or GKS setup needed.
@reexport using CalculusWithJuliaSquared, LaTeXStrings

# Pure computational functions (no plotting dependencies)

# Integrated plotting functions (computation + visualization)

# include("calculus_basics.jl")  # uncomment when source file exists

end # module
