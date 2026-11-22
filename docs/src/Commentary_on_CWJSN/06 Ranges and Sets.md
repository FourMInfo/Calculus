# Ranges and Sets

Commentary on the CWJSN chapter [Ranges and Sets](https://fourm.info/cwjsn/basics/ranges.html).

## Ranges and sequences

Below are some details about ranges and sequences created by Claude and edited by me. The results are from Julia 1.13.3.

### How a range expresses a sequence

Verzani introduces a range as Julia's way to write an arithmetic sequence. He answers his two sequence questions using the formula $a_n = a_0 + nh$, but doesn't show how this works with a range. This section shows how the two match.

### The sequence as a whole

The formula $a_n = a_0 + nh$ on its own gives one term. A sequence is the whole indexed list: the sequence symbol, the formula and the bounds of the index together. Written out, with $N$ for the last index so that it is not confused with the running index $n$:

$$(a_n)_{n=0}^{N} = (a_0 + nh)_{n=0}^{N} = (a_0,\ a_0 + h,\ a_0 + 2h,\ \dots,\ a_0 + Nh)$$

A range is this whole object, not the formula alone. `range(a0, step=h, length=N+1)` builds the entire arithmetic sequence, with the index shifted to start at 1:

$$r = (r_i)_{i=1}^{N+1}, \qquad r_i = a_0 + (i - 1)h$$

For Verzani's first question, $a_0 = 200$, $h = -10$ and $N = 20$:

$$(200 - 10n)_{n=0}^{20} = (200,\ 190,\ 180,\ \dots,\ 0)$$

is `range(200, step=-10, length=21)`, which `Julia` shows as `200:-10:0`.

!!! note "Braces or parentheses"
    Some texts write a sequence with braces, $\{a_n\}_{n=0}^{N}$; parentheses are used here because braces also mean a set, and a set has no order.

### The same rule

As we note above, an arithmetic sequence is a rule from positions to values: position $n$ holds $a_0 + nh$, where $n$ is the current index, running from $0$ to $N$. As we can now see, the range holds the exact same rule, expressed slightly differently. Let's dive deeper into Verzani's first question, $a_0 = 200$ and $h = -10$, and keep the terms up to $a_{20}$:

| Sequence | Range `r = range(200, step=-10, length=21)` |
| :--- | :--- |
| $a_0 = 200$ | `first(r)` → `200`: the first element of the range, at $i = 1$ |
| $h = -10$ | `step(r)` → `-10`: the step between elements, the common difference $h$ |
| $N = 20$, so 21 terms $a_0, \dots, a_{20}$ | `length(r)` → `21`: the number of elements in the range, $N + 1$ |
| $a_n = a_0 + nh$ | `r[n + 1]`, computed as `first(r) + n * step(r)` |

The last row is where arithmetic sequences and ranges connect. Base `Julia` defines the value at index `i` as `first(r) + (i - 1) * step(r)` (`range.jl`, `Julia` 1.13), which is $a_0 + nh$ with $n = i - 1$. The sequence counts from $a_0$ and a `Julia` range counts from index 1, so every term sits one index higher than its subscript:

| Term | Math | Index | `Julia` | Value |
| :--- | :--- | :--- | :--- | :--- |
| first | $a_0$ | 1 | `r[1]` | `200` |
| second | $a_1$ | 2 | `r[2]` | `190` |
| third | $a_2$ | 3 | `r[3]` | `180` |
| last | $a_{20}$ | 21 | `r[21]` | `0` |

So Verzani's first question, $a_{20}$, is `r[21]`:

```julia
r = range(200, step=-10, length=21)
r[21]    # 0, the same as 200 + 20 * (-10)
```

Because the values are computed, not stored, a range takes the same memory however long it is:

```julia
sizeof(1:1_000_000)             # 16 bytes: the first and last value
sizeof(collect(1:1_000_000))    # 8000000 bytes: a million stored values
(1:1_000_000)[999_999]          # 999999, computed on request
```

### Three ways to write the same range

The math describes a sequence by $a_0$, $h$ and $N$. The colon operator takes a start, a step and a _suggested_ stop. The function `range` accepts several combinations. `range(a0; step = h, length = N + 1)` takes the math's three values directly (the chapter's Questions ask for this signature). These all give the same range:

