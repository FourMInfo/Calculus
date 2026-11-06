# Inequalities and Logical Expressions

Commentary on the CWJSN chapter [Inequalities and Logical Expressions](https://fourm.info/cwjsn/basics/logical_expressions.html).

## Geometric Mean expressed in Julia

It is not clear why Verzani chose in CWJSN to use the expression `(a * b)^(1/2)` in the example about the geometric mean, rather than `sqrt(a * b)` as the code for the expression $g = \sqrt{ab}$. A related question is whether `sqrt(a * b) == (a * b)^(1/2)` is always `true`. I asked Claude to provide some insight on this.

The geometric mean of $n$ numbers is

$$G = \left(x_1 x_2 \cdots x_n\right)^{1/n}, \qquad n = 2:\ G = (ab)^{1/2} = \sqrt{ab},$$

so the power form shows the definition and generalizes by changing the exponent. In the same CWJSN code block, the next line uses `sqrt` for the quadratic mean, so the choice may be stylistic.

| Measured (Julia 1.13.2, $10^7$ values of `rand()`) | Result |
| :--- | :--- |
| `x^(1/2) != sqrt(x)` | about 1.05% of values |
| largest difference | 1 ulp (unit in the last place) |
| example $x$ | `0.7092888978478461` |
| `x^(1/2)` | `0.8421929101149249` |
| `sqrt(x)` (correctly rounded) | `0.842192910114925` |

As for whether the two different expressions are `==`, running a test returns `false` for some inputs. With `a = 0.7092888978478461` and `b = 1.0` (chosen so the product will be equal to `x` in the table above):

```julia
a = 0.7092888978478461; b = 1.0
sqrt(a * b) == (a * b)^(1/2)   # false
sqrt(a * b)                    # 0.842192910114925
(a * b)^(1/2)                  # 0.8421929101149249
```

Over a million pairs from `rand(2)`, 9,650 gave `false`, about 1 in 100.

**Why the two results differ:**

- **The exponent isn't the cause.** `1/2` is exactly `0.5` in binary, so `(a*b)^(1/2)` really does ask for the power 0.5.
- **`sqrt` always returns the closest floating-point number to the true root.** The IEEE floating-point standard requires that of square root, and the processor has an instruction for it.
- **`^` with a `Float64` exponent uses a general power routine.** It is built to be accurate to within about 1 unit in the last place for any exponent, but it doesn't promise the closest number. About 1% of the time it lands one step away from what `sqrt` gives.

Both results are within 1 unit in the last place of the true root, so `sqrt(a * b) ≈ (a * b)^(1/2)` is always `true`. It's the same `==` versus `≈` lesson as in the [Overflow, rounding and `≈`](03 Number Systems.md#Overflow,-rounding-and) section: two different routes to the same real number can land on adjacent floats.

## The bitwise operators

Verzani mentions bitwise operators but he doesn't explain them at all. He just says a few words about their precedence. So I asked Claude to write something up about bitwise operators. An extensively edited (by me) version follows.

### What "bitwise" means

An integer is stored as a row of binary bits. For the purpose of bitwise operation, each bit is assigned a logical value. The bit `1` is equivalent to `true` and the bit `0` to `false`. Bitwise operators apply a logical function to the bits. Binary bitwise operators combine two rows of bits, operating on the two matched bits, position by position.

The bitwise operators `&` and `|` apply the truth value function of `and` and `or` respectively. Hence `&` puts a 1 only where both bits are 1, and `|` puts a 1 where either bit is 1.

Using the function `bitstring` that shows the bits in the rows, we get the following:

```julia
bitstring(Int8(12))        # "00001100"
bitstring(Int8(10))        # "00001010"
12 & 10                    # 8   = 00001000
12 | 10                    # 14  = 00001110
```

On truth values, `&` and `|` apply the same truth value function as `&&` and `||`, but they differ from them in four ways discussed below.

### 1. Both sides are always evaluated

`&&` and `||` stop evaluating expressions as soon as the answer is known, which is why they are called shortcut (short-circuit) operators. `&` and `|` always evaluate both sides first.

A _guard_ is a condition placed first so that the expression after it runs only when that is safe. In `x >= 0 && sqrt(x) > 1`, the test `x >= 0` guards `sqrt(x)`: when `x` is negative, `&&` already knows the answer is `false` and never calls `sqrt`. So a guard only works with `&&` (and `||`), not with `&` (or `|`):

```julia
x = -4
x >= 0 && sqrt(x) > 1        # false: sqrt is never called
(x >= 0) & (sqrt(x) > 1)     # DomainError with -4.0: sqrt runs anyway
```

### 2. Precedence: above the comparisons, not below

`Base.operator_precedence` gives the levels (higher binds tighter):

```julia
Base.operator_precedence.([:&, :*, :|, :+, :<, :&&, :||])   # [12, 12, 11, 11, 7, 6, 5]
```

So `&` sits with `*` and `|` with `+`, both above the comparisons (`<` and the rest, 7), while `&&` and `||` sit below them.

`&&` and `||` bind more loosely than the comparisons, so `x > 0 && x < 10` needs no parentheses. `&` and `|` bind more tightly than the comparisons, so Julia joins `0 & x` before it compares anything:

```julia
x = 20
x > 0 & x < 10          # true  -- parsed as x > (0 & x) < 10, a chained comparison
(x > 0) & (x < 10)      # false -- the intended "0 < x < 10"
```

This gives no error, just a wrong answer. The same thing happens with CWJSN's $\lvert x-5\rvert > 7$:

```julia
x = 18
x - 5 < -7 | x - 5 > 7        # false -- parsed as x - 5 < ((-7 | x) - 5) > 7
(x - 5 < -7) | (x - 5 > 7)    # true
```

**Rule:** with `&` and `|`, put every comparison in parentheses.

### 3. What the operands may be

`Bool` is Julia's type for truth values. It has exactly two values, `true` and `false`, and a comparison such as `3 > 2` returns one (`typeof(3 > 2)` is `Bool`). `Bool` is a subtype of `Integer`, with `true == 1` and `false == 0`, so arithmetic works on it (`true + true` is `2`). It is stored in a whole byte, not a single bit: `bitstring(true)` is `"00000001"`.

`&&` and `||` require a `Bool` on the left (`1 && true` is a TypeError: non-boolean (Int64) used in boolean context). The right side is returned as it is, so `true && 5` returns `5`. `&` and `|` are integer operations, so `true & 5` returns `1` (an `Int`), and `5 & 3.0` is a MethodError: there is no bitwise "and" for floats.

### 4. Where `&` and `|` are the right tool: vectors

`&&` asks for one `true` or `false`, so it refuses a vector of them:

```julia
v = [-3, 2, 5, 12]
(v .> 0) && (v .< 10)       # TypeError: non-boolean (BitVector) used in boolean context
(v .> 0) .& (v .< 10)       # Bool[0, 1, 1, 0]
v[(v .> 0) .& (v .< 10)]    # [2, 5] -- keep the entries between 0 and 10
(v .< 0) .| (v .> 10)       # Bool[1, 0, 0, 1]
```

#### What `v[(v .> 0) .& (v .< 10)]` does

The expression listed in the code above needs some explanation. First, it is read from the inside out, with `v = [-3, 2, 5, 12]`. So step by step we see:

```julia
v = [-3, 2, 5, 12]
v .> 0                     # Bool[0, 1, 1, 1]  is each entry > 0?
v .< 10                    # Bool[1, 1, 1, 0]  is each entry < 10?
(v .> 0) .& (v .< 10)      # Bool[0, 1, 1, 0]  "and", applied entry by entry
v[Bool[0, 1, 1, 0]]        # [2, 5]            keep the entries marked true
```

1. **The dot broadcasts.** `v .> 0` compares each entry of `v` with 0 and gives one truth value per entry. The result is a `BitVector`, a vector of truth values packed one per bit, which prints as `Bool[…]`.
2. **`.&` applies "and" to each pair.** Position by position it combines the two vectors: true only where the entry is both > 0 and < 10.
3. **Indexing with a vector of truth values selects.** When the index is a vector of `true`/`false` the same length as `v`, `v[mask]` returns the entries where the mask is `true`, in order. This is called _logical indexing_. The mask must have the same length as `v`; `v[[true, false]]` is a BoundsError.

It is the same as finding the positions first and then indexing with them: `findall(mask)` gives `[2, 3]`, and `v[[2, 3]]` gives `[2, 5]`.

Two other ways to write the same selection:

```julia
v = [-3, 2, 5, 12]
v[0 .< v .< 10]                  # [2, 5]  the chained comparison, broadcast
filter(x -> 0 < x < 10, v)       # [2, 5]  keep the x for which the test is true
```

#### Is it nonetheless possible to use `&&` on vectors? Only the dotted version: `.&&`

Since Julia 1.7 there are also `.&&` and `.||`. They have the low precedence of `&&`, so `v .> 0 .&& v .< 10` is correct without parentheses (`Bool[0, 1, 1, 0]`).

Plain `&&` still refuses a vector. By contrast, the dotted `.&&` applies `&&` to each matched pair of entries. This is indicated by the Julia 1.7 release notes which state: "The short-circuiting operators `&&` and `||` can now be dotted to participate in broadcast fusion as `.&&` and `.||`." We can see this in action:

```julia
v = [-3, 2, 5, 12]
(v .> 0) && (v .< 10)      # TypeError: non-boolean (BitVector) used in boolean context
v .> 0 .&& v .< 10         # Bool[0, 1, 1, 0]
```

The short-circuit survives, entry by entry, because the whole dotted expression is fused into one loop:

```julia
x = [-4, 4]
x .>= 0 .&& sqrt.(x) .> 1          # Bool[0, 1] -- sqrt(-4) is never called
(x .>= 0) .& (sqrt.(x) .> 1)       # DomainError -- sqrt.(x) runs on every entry first
```

The Julia manual ("Noteworthy differences from other languages", MATLAB section) recommends `.&&` and `.||` for logic over arrays, e.g. `A .== 1 .|| A .== 2`.

### `missing`

Both kinds of logical operators use the same three-valued logic, and the result is `missing` only when the unknown value could change the answer. `&` and `|` accept `missing` on either side, but `&&` and `||` accept it only on the right:

```julia
true  & missing      # missing -- depends on the unknown
false & missing      # false   -- false whatever the unknown is
true  | missing      # true
false | missing      # missing
missing && true      # TypeError: non-boolean (Missing) used in boolean context
true && missing      # missing -- the right side is returned as it is
```

### The other bitwise operators

The manual ("Mathematical Operations", "Bitwise Operators") lists nine operators for integers: `~`, `&`, `|`, `⊻`, `⊼`, `⊽`, `>>>`, `>>`, `<<`. Using the same two rows as before (as `Int8`, so that `bitstring` shows 8 bits):

```julia
a, b = Int8(12), Int8(10)   # 00001100, 00001010
~a           # -13  = 11110011   not: flip every bit
a ⊻ b        #   6  = 00000110   xor: 1 where the bits differ
a ⊼ b        #  -9  = 11110111   nand: not (a & b)
a ⊽ b        # -15  = 11110001   nor:  not (a | b)
```

`⊻` is typed `\xor` Tab, `⊼` is `\nand` Tab and `⊽` is `\nor` Tab. Each one also has a name you can call: `xor(a, b)`, `nand(a, b)`, `nor(a, b)`.

Flipping every bit gives a negative number because of how integers store their sign (two's complement): `~x == -x - 1` for every integer, so `~5` is `-6`.

### On truth values

```julia
~true            # false -- the same as !true
~5               # -6
!5               # MethodError: ! is only for Bool
true ⊻ true      # false -- "exactly one of them is true"
true ⊻ false     # true  (on truth values, ⊻ applies the same truth-value function as !=)
true ⊼ true      # false
false ⊽ false    # true
true ⊻ missing   # missing
```

So `!` is the logical "not" and only takes a `Bool`, while `~` is the bitwise "not" and takes any integer. Like `&` and `|`, all of these evaluate both sides and broadcast with a dot: `[true, false] .⊻ [true, true]` gives `Bool[0, 1]`, and `.~[true, false]` gives `Bool[0, 1]`.

### Shifts

A shift slides the whole row of bits left or right. Bits that fall off the end are lost.

```julia
1 << 3              # 8   -- shifting left by n multiplies by 2^n
5 >> 1              # 2   -- shifting right by n divides by 2^n, rounding down
-16 >> 2            # -4  -- >> copies the sign bit into the new places (arithmetic shift)
Int8(-16) >>> 2     # 60  -- >>> fills them with 0s (logical shift): 11110000 → 00111100
Int8(64) << 1       # -128 -- the 1 slides into the sign bit: overflow wraps, as with *
1 << 64             # 0   -- every bit has fallen off an Int64
```

### Precedence of all of them

```julia
Base.operator_precedence.([:^, :<<, :>>, :>>>, :*, :&, :⊼, :+, :|, :⊻, :⊽, :<])
# [15, 14, 14, 14, 12, 12, 12, 11, 11, 11, 11, 7]
```

So the shifts bind more tightly than `*` but less tightly than `^`, the "and" family (`&`, `⊼`) sits with `*`, and the "or" family (`|`, `⊻`, `⊽`) sits with `+`. In C the shifts bind more loosely than `+`, so code copied from C can change meaning: in Julia, `1 << 2 + 1` is `(1 << 2) + 1 = 5`, while in C it is `1 << 3 = 8`. All of these sit above the comparisons. Hence the rule from the previous section applies to every one of them: **_put each comparison in parentheses_**.

---

## CWJSN logical_expressions: Questions

Values marked * were not in my REPL session; they were added afterwards by Claude to complete the comparison. As always, try to answer on your own before looking at the answers.

| Q | Question (CWJSN) | My Julia → result | Answer | Why |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Is `e^pi` or `pi^e` greater? | `ℯ^pi` → `23.140692632779267`; `pi^ℯ` → `22.459157718361038`; `ℯ^pi > pi^ℯ` → `true` | `e^pi` is greater | the two values differ by about 0.68, far more than any rounding error, so the `Float64` comparison can be trusted |
| 2 | Is $\sin(1000)$ positive? | `sin(1000)` → `0.8268795405320025`; `sin(1000) > 0` → `true` | Yes | 1000 radians is a whole number of turns plus `mod(1000, 2pi)` → `0.9735361584457891`\* radians, which lies in the first quadrant, where sine is positive |
| 3 | Suppose $0 < a < b$. How are $-1/a$ and $-1/b$ related? | `b = 10`, `a = 5`: `0 < a < b` → `true`; `1/a > 1/b` → `true`; `-1/b > -1/a` → `true` | $-1/a < -1/b$ | for positive numbers, taking reciprocals reverses the order ($1/a > 1/b$), and negating reverses it again |
| 4 | Suppose $a < 0 < b$. Is $1/a > 1/b$? | `a = -5` (`b = 10`): `a < 0 < b` → `true`; `1/b > 1/a` → `true` | It is never true | $1/a$ is negative and $1/b$ is positive, whatever the values of $a$ and $b$ |
| 5 | `airyai` is positive for $x > 0$. Which is the first negative value: `airyai(-1) < 0`, …, `airyai(-5) < 0`? | `for i in -5:-1 println(i,airyai(i) < 0) end` → `-5false`, `-4true`, `-3true`, `-2false`, `-1false` | `airyai(-3) < 0` | counting down from $-1$: $-1$ and $-2$ are still positive, and $-3$ is the first negative value. For negative $x$ the function oscillates, so $-5$ is positive again |
| 6 | By trying three values of $x > 0$: which could be always true, `x^x <= (1/e)^(1/e)`, `x^x == (1/e)^(1/e)` or `x^x >= (1/e)^(1/e)`? | `for i in rand()*(1:3) println((i,i^i >= (1/ℯ)^(1/ℯ))) end` → `true` three times ($i \approx 0.31, 0.62, 0.93$); the same loop with `==` → `false` three times; with `<=` → `false` three times | `x^x >= (1/e)^(1/e)` | $x^x$ has its minimum at $x = 1/e$, where it equals $(1/e)^{1/e} \approx 0.6922$. Values of $x$ below 1 are the real test: there $x^x < 1$, yet still $\ge 0.6922$ |
| 7 | Which is true for $x, y > 0$ and $0 < p < 1$: `(x+y)^p < x^p + y^p`, `==` or `>`? | `for i in 1:3,j=4:6,k = 0.5 println((i,j,k, (i+j)^k < i^k + j^k)) end` → `true` for all 9 pairs; the same loop with `>` → `false` for all 9; with `==` → `false` for all 9 | `(x+y)^p < x^p + y^p` | with $p = 1/2$, square both sides of $\sqrt{x+y} < \sqrt{x} + \sqrt{y}$: $x + y < x + y + 2\sqrt{xy}$, true whenever $x, y > 0$ |
| 8 | Which is always true for $a, b > 0$: `a^a + b^b <= a^b + b^a`, `a^a + b^b >= a^b + b^a` or `a^b + b^a <= 1`? | `for i in rand()*(1:3),j=rand()*(4:6) println((i,j, i^i + j^j >= i^j + j^i)) end` → `true` for all 9 pairs; the same loop with `<=` → `false` for all 9; with `==` → `false` for all 9 | `a^a + b^b >= a^b + b^a` | this is Ilani's inequality; the two sides are equal when $a = b$. The third option fails already at $a = b = 1$: `1^1 + 1^1 <= 1` → `false`\* |
| 9 | Is 3 in the set $\lvert x - 2\rvert < 1/2$? | `x = 3`; `abs(x-2) < 1/2` → `false` | No | $\lvert 3 - 2\rvert = 1$, which is not less than $1/2$ |
| 10 | Which is equivalent to $\lvert x - a\rvert > b$? | `x, a, b = 5, 3, 1`: `abs(x-a) > b` → `true`; `x, a, b = 5, 7, 1`: `abs(x-a) > b` → `true`, `-b > x -a` → `true` | $x - a < -b$ or $x - a > b$ | $\lvert y\rvert > b$ means $y$ lies more than $b$ away from 0, on either side: at $(5, 3, 1)$, $x - a = 2 > 1$; at $(5, 7, 1)$, $x - a = -2 < -1$. The other two options describe $\lvert x - a\rvert < b$, the opposite |
| 11 | If $\lvert x - \pi\rvert < 1/10$, is $\lvert \sin(x) - \sin(\pi)\rvert < 1/10$? | three runs of `x = pi + 1/10 * (2rand()-1)` ($x \approx 3.112, 3.167, 3.074$), each followed by `abs(x - pi) < 1/10, abs(sin(x) - sin(pi)) < 1/10` → `(true, true)` | True | $\sin\pi = 0$ and $\lvert\sin x\rvert = \lvert\sin(x - \pi)\rvert \le \lvert x - \pi\rvert < 1/10$, because $\lvert\sin u\rvert \le \lvert u\rvert$ for every $u$ |
| 12 | Does 12 satisfy $\lvert x - 3\rvert + \lvert x - 9\rvert > 12$? | `x = 12`; `abs(x -3) + abs(x-9) > 12` → `false` | No | $9 + 3 = 12$: the two sides are equal, so "greater than" is false |
| 13 | Which shows DeMorgan's law holds when both values are `false`? | see the code below the table | the third option | see the code below the table |
| 14 | For `Inf` and `NaN`: for which are both comparisons always `false`, `Inf < 3.0` and `3.0 <= Inf`, or `NaN < 3.0` and `3.0 <= NaN`? | `NaN < 3.0` → `false`; `3.0 <= NaN` → `false`; `Inf < 3.0` → `false`; `3.0 <= Inf` → `true` | `NaN < 3.0` and `3.0 <= NaN` | every comparison with `NaN` is `false`; `Inf` is greater than 3.0, so `3.0 <= Inf` is `true` |
| 15 | Do the four IEEE 754 facts hold in Julia: $+0$ equals but is not greater than $-0$; `Inf` equals itself and is greater than everything except `NaN`; `-Inf` likewise, less; `NaN` is not equal to, less than or greater than anything, itself included? | `-0.0 == 0.0` → `true`; `0.0 > -0.0` → `false`; `Inf == Inf` → `true`; `Inf > floatmax(Float64)` → `true`; `-Inf == -Inf` → `true`; `-Inf < -floatmax(Float64)` → `true`; `Inf > NaN`, `Inf == NaN`, `Inf < NaN` → `false`; `Inf != NaN`, `-Inf != NaN` → `true`; `NaN != NaN` → `true`; `NaN > NaN`, `NaN < NaN` → `false`; `NaN != nextfloat(0.0)` → `true` | Yes | `floatmax(Float64)` is the largest finite `Float64` and `nextfloat(0.0)` the smallest positive one, so they test the facts at the edges |
| 16 | `true && missing` gives `missing`, and the same with "or" gives `true`. Why each value? | see the code below the table | the first option, both times | see the code below the table |

**Q13 (DeMorgan's law)**, the three options:

```julia
!(false && false) == (!false && !false)   # true
!(false && false) == (false || false)     # false
!(false && false) == (!false || !false)   # true
```

Two options return `true` when both values are `false`, so this run alone cannot decide. DeMorgan's law is `!(a && b) == (!a || !b)`, the third option. The first is not a law: it fails when the values differ.

```julia
!(true && false) == (!true && !false)   # false *
```

**Q16 (`missing`)**:

```julia
true && missing, true || missing   # (missing, true)
```

- `true || missing` → `true`: in `a || b`, `b` is evaluated only if `a` is `false`. Here `a` is `true`, so `true` is returned and `missing` is never looked at.
- `true && missing` → `missing`: in `a && b`, `b` is evaluated only if `a` is `true`. Here it is, so `b` is evaluated and returned, and `b` is `missing`.

The second option for `||` claims `false || missing` would be `false`. It is not:

```julia
false || missing   # missing *
```
