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

## CWJSN ranges: Questions

Values marked * were not in my REPL session; they were added afterwards by Claude to complete the comparison. As always, try to answer on your own before looking at the answers.

| Q | Question (CWJSN) | My Julia → result | Answer | Why |
| :--- | :--- | :--- | :--- | :--- |
| 1 | Which of these will produce the odd numbers between $1$ and $99$: `1:99`, `1:3:99` or `1:2:99`? | `collect(1:2:99)` → `50-element Vector{Int64}`: `1, 3, 5, …, 97, 99`; `collect(1:99)` → `99-element Vector{Int64}`: `1, 2, …, 99`; `collect(1:3:99)` → `33-element Vector{Int64}`: `1, 4, 7, …, 94, 97` | `1:2:99` | a step of 2 from 1 gives every odd number, and 99 is reached exactly. `1:99` steps by 1, so it gives every number; `1:3:99` gives every third one |
| 2 | Which of these will create the sequence $2, 9, 16, 23, \dots, 72$: `2:7:72`, `2:9:72`, `2:72` or `72:-7:2`? | `collect(2:7:72)` → `2, 9, 16, 23, 30, 37, 44, 51, 58, 65, 72`; `collect(2:72)` → `71-element Vector{Int64}`: `2, 3, …, 72`; `collect(2:9:72)` → `2, 11, 20, 29, 38, 47, 56, 65`; `collect(72:-7:2)` → `72, 65, 58, 51, 44, 37, 30, 23, 16, 9, 2` | `2:7:72` | the terms go up by 7, and $72 = 2 + 10 \cdot 7$. `72:-7:2` has the same numbers in the opposite order; `2:9:72` stops at 65, the last term below 72 |
| 3 | How many numbers are in the sequence produced by `0:19:1000`? | `length(collect(0:19:1000))` → `53` | 53 | the last term is $988 = 52 \cdot 19$, since $53 \cdot 19 = 1007$ is past 1000, so the terms are $0 \cdot 19$ to $52 \cdot 19$. A range has a `length` of its own: `length(0:19:1000)` is `53` without the `collect` |
| 4 | Which of these will count down from `10` to `1`: `10:-1:1`, `10:1`, `1:-1:10` or `1:10`? | `collect(10:-1:1)` → `10, 9, 8, 7, 6, 5, 4, 3, 2, 1`; `collect(1:-1:10)` → `Int64[]`; `collect(1:10)` → `1, 2, …, 10`; `collect(10:1)` → `Int64[]` | `10:-1:1` | counting down needs a negative step. `10:1` steps by 1 from 10, and `1:-1:10` steps down from 1 towards a larger number, so neither reaches a single term: both are empty |
| 5 | What is the last number generated by `1:4:7`? | `collect(1:4:7)` → `1, 5` | 5 | the next term, 9, is past 7. The chapter's own answer is `(1:4:7)[end]`, the range's last term |
| 6a | Do ranges act like vectors? Does scalar multiplication work as expected: is the result of `2*(1:5)` *basically* the same as `2 * [1,2,3,4,5]`? | `2*(1:5)` → `2:2:10`; `2 * [1,2,3,4,5]` → `[2, 4, 6, 8, 10]`; `collect(2*(1:5))` → `[2, 4, 6, 8, 10]`; `2*(1:5) == 2*[1,2,3,4,5]` → `true`\* | Yes | in Julia "the same" is `==`: the same values in the same order. But the result is another range, not a stored vector, and that difference matters (see [Arithmetic on a range gives a range](#Arithmetic-on-a-range-gives-a-range) below) |
| 6b | Does vector addition work as expected: is the result of `(1:4) + (2:5)` *basically* the same as `[1,2,3,4] + [2,3,4,5]`? | `(1:4) + (2:5)` → `3:2:9`; `collect(1:4) + (2:5) == [1,2,3,4] + [2,3,4,5]` → `true` | Yes | as in 6a: `3:2:9` holds the values `3, 5, 7, 9`, so it is `==` to the vector sum, but it is again a range. Adding a `Vector` and a range, as in my second line, gives a `Vector` |
| 6c | What if the parentheses are left off? Explain the output of `1:4 + 2:5`: "It is just random", "Addition happens prior to the use of `:` so this is like `1:(4+2):5`" or "It gives the correct answer, a generator for the vector `[3,5,7,9]`" | `1:4 + 2:5` → `1:6:1` | Addition happens prior to the use of `:`, so this is like `1:(4+2):5` | `+` binds more tightly than `:`, so the line is the range from 1 in steps of 6 up to 5. Its next term, 7, is past 5, so its only term is 1, and Julia shows a range ending at the last term it reaches: `1:6:1`. `[3, 5, 7, 9]` needs the parentheses of 6b |
| 7 | How is `a:b-1` interpreted: as `a:(b-1)`, or as `(a:b) - 1`, which is `(a-1):(b-1)`? | `3:4-1` → `3:3` | as `a:(b-1)` | as in 6c, `-` binds more tightly than `:`, so `3:4-1` is `3:(4-1)`, the one-term range `3:3`. Shifting the whole range down by one takes a dot: `(3:4) .- 1` is `2:3` |
| 9 | Create the sequence $10, 100, 1000, \dots, 1{,}000{,}000$ using a list comprehension: `[10^i for i in 1:6]`, `[10^i for i in [10, 100, 1000]]` or `[i^10 for i in [1:6]]`? | `[10^i for i in 1:6]` → `[10, 100, 1000, 10000, 100000, 1000000]`; `[i^10 for i in [1:6]]` → `ERROR: MethodError: no method matching ^(::UnitRange{Int64}, ::Int64)`; `[10^i for i in [10, 100, 1000]]` → `[10000000000, 0, 0]` | `[10^i for i in 1:6]` | $10^i$ for $i = 1, \dots, 6$. `[1:6]` is a one-element vector whose only element is the range `1:6`, so `i` is the whole range, and `^` has no method for a range. `[10, 100, 1000]` makes the exponents 10, 100 and 1000: $10^{10}$ fits in an `Int64`, but $10^{100}$ and $10^{1000}$ overflow. Both are multiples of $2^{64}$, so the wrap-around leaves exactly 0 (see [Overflow, rounding and `≈`](03 Number Systems.md#Overflow,-rounding-and)) |
| 10 | Create the sequence $0.1, 0.01, 0.001, \dots, 0.0000001$ using a list comprehension: `[10^-i for i in 1:7]`, `[(1/10)^i for i in 1:7]` or `[i^(1/10) for i in 1:7]`? | `[(1/10)^i for i in 1:7]` → `[0.1, 0.010000000000000002, 0.0010000000000000002, 0.00010000000000000002, 1.0000000000000004e-5, 1.0000000000000004e-6, 1.0000000000000005e-7]`; `[10^-i for i in 1:7]` → `ERROR: DomainError with -1: Cannot raise an integer x to a negative power -1.`; `[10.0^-i for i in 1:7]` → `[0.1, 0.010000000000000002, 0.001, 0.0001, 1.0e-5, 1.0e-6, 1.0000000000000001e-7]`; `[i^(1/10) for i in 1:7]` → `[1.0, 1.0717734625362931, 1.1161231740339044, …, 1.214814044039067]` | `[(1/10)^i for i in 1:7]` | $(1/10)^i = 10^{-i}$, computed in floats, so the last digits carry rounding: `0.1` is not exactly one tenth in binary (`big(0.1)` → `0.1000000000000000055511151231257827021181583404541015625`), and each power carries that error along. `10^-i` raises the integer 10 to a negative power, which Julia refuses for integers; the float `10.0` makes it work, and here five of the seven values print as the plain decimal. `i^(1/10)` is the tenth root of $i$, a different sequence |
| 11 | Evaluate the expression $x^3 - 2x + 3$ for each of the values $-5, -4, \dots, 4, 5$ using a comprehension: `[x^3 - 2x + 3 for i in -5:5]`, `[x^3 - 2x + 3 for x in -(5:5)]` or `[x^3 - 2x + 3 for x in -5:5]`? | `[x^3 - 2x + 3 for x in -5:5]` → `[-112, -53, -18, -1, 4, 3, 2, 7, 24, 59, 118]`; `[x^3 - 2x + 3 for i in -5:5]` → `ERROR: UndefVarError: x not defined in Main`; `[x^3 - 2x + 3 for x in -(5:5)]` → `[-112]` | `[x^3 - 2x + 3 for x in -5:5]` | the variable after `for` must be the one in the expression: with `for i`, `x` is never given a value. `-(5:5)` negates the one-term range `5:5`, giving `-5:-1:-5`, so the comprehension has only the value at $x = -5$ |
| 12 | How many prime numbers are there between $1100$ and $1200$? (Use `filter` and `isprime`) | `filter(isprime, 1100:1200)` → `[1103, 1109, 1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193]`; `length(filter(isprime, 1100:1200))` → `12` | 12 | `isprime` comes from the package `Primes`, which must be loaded first with `using Primes`; `CalculusWithJuliaSquared` does not load it |
| 13 | Which has more prime numbers, the range `1000:2000` or the range `11000:12000`? | `length(filter(isprime, 1000:2000)) > length(filter(isprime, 11000:12000))` → `true` | `1000:2000` | the first range has 135 primes and the second 103: primes become rarer as numbers grow |
| 14 | What is the sum of the odd numbers between $0$ and $100$? | `sum(filter(isodd, 0:100))` → `2500` | 2500 | the chapter's own answer is `sum(1:2:99)`: a range holds the 50 odd numbers directly, with no `filter`. The sum of the first $n$ odd numbers is $n^2$, here $50^2$ |

### Arithmetic on a range gives a range

Both answers in 6a and 6b are yes, because the results are `==` to the vectors. What Julia returns, though, is not the vector `[2, 4, 6, 8, 10]` but another range, `2:2:10`: it works out the new range from the old one's start and step, and computes no element. The difference is significant:

```julia
r = 2*(1:5)                  # 2:2:10, a range
v = 2*[1, 2, 3, 4, 5]        # [2, 4, 6, 8, 10], a Vector
r == v                       # true: the same values in the same order
r isa AbstractVector         # true: a range is a vector too
sizeof(2*(1:5000))           # 32: four numbers describe the range, at any length
sizeof(2*collect(1:5000))    # 40000: a Vector stores every element, 8 bytes each
v[1] = 0                     # v is now [0, 4, 6, 8, 10]
r[1] = 0                     # CanonicalIndexError: a range cannot be changed
```

So a range costs almost no memory however long it is, but to change one of its values you must first `collect` it into a `Vector`. Adding two ranges, as in 6b, behaves the same way: `(1:4) + (2:5)` is the range `3:2:9`.
