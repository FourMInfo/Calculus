# Variables

Commentary on the CWJSN chapter [Variables](https://fourm.info/cwjsn/basics/variables.html). The code behind the results shown here runs in the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook.

## Variable gotchas

The text notes the danger of shadowing which can overwrite the meaning of a name binding. Specifically let's look at the example of `x + y = 3`, which is a function definition in Julia's short _assignment form_ of functions. Running it redefines the name binding for `+` and detaches it from the `Base.:+` function, and attaches it to the newly defined function. Let's see how this plays out.

The output of the two cells in the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook that show this:

```text
Inside a 'let' block, we define the new function x + y = 3 and this is what happens:
1 + 5 = 3
Base.:+(1, 5) = 6
Outside the 'let' block, the original definition of '+' is unchanged.
1 + 5 = 6
In this part of the notebook (and similarly in the CLI, we are in 'Main' module).
So here is what happens when we define a simple function in the 'Main' module.
1 + 5 = 3
After redefining '+' again using 'const (+) = Base.:+', the following results are observed:
1 + 5 = 6
It is important to note that this is just restoring the 'Base' definition of '+' in the 'Main' module.
However it is not actually deleting the new definition of '+'. It is still there, but nothing refers to it.
If you re-run this cell, the new definition will add a method, +(::Any, ::Any), to Base's own + function
rather than defining a new function.
On first run the line "a" + "b" creates an error. On the second run this line gives an answer
MethodError
Note: the simplest way to delete the new method completely is to restart the kernel.
```

```text
After you restart the kernel and run the cell above only once, try this
Add the function and then use `Base.delete_method` to remove it
MethodError: no method matching +(::String, ::String)
After using `Base.delete_method` to delete the method, trying to add two strings results in an error.
```

## Euler's number: use `ℯ`, not `e`

**NB:** This is actually a gotcha in _Calculus with Julia Squared_ (inherited from _Calculus with Julia_), not a specifically Julia gotcha.

Julia's Euler's number is `ℯ`, typed `\euler` then Tab. Like `π`, it is an `Irrational`: it has no fixed precision, and it turns into a number of the right type only when it is combined directly with a number (e.g. `2ℯ`, `ℯ + 1`). This is equally true if this expression is evaluated inside a `Symbolics.jl` expression. The exception where `ℯ` is never turned into a number, but is still meaningfully evaluated, is where Julia has a special method (e.g. `ℯ^2` is computed as `exp(2)`).

By contrast, bare `e` is not defined in Julia (`Base.MathConstants.e` is the same `ℯ`). `using Calculus` brings in CalculusWithJuliaSquared's `e`, which is `const e = exp(1)`, an ordinary `Float64` rounded to about 16 digits. So `e === ℯ` is `false`.

Write `b` for either one (measured with Julia 1.13.2, CalculusWithJuliaSquared 0.17.0, Symbolics 7.45.0, `@variables x`):

| computation | `b = e` | `b = ℯ` |
| --- | --- | --- |
| `typeof(b)` | `Float64` | `Irrational{:ℯ}` |
| `b^2 - exp(2)` | `-8.881784197001252e-16` | `0.0` |
| `log(b)` | `1.0` | `1` |
| `big(b) - big(ℯ)` | `-1.4456…e-16` | `0.0` |
| `b^x` | `2.718281828459045^x` | `exp(x)` |
| `Symbolics.derivative(b^x, x)` | a float power times a float log (below) | `exp(x)` |
| `b*x` | `2.718281828459045x` | `ℯ*x` |
| `2b*x` | `5.43656365691809x` | `5.43656365691809x` |
| `2*(b*x)` | `5.43656365691809x` | `2ℯ*x` |

With `e` the derivative comes back as `(2.718281828459045^x)*log(2.718281828459045)`. That is numerically $e^x$, but Symbolics only sees an arbitrary float base, so the simplification $\frac{d}{dx}e^x = e^x$ never appears.

Why `ℯ` gives exact results: Julia defines `ℯ^y` as `exp(y)` and `log(ℯ)` as the integer `1` (special methods in `Base.MathConstants`). `big(ℯ)` is correct to the full `BigFloat` precision, while `big(e)` converts the 16-digit float and is wrong after that.

The _CalculusWithJuliaSquared_ text (`precalc/exp_log_functions`) inherits Verzani's comment that the float `e` "loses the feature of arbitrary precision, but has other advantages" and does not say which. The obvious one is that `e` can be typed on any keyboard. In ordinary floating-point arithmetic the two mostly agree, because `ℯ` becomes a `Float64` as soon as it is used in an expression with a number (`2ℯ` is `5.43656365691809`). For anything exact or symbolic, use `ℯ` (or `exp(...)`).

---

## CWJSN variables: Questions

Values marked * were not in my REPL session; they were added afterwards by Claude to complete the comparison. As always, try to answer on your own before looking at the answers.

| Q | Question (CWJSN) | My Julia → result | Answer | Why |
| --- | --- | --- | --- | --- |
| 1 | Let $a=10$, $b=2.3$, $c=8$. Find $(a-b)/(a-c)$ | `a, b, c = 10, 2.3, 8`; `(a − b)/(a − c)` → `3.85` | `3.85` | $7.7/2$. The `−` here is the Unicode minus sign (U+2212), copied from the page's math, not the keyboard `-`; Julia's parser turns it into the ordinary `-`, so `a − b` is `a - b` |
| 2 | Let `x = 4`. Compute $y=100 - 2x - x^2$ | `x = 4`; `y = 100 - 2x -x^2` → `76` | `76` | $100 - 8 - 16$ |
| 3 | Value of `a^b - b^a` after `a = 3.2; b=2.3` | `a = 3.2; b=2.3` → `2.3`; `a^b - b^a` → `0.14354012963861962` | `0.14354012963861962` | `;` puts two statements on one line; only the last value is shown |
| 4 | $\frac{p - q}{\sqrt{p(1-p)}}$ for $p=0.25$, $q=0.2$, computed in parts | `p, q = 0.25, 0.2`; `top = p - q` → `0.04999999999999999`; `bottom = sqrt(p*(1-p))` → `0.4330127018922193`; `ans = top/bottom` → `0.11547005383792514` | `0.11547005383792514` | `top` is not exactly $0.05$ because $0.2$ has no exact binary form (as in the calculator Q5) |
| 5 | $y = \frac{x^2 - 2x - 8}{x^2 - 9x - 20}$ for $x=3$, with variables for the top and the bottom | `x = 3`; `top = x^2 - 2x - 8` → `-5`; `bottom = x^2 - 9x -20` → `-38`; `y = top/bottom` → `0.13157894736842105` | `0.13157894736842105` | $\frac{-5}{-38} = \frac{5}{38}$ |
| 6 | Which is not a valid variable name: `5degreesbelowzero`, `some_really_long_name…` (full name below), `aMiXeDcAsEnAmE`, `fahrenheit451` | `5degreesbelowzero = 1` → `ERROR: syntax: "5" is not a valid function argument name`; `some_really_long_name… = 1` → `1`\*; `aMiXeDcAsEnAmE = 1` → `1`\*; `fahrenheit451 = 1` → `1`\* | `5degreesbelowzero` | a name cannot start with a digit. Julia reads `5degreesbelowzero` as the numeric-literal product `5 * degreesbelowzero`, so `= 1` is a short-form definition of `*` with `5` as an argument name, the same pattern as `x + y = 3` above |
| 7 | Which is one of Julia's built-in math constants: `pi`, `oo`, `E`, `I` | `pi` → `π = 3.1415926535897...`; `oo` → `UndefVarError`\*; `E` → `UndefVarError`\*; `I` → `UndefVarError`\* in bare Julia, `UniformScaling{Bool}(true)`\* after `using Calculus` | `pi` | `oo`, `E` and `I` are SymPy's names for $\infty$, $e$ and $i$ (Julia's are `Inf`, `ℯ` and `im`). The `I` that `using Calculus` brings in is LinearAlgebra's identity matrix, not a constant |
| 8 | Which key sequence produces `δ = 1/10`: `\delta[tab] = 1/10`, `delta[tab] = 1/10`, `$\delta$ = 1/10` | `δ = 1/10` → `0.1`; `delta = 1/10` → `0.1`\*; `$\delta$ = 1/10` → `ERROR: syntax: "$" expression outside quote`\* | `\delta[tab] = 1/10` | without the backslash, Tab does not convert, so `delta` stays an ordinary name; `$` is interpolation, valid only inside strings and quoted code |
| 9 | Which is not a valid way to assign three variables at once: `a=1, b=2, c=3`, `a,b,c = 1,2,3`, `a=1; b=2; c=3` | `a,b,c = 1,2,3` → `(1, 2, 3)`; `a=1, b=2, c=3` → `ERROR: syntax: invalid assignment location "2"`; `a=1; b=2; c=3` → `3` | `a=1, b=2, c=3` | the commas build tuples, so it parses as `a = ((1, b) = ((2, c) = 3))`, and `2` cannot be assigned to |
| 10 | `x = y = z = 3` will always: assign all three variables to `3`, create 3 linked values that stay synced, or throw an error | `x = y = z = 3` → `3`; `x, y, z` → `(3, 3, 3)`; `x = 4`; `(x, y, z)` → `(4, 3, 3)`\* | assign all three variables at once to `3` | `=` associates right to left and returns its right-hand side: `x = (y = (z = 3))`. The names are not linked: rebinding `x` leaves `y` and `z` alone |

Q6, the full name: `some_really_long_name_that_is_no_fun_to_type`
