module Calculus
using Reexport
@reexport using Plots, BlockArrays, LAlatex, LaTeXStrings

# GR backend — auto-configures for CI or interactive use
if haskey(ENV, "CI") || get(ENV, "GKSwstype", "") == "100"
    ENV["GKSwstype"] = "100"
    gr(show=false)
else
    gr()
end

# Pure computational functions (no plotting dependencies)

# Integrated plotting functions (computation + visualization)

# include("calculus_basics.jl")  # uncomment when source file exists

end # module
