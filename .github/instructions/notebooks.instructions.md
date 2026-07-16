---
applyTo: 'notebooks/**'
---
# Notebook Conventions

## Setup Pattern

All notebooks should start with the standard setup cell:

```julia
using Revise
using Calculus
using LAlatex, BlockArrays

LAlatex.set_backend!(:symbolics)
LAlatex.reset_display_defaults!()
```

What comes from where:

- `using Calculus` provides everything the module reexports — `LaTeXStrings` (the `L"..."` macro) plus the full `CalculusWithJuliaSquared` chain (`Plots`, `Symbolics`, `Roots`, calculus utilities and plotting recipes — see "What CalculusWithJuliaSquared Provides" in `copilot-instructions.md`).
- `LAlatex` and `BlockArrays` are **notebooks-environment dependencies only** (in `notebooks/Project.toml`, not the root project), so they need their own `using` line — they are *not* re-exported by `Calculus`.

`set_backend!(:symbolics)` is required because this package uses Symbolics.jl; the default `:latexify` backend gives worse output for symbolic expressions.
`reset_display_defaults!()` ensures a clean display state on every kernel restart.

## Notebook Guidelines

- Notebooks are for exploration and study, not tested in CI
- The `notebooks/` environment is **not** a workspace member — run `pkg> dev ..` + `pkg> instantiate` once after cloning. See `julia-coding-conventions` skill for the full pattern. Do not commit `notebooks/Manifest.toml`.
- Use `println()` for output to make results clear when re-running cells
- Include explanatory markdown cells between code cells
- Use Unicode variable names consistent with the source code (e.g., `v₁`, `θ`, `λ`)
- Reference the documentation sections being studied

## Plotting in Notebooks

- Plots render inline in Jupyter notebooks
- No need for headless mode configuration
- Prefer the ready-made recipes from `CalculusWithJuliaSquared` (`plotif`, `riemann_plot`, `plot_parametric`, `vectorfieldplot`, …) and this package's own plotting functions before writing new ones

## LAlatex Display

[LAlatex.jl](https://github.com/ea42gh/LAlatex.jl) (by ea42gh) is available in the notebooks environment (`using LAlatex` in the setup cell) and provides clean LaTeX rendering of mathematical objects in notebooks. Use it instead of raw `println` or `display` whenever presenting mathematical results.

### Core functions

| Function | Purpose |
|---|---|
| `l_show(...)` | Display one or more objects inline or as a display equation |
| `L_show(...)` | Same but returns a `String` instead of displaying |
| `lc(coeffs, vecs)` | Linear combination display |
| `set(...)` | Finite set or set-builder notation |
| `cases(...)` | Piecewise / cases display |
| `aligned(...)` | Multi-line aligned derivation or equation chain |
| `mixed_matrix(...)` / `@mixed_matrix` | Matrix with mixed numeric/symbolic entries |
| `factor_out_denominator(A)` | Factor a common denominator out of a rational matrix |

### Common options for `l_show`

```julia
l_show(L"A = ", A; arraystyle=:bmatrix)          # bracket style: :bmatrix, :pmatrix, :vmatrix, :array
l_show(expr; symopts=(expand=true,))              # symbolic transformations: expand, factor, collect
l_show(A; number_formatter=x -> round_value(x,2)) # custom number formatting
l_show(A; number_formatter=percentage_formatter)  # percentage display
l_show(aligned(...); inline=false, tag="1")        # numbered display equation (no label — see below)
with_display_defaults(arraystyle=:bmatrix) do ... end  # scoped defaults
```

### Block-partitioned matrices

Wrap a plain matrix in `BlockArray` to get visual partition lines (horizontal `\hline` and vertical `|` separators) between blocks:

```julia
B = BlockArray([1 2 4; 3 4 5], [1, 1], [2, 1])   # row sizes [1,1], col sizes [2,1]
display(l_show(L"B = ", B))
```

### KaTeX constraint: no `\label`

Jupyter notebooks render math with **KaTeX**, which supports `\tag{...}` but **not** `\label{...}`. Never pass the `label=` keyword to `l_show` in a notebook — it will produce a parse error. Use `tag=` only:

```julia
# ✅ correct
display(l_show(aligned(...); inline=false, tag="1"))
# ❌ will fail in Jupyter
display(l_show(aligned(...); inline=false, tag="1", label="eq:foo"))
```

`label=` is only valid when rendering to full LaTeX/MathJax (e.g. Documenter.jl docs).

### Reference

- [LAlatex.jl docs](https://ea42gh.github.io/LAlatex.jl/)
- [Demo notebook (upstream)](https://github.com/ea42gh/LAlatex.jl/blob/main/notebooks/LAlatex_demo.ipynb)
- [Interactive Binder demo](https://mybinder.org/v2/gh/ea42gh/LAlatex.jl/main?filepath=notebooks%2FLAlatex_demo.ipynb)

## Julia Kernel Gotchas

See `julia-coding-conventions` skill (stale variable slot, building matrix from row vectors).