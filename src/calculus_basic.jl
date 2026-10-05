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
