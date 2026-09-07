module Calculus
using Reexport
# CalculusWithJuliaSquared reexports Plots, Symbolics, Roots, LinearAlgebra,
# SpecialFunctions, IntervalSets and LaTeXStrings, and auto-configures the GR backend
# for CI/interactive use at load time — no separate `using Plots`, `using LaTeXStrings`
# or GKS setup needed. LaTeXStrings moved into it in v0.12.0; until then this line had to
# name it alongside, which is precisely what made the gap visible.
@reexport using CalculusWithJuliaSquared

# Pure computational functions (no plotting dependencies)

# Integrated plotting functions (computation + visualization)

# include("calculus_basics.jl")  # uncomment when source file exists

end # module
