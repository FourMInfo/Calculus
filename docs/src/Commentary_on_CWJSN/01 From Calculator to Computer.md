# From Calculator to Computer

Commentary on the CWJSN chapter [From Calculator to Computer](https://fourm.info/cwjsn/basics/calculator.html). The code behind the results shown here runs in the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook.

## Big Numbers

Two interesting points I picked up in this chapter.

1. In julia you can express a large number using underscores for better readability, e.g., `1_000_000` instead of $1000000$
2. You need to be careful when you run into big integers. So $10^{20}$ gives a wrong number with no error or warning, while the same value typed as a literal comes out right. If a computation might pass about $9.2 \times 10^{18}$ you need to use `big(...)`

Results from the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook, where the code runs:

| Julia | value | type | note |
| :--- | :--- | :--- | :--- |
| `10_000_000_000_000_000_000` | `10000000000000000000` | `Int128` | literal, widened |
| `1_000_000_000_000_000_000_000_000_000_000_000_000_000` | `1000000000000000000000000000000000000000` | `BigInt` | literal, widened |
| `10^20` | `7766279631452241920` | `Int64` | wrong: overflow wraps around |
| `big(10)^20` | `100000000000000000000` | `BigInt` | correct |
| `big"123_456"` | `123456` | `BigInt` | string form takes underscores too |

The wrong way and the right ways side by side:

| Way | Julia | value |
| :--- | :--- | :--- |
| Wrong | `10^20` | `7766279631452241920` |
| Right | `big(10)^20` | `100000000000000000000` |
| Right | `10^big(20)` | `100000000000000000000` |

In the CWJSN text, when discussing big integers, Professor Verzani states:

>The user is expected to have a sense that they need to be careful when their values are quite large. But the better recommendation is that the user use floating point numbers, which as easy as typing `2.0^63`. Though not always exact, floating point values can represent a much bigger range values and are exact for a reasonably wide range of integer values.

Is this a good recommendation?

If we are just interested in sheer size of numbers, then it is true that floating point values reach much farther than Int64:

| type | largest value | exact for every integer up to |
| :--- | :--- | :--- |
| `Int64` | $2^{63}-1 \approx 9.2 \times 10^{18}$ | all of them (then wraps silently) |
| `Float64` | $\approx 1.8 \times 10^{308}$ | $2^{53} \approx 9.0 \times 10^{15}$ (then rounds silently) |
| `BigInt` | limited only by memory | all of them |

However, as Verzani himself notes, these larger values are not always exact. In fact, `Float64`'s exact range is smaller than `Int64`'s. Past $2^{53}$, floats skip integers: `2.0^53 + 1 == 2.0^53` is true. So switching to floats trades one silent failure (wrap-around) for another (rounding), and the rounding starts about a thousand times sooner:

| Julia | exact? |
| :--- | :--- |
| `2.0^63` | yes — a power of two |
| `10.0^20` | yes |
| `10.0^23` | no — stored as $99999999999999991611392$ |
| `prod(1.0:21)` | yes, $= 21!$ (its factors of 2 keep it representable) |
| `prod(1.0:25)` | no — off from $25!$ by $71303168$ |

So there should be two recommendations, not one:

* For exact integers, use `big`, which will always give exact results.
* For magnitude only, use floats, and accept about 16 significant digits.

Floats are the better recommendation only when you don't care about the last digits.

We can see this played out in the Homer Simpson example. The board in the photo claims $3987^{12} + 4365^{12} = 4472^{12}$. The text instead writes the
expression

$$3987^{12} + 4365^{12} - 4472^{12}$$

because the equation holds **exactly when that difference is $0$** — so "is it $0$?" is the test. The claim is the answer is yes on calculators, but not in Julia!

| Julia | result | note |
| :--- | :--- | :--- |
| `3987^12 + 4365^12 - 4472^12` | `-842986283280935454` | `Int64` overflow: meaningless |
| `3987.0^12 + 4365.0^12 - 4472.0^12` | `1.2118937808588159e33` | floats: right size, last digits off |
| `big(3987)^12 + big(4365)^12 - big(4472)^12` | `1211886809373872630985912112862690` | exact, and not $0$: no counterexample |

## Factorial

The text mentions `factorial` but doesn't show you how to use it. Below is a table that does.

Results from the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook, where the code runs:

| Julia | result | type |
| :--- | :--- | :--- |
| `factorial(5)` | `120` | `Int64` |
| `factorial(20)` | `2432902008176640000` | `Int64` |
| `factorial(21)` | error | `OverflowError` |
| `factorial(big(21))` | `51090942171709440000` | `BigInt` |
| `prod(1:21)` | `-4249290049419214848` | `Int64` |

Notice how unlike the power function, the factorial function in Julia will throw an error if the result does not fit in the default integer type. In the example shown, we get an error message which actually suggests a solution!:

```text
OverflowError: 21 is too large to look up in the table; consider using `factorial(big(21))` instead
```

Also notice that the `prod` function multiplies in `Int64` and wraps around silently like `^`. If you want, use `prod(big(1):big(21))`.

Note that `factorial` only works for integers. For non-integers use the `gamma` function, which extends it to real (and complex) numbers using an integral. Since that is related to future lessons, we will skip the details here. The important thing to remember at this point, is that `gamma` shifts by 1 relative to factorial.

You can see examples of all of the above in the table below:

| Julia | result | type | note |
| :--- | :--- | :--- | :--- |
| `prod(big(1):big(21))` | `51090942171709440000` | `BigInt` | $= 21!$, no wrap-around |
| `factorial(5.0)` | error | `MethodError` | integers only |
| `factorial(-1)` | error | `DomainError` | not defined for negatives |
| `factorial(n)` | error | `AssertionError` | no symbolic factorial |
| `gamma(6)` | `120.0` | `Float64` | $\Gamma(6) = 5!$ |
| `gamma(4.5)` | `11.631728396567448` | `Float64` | $\Gamma(4.5) = 3.5!$ |
| `gamma(big(31)) == factorial(big(30))` | `true` | `Bool` | $\Gamma(n+1) = n!$ |

## Numeric Literals: numerals written in Julia syntax

Mathematicians make a distinction between _numbers_ which are abstract values and _numerals_ which are representations of those values. _Numeric literals_ are how numerals are written in Julia syntax. But the reverse isn't always true - numerals representing numbers in standard math are not always represented as numeric literals.

In Julia syntax there are also _names_ which are bound to values in various ways. For example `im` or `pi` are names that are bound to constant values. Variables are also names which are bound to values by assignment. And names are also bound to functions in various ways. `sin` is a name bound to a fixed function and `f(x) = x^2` binds `f` to a newly defined function. Names are often juxtaposed with numeric literals. This table should make things clear:

| Typed | Julia sees | Literal? |
| :--- | :--- | :--- |
| `2` | `Int64` | yes |
| `-1` | `Int64` | yes, the sign is part of it |
| `-1^2` | `-(1 ^ 2)` | no: only the `1` is a literal; `^` comes before the minus |
| `1_000` | `Int64` | yes |
| `1e-21` | `Float64` | yes |
| `1.0f0` | `Float32` | yes |
| `0x1F`, `0b101` | `UInt8` | yes |
| `10_000_000_000_000_000_000` | widened to `Int128` | yes, too big for `Int64` |
| `1//2` | a call to `//` | no, two literals |
| `2im` | `2 * im` | no, a juxtaposed literal and a name |
| `2sin(x)` | `2 * sin(x)` | no, a juxtaposed literal and a function call |
| `pi`, `im` | a name | no |

In the CWJSN section on `Numeric literals` the author asks what is the value of `2pi^2pi` and the author notes that the correct answer is `2 * (pi ^ (2pi))` because this is the "usual mathematical convention". He does not make clear why that is the case. The explanation is: the juxtaposed product `2pi` (a numeric literal `2`, written directly against the named constant `pi`) to the right of the exponent is read as a single term - i.e. the exponent itself. By contrast, using PEMDAS the power symbol (`^`) is tied to the term immediately to the left, i.e. the `pi`. Once the exponential term is calculated, we multiply it by the leftmost term.

Be sure to note that in this example, PEMDAS applies only to the left-hand side while on the right-hand side the juxtaposition rule applies. Without the juxtaposition, PEMDAS always applies. In the case of an explicit `*` with no juxtaposition, the usual PEMDAS order returns, so `2^3*x` is $2^3 \cdot x$, not $2^{3x}$ (last row in table below). Hence the author's advice to be explicit.

The table below gives examples of how Julia applies its rules, and shows why by first translating the Julia code to standard mathematical notation:

With $x = 2$:

| typed | Julia reads | value | not | value |
| :--- | :--- | :--- | :--- | :--- |
| `2pi^2pi` | $2\pi^{2\pi}$ | `2658.98` | $2\pi^{2}\cdot\pi$ | `62.01` |
| `2x^3` | $2x^{3}$ | `16` | $(2x)^{3}$ | `64` |
| `2^3x` | $2^{3x}$ | `64` | $2^{3}\cdot x$ | `16` |
| `2^3*x` | $2^{3}\cdot x$ | `16` | $2^{3x}$ | `64` |

## Logarithms in Julia vs on paper

| Julia | result | meaning |
| :--- | :--- | :--- |
| `log(x)` | `log(ℯ)` = `1` | natural log, $\ln x$ |
| `log10(x)` | `log10(1000)` = `3.0` | base 10, $\log_{10} x$ |
| `log2(x)` | `log2(8)` = `3.0` | base 2, $\log_2 x$ |
| `log(b, x)` | `log(2, 8)` = `3.0` | base $b$, $\log_b x = \dfrac{\ln x}{\ln b}$ |
| `ln(x)` | not defined | Julia has no `ln` |

On paper: school/engineering write $\log x$ for base 10 and $\ln x$ for base $e$; higher mathematics
(and Julia) write $\log x$ for the natural log, because

$$\frac{d}{dx}\ln x = \frac{1}{x} \qquad\text{while}\qquad \frac{d}{dx}\log_{10} x = \frac{1}{x \ln 10}.$$

Trap: `log(10, 1000)` = `2.9999999999999996` (it computes $\ln 1000 / \ln 10$); use `log10`.

---

## CWJSN calculator: Questions

Values marked * were not in my REPL session; they were added afterwards by Claude to complete the comparison. Try to answer on your own before looking at the answers.

| Q | Question (CWJSN) | My Julia → result | Answer | Why |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Compute $22/7$ | `22/7` → `3.142857142857143` | `3.142857142857143` | `/` always returns a `Float64` |
| 2 | Compute $\sqrt{220}$ | `sqrt(220)` → `14.832396974191326` | `14.832396974191326` | `sqrt` always returns a `Float64`, even for a perfect square: `sqrt(16)` → `4.0`\* |
| 3 | Compute $2^8$ | `2^8` → `256` | `256` | integer base and exponent stay `Int` |
| 4 | Compute $\frac{9 - 5 \cdot (3-4)}{6 - 2}$ | `(9 - 5* (3-4))/(6-2)` → `3.5` | `3.5` | numerator and denominator each need a pair of parentheses |
| 5 | Compute $\frac{(.25 - .2)^2}{(1/4)^2 + (1/3)^2}$ | `(.25 - .2)^2/((1/4)^2 + (1/3)^2)` → `0.014399999999999993` | `0.014399999999999993` | exact value is $0.0144$; `0.25 - 0.2` → `0.04999999999999999`\* because $0.2$ has no exact binary form |
| 6 | Decimal value of $1 + \frac{1}{2} + \frac{1}{2^2} + \frac{1}{2^3} + \frac{1}{2^4}$ | `1 + 1/2 + 1/2^2 + 1/2^3 + 1/2^4` → `1.9375` | `1.9375` | `^` before `/`, so `1/2^2` is $1/4$; exact, since powers of 2 are exact in binary |
| 7 | Compute $\frac{3 - 2^2}{4 - 2\cdot3}$ | `(3-2^2)/(4-(2*3))` → `0.5` | `0.5` | the inner `(2*3)` is optional: `*` before `-` |
| 8 | Compute $(1/2) \cdot 32 \cdot 3^2 + 100 \cdot 3 - 20$ | `(1/2) * 32 * 3^2 + 100 * 3 -20` → `424.0` | `424.0` | a `Float64` because of `1/2` |
| 9a | Oven at 200 Celsius: closest Fahrenheit of 350, 375, 400, 425, 450? | `((9/5) * 200) + 32` → `392.0` | 400 | $F = 9/5 \cdot C + 32$ |
| 9b | Internal 165 Fahrenheit: closest Celsius of 68, 70, …, 80? | `(5/9) * (165-32)` → `73.88888888888889` | 74 | $C = 5/9\,(F - 32)$ |
| 10 | Least parentheses for $\frac{3 - 2}{4 - 1}$ | `(3-2)/(4-1)` → `0.3333333333333333`; `(3 - 2)/ 4 - 1` → `-0.75`\*; `3 - 2 / (4 - 1)` → `2.3333333333333335`\* | `(3 - 2) / (4 - 1)` | `/` binds tighter than `-`, so both pairs are needed |
| 11 | Least parentheses for $\frac{3\cdot2}{4}$ | `3*2 /4` → `1.5`; `(3*2) /4` → `1.5` | `3 * 2 / 4` | `*` and `/` have equal precedence and go left to right, so `3*2` is done first anyway |
| 12 | Least parentheses for $2^{4 - 2}$ | `2 ^ (4-2)` → `4`; `2 ^ 4 - 2` → `14`\*; `(2 ^ 4) - 2` → `14`\* | `2 ^ (4 - 2)` | `^` binds tighter than `-`, so the exponent needs its pair |
| 13 | The Office: `9653 +` gives `11532`; what was added? | `11532- 9653` → `1879` | `1879` | check: `9653 + 1879` → `11532`\* |
| 14 | A more familiar expression for `1 / 2 / 3 / 4 / 5 / 6` | `1 / 2 / 3 / 4 / 5 / 6` → `0.001388888888888889`; `1 / (2 / 3 / 4 / 5 / 6)` → `180.0`; `1 /(2 * 3 * 4 * 5 * 6)` → `0.001388888888888889`; `1 / 2 * 3 / 4  * 5 / 6` → `0.3125`; `1 / 2 / 3 / 4 / 5 / 6 *  (2/2) * (3/3) * (4/4) * (5/5) * (6/6)` → `0.001388888888888889` | `1 /(2 * 3 * 4 * 5 * 6)` | `/` goes left to right, so dividing by each number in turn is dividing by their product. `2 / 3 / 4 / 5 / 6` is $2/360 = 1/180$, so its reciprocal is 180; `1 / 2 * 3 / 4 * 5 / 6` is $\frac{1\cdot3\cdot5}{2\cdot4\cdot6} = \frac{15}{48}$ |
| 15 | Which gives a different answer: `2 - 3 - 4`, `(2 - 3) - 4`, `2 - (3 - 4)` | `(2 - 3) - 4` → `-5`; `2 - (3 - 4)` → `3`; `2 - 3 - 4` → `-5` | `2 - (3 - 4)` | `-` is left-associative: `2 - 3 - 4` means `(2 - 3) - 4` |
| 16 | Which gives a different answer: `2 - 3 * 4`, `(2 - 3) * 4`, `2 - (3 * 4)` | `(2 - 3) * 4` → `-4`; `2 - (3 * 4)` → `-10`; `2 - 3 * 4` → `-10` | `(2 - 3) * 4` | `*` before `-`, so `2 - 3 * 4` means `2 - (3 * 4)` |
| 17 | Which gives a different answer: `-1^2`, `(-1)^2`, `-(1^2)` | `-(1^2)` → `-1`; `-1^2` → `-1`; `(-1)^2` → `1` | `(-1)^2` | `^` before unary minus: `-1^2` parses as `-(1 ^ 2)`\* |
| 18 | Value of $\sin(\pi/10)$ | `sin(pi/10)` → `0.3090169943749474` | `0.3090169943749474` | `sin` takes radians |
| 19 | Value of $\sin(52^\circ)$ | `sind(52)` → `0.788010753606722` | `0.788010753606722` | `sind` takes degrees |
| 20 | Value of $\frac{\sin(\pi/3) - 1/2}{\pi/3 - \pi/6}$ | `(sin(pi/3)-(1/2))/((pi/3)-(pi/6))` → `0.6990570277140041` | `0.6990570277140041` | the whole denominator needs one pair; the inner pairs are optional |
| 21 | Is $\sin^{-1}(\sin(3\pi/2))$ equal to $3\pi/2$? | `asin(sin(3pi/2))` → `-1.5707963267948966`; `3pi/2` → `4.71238898038469` | No | `asin` returns an angle in $\lbrack -\pi/2, \pi/2 \rbrack$; $\sin(3\pi/2) = -1$, and the angle in that range with sine $-1$ is $-\pi/2$ (`asin(sin(3pi/2)) == -pi/2` → `true`\*) |
| 22 | Value of `round(3.5000)` | `round(3.5000)` → `4.0` | `4.0` | `round` keeps the type (`Float64`); `round(Int, 3.5)` → `4`\*. Ties go to the even neighbour: `round(2.5)` → `2.0`\* |
| 23 | Value of `sqrt(32 - 12)` | `sqrt(32 - 12)` → `4.47213595499958` | `4.47213595499958` | $\sqrt{20} = 2\sqrt{5}$; `2sqrt(5)` → `4.47213595499958`\* |
| 24 | Which is greater, $e^\pi$ or $\pi^e$? | `ℯ^pi > pi^ℯ` → `true` (`ℯ` typed as `\euler` then Tab) | $e^\pi$ | `ℯ^pi` → `23.140692632779267`\*, `pi^ℯ` → `22.459157718361038`\*. Without the Tab: `exp(pi) > pi^exp(1)` → `true`\* (`exp(1)` is $e$ as a `Float64`), or `MathConstants.e`, the same constant as `ℯ`\*; `using Base.MathConstants: e` then lets you write plain `e`\*. A plain `e` is not predefined |
| 25 | Value of $\pi - (x - \sin(x)/\cos(x))$ when $x = 3$ | `x = 3 ; pi - (x - sin(x)/cos(x))` → `-0.0009538894844847157` | `-0.0009538894844847157` | `x - sin(x)/cos(x)` → `3.142546543074278`\*: one Newton step for $\sin x = 0$ from $x = 3$, already close to $\pi$ |
| 26 | What is $10!$? | `factorial(10)` → `3628800` | `3628800` | `!` is not a factorial operator in Julia |
| 27 | Will `-2^2` produce `4` or `-4`? | `-2^2` → `-4` | `-4` | as Q17: parses as `-(2 ^ 2)`\* |
| 28a | Twitter post: $8 \div 2(2+2)$ — what is the answer by strict left-to-right PEMDAS? | `8/2*(2+2)` → `16.0`; `8/(2*(2+2))` → `1.0` | `16` | the chapter takes strict left-to-right PEMDAS, treating `2(2+2)` as an ordinary multiplication; reading implied multiplication as binding tighter gives 1. A choice of convention |
| 28b | Does `Julia` give the strict left-to-right PEMDAS answer for `8÷2(2+2)`? Why or why not? | `8÷2(2+2)` → `1`; `8 ÷ (2 * (2 + 2))` → `1` | No; Julia gives numeric literal coefficients higher precedence than `*`, `/` and `÷` | Julia reads `8 ÷ (2 * (2 + 2))`; `÷` is integer division, so the result is an `Int` |
| 29 | Sagan's number, 10 sextillion ($10^{22}$): which entry does _not_ work? `10*10^21`, `10*10.0^21`, `10e21`, `1e22`, `10_000_000_000_000_000_000_000` | `10*10^21` → `1864712049423024128`\*; `10*10.0^21` → `1.0e22`\*; `10e21` → `1.0e22`\*; `1e22` → `1.0e22`\*; `10_000_000_000_000_000_000_000` → `10000000000000000000000`\* | `10*10^21` | `10^21` has an integer base, so it overflows `Int64` and wraps silently: `10^18` → `1000000000000000000`\* is the last power that fits; `10^19` → `-8446744073709551616`\*, past `typemax(Int64)` = `9223372036854775807`\*. A float base (`10.0^21`) or a float literal (`10e21`, `1e22`) does not overflow; the long literal is parsed as `Int128`\* |
| 30 | Planck length $l_p = \sqrt{\hbar G / c^3}$ comes out near $10^{-32}$, not $10^{-35}$. Why? | with `c = 299_792_458;` `planck_length = sqrt(h_bar * G / c^3)` → `3.5793584153084007e-32`; with `c = big(299_792_458)` → `1.6162550244237053…e-35` (full value below) | "`Julia` computes this value incorrectly" | `c^3` overflows `Int64` silently: `299_792_458^3` → `5493783091195596520`\*, but the true value is `26944002417373989539335912`\*, above `typemax(Int64)` = `9223372036854775807`\*. `big(c)` fixes it, as does a float: `c = 299792458.0` gives `1.6162550244237053e-35`\* |

Q30 with `c = big(299_792_458)`, in full: `1.616255024423705337061393098475417498117496219791154915828327386777545429675462e-35`
