CI = get(ENV, "CI", nothing) == "true" || get(ENV, "GITHUB_TOKEN", nothing) !== nothing
using Documenter, Dates
using Calculus

@info "Building Documentation"
makedocs(;
    modules=[Calculus],
    sitename = "Calculus",
    pagesonly = true,
    pages = [
        "index.md",
    ],
    format = Documenter.HTML(
        prettyurls = CI,
        edit_link = "main",
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
