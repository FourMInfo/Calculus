# Calculus

A Julia study project covering calculus topics (derivatives, integrals, limits, series, and
applications), adapted from Guido Walz et al., *Foundations of Mathematics: A Preparatory Course*
(Springer, 2023).

This repository uses a [Julia](https://julialang.org/) workspace for reproducibility — see
[Julia Workspace Layout](.github/copilot-instructions.md) in the Copilot instructions for the
full member/environment breakdown.

## Setup

1. Clone this repository.
2. Instantiate the root environment (library + its production dependencies):

   ```julia
   julia --project=. -e 'using Pkg; Pkg.instantiate()'
   ```

3. Run the tests (uses the `test/` workspace member environment):

   ```julia
   julia --project=. -e 'using Pkg; Pkg.test()'
   ```

4. Build the documentation locally (uses the `docs/` workspace member environment):

   ```julia
   julia --project=docs docs/make.jl
   ```

   The built site is in `docs/build/` — open `docs/build/index.html` in a browser.

### Notebook Setup

`notebooks/` is **not** a workspace member, so `Calculus` is not auto-resolved there.
After cloning (or after removing `notebooks/Manifest.toml`), run once in the notebooks directory:

```julia-repl
julia --project=./notebooks
```

Then in the REPL Pkg mode (press `]`):

```julia-repl
pkg> dev ..
pkg> instantiate
```

This creates `notebooks/Manifest.toml` (gitignored) with `path = ".."` pointing at the root
package. Subsequent `julia --project=./notebooks` invocations will resolve
`Calculus` from the local source.

## Documentation

Documentation is deployed cross-repo to the Math & Tech Study Hub:

<https://fourm.info/calculus/dev/>