```julia
200:-10:0                              # start, step, stop
200:-10:-5                             # the stop is only a limit: the range still ends at 0
range(200, step=-10, length=21)        # a_0, h, and N + 1 terms
range(200, step=-10, length=21) == 200:-10:0    # true
```

#### The colon and `range` read three numbers differently

With three positional arguments, `range` reads them as start, _stop_ and _length_, not as start, step and stop like the colon. The same three numbers give two different ranges:

```julia
1:5:10                       # 1:5:6: start 1, step 5, stop at most 10, so the values 1 and 6
range(1, 5, 10)              # 1.0:0.4444444444444444:5.0: 10 values from 1 to 5
range(1, 5, 10) == 1:5:10    # false
range(1, step=5, stop=10) == 1:5:10    # true: name the step to get the colon's meaning
```

#### A range is already the whole sequence

`collect` copies a range's values into a `Vector`. The values are the same, and `==` compares values, so a range equals its collected vector:

```julia
r = 1:5:10
v = collect(r)
v == r       # true: the same values
r[2]         # 6, computed when asked
v[2]         # 6, read from memory
```

What differs is how the values are held, not which values they are:

| What | Range `r = 1:5:10` | Vector `v = collect(r)` |
| :--- | :--- | :--- |
| Type | `StepRange{Int64, Int64}` | `Vector{Int64}` |
| Second value | `r[2]` → `6`, computed when asked | `v[2]` → `6`, read from memory |
| Stores | start, step and stop | every value |
| Change a value | `r[2] = 0` → `CanonicalIndexError`: a range cannot be changed | `v[2] = 0` works |

So a range does not need `collect` to become the sequence: any term can be indexed without it. `collect` is for when every value has to be stored, for example to change one of them.

### Where a range differs from a sequence

A sequence such as $1, 2, 3, \dots$ can go on forever. A range always has a last value, so it only holds the stretch from its start to its end. To get $a_n$ from a range, the range must reach $a_n$; asking for an index past the end is an error, not the next term:

```julia
r = range(200, step=-10, length=21)
r[22]    # BoundsError: r stops at a_20
```

For a single term the formula is the shorter route, which is why Verzani uses it. A range is most useful when you want many terms: to `collect` them, `sum` them, plot them or loop over them.

### A range is not a generator

