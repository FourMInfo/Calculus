# CalculusWithJuliaSquared API

[`CalculusWithJuliaSquared`](https://github.com/FourMInfo/CalculusWithJuliaSquared.jl) is a
separate, pure-Julia package — a fork of `CalculusWithJulia` — that these study materials are built on. It has its own repository, versioning, and documentation; it is not maintained as part of `Calculus`.

`Calculus` does, however, `@reexport` it, so its exported helpers (`lim`, `tangent`, `secant`, `D`, `riemann`, `∇`, …) are available directly once you `using Calculus` — no separate install or `using CalculusWithJuliaSquared` needed. That is why its API is documented here: the reference below is generated from the package's own docstrings, so it always tracks the installed version.

The companion notes that exercise this package are a work-in-progress port of the _Calculus
with Julia_ notes onto `Symbolics` / pure Julia:

- The original notes (Python-backed `SymPy`): [Calculus with Julia](https://calculuswithjulia.github.io/), by John Verzani.
- Our fork, where the port progresses chapter by chapter: [CalculusWithJuliaSquaredNotes.jl](https://github.com/FourMInfo/CalculusWithJuliaSquaredNotes.jl) on GitHub.
- The rendered ported book — _forthcoming_ at `fourm.info/cwjsn`.

```@autodocs
Modules = [CalculusWithJuliaSquared]
```
