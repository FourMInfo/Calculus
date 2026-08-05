CI = get(ENV, "CI", nothing) == "true" || get(ENV, "GITHUB_TOKEN", nothing) !== nothing
using Documenter, Dates
using Calculus
# Bring the CalculusWithJuliaSquared module binding into scope so its docstrings can be
# pulled into an API section here. It ships with the package (Calculus reexports it), so
# this embeds CWJS's API reference natively in the Calculus site — no cross-repo HTML.
using Calculus.CalculusWithJuliaSquared

@info "Building Documentation"
makedocs(;
    modules=[Calculus, CalculusWithJuliaSquared],
    sitename = "Calculus",
    pagesonly = true,
    # Keep Calculus's own content strictly checked; tolerate only what the embedded CWJS
    # autodocs block needs (mirrors CalculusWithJuliaSquared's own docs/make.jl).
    warnonly = Documenter.except(:autodocs_block),
    # CWJS is installed as an extracted package tree (no .git), so Documenter can't infer a
    # remote for its docstrings' "source" links. Point them at the fork's main branch.
    remotes = Dict(
        pkgdir(CalculusWithJuliaSquared) =>
            (Documenter.Remotes.GitHub("FourMInfo", "CalculusWithJuliaSquared.jl"), "main"),
    ),
    pages = [
        "index.md",
        "API/CalculusWithJuliaSquared.md",
        "Differential Calculus" => [
            "Differential_Calculus/01 Derivatives and Rules.md",
            "Differential_Calculus/02 Applications and Extrema.md",
            "Differential_Calculus/03 Curve Sketching.md",
        ],
        "Integral Calculus" => [
            "Integral_Calculus/01 Definite Integral.md",
            "Integral_Calculus/02 Antiderivatives and Main Theorem.md",
            "Integral_Calculus/03 Integration Techniques.md",
        ],
        "sites.md",
    ],
    format = Documenter.HTML(
        prettyurls = CI,
        edit_link = "main",
        assets = ["assets/custom.css"],
        inventory_version = "0.1.0",
        mathengine = Documenter.MathJax3(Dict(
            :loader => Dict("load" => ["[tex]/physics", "[tex]/ams"]),
            :tex => Dict(
                "packages" => ["base", "ams", "mathtools"],
                "inlineMath" => [["\$", "\$"]],
                "displayMath" => [["\$\$", "\$\$"], ["\\[", "\\]"]],
            ),
        )),
        footer = "Powered by [Documenter.jl](https://documenter.jl) and the [Julia Programming Language](https://julialang.org) generated on $(Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:ss"))"
    ),
)

@info "Deploying Documentation"
if CI
    # Override to target math_tech_study for cross-repository deployment
    # DO NOT REMOVE OR CHANGE THIS
    ENV["GITHUB_REPOSITORY"] = "FourMInfo/math_tech_study"
    deploydocs(
        repo = "github.com/FourMInfo/math_tech_study.git",
        target = "build",
        push_preview = true,
        devbranch = "main",
        dirname = "calculus",
    )
end

@info "Finished with Documentation"
