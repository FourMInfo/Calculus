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

end
