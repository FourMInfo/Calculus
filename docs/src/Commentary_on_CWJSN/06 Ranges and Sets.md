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
