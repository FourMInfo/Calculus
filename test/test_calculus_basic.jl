@testset "Calculus basics" begin

    @testset "attempt: a value, or the error instead of stopping" begin
        @test attempt(() -> factorial(5)) == 120
        @test attempt(() -> factorial(big(21))) == factorial(big(21))
        # factorial throws where ^ wraps around: the error comes back as a value
        @test attempt(() -> factorial(21)) isa OverflowError
        @test attempt(() -> factorial(-1)) isa DomainError
        @test attempt(() -> prod(1:21)) == -4249290049419214848   # wraps silently, no error
        # an interrupt still stops the cell rather than becoming a result
        @test_throws InterruptException attempt(() -> throw(InterruptException()))
    end

    @testset "latex_error: an error message as LaTeX lines" begin
        # the real error a notebook meets; its structure is ours, its wording is Julia's
        err = attempt(() -> factorial(21))
        msg = sprint(showerror, err)
        tex = latex_error(err)
        @test tex == latex_error(msg)
        lines = split(tex, " \\\\ ")
        @test length(lines) == count("; ", msg) + 1
        @test all(startswith("\\quad \\text{"), lines)
        @test startswith(tex, "\\quad \\text{OverflowError: ")
        @test all(endswith("\\text{;}"), lines[1:end-1])        # the semicolon is kept
        @test occursin("\\mathtt{factorial(big(21))}", tex)     # backticks become typewriter
        @test !occursin('`', tex)

        # hand-built messages, for the cases the real one does not exercise
        @test latex_error("plain message") == "\\quad \\text{plain message}"
        @test latex_error("first; second") ==
              "\\quad \\text{first}\\text{;} \\\\ \\quad \\text{second}"
        @test latex_error("use `my_fun` here") ==
              "\\quad \\text{use }\\mathtt{my\\_fun}\\text{ here}"
        @test latex_error("50% & #1 for \$5") ==
              "\\quad \\text{50\\% \\& \\#1 for \\\$5}"
        @test latex_error("a {b} c\\d") ==
              "\\quad \\text{a \\{b\\} c\\textbackslash{}d}"
        @test latex_error("x^2 ~ y") ==
              "\\quad \\text{x\\textasciicircum{}2 \\textasciitilde{} y}"

        # embedded in a LaTeXString block, as a notebook uses it
        block = L"""\begin{array}{l} %$(latex_error("first; second")) \end{array}"""
        @test block isa LaTeXString
        @test occursin("\\quad \\text{first}\\text{;} \\\\ \\quad \\text{second}", block)
    end

    @testset "latex_cell: a table entry for a value or a caught error" begin
        # what attempt hands back, as the notebook tables use it
        @test latex_cell(attempt(() -> factorial(21))) == "\\text{error}"
        @test latex_cell(attempt(() -> factorial(5))) == "120"
        @test latex_cell(attempt(() -> factorial(big(21)))) == "51090942171709440000"
        @test latex_cell(attempt(() -> gamma(6))) == "120.0"
        @test latex_cell(attempt(() -> gamma(big(31)) == factorial(big(30)))) == "\\mathtt{true}"
        @test latex_cell(false) == "\\mathtt{false}"
        # exact ratios as fractions, not Julia's 1//2
        @test latex_cell(1//2) == "\\frac{1}{2}"
        @test latex_cell(-3//4) == "-\\frac{3}{4}"
        @test latex_cell(big(1)//3) == "\\frac{1}{3}"
        @test latex_cell(4//2) == "2"
        # infinities and NaN as symbols, not italic letters
        @test latex_cell(Inf) == "\\infty"
        @test latex_cell(-Inf) == "-\\infty"
        @test latex_cell(NaN) == "\\mathrm{NaN}"
        # a symlim result, as the limits notebook will meet it: value and route
        @variables x
        lim = symlim(log(x), x, 0; side = :right)
        @test latex_cell(lim[1]) == "-\\infty"
        @test latex_cell(lim[2]) == "\\mathtt{:divergent\\_numeric}"
        # symbolic results in CWJS's conventional order, not the stored one
        q = (x^2 - 1)/(x - 1)
        @test latex_cell(q) == conventional_latex(q)
        @test latex_cell(q) == "\\frac{x^{2} - 1}{x - 1}"
        # text is escaped
        @test latex_cell("a_b & c") == "\\text{a\\_b \\& c}"
    end

    @testset "latex_type: a table's type column" begin
        @test latex_type(attempt(() -> factorial(21))) == "\\mathtt{OverflowError}"
        @test latex_type(attempt(() -> factorial(big(21)))) == "\\mathtt{BigInt}"
        # a parametric type keeps its braces, which LaTeX would otherwise swallow as grouping
        @test latex_type(1//2) == "\\mathtt{Rational\\{Int64\\}}"
        @variables x
        @test latex_type([x]) == "\\mathtt{Vector\\{Num\\}}"
        @test latex_type(:divergent_numeric) == "\\mathtt{Symbol}"
    end

end
