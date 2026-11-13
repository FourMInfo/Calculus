# Ranges and Sets

Commentary on the CWJSN chapter [Ranges and Sets](https://fourm.info/cwjsn/basics/ranges.html).

## How a range expresses a sequence

Verzani introduces ranges as `Julia`'s way to write an arithmetic sequence, but he answers his two sequence questions with the formula $a_n = a_0 + nh$, not with a range. This section shows how the two match.

### The same rule

An arithmetic sequence is a rule from positions to values: position $n$ holds $a_0 + nh$. A range holds the same rule. It stores only a few numbers (where it starts, its step, where it ends) and computes each value when you ask for it. Take Verzani's first question, $a_0 = 200$ and $h = -10$, and keep the terms up to $a_{20}$:

| Sequence | Range `r = range(200, step=-10, length=21)` |
| :--- | :--- |
| $a_0 = 200$ | `first(r)` → `200` |
| $h = -10$ | `step(r)` → `-10` |
| $n = 20$, so 21 terms $a_0, \dots, a_{20}$ | `length(r)` → `21` |
| $a_n = a_0 + nh$ | `r[n + 1]`, computed as `first(r) + n * step(r)` |

The last row is the whole connection. Base `Julia` defines the value at index `i` as `first(r) + (i - 1) * step(r)` (`range.jl`, `Julia` 1.13), which is $a_0 + nh$ with $n = i - 1$. The sequence counts from $a_0$ and a `Julia` range counts from index 1, so every term sits one index higher than its subscript:

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

The math describes a sequence by $a_0$, $h$ and $n$. The colon operator takes a start, a step and a _suggested_ stop. `range` accepts several combinations, and `range(a0; step = h, length = n + 1)` takes the math's three values directly (the chapter's Questions ask for this signature). These all give the same range:

```julia
200:-10:0                              # start, step, stop
200:-10:-5                             # the stop is only a limit: the range still ends at 0
range(200, step=-10, length=21)        # a_0, h, and n + 1 terms
range(200, step=-10, length=21) == 200:-10:0    # true
```

### Where a range differs from a sequence

A sequence such as $1, 2, 3, \dots$ can go on forever. A range always has a last value, so it only holds the stretch from its start to its end. To get $a_n$ from a range, the range must reach $a_n$; asking for an index past the end is an error, not the next term:

```julia
r = range(200, step=-10, length=21)
r[22]    # BoundsError: r stops at a_20
```

For a single term the formula is the shorter route, which is why Verzani uses it. A range earns its place when you want many terms: to `collect` them, `sum` them, plot them or loop over them.

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
| Get the $n$th value directly (`r[i]`) | yes | no, `MethodError` |
| `length` | yes | only when what it iterates over has one |
| Memory | a few numbers: start, step, end | the expression and what it iterates over |
| Is an `AbstractVector` | yes | no |

The indexing is what makes a range express a sequence: like the sequence, it can give you any term by its position, without going through the terms before it.
