---
applyTo: 'test/**'
---
# Testing Conventions

## CI Testing Strategy

The CI testing strategy consists of three components:

### 1. Module-Level Headless Detection
Configured in the main module (`Linear_Algebra.jl`) at load time. See `julia-coding-conventions` skill for the canonical GKSwstype pattern.

### 2. Manual GKS Configuration in Tests
Set `ENV["GKSwstype"] = "100"` in test files before loading the module:
```julia
# In test files - Configure headless mode before loading module
ENV["GKSwstype"] = "100"  # Force headless plotting for CI
using DrWatson, Test
@quickactivate "Calculus"
using Calculus
```

### 3. Separated Computational/Plotting Logic with Robust Testing
- **Pure computational functions** (`calculate_*`): Test mathematical logic directly, no try-catch
- **Plotting functions** (`plot_*`): Test with try-catch fallback for CI compatibility
- **Integration testing**: Verify both computation and visualization work together

## Test Setup (Uses @quickactivate)
```julia
# Tests use DrWatson @quickactivate pattern
using DrWatson, Test
@quickactivate "Calculus"
# Load the Calculus package
using Calculus
```

## CI-Compatible Plotting Pattern
```julia
# Environment detection for plotting tests
if get(ENV, "CI", "false") == "true" || get(ENV, "GITHUB_ACTIONS", "false") == "true"
    # In CI, just test that the function exists
    @test hasmethod(plot_param_line, (typeof(p), typeof(q), Int64))
else
    # Local testing - allow plotting but capture any display issues
    try
        points = plot_param_line(p, q, 3)
        # ... test plotting results
    catch e
        # Graceful fallback for plotting failures
        @test hasmethod(plot_param_line, (typeof(p), typeof(q), Int64))
    end
end
```

## Testing Patterns

- **Comprehensive Coverage**: Test coverage includes all mathematical functions
- **CI-Safe**: Plotting tests work in both local and headless environments
- **Edge Cases**: Test mathematical edge cases (orthogonal vectors, zero angles, etc.)
- **Type Testing**: Verify return types (Point2f, AbstractVector, matrices)
- **Numerical Precision**: Use `atol=1e-10` for floating-point comparisons
- Use `@test_throws` for expected errors, `@test_broken` for known failures

## CI-Compatible Testing Pattern

Separate computational logic from plotting, test math directly without try-catch, only use try-catch for visualization:

```julia
# Test computational logic directly (NO try-catch - mathematical errors should fail)
@testset "Pure Computational Tests" begin
    points = calculate_param_line(p, q, 3)
    @test length(points) == 3
    @test typeof(points) == Vector{Point2f}
    # Test mathematical correctness without plotting dependencies
end

# Test integration (plotting + computation) with CI-safe fallback
@testset "Integration Tests" begin
    try
        # Test the plotting function (includes computation + visualization)
        result = plot_param_line(p, q, 3)
        @test typeof(result) == Vector{Point2f}
        @test length(result) == 3
    catch e
        # Only catch plotting-related errors, not computational errors
        if contains(string(e), "display") || contains(string(e), "GKS") || isa(e, ArgumentError)
            @test hasmethod(plot_param_line, (Point2f, Point2f, Int64))
        else
            # Re-throw computational errors - these should fail the test
            rethrow(e)
        end
    end
end
```

## Test Organization

- **Grouped by Category**: Basic functions, transformation matrices, line geometry, advanced functions
- **CI Compatibility**: Plotting tests with environment detection
- **Comprehensive Coverage**: Test both happy path and edge cases
- **Type Validation**: Verify return types match expectations
- **Testing Structure**: Modular test files (`test_linear_algebra_basic.jl`, `test_linear_algebra_transform.jl`)

## Plotting in Tests

- If saving plots, use timestamped paths: `"plots/" * Dates.format(now(),"yyyymmdd-HHMMSS") * "functionname.png"`
- Ensure `plots/` directory exists before running tests that save plots
- Use LaTeX titles where appropriate: `title!(L"Plot\ Title")`

## Running Tests

```bash
# Local
julia --project=. test/runtests.jl

# CI mode
CI=true julia --project=. test/runtests.jl
```

## CI/CD Pipeline

- **Tests**: Run on all PRs (`.github/workflows/CI.yml`)
- **Docs Build**: Test on PR (no deploy)
- **Docs Deploy**: Auto-deploy to `https://study.fourm.info/linear_algebra/` on merge to `main`
- **Cross-Repo**: Deploys to `FourMInfo/math_tech_study` subdirectory

## CI Considerations

- Tests automatically detect CI environment via ENV variables
- Plotting tests skip gracefully in headless mode
- 68 tests pass in both local and CI modes (plotting tests with fallbacks)
- Test execution time: ~15-16 seconds
