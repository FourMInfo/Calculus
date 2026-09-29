---
applyTo: 'test/**'
---
# Testing Conventions

This file is **shared**: copied unchanged into every math study repo from the hub
(`FourMInfo/math_tech_study`, `project_resources/instructions/`) and byte-identical everywhere.
This repo's package name, test files and subject-specific testing notes are in
`project.instructions.md`. How to design tests that can actually catch a defect is covered by
the `test-design-discipline` skill.

## Test Setup

`test/runtests.jl` sets headless plotting **before** loading the package, loads it with a plain
`using` (the module reexports its dependencies — no `@quickactivate`), then includes one file per
topic inside a single top-level `@testset`:

```julia
using Test

# Set headless mode for CI before loading module
ENV["GKSwstype"] = "100"

using MyPackage

@testset "MyPackage tests" begin
    include("test_mypackage_basic.jl")
end
```

- Test files are named `test_<topic>.jl`, one per source file or topic, and **every** test file
  must be `include`d from `runtests.jl` — an orphaned file silently never runs (see the
  `julia-coding-conventions` skill).
- Test-only dependencies go in `test/Project.toml`.

## Separate Computational and Plotting Tests

Mirror the source split: test the mathematics directly, and fence off only the display.

```julia
# Computational logic: NO try/catch — a mathematical error must fail the test
@testset "Computation" begin
    result = calculate_something(args...)
    @test result ≈ expected atol=1e-10
end

# Plotting: the computation still must be right; only display failures are tolerated
@testset "Plotting" begin
    try
        result = plot_something(args...)
        @test result ≈ expected atol=1e-10
    catch e
        if contains(string(e), "display") || contains(string(e), "GKS") || isa(e, ArgumentError)
            @test hasmethod(plot_something, typeof.(args))
        else
            rethrow(e)
        end
    end
end
```

## Testing Patterns

- Cover every exported function, the happy path **and** mathematical edge cases (degenerate
  inputs, zero and boundary values, orthogonal or parallel cases)
- Check return types as well as values
- Floating-point comparisons use `≈` / `isapprox` with an explicit tolerance (`atol=1e-10`
  unless the mathematics needs otherwise)
- `@test_throws` for expected errors, `@test_broken` for known failures
- Plots saved during tests go under `plots/`; the `julia-figure-authoring` skill covers naming

## Running Tests

```bash
# As CI runs them
julia --project=. -e 'using Pkg; Pkg.test()'

# Simulating CI's headless environment
CI=true julia --project=. -e 'using Pkg; Pkg.test()'
```

## Tests in CI

- The **test** job runs on pull requests and manual triggers only — not on pushes to `main`,
  and the deploy job does not wait for it. A change must pass on its pull request before merge.
- Plotting tests pass headless because of the `GKSwstype` setting and the fallbacks above.
- CI pipeline details and the deployed docs URL: `ecosystem.instructions.md` and
  `project.instructions.md`.
