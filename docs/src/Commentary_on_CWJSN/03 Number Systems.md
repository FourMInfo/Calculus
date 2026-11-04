# Number Systems

Commentary on the CWJSN chapter [Number Systems](https://fourm.info/cwjsn/basics/numbers_types.html). The code behind the results shown here runs in the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook.

## Some Gotchas and Clarifications

### `1.`, `2.*3` and the broadcasting dot

In this chapter, in the "Heads up" paragraph regarding `2.*3`, Verzani brings up broadcasting without explaining it. Broadcasting is a powerful operation in Julia which applies a function or operator to each element of a collection such as a vector or tuple. The table below shows how broadcasting works, and why the `.` causes parsing ambiguity.

Measured with Julia 1.13.2:

| input | result |
| --- | --- |
| `1.` | `1.0` (a `Float64`) |
| `2. * 3` | `6.0`: the dot belongs to the `2` |
| `2 .* 3` | `6`: the dot belongs to the `*` (broadcast) |
| `2 .* (3, 6)` | `(6, 12)`: the dot belongs to the `*` (a more realistic broadcast EXAMPLE) |
| `2.*3` | `ParseError: ambiguous '.' syntax; add whitespace to clarify` |

### Number Representation

Verzani mentions the problem of rounding error, where for example `sqrt(2) * sqrt(2) - 2` produces the very small number `4.440892098500626e-16` instead of zero. What he leaves off is the standard  solution used to address this problem in Julia: `sqrt(2) * sqrt(2) ≈ 2` which yields `true`.

He also seems to imply that integer overflow is in a different category than rounding errors. The source of the error is actually the same - the size of memory used to store numbers. How the error manifests itself is slightly different: a seemingly arbitrary result as opposed to a tiny residue. But the residue is also not mathematically correct and does not exist according to mathematical definitions. Rather, it arises only inside a computer because a number with no finite binary expansion (such as $\sqrt{2}$ or $1/10$) cannot be stored exactly in a finite number of bits.

Hence, the key to avoiding and handling these errors is understanding how numbers are represented in computers. That is why in the earlier section on [Big Numbers](01 From Calculator to Computer.md#Big-Numbers) I stressed that taking the power of a float instead of an integer is not always the best solution, as you are just substituting one memory issue for another. What does differ is how to fix the problem:

- **Overflow** is purely a size limit, and more bits remove it completely: `big(2)^64` yields `18446744073709551616`, exact.
- **Rounding** is also about the binary format: $\sqrt{2}$ and $1/10$ have no finite binary expansion, so more bits shrink the error but never remove it. `sqrt(big(2)) * sqrt(big(2)) - 2` yields `-1.7272…e-77`, still not zero. Hence use the function `isapprox()` or `≈` when comparing floats.
- Float overflow also looks different from integer overflow: `2.0^1024` yields `Inf`, whereas `typemax(Int64) + 1` wraps to `-9223372036854775808`.

In the next section you can see examples (created by Claude) of what is discussed here.

### Overflow, rounding and `≈`

Measured with Julia 1.13.2.

| error | example → result | why | fix → result |
| --- | --- | --- | --- |
| integer overflow | `typemax(Int64) + 1` → `-9223372036854775808`; `2^64` → `0` | `Int64` arithmetic wraps around silently | more bits remove it: `big(2)^64` → `18446744073709551616`, exact |
| float rounding | `sqrt(2) * sqrt(2) - 2` → `4.440892098500626e-16` | $\sqrt{2}$ has no finite binary expansion | more bits only shrink it: `sqrt(big(2)) * sqrt(big(2)) - 2` → `-1.7272…e-77`; compare with `≈` (next table) |
| float rounding of π | `sin(1pi)` → `1.2246467991473532e-16` | `1pi` is a `Float64`, the float nearest π but not π (`1pi == pi` → `false`), so its sine is not 0 | keep `pi` an `Irrational`: `sin(pi)` → `0.0`, because Base defines `sin(::Irrational{:π}) = 0.0` (`mathconstants.jl:146`) |
| float overflow | `2.0^1024` → `Inf` | above `floatmax(Float64)` → `1.7976931348623157e308` | `big(2.0)^1024` → `1.7976931348623159…e308` |

`≈` is typed `\approx` then Tab; it is the same function as `isapprox(a, b)`.

| comparison | with `==` | with `≈` |
| --- | --- | --- |
| `0.1 + 0.2` and `0.3` | `false` | `true` |
| `sqrt(2) * sqrt(2)` and `2` | `false` | `true` |
| `1/10 + (2/10 + 3/10)` and `(1/10 + 2/10) + 3/10` | `false` | `true` |
| `0.1 + 0.2 - 0.3` and `0` | `false` | `false`: the trap (below) |
| `isapprox(0.1 + 0.2 - 0.3, 0; atol=1e-12)` | not applicable | `true` |

The trap: by default `≈` uses a _relative_ tolerance of about `1.49e-8` (`sqrt(eps(1.0))`), scaled by the larger of the two numbers. `isapprox(1.0, 1.0 + 1e-9)` → `true`, but `isapprox(1.0, 1.0 + 1e-7)` → `false`. Against `0` the tolerance scales down with the other number, so any non-zero value fails. `0.1 + 0.2 - 0.3` is `5.551115123125783e-17`, not `0`. To compare with zero, give an absolute tolerance with `atol`.

### Abstract and concrete types

Every value in Julia has exactly one _concrete_ type, which `typeof` returns: `typeof(1)` → `Int64`, `typeof(1.0)` → `Float64`. A concrete type exactly describes how the value is stored in computer memory. `Int8(1)` and `1` are the same integer, but `sizeof` gives 1 byte for the first and 8 for the second.

An _abstract_ type is a name for a group of types. It allows you to specify what kind of value a variable or function argument might contain, without determining up front how it is stored in memory. No value has an abstract type as its `typeof`. You can only ask whether a value belongs to one, with `isa`: `1 isa Integer` → `true`, `1 isa Real` → `true`, `1.0 isa Integer` → `false`.

Types form a hierarchy, a tree with `Any` at the top and the concrete types as its leaves. The function `supertypes` lists the chain upward from a concrete type:

- `supertypes(Int64)` → `(Int64, Signed, Integer, Real, Number, Any)`
- `supertypes(Float64)` → `(Float64, AbstractFloat, Real, Number, Any)`
- `supertypes(Complex{Int64})` → `(Complex{Int64}, Number, Any)`: `Complex` sits directly under `Number`, which is why a complex number is a `Number` but not a `Real`.

It's important to note: Verzani's remark that `Rational` and `Complex` "aren't even concrete types" does not mean they are abstract. They are _parametric_ types: families that become concrete once the type of their parts is given. `typeof(1//1)` → `Rational{Int64}`, `typeof(1 + 0im)` → `Complex{Int64}`, `typeof(1.0 + 0im)` → `ComplexF64` (short for `Complex{Float64}`).

| type | kind | `isabstracttype` | `isconcretetype` |
| --- | --- | --- | --- |
| `Number`, `Real`, `Integer` | abstract | `true` | `false` |
| `Int64`, `Int8`, `BigInt`, `Float64` | concrete | `false` | `true` |
| `Rational`, `Complex` | parametric family | `false` | `false` |
| `Rational{Int64}`, `Complex{Float64}` | concrete | `false` | `true` |

Abstract types let one function cover many concrete types. With `twice(x::Real) = 2x`, `twice(3)` → `6`, `twice(1.5)` → `3.0`, `twice(1//3)` → `2//3` and `twice(big(10)^20)` → `200000000000000000000`. But `twice(1 + 2im)` → `MethodError: no method matching twice(::Complex{Int64})`, because `Complex` is not `Real`.

`supertypes` comes from the standard library `InteractiveUtils`, and is not always available in your workspace. The Julia REPL loads `InteractiveUtils` for you; `using Calculus` does not. Hence, if Julia says `supertypes` is not defined, run `using InteractiveUtils` first. By contrast, Base's `supertype` (singular) always works and gives one step at a time: `supertype(Int64)` → `Signed`.

### Scientific notation: base 10 on Wikipedia, base 2 in a `Float64`

Verzani in this chapter writes a float as $a\cdot 2^b$ with $1 \leq \lvert a\rvert < 2$; the Wikipedia article he links uses $a\cdot 10^b$ with $1 \leq \lvert a\rvert < 10$. The idea is the same in any base $\beta$: $a\cdot\beta^b$ with $1 \leq \lvert a\rvert < \beta$. A `Float64` uses $\beta = 2$ because the hardware stores bits.

| `x` | `significand(x)` | `exponent(x)` | so `x` is |
| --- | --- | --- | --- |
| `6.0` | `1.5` | `2` | $1.5\cdot 2^{2}$ |
| `0.1` | `1.6` | `-4` | $1.6\cdot 2^{-4}$ (nearest float, not exact) |
| `1e-21` | `1.1805916207174112` | `-70` | $1.18\ldots\cdot 2^{-70}$ |
| `1e300` | `1.4932217896051503` | `996` | $1.49\ldots\cdot 2^{996}$ |

`1e-21` is base-10 notation only on entry and display: Julia converts it to the nearest base-2 float. That conversion is where $1/10$ loses exactness — it is finite in base 10 ($0.1$) but has no finite base-2 expansion: `big(0.1)` → `0.1000000000000000055511151231257827…`. Hence `0.1 + 0.2 == 0.3` → `false`, while `0.5 + 0.25 == 0.75` → `true` ($2^{-1}$ and $2^{-2}$ are exact in base 2).

### Euler's formula, Complex Numbers and Calculus

**Euler's formula.**

Verzani says that while learning calculus, complex numbers are mainly used to find polynomial roots, but that they matter for later work. A good example of this is Euler's formula (in the form of Euler's identity - see below), which I came across in a basic number theory course. I asked Claude to give some details on it and its relationship to Calculus and Number Theory. I have edited that material in the section below.

First what the formula is:

For every real $\theta$,

$$e^{i\theta} = \cos\theta + i\sin\theta .$$

Geometrically, $e^{i\theta}$ is the point at angle $\theta$ on the unit circle: $|e^{i\theta}| = 1$, and multiplying by $e^{i\theta}$ rotates a complex number by $\theta$.

Richard Feynman called this "the most remarkable formula in mathematics."

#### Euler's identity and transcendence

With $\theta = \pi$, Euler's formula gives _Euler's identity_:

$$e^{i\pi} = -1, \qquad\text{i.e.}\qquad e^{i\pi} + 1 = 0 .$$

This identity is what I came across in my basic Number Theory course. It's famous because it links five important mathematical constants (and only these) in one line: e, i, π, 1 and 0. Mathematicians see it as exemplifying the aesthetic beauty of mathematics. Professor Edward Burger, in his course _Introduction to Number Theory_, states this equation "is considered by many to be the most beautiful in all mathematics."

| Constant | Kind |
| --- | --- |
| $e$ | transcendental (Hermite 1873) |
| $\pi$ | transcendental (Lindemann 1882) |
| $i$ | algebraic: a root of $x^2 + 1$ |
| $1$, $0$ | integers |

**Why $\pi$ is transcendental (Lindemann).**

Lindemann proved: if $\alpha \ne 0$ is algebraic, then $e^{\alpha}$ is transcendental. Suppose $\pi$ were algebraic. Then $i\pi$ would be algebraic too, so $e^{i\pi}$ would be transcendental. But $e^{i\pi} = -1$, which is algebraic. So $\pi$ is transcendental.

**Gelfond's constant.** From $e^{i\pi} = -1$,

$$e^{\pi} = \left(e^{i\pi}\right)^{-i} = (-1)^{-i},$$

which the Gelfond–Schneider theorem (1934) shows to be transcendental.

**Why $-1$.**

At first it might seem surprising that $e^{i\pi}$ equals $-1$. However that is only if you read it as "$e$ multiplied by itself $i\pi$ times." The geometric explanation clarifies why this is the case: We said if you start at a point on the circle, multiplying it by $e^{i\theta}$ rotates the point by $\theta$. So start at the point 1 on the unit circle and multiply 1 by $e^{i\theta}$, where we set $\theta$ as $\pi$. Geometrically, on the unit circle $\pi$ is a half-circle arc, which means the rotation ends up at -1.

**Where Euler's formula comes from: two calculus proofs.**

_Taylor series._ The series $e^z = \sum_{n=0}^{\infty} \dfrac{z^n}{n!}$ converges for every complex $z$. Put $z = i\theta$. The powers of $i$ cycle $1, i, -1, -i$, so the even terms are real and the odd terms are imaginary:

$$e^{i\theta}
= \underbrace{\left(1 - \frac{\theta^2}{2!} + \frac{\theta^4}{4!} - \cdots\right)}_{\cos\theta} + i\,\underbrace{\left(\theta - \frac{\theta^3}{3!} + \frac{\theta^5}{5!} - \cdots\right)}_{\sin\theta} .$$

_Derivative._ Let $g(\theta) = e^{-i\theta}(\cos\theta + i\sin\theta)$. The product rule gives

$$g'(\theta) = -i e^{-i\theta}(\cos\theta + i\sin\theta) + e^{-i\theta}(-\sin\theta + i\cos\theta) = 0 ,$$

so $g$ is constant, and $g(0) = 1$. Hence $e^{i\theta} = \cos\theta + i\sin\theta$.

**How advanced calculus uses it.**

1. _Defining sine and cosine._ Rudin (_Principles of Mathematical Analysis_, ch. 8) turns the formula around. He defines $e^z$ by its power series, then defines $\cos\theta = \operatorname{Re} e^{i\theta}$ and $\sin\theta = \operatorname{Im} e^{i\theta}$, and defines $\pi$ as twice the first positive zero of $\cos$. Every property of sin and cos, including $\sin' = \cos$, then follows from properties of $\exp$, with no geometry of angles needed.

2. _Trigonometric identities._ From $e^{i(a+b)} = e^{ia}e^{ib}$ come the angle-addition formulas. From $(e^{i\theta})^n = e^{in\theta}$ (de Moivre) come the multiple-angle formulas, e.g. taking real parts for $n = 3$:

$$\cos 3\theta = 4\cos^3\theta - 3\cos\theta .$$

3. _Integrals._ Writing $\cos x = \dfrac{e^{ix} + e^{-ix}}{2}$ and $\sin x = \dfrac{e^{ix} - e^{-ix}}{2i}$ turns integrals of trigonometric functions into integrals of exponentials, which are easy. Two examples follow.

*Example: $\int e^{ax}\cos bx\,dx$.* The usual textbook route integrates by parts twice; the second integration by parts brings back the original integral, and you then solve the resulting equation for it. With Euler's formula, $e^{ax}\cos bx$ is the real part of $e^{(a+ib)x}$, so one exponential integral does it:

$$\int e^{ax}\cos bx\,dx = \operatorname{Re}\int e^{(a+ib)x}\,dx = \operatorname{Re}\frac{e^{(a+ib)x}}{a+ib} .$$

To take the real part, multiply top and bottom by $a - ib$ and expand $e^{(a+ib)x} = e^{ax}(\cos bx + i\sin bx)$:

$$\frac{e^{(a+ib)x}}{a+ib} = \frac{e^{ax}(a - ib)(\cos bx + i\sin bx)}{a^2 + b^2} ,
\qquad
\operatorname{Re}\frac{e^{(a+ib)x}}{a+ib} = \frac{e^{ax}(a\cos bx + b\sin bx)}{a^2 + b^2} .$$

So $\displaystyle\int e^{ax}\cos bx\,dx = \frac{e^{ax}(a\cos bx + b\sin bx)}{a^2 + b^2} + C$.

*Example: $\int_0^{2\pi} \cos^4 x\,dx$.* Expand with the binomial theorem:

$$\cos^4 x = \left(\frac{e^{ix} + e^{-ix}}{2}\right)^4 = \frac{e^{4ix} + 4e^{2ix} + 6 + 4e^{-2ix} + e^{-4ix}}{16} .$$

Over a full period, $\int_0^{2\pi} e^{ikx}\,dx = 0$ for every integer $k \ne 0$, so only the constant term survives:

$$\int_0^{2\pi} \cos^4 x\,dx = \frac{6}{16}\cdot 2\pi = \frac{3\pi}{4} .$$

Checked numerically in Julia 1.13.2 ($\theta = 0.7$, $a = 0.5$, $b = 3$):

| Check | Computed | Expected |
| --- | --- | --- |
| Series $\sum_{n=0}^{15} (i\theta)^n/n!$ | `0.7648421872844883 + 0.644217687237691im` | `cis(0.7)` = `0.7648421872844885 + 0.644217687237691im` |
| $g(\theta)$ at $0.3$, $2.0$, $-5.0$ | `1.0`, `1.0`, `0.9999999999999999` | $1$ |
| $\cos 3\theta$ | `-0.5048461045998571` | $4\cos^3\theta - 3\cos\theta$ = `-0.5048461045998571` |
| derivative of the antiderivative at $x = 1.2$ | `-1.6340003697046246` | $e^{ax}\cos bx$ = `-1.634000369810869` |
| $\int_0^{2\pi}\cos^4 x\,dx$ (1000-point sum) | `2.3561944901923453` | $3\pi/4$ = `2.356194490192345` |

### Symbols

#### Symbols are Interned strings

I was not familiar with the term "interned" used by Verzani, so I asked Claude for an explanation:

"Interned" is a computer-science term, not a typo for "internal". **Interning** means keeping only one stored copy of each distinct string value. Each time you write `:abc` or build `Symbol("ab", "c")`, Julia looks the name up in a table. If it is already there, you get back that same object. Two symbols with the same name are therefore one object in memory, so checking whether they are equal is a single address comparison, not a character-by-character one. That is why symbols are good as identifiers: names that get compared often.

Checked in Julia 1.13.2:

| Expression | Same content (`===`) | Same object in memory (`pointer_from_objref`) |
| --- | --- | --- |
| `Symbol("ab", "c")` vs `:abc` | true | true: one interned copy |
| `string("ab", "c")` vs `"abc"` | true | false: two separate strings |

`===` cannot show the difference here because Julia compares strings by content. Only the memory address shows that the two strings are separate copies.

"Used as identifiers" is literal too. When Julia parses code, the names in it become symbols: `Meta.parse("x + 1").args` gives `[:+, :x, 1]`. In CWJSN you will only meet symbols as plot options, such as `linestyle = :dash`.

#### Symbols and enumerated types

I also asked Claude about the relationship between symbols and enumerated types.

Julia uses symbols internally for an enum's names, but an enum value is not a symbol. Checked in Julia 1.13.2 with `@enum Fruit apple banana`:

| Expression | Result |
| --- | --- |
| `typeof(apple)` | `Fruit`, a new type whose supertype is `Enum{Int32}` |
| `Integer(banana)` | `1`: the values are stored as integers |
| `apple == :apple` | `false`: an enum value is not a symbol |
| `Symbol(apple)` | `:apple`: you can convert one to its name |
| `Base.Enums.namemap(Fruit)` | `Dict(0 => :apple, 1 => :banana)` |

So the values are integers wrapped in their own type. Symbols are only how Julia stores the names, which it uses for printing and for `Symbol(apple)`.

More common is the reverse: a function takes a plain symbol from a fixed set, as a lightweight stand-in for an enum. Plots' `linestyle = :solid` / `:dash` / `:dot` is one example. CWJS's `symlim` does the same: it returns its route as a symbol, as in `(0, :substitution)`. That is simpler to write, but nothing checks the value. A misspelled `:dahs` is still a valid symbol, and you only find out if the receiving function rejects it. An `@enum` would catch the misspelling, because `dahs` would be an undefined name.

### Type Stability

In the text, Verzani makes the following claim:

>A basic premise is the shorter the [compiled list of assembly] instructions, the faster they are to process. Shorter instructions can come about by being more explicit about what types of values the instructions concern. Explicitness means, there is no need to reason about what a value can be. When Julia can reason about the type of value involved without having to reason about the values themselves, it can work with the compiler to produce shorter lists of instructions.

This claim does not sound correct to me. In fact, a shorter list of assembly instructions is a poor proxy for processing speed of a program.

Claude wrote a program for me that makes this point which is in the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook. Here is Claude's explanation for how the program works:

The timer doesn't measure the assembly listing directly. It times calls to `sumloop`, and when you call `sumloop(v)`, the compiled machine code is what actually runs. All of this is in `besttime`:

1. **Compile first.** The line `sumloop(v_int); sumloop(v_any)` runs each version once. Julia compiles a function for each argument type the first time it's called, so compile time stays out of the measurement.
2. **Time one call.** `t0 = time_ns()` reads the clock in nanoseconds, then `r = sumloop(v)` runs the compiled code, then `time_ns() - t0` gives the elapsed time.
3. **Repeat 200 times and keep the fastest.** Other programs and the operating system sometimes interrupt a run and make it look slower. Nothing can make a run look faster, so the minimum is the best estimate of the code's own cost.
4. **Use the result.** `r == 50_005_000 || error(...)` checks the sum. If the result were never used, the compiler could delete the call entirely. That happened in Claude's first attempt, which reported 0.0 μs.
5. **Convert units.** `best / 1e3` turns nanoseconds into microseconds.

**How fine the clock is** (measured on an Apple M2 Max): the clock moves in steps of 41 ns, because it ticks at 24 MHz. So 0.67 μs is about 16 ticks, and that reading could be off by up to about 6%. For the 169 μs reading the error is negligible, and the 250× ratio stands either way.

The time also includes the cost of calling the function and reading the clock, but that's a few tens of nanoseconds, small next to both readings.

The standard Julia tool for this is BenchmarkTools' `@btime`, which repeats the same idea with more care. The hand-written loop has the advantage that every step is visible in the code.

What follows is the code. It outputs the assembly code and then shows the results.

```julia
# Type stability: listing length vs speed 
using InteractiveUtils   # for code_native

function sumloop(v)
    t = 0
    for x in v
        t += x
    end
    t
end

# show the assembly code for sumloop with Vector{Int} argument
code_native(sumloop, (Vector{Int},); debuginfo=:none) 

v_int = collect(1:10_000)      # Vector{Int64}
v_any = Vector{Any}(v_int)     # the same values, element type Any

# The compiled machine code as text; count its instructions (labels, directives, comments left out)
asm(T) = sprint(io -> code_native(io, sumloop, (T,); debuginfo=:none))
ninstr(T) = count(l -> occursin(r"^\s+[a-z]", l), split(asm(T), "\n"))
ndispatch(T) = count(l -> occursin("apply_generic", l), split(asm(T), "\n"))

# Best of 200 runs in μs; checking the result stops the compiler from deleting the call
function besttime(v; runs = 200)
    best = typemax(UInt64)
    for _ in 1:runs
        t0 = time_ns()
        r = sumloop(v)
        best = min(best, time_ns() - t0)
        r == 50_005_000 || error("wrong sum")
    end
    best / 1e3
end

sumloop(v_int); sumloop(v_any)   # compile both before measuring
println("Timing results:\n")
for (name, v) in (("Vector{Int}", v_int), ("Vector{Any}", v_any))
    T = typeof(v)
    println(name, ": ", ninstr(T), " instructions, ",
            round(besttime(v), digits = 2), " μs, ",
            @allocated(sumloop(v)), " bytes allocated, ",
            ndispatch(T), " dispatcher calls, SIMD adds: ", occursin("add.2d", asm(T)))
end
```

The output of the code in the [Mathematical Basics](https://github.com/FourMInfo/Calculus/blob/main/notebooks/MathematicalBasics.ipynb) notebook:

```text
.build_version macos, 18, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_julia_sumloop_12994            ; -- Begin function julia_sumloop_12994
	.p2align	2
_julia_sumloop_12994:                   ; @julia_sumloop_12994
; Function Signature: sumloop(Array{Int64, 1})
; %bb.0:                                ; %top
	;DEBUG_VALUE: sumloop:v <- [$x0+0]
	;DEBUG_VALUE: sumloop:v <- [$x0+0]
	ldr	x11, [x0, #16]
	cbz	x11, LBB0_4
; %bb.1:                                ; %L34
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	ldr	x8, [x0]
	ldr	x0, [x8]
	subs	x12, x11, #1
	b.eq	LBB0_10
; %bb.2:                                ; %L72.preheader
	cmp	x11, #9
	b.hs	LBB0_5
; %bb.3:
	mov	w9, #2                          ; =0x2
	mov	w10, #1                         ; =0x1
	b	LBB0_8
LBB0_4:
	mov	x0, #0                          ; =0x0
	ret
LBB0_5:                                 ; %vector.ph
	and	x13, x12, #0xfffffffffffffff8
	orr	x10, x13, #0x1
	orr	x9, x13, #0x2
	movi.2d	v0, #0000000000000000
	movi.2d	v1, #0000000000000000
	mov.d	v1[0], x0
	add	x14, x8, #40
	mov	x15, x13
	movi.2d	v2, #0000000000000000
	movi.2d	v3, #0000000000000000
LBB0_6:                                 ; %vector.body
                                        ; =>This Inner Loop Header: Depth=1
	ldp	q4, q5, [x14, #-32]
	ldp	q6, q7, [x14], #64
	add.2d	v1, v1, v4
	add.2d	v0, v0, v5
	add.2d	v2, v2, v6
	add.2d	v3, v3, v7
	subs	x15, x15, #8
	b.ne	LBB0_6
; %bb.7:                                ; %middle.block
	add.2d	v0, v0, v1
	add.2d	v0, v2, v0
	add.2d	v0, v3, v0
	addp.2d	d0, v0
	fmov	x0, d0
	cmp	x12, x13
	b.eq	LBB0_10
LBB0_8:                                 ; %L72.preheader1
	sub	x11, x11, x9
	add	x11, x11, #1
LBB0_9:                                 ; %L72
                                        ; =>This Inner Loop Header: Depth=1
	ldr	x12, [x8, x10, lsl #3]
	mov	x10, x9
	add	x9, x9, #1
	add	x0, x0, x12
	subs	x11, x11, #1
	b.ne	LBB0_9
LBB0_10:
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
                                        ; -- End function
.subsections_via_symbols
Timing results:

Vector{Int}: 50 instructions, 0.67 μs, 0 bytes allocated, 0 dispatcher calls, SIMD adds: true
Vector{Any}: 69 instructions, 169.08 μs, 159504 bytes allocated, 2 dispatcher calls, SIMD adds: false
```

This table shows the results of the test based on the run I made (it may vary from run to run):

#### Apple M2 Max

| Measure | `Vector{Int}` | `Vector{Any}` |
| --- | --- | --- |
| Machine instructions in the listing | 50 | 69 |
| Best time | 0.67 μs | 169 μs (about 250× slower) |
| Memory allocated | 0 bytes | 159,504 bytes |
| Calls to the run-time dispatcher | 0 | 2 |
| SIMD adds (several numbers per instruction) | yes | no |

I also had Claude run this on an Intel machine out of curiosity. Here are the results:

#### Apple M2 Max vs Intel

The same code run as a script, several times on each machine, both on Julia 1.13.2. On Intel the SIMD check looks for `paddq`/`vpaddq` instead of ARM's `add.2d`.

| Machine | Instructions: `Vector{Int}` / `Vector{Any}` | Time `Vector{Int}` | Time `Vector{Any}` | Slowdown |
| --- | --- | --- | --- | --- |
| Apple M2 Max (2023) | 50 / 69 | 0.71–0.75 μs | 127 μs | about 180× |
| Intel i5-8500B (2018) | 78 / 77 | 0.81–0.90 μs | 262–283 μs | about 330× |

- The typed sum runs about equally fast on both chips: a short SIMD loop over data that fits in the cache.
- The untyped sum is about twice as slow on the Intel chip. Dispatch, pointer-following and allocation on every element cost the older chip more.
- On Intel the typed listing (78 instructions) is _longer_ than the untyped one (77), yet it runs about 330 times faster.
- The same Julia compiles different code for each chip: one dispatcher call per step on Intel, two on ARM.
- This compares a 2018 chip with a 2023 one, so the chip's age and its maker can't be told apart.
- The script times differ from the run above (169 μs on the M2 Max): the `Vector{Any}` time depends on the state of the session.

Let's focus on the results of the first table which shows the notebook's run on the Apple M2 Max. Notice how `Vector{Any}`—the version which doesn't allow Julia to reason about type output from the inputs, i.e. lacks type stability—generates assembly code that is only 38% longer than `Vector{Int}`. But the code runs 250 times slower! So obviously listing length is not a good predictor of speed.

We must keep in mind that even the compiled assembly code is an abstraction of the underlying hardware and does not necessarily indicate what is going on "under the hood". It does not show every operation that runs on the different parts of the hardware, nor how long they take. Hence length of code is just not a necessary or sufficient explanation for timing. We can see how this plays out in this example:

- **Memory work is not explicit in the code.** 159,504 bytes is about 16 bytes per element. That fits one new heap object (a "box") for the running total on every step. Allocating memory is much slower in relative terms than addition, and is never visible in the code listing.
- **What the assembly listing shows is not what gets executed.** Each call to the dispatcher is one line in the assembly code listing, but it runs on every element, and each run executes many instructions that aren't listed. Each dispatch is a lookup which does the following:
  - Read the value's type. In a `Vector{Any}`, each element is a pointer to a box, and the box records the value's type. Finding the type means following the pointer and reading that record.
  - Find the method. Julia looks up which `+` method fits those types in its method cache. That takes more memory reads, plus comparisons and branches, which is computation.
  - Make the call. It's an indirect call, so the compiler can't inline it and can't apply SIMD across it to speed it up.
- **The faster version was made longer on purpose.** The typed listing contains two loops. The main loop adds 8 integers per pass using vector (SIMD) instructions such as `add.2d v1, v1, v4`, which adds two integers at once. A second, plain loop handles the leftover elements and short arrays. The compiler actually added code to gain speed. Unrolling loops and inlining function calls do the same. This is a direct contradiction of Verzani's claim!
- **Instructions don't all cost the same.** A memory load that misses the cache, an integer division, or a mispredicted branch can each cost tens to hundreds of simple additions.

There are, in fact, other factors that can impact speed as well, but the point is made clear from this one example.

So if assembly code length is not what causes slowdown, what is the advantage of type stability? The answer can be put succinctly:

**_Knowing the types of values lets the compiler decide once and only once, while compiling, how to handle the value. Otherwise these decisions need to be made on every step while running._**

For example, in `sumloop`, when adding two values, if the types are known the compiler can decide up front which `+` to call, where to keep the running total (a register instead of the heap), and whether it can add several numbers at once. Without the type, these decisions need to be made at run time, and that's what slows things down.

### Powers: a numeric literal as the exponent

In this chapter numeric literals come up again in relation to powers. Numeric literals and names impact how the power function calculates expressions.

| Typed | Exponent written as | Result |
| --- | --- | --- |
| `2^-1` | a literal numeral | `0.5` |
| `2^(-1)` | a literal numeral | `0.5` |
| `a^-1` with `a = 2` | a literal numeral | `0.5` |
| `2^b` with `b = -1` | a name | `DomainError` |
| `a^b` | a name | `DomainError` |
| `2^(0-1)` | an expression of literals | `DomainError` |

If the exponent is an integer written as a literal numeral, Julia rewrites the power before running it, into `Base.literal_pow(^, 2, Val(-1))`. The value `-1` is now part of the type `Val{-1}`, so the compiler knows it while compiling and can return a `Float64` for a negative exponent. Another example of type stability being beneficial.

If the exponent is a name or an expression, its value is only known when the code runs, so the ordinary `^` for two `Int`s runs. That `^` always returns an `Int`: `Base.return_types(^, (Int, Int))` gives `Int64`. The result type depends only on the argument types, never on their values. An `Int` cannot hold $\frac{1}{2}$, so a negative exponent throws a `DomainError`. Here too we see type stability in action. However, in this case `^` keeps the return type fixed, and the consequence is an error instead of a `Float64`.

To get $2^{-1}$ from names, make one side non-integer, as the error message suggests: `float(a)^b` → `0.5`, `a^float(b)` → `0.5`, or `(a//1)^b` → `1//2` to keep it exact.

---

## CWJSN numbers_types: Questions

Values marked * were not in my REPL session; they were added afterwards by Claude to complete the comparison. As always, try to answer on your own before looking at the answers.

| Q | Question (CWJSN) | My Julia → result | Answer | Why |
| --- | --- | --- | --- | --- |
| 1 | The number created by `pi/2` is? | `pi/2` → `1.5707963267948966`; `typeof(ans)` → `Float64` | Floating point | `pi` is an `Irrational`; arithmetic with it gives a `Float64` |
| 2 | The number created by `2/2` is? | `2/2` → `1.0`; `typeof(ans)` → `Float64` | Floating point | `/` always returns a `Float64`, even when the division is exact |
| 3 | The number created by `2//2` is? | `2//2` → `1//1`; `typeof(ans)` → `Rational{Int64}` | Rational | `//` builds a `Rational` and reduces it to lowest terms; it stays a `Rational` even when the value is a whole number |
| 4 | The number created by `1 + 1//2 + 1/3` is? | `1 + 1//2 + 1/3` → `1.8333333333333333`; `typeof(ans)` → `Float64` | Floating point | left to right: `1 + 1//2` → `3//2`\* is a `Rational`; adding the `Float64` `1/3` promotes the sum to `Float64` |
| 5 | The number created by `2^3` is? | `2^3` → `8`\*; `typeof(ans)` → `Int64`\* | Integer | integer base and exponent stay `Int` |
| 6 | The number created by `sqrt(im)` is? | `sqrt(im)` → `0.7071067811865476 + 0.7071067811865475im`; `typeof(ans)` → `ComplexF64 (alias for Complex{Float64})` | Complex | $\sqrt{i} = \frac{1 + i}{\sqrt{2}}$; the real and imaginary parts are equal, and the last digits differ only by rounding |
| 7 | The number created by `2^(-1)` is? | `2^(-1)` → `0.5`; `typeof(ans)` → `Float64` | Floating point | a negative exponent written as a literal numeral is handled specially and returns a float (see Q11) |
| 8 | The "number" created by `1/0` is? | `1/0` → `Inf`; `typeof(ans)` → `Float64` | Floating point | `/` returns a `Float64`, and `Inf` is a `Float64` value |
| 9 | Is `(2 + 6) + 7` equal to `2 + (6 + 7)`? | `(2+6)+7 === 2+(6+7)` → `true` | Yes | integer addition is exact, so the grouping does not matter |
| 10 | Is `(2/10 + 6/10) + 7/10` equal to `2/10 + (6/10 + 7/10)`? | `(2/10 + 6/10) + 7/10 === 2/10 + (6/10 + 7/10)` → `false` | No | each `/10` is rounded, and each addition rounds again, so the grouping changes the result: the left side is `1.5`\*, the right side `1.4999999999999998`\* |
| 11 | `a, b = 2, -1` then `a^b` _should_ compute `2^(-1)`, which returns `0.5`. Does it? | `a, b = 2, -1` → `(2, -1)`; `a^b` → `ERROR: DomainError with -1: Cannot raise an integer x to a negative power -1.`; `a^-1` → `0.5` | No | Julia rewrites a power whose exponent is an integer written as a _literal numeral_ into a special call (`Base.literal_pow`), which returns `0.5`. With `b`, a variable, the ordinary `^` for two `Int`s runs; its result must be an `Int`, which cannot hold $1/2$, so it throws. `a^-1` works because its exponent `-1` is a literal numeral |
| 12 | Which value directly represents a zeptosecond: `1/10^21` or `1e-21`? | `1e-9 / 1e12` → `1.0000000000000001e-21`; `1e-21` → `1.0e-21`; `1/10^21` → `2.5800991659088344e-19` | `1e-21` | `10^21` has an integer base, so it overflows `Int64` and wraps silently: `10^21` → `3875820019684212736`\*. A float base works: `1/10.0^21` → `1.0e-21`\*. `1e-9 / 1e12` is off by one rounding step |