Verzani says that `range`, "like the range operation, … returns a generator which can be collected". It returns a range. A range can be iterated, as every collection can, but it is also a vector: `(1:10) isa AbstractVector` is `true`. A [generator](05-2 The Container Interface.md#What-a-generator-is) is only an iterator: it hands out its values one after another and has no index.

```julia
r = range(200, step=-10, length=21)
g = (200 - 10n for n in 0:20)    # a generator with the same 21 values

collect(g) == collect(r)    # true: the same values
r[3]                        # 180
g[3]                        # MethodError: a generator has no index
length(r)                   # 21
r isa AbstractVector        # true
g isa AbstractVector        # false
```

| Can it … | Range | Generator |
| :--- | :--- | :--- |
| Iterate over the values | yes | yes |
| Get the $n$th value directly (`r[i]`) | yes | no, `MethodError`; once `collect(g)` has stored all the values, `collect(g)[i]` works (for $a_n$, $i = n + 1$) |
| `length` | yes | only when what it iterates over has one |
| Memory | a few numbers: start, step, end | the expression and what it iterates over |
| Is an `AbstractVector` | yes | no |

The indexing is what makes a range express a sequence: like the sequence, it can give you any term by its position, without going through the terms before it.

## Modifying sequences

Below are some details about filtering, comprehensions and generators created by Claude and edited by me. The results are from Julia 1.13.4.

Verzani's section "Modifying sequences" makes a new sequence from an old one in three ways: `filter`, comprehensions and generators. Comprehensions and generators were first covered in [Generators and sets](05-2 The Container Interface.md#Generators-and-sets) on The Container Interface page. The sections below add only what this chapter brings that the earlier page does not.

### Filtering

`filter(pred, collection)` keeps the elements for which the function `pred` returns `true`. A function that returns `true` or `false` is called a _predicate_ (see [The reductions Julia already provides](05-2 The Container Interface.md#The-reductions-Julia-already-provides)). On a range or a vector, the result is a new `Vector`:

```julia
filter(iseven, 0:25)    # [0, 2, 4, …, 24], a Vector{Int64}
```

#### A predicate for divisibility by 7

Verzani gives two ways to write the predicate he needs: `is_seven(x) = x%7 == 0` and, "if being fancy", `Base.Fix2(iszero∘rem, 7)`. Both answer "does 7 divide `x`?". The second builds the function from existing ones. Read it from the inside out:

| Piece | What it is | Example |
| :--- | :--- | :--- |
| `rem` | a function that gives the remainder resulting from dividing its first argument by its second | `rem(15, 7)` → `1` |
| `iszero ∘ rem` | a composition of two functions, where you apply the one on the right first. The symbol for composition is `∘` (typed `\circ` Tab). `(f ∘ g)(args...)` is `f(g(args...))`, and all the arguments go to `g` | `(iszero ∘ rem)(14, 7)` is `iszero(rem(14, 7))` → `true` |
| `Base.Fix2(f, 7)` | a function with `7` fixed as the _second_ argument of `f`: calling it with `x` runs `f(x, 7)` | `Base.Fix2(iszero∘rem, 7)(15)` → `false` |

The `2` in `Fix2` names the position that is fixed, not the number of arguments: `Base.Fix1(rem, 7)` is `x -> rem(7, x)`. The general form `Base.Fix{N}` fixes the `N`th argument, and `Base.Fix2 === Base.Fix{2}` is `true`. Any further arguments fill the remaining positions in order. `Fix2` is public but not exported, hence the `Base.` prefix.

```julia
f = Base.Fix2(iszero∘rem, 7)
f(14), f(15)       # (true, false)
filter(f, 1:30)    # [7, 14, 21, 28]
```

`x -> x % 7 == 0` (referred to as an _anonymous function_) does the same and reads more easily. What the fancy form gains is that it shows how it is built: it prints as `Base.Fix2{ComposedFunction{typeof(iszero), typeof(rem)}, Int64}(iszero ∘ rem, 7)`, while an anonymous function prints only as a generated name such as `#2`.

#### Filtering for primes, and a faster way

Verzani calls `filter(isprime, 100:200)` "an inefficient way to list the prime numbers between $100$ and $200$" without saying why. `filter` tests every number of the range on its own, and `isprime` does not use what it learned about the numbers before. How it tests one number depends on its size (`Primes` package, 0.5.7 source): below $2^{16}$ it looks the number up in a table of smallest factors; below $2^{32}$ it divides by the primes 3 to 23 and then runs a Miller–Rabin test; above that it runs Miller–Rabin and a Lucas test.

The `Primes` package also has `primes(lo, hi)`, which lists the primes from `lo` to `hi` with a sieve (the source cites the Sieve of Eratosthenes and wheel factorization). A sieve crosses out the multiples of each small prime once, up to $\sqrt{hi}$, so no number is tested on its own. Both give the same list:

```julia
using Primes
filter(isprime, 100:200) == primes(100, 200)    # true: the same 21 primes
```

Measured on an Apple M4 Pro, the fastest of several runs:

| Range | `filter(isprime, ...)` | `primes(lo, hi)` | `filter` takes |
| :--- | :--- | :--- | :--- |
| `100:200` | 0.17 μs | 0.083 μs | 2 times as long |
| `1:10^6` | 16 ms | 0.73 ms | 22 times as long |
| `1:10^8` | 2.1 s | 87 ms | 24 times as long |
| `10^12:10^12 + 10^6` | 129 ms | 2.0 ms | 64 times as long |

For Verzani's range the difference does not matter. It grows with the length of the range, and more with the size of the numbers, because each `isprime` call on a large number runs the costlier tests, while the sieve only needs the primes up to $\sqrt{hi}$.

#### `filter` or `if`

Verzani gets the multiples of 7 both with `filter` and with an `if` in a comprehension. His note after the generator example shows the difference between these two approaches: `filter` takes a function, while the `if` takes an expression. On a range the two give the same vector:

```julia
filter(k -> rem(k, 7) == 0, 1:100) == [k for k in 1:100 if rem(k, 7) == 0]    # true
```

The difference matters when the values go straight into a reduction. `sum(filter(isprime, 1:100))` first stores the primes in a vector and then adds them, while `sum(p for p in 1:100 if isprime(p))` adds them as they come. Both give `1060`; inside a function, after a first call, the first allocates 1184 bytes and the second none. (`isprime` comes from the `Primes` package, which the Calculus notebook environment now includes.)

`filter` also does not take a generator: `filter(iseven, (x^2 for x in 1:5))` is a `MethodError`. `Iterators.filter` takes any iterable and returns another iterator, which computes nothing until it is iterated:

```julia
collect(Iterators.filter(iseven, (x^2 for x in 1:5)))    # [4, 16]
```

### Comprehensions

The basics are in [Set notation and comprehensions](05-2 The Container Interface.md#Set-notation-and-comprehensions) and [Comprehension or generator?](05-2 The Container Interface.md#Comprehension-or-generator?) on The Container Interface page. This chapter adds three things: several `for` clauses, a `for` over a single number, and choosing the element type.

#### Several `for` clauses

Verzani's "Making change" example chains four `for` clauses. Each later clause runs once for every value of the clauses before it and can use their variables: `d` runs up to `100 - q`. The result is one flat vector. Separating the clauses with commas instead gives an array with one dimension per clause, and then no range may use another clause's variable:

```julia
[(a, b) for a in 1:2 for b in 1:3]    # 6-element Vector: (1, 1), (1, 2), (1, 3), (2, 1), (2, 2), (2, 3)
[(a, b) for a in 1:2, b in 1:3]       # 2×3 Matrix: a picks the row, b the column
[(a, b) for a in 1:3 for b in a:3]    # [(1, 1), (1, 2), (1, 3), (2, 2), (2, 3), (3, 3)]: b starts at a
[(a, b) for a in 1:3, b in a:3]       # UndefVarError: `a` not defined
```

| Form | Result | A later range may use an earlier variable |
| :--- | :--- | :--- |
| `for a in A for b in B` | a flat vector, `a` changing slowest | yes |
| `for a in A, b in B` | a `length(A)`×`length(B)` matrix | no |

An `if` at the end of the chain tests every combination, as in Verzani's `if q > d > n > p`.

#### A `for` over a single number

The last clause of the making-change comprehension, `for p = (100 - q - d - n)`, iterates over one number. A number in `Julia` is iterable and yields itself once, so this clause just sets `p` to the amount that brings the total to 100. In a chain it adds one element per combination; on its own it gives a zero-dimensional array, not a vector:

```julia
[(q, p) for q in 1:2 for p = 10 - q]    # [(1, 9), (2, 8)]
[p for p = 5]                           # fill(5), an Array{Int64, 0}
```

Verzani writes `=` in this example and `in` elsewhere. In a `for` clause `=`, `in` and `∈` mean the same.

#### Choosing the element type

Verzani writes: "Sometimes, the comprehension does not produce the type of output that may be expected. This is related to `Julia`'s more limited abilities to infer types at the command line. If the output type is important, the extra prefix of `T[]` can be used, where `T` is the desired type." Here is a comprehension whose values mix integers and floating point numbers:

```julia
[iseven(x) ? x : x/2 for x in 1:4]           # Real[0.5, 2, 1.5, 4]
[0.5, 2, 1.5, 4]                             # [0.5, 2.0, 1.5, 4.0]: a literal promotes
Float64[iseven(x) ? x : x/2 for x in 1:4]    # [0.5, 2.0, 1.5, 4.0]
```

A literal vector converts mixed numbers to one common type. A comprehension does not: its element type is a common supertype of the values it produced, here `Real`, and for a number and a string `Any`. The same function body gives `Vector{Real}` inside a function too, so in `Julia` 1.13 the command line is not what causes it. Type inference decides the element type only when there are no values: `[x for x in 1:3 if x > 5]` is an empty `Vector{Int64}`.

The `T[...]` prefix converts each value to `T`, and fails when a value cannot be converted exactly:

```julia
Int[x/2 for x in 2:2:6]    # [1, 2, 3]
Int[x/2 for x in 1:3]      # InexactError: 0.5 is not an integer
```

### Generators

The basics are in [What a generator is](05-2 The Container Interface.md#What-a-generator-is), [Comprehension or generator?](05-2 The Container Interface.md#Comprehension-or-generator?) and [When the parentheses can be left out](05-2 The Container Interface.md#When-the-parentheses-can-be-left-out) on The Container Interface page, and in [A range is not a generator](#A-range-is-not-a-generator) above. This chapter adds which functions take a generator, what an `if` changes, and counting without storing.

#### Which functions take a generator

Verzani writes: "Not all functions allow generators as arguments, but most common reductions do." With `g = (x^2 for x in 1:5)` and the filtered `h = (x^2 for x in 1:5 if isodd(x))`:

| Function | `g` | `h`, with an `if` | Why, and the fix |
| :--- | :--- | :--- | :--- |
| `sum`, `maximum`, `first`, `last` | `55`, `25`, `1`, `25` | `35`, `25`, `1`, `25` | each goes through the values once, from the first: nothing to fix |
| `collect`, `unique`, `Set`, `map(sqrt, ...)`, `sqrt.(...)` | work | work | the same |
| `length`, `size` | `5`, `(5,)` | `MethodError` | how many values pass the `if` is only known once they have been computed. Fix: `length(collect(h))` → `3`, or `count(Returns(true), h)` → `3`, which counts them without storing them |
| `findfirst(iseven, ...)` | `2` | `MethodError` | `findfirst` returns a position, and `h` has no positions (`keys(h)` is a `MethodError`). Fix: `findfirst(iseven, collect(h))` → `nothing`, because none of `1`, `9`, `25` is even; `findfirst(>(5), collect(h))` → `2` |
| `sort`, `reverse`, `filter(iseven, ...)` | `MethodError` | `MethodError` | `sort` and `reverse` need all the values at once. `filter` makes a filtered copy and has methods only for collections such as arrays, sets, dictionaries, strings and tuples. Fix: `sort(collect(g))`, `reverse(collect(g))`, `filter(iseven, collect(g))`. Without storing: `Iterators.reverse(g)` and `Iterators.filter(iseven, g)`, which work on `h` too |
| indexing, `g[1]` | `MethodError` | `MethodError` | a generator computes its values in order and keeps none, so there is nothing to look up. Fix: `collect(g)[1]` → `1`. Without storing: `first(g)`, or `first(Iterators.drop(g, 2))` → `9` for the third value |

The `length` row in the range-versus-generator table above holds only for a generator without an `if`.

#### Counting without storing

Verzani stores all 242 ways to make change and then counts them with `length(ways)`. If only the count is wanted, a generator with the same `for` clauses counts without storing them:

```julia
sum(1 for q = 0:25:100
      for d = 0:10:(100 - q)
      for n = 0:5:(100 - q - d)
      for p = (100 - q - d - n))    # 242
```

Inside a function, after a first call, this allocates 928 bytes, and the comprehension with `length` 28208 bytes. Generators take several `for` clauses just like comprehensions, in both forms: `sum(a*b for a in 1:2 for b in 1:3)` and `sum(a*b for a in 1:2, b in 1:3)` are both `18`. The same difference as for comprehensions applies: in the comma form no range may use another clause's variable, so `sum(a*b for a in 1:3 for b in a:3)` is `25`, while `sum(a*b for a in 1:3, b in a:3)` is an `UndefVarError`. The shapes differ too: `collect(a*b for a in 1:2, b in 1:3)` is the 2×3 matrix `[1 2 3; 2 4 6]`, and `collect(a*b for a in 1:2 for b in 1:3)` the flat vector `[1, 2, 3, 2, 4, 6]`. The chained form, with `for` after `for`, has no `length` (an `ArgumentError`), because its values come from several ranges chained together.
