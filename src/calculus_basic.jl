# Notebook display helpers: show a computation's outcome -- a value or the error it raised --
# inside one typeset LaTeXString block, without the error stopping the notebook cell.

"""
    attempt(f)

Call `f()` and return its value, or return the exception it throws instead of letting it
stop the caller. Pass the computation as a zero-argument function, `attempt(() -> expr)`,
so that it runs inside the `try`: `attempt(expr)` would evaluate `expr`, and throw, before
`attempt` is ever called.

An `InterruptException` (the notebook's stop button, or Ctrl-C) is rethrown rather than
returned, so interrupting still interrupts.

# Examples
```julia
attempt(() -> factorial(5))    # 120
attempt(() -> factorial(21))   # OverflowError(...): 21! does not fit in an Int64
```
"""
function attempt(f)
    try
        return f()
    catch err
        err isa InterruptException && rethrow()
        return err
    end
end

# Escape the characters that are special in LaTeX text mode.
function _latex_text_escape(s::AbstractString)
    replace(s, "\\" => "\\textbackslash{}", "{" => "\\{", "}" => "\\}",
               "_" => "\\_", "%" => "\\%", "&" => "\\&", "#" => "\\#", "\$" => "\\\$",
               "^" => "\\textasciicircum{}", "~" => "\\textasciitilde{}")
end

# Escape the characters that are special inside `\mathtt{...}`. A `^` is left alone, so
# backticked code such as `x^2` reads as a superscript.
_latex_code_escape(s::AbstractString) =
    replace(s, "{" => "\\{", "}" => "\\}", "_" => "\\_", "%" => "\\%", "&" => "\\&",
               "#" => "\\#", "\$" => "\\\$")

"""
    latex_error(err::Exception)
    latex_error(msg::AbstractString)

An error message as LaTeX lines, for embedding in a `LaTeXString` block with
`%\$(latex_error(err))`. The message is broken into one line after each `"; "` (the
semicolon kept), each line indented with `\\quad`; parts of the message in backticks are set
in typewriter (`\\mathtt`), the rest as text (`\\text`), with LaTeX's special characters
escaped. Lines are separated by `\\\\`, so place the result where line breaks are allowed,
such as a one-column `array`.

Returns a `String` of LaTeX source, not a `LaTeXString`: it is a fragment, not a formula.

# Examples
```julia
r = attempt(() -> factorial(21))
L\"\"\"
\\begin{array}{l}
\\text{The error from } \\mathtt{factorial(21)}\\text{:} \\\\[1ex]
%\$(latex_error(r))
\\end{array}
\"\"\"
```
"""
latex_error(err::Exception) = latex_error(sprint(showerror, err))

function latex_error(msg::AbstractString)
    line(clause) = join(isodd(i) ? "\\text{$(_latex_text_escape(part))}" :
                                   "\\mathtt{$(_latex_code_escape(part))}"
                        for (i, part) in enumerate(split(clause, '`')) if !isempty(part))
    join(("\\quad " * line(clause) for clause in split(msg, "; ")), "\\text{;} \\\\ ")
end

"""
    latex_cell(r)

A value, or an error caught by [`attempt`](@ref), as the LaTeX for one entry of a results table
in a `LaTeXString` block: `%\$(latex_cell(r))`.

| `r` | entry |
|:--- | :--- |
| an `Exception` | `\\text{error}` (show its type with [`latex_type`](@ref)) |
| `true` / `false` | `\\mathtt{true}` — math mode would italicise the letters as variables |
| a `Rational` | `\\frac{1}{2}`, not Julia's `1//2`; a whole number stays `2` |
| `Inf`, `-Inf`, `NaN` | `\\infty`, `-\\infty`, `\\mathrm{NaN}` |
| a `Symbol` | `\\mathtt{:name}` (a `symlim` route, say) |
| a symbolic `Num` | `conventional_latex(r)`: textbook order, not the stored one |
| a string | `\\text{…}`, escaped |
| anything else | `string(r)` |

# Examples
```julia
r1 = attempt(() -> factorial(5))
r2 = attempt(() -> factorial(21))
L\"\"\"
\\begin{array}{lrl}
\\mathtt{factorial(5)}  & %\$(latex_cell(r1)) & %\$(latex_type(r1)) \\\\
\\mathtt{factorial(21)} & %\$(latex_cell(r2)) & %\$(latex_type(r2))
\\end{array}
\"\"\"
```
"""
latex_cell(r) = string(r)
latex_cell(::Exception) = "\\text{error}"
latex_cell(r::Bool) = "\\mathtt{$r}"
latex_cell(r::AbstractString) = "\\text{$(_latex_text_escape(r))}"
latex_cell(r::Symbol) = "\\mathtt{$(_latex_code_escape(repr(r)))}"
latex_cell(r::Num) = conventional_latex(r)

function latex_cell(r::Rational)
    isone(denominator(r)) && return string(numerator(r))
    (r < 0 ? "-" : "") * "\\frac{$(abs(numerator(r)))}{$(denominator(r))}"
end

function latex_cell(r::AbstractFloat)
    isnan(r) && return "\\mathrm{NaN}"
    isinf(r) && return r > 0 ? "\\infty" : "-\\infty"
    string(r)
end

"""
    latex_type(r)

The type of `r` in typewriter, for the type column of a results table: `%\$(latex_type(r))`.
Braces in a parametric type are escaped, so `Rational{Int64}` does not lose them to LaTeX's
grouping and print as `RationalInt64`. For an error caught by [`attempt`](@ref) it is the
error's type, e.g. `OverflowError`.
"""
latex_type(r) = "\\mathtt{$(_latex_code_escape(string(typeof(r))))}"
