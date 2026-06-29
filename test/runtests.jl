using Test

# Set headless mode for CI before loading module
ENV["GKSwstype"] = "100"

# Load the package
using Calculus

println("Starting tests")
ti = time()

@testset "Calculus tests" begin
    include("test_calculus_basics.jl")
    # add more test files here
end

ti = time() - ti
println("\nTest took total time of:")
println(round(ti/60, digits = 3), " minutes")
