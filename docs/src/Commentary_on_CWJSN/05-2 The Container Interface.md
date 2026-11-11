# The Container Interface

Commentary on the CWJSN chapter [Vectors and Containers](https://fourm.info/cwjsn/basics/vectors.html), from its section "The container interface in Julia" on. The commentary on the earlier part of the chapter is on the Vectors and Containers page.

## Queues and stacks

Below are some details about queues and stacks created by Claude and edited by me. The results are from Julia 1.13.3 and DataStructures 0.19.6.

### What makes a queue or a stack

Verzani talks about queues but that is only half the story. The computer science data structures he is talking about are queues and stacks. These have many uses in building data applications.

The difference between the two is:

- A queue adds at the end of the collection and removes from the front. To do this in Julia you add with the operation `push!` and remove with `popfirst!`. This type of data structure is often referred to as first in first out (FIFO).
- A stack both adds and removes at the end of the collection. To do this in Julia you add with the operation `push!` and remove with `pop!`: this type of data structure is often referred to as last in first out (LIFO).

So in Julia, it's the operations used that turn a collection into a queue or a stack, more than its type. For example, a `Vector` is a type of collection that can act as either one:

```julia
v = [1, 2, 3]
push!(v, 4)
pop!(v)                      # 4: last in, first out, so a stack
v                            # [1, 2, 3]

v = [1, 2, 3]
push!(v, 4)
popfirst!(v)                 # 1: first in, first out, so a queue
v                            # [2, 3, 4]
```

### Where the other types come from

Verzani writes "Vectors can be used as a queue, though for just that task, there are more performant structures available." That wording is a bit misleading, because it doesn't name those "structures" (he means types) and they aren't in Julia's `Base`. `Vector` is the only type in the table below that `Base` provides. The others, and the priority types further down, need the package [DataStructures](https://github.com/JuliaCollections/DataStructures.jl).

Neither CWJSN's chapters nor the source of the CWJS package mention DataStructures, and it isn't in this repo's `notebooks/Project.toml`, so add it to your own environment to run the examples that use it:

```julia
using Pkg
Pkg.add("DataStructures")
using DataStructures
```

### Which operations each type allows

| Type | Comes from | `push!` | `pop!` | `popfirst!` | `pushfirst!` | `x[2]` | Works as |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `Vector` | `Base` | yes | yes | yes | yes | yes | either |
| `Deque` | DataStructures | yes | yes | yes | yes | no | either |
| `CircularDeque` | DataStructures | yes | yes | yes | yes | yes | either |
| `CircularBuffer` | DataStructures | yes | yes | yes | yes | yes | either |
| `Queue` | DataStructures | yes | no | yes | no | no | queue only |
| `Stack` | DataStructures | yes | yes | no | no | no | stack only |

So `Queue` and `Stack` are the two types that do fix the behaviour. Each one is a struct with a single field, `store::Deque{T}`, and it defines only the methods that fit its behaviour. The other operations cause a `MethodError`:

```julia
using DataStructures
q = Queue{Int}()
push!(q, 1); push!(q, 2); push!(q, 3)
popfirst!(q)                 # 1
first(q)                     # 2: the next to come off
pop!(q)                      # MethodError

s = Stack{Int}()
push!(s, 1); push!(s, 2); push!(s, 3)
pop!(s)                      # 3
first(s)                     # 2: the next to come off
popfirst!(s)                 # MethodError
```

In both types `first` means the next to come off. For a `Stack` that is the most recent item, so with 1, 2 and 3 pushed, `collect(s)` is `[3, 2, 1]`.

### Types with a fixed capacity

`CircularBuffer` and `CircularDeque` both take a maximum size when you create them. They differ in what happens when they are full. A `CircularBuffer` overwrites its oldest item, which suits keeping the last $n$ items. A `CircularDeque` throws an error:

```julia
using DataStructures
c = CircularBuffer{Int}(3)
for i in 1:5
    push!(c, i)
end
collect(c)                   # [3, 4, 5]: 1 and 2 were overwritten

d = CircularDeque{Int}(3)
for i in 1:3
    push!(d, i)
end
push!(d, 4)                  # BoundsError
```

### Removing by priority

`PriorityQueue` and the heaps, such as `BinaryMinHeap`, are a third kind. They remove by priority, not by position. In these two the smallest number comes off first:

```julia
using DataStructures
pq = PriorityQueue{String,Int}()
push!(pq, "low" => 3)
push!(pq, "high" => 1)
push!(pq, "mid" => 2)
popfirst!(pq)                # "high" => 1
first(pq)                    # "mid" => 2

h = BinaryMinHeap{Int}()
push!(h, 3); push!(h, 1); push!(h, 2)
pop!(h)                      # 1
first(h)                     # 2
```

### Are they more performant?

Not necessarily, at least for a plain queue. Here each step is one `push!` at the end plus one `popfirst!` at the front, with `Int` elements, over $10^7$ steps. The time is the best of three runs on an Apple M2 Max and includes filling the queue first. Each cell gives the time and the bytes allocated per step:

| Type | Holding 1,000 elements | Holding $10^6$ elements |
| :--- | :--- | :--- |
| `Vector{Int}` | 1.1 ns, 0 bytes | 1.7 ns, 5 bytes |
| `CircularDeque{Int}` | 1.4 ns, 0 bytes | 1.8 ns, 0 bytes |
| `CircularBuffer{Int}` | 1.5 ns, 0 bytes | 1.9 ns, 0 bytes |
| `Deque{Int}` | 5.6 ns, 8 bytes | 5.9 ns, 9 bytes |
| `Queue{Int}` | 5.7 ns, 8 bytes | 6.2 ns, 9 bytes |

`Vector` does well because `popfirst!` doesn't shift the remaining elements. It moves the array's reference to its first element one place along (`_deletebeg!` in `base/array.jl`). `Queue` takes about as long as `Deque` because that is what it stores.

This is one workload on one machine, and these are averages, so they wouldn't show an occasional slow step. They don't show that `Vector` is always the fastest. They do show that speed alone is not a reason to not use it for a simple queue.

### Which one to choose

| What you need | Use |
| :--- | :--- |
| A simple queue or stack, or you aren't sure | `Vector` |
| Code that says what it means and rejects the wrong operation | `Queue` or `Stack` |
| Only the last $n$ items | `CircularBuffer` |
| A fixed maximum size, with an error when it is exceeded | `CircularDeque` |
| Storage that grows in linked blocks | `Deque` |
| The next item chosen by priority | `PriorityQueue` or a heap |

## Generators and sets

Below are some details about generators and sets created by Claude and edited by me. All run on Julia 1.13.3.

### Set notation and comprehensions

Verzani describes the first five cubes in set notation:

$$\{x^3: x \text{ in } 1, 2,\dots, 5\}$$

He then writes "Comprehension notation is similar" and gives `[x^3 for x in xs]`.

A comprehension is the expression `[x^3 for x in xs]`: it goes through `xs`, evaluates `x^3` for each element, and stores the results in a new array. Julia's manual says "Comprehensions provide a general and powerful way to construct arrays." Written without the square brackets, the same form is a generator (see "What a generator is" below), and a comprehension is that generator passed to `collect`, so `[x^3 for x in xs]` and `collect(x^3 for x in xs)` give the same vector.

Similar is the right word, because the result is a vector and not a set. A mathematical set has no order and no repeats, while a vector has both. In the example given, using cubes hides this difference, since no two of them are equal, but using squares shows this difference. The set of these squares is $\{1, 4\}$, while the comprehension gives:

```julia
xs = [-2, -1, 1, 2]
[x^2 for x in xs]            # [4, 1, 1, 4]: keeps the order and the repeats
```

Set notation often carries a condition as well, such as $\{x^3: x \text{ in } 1, 2,\dots, 5,\ x \text{ even}\}$. A comprehension can have one too, written with `if`:

```julia
[x^3 for x in 1:5 if iseven(x)]    # [8, 64]
```

### What a generator is

Without the square brackets, `x^3 for x in xs` is a generator. **A generator is not a set, and it is not a vector either.** It is a recipe for producing values one at a time. Something has to consume the values to make use of them, such as a function like `sum` or a constructor like `Set`. In `Set(x^3 for x in xs)` the generator is the input, and it is `Set` that makes the set. Assigned to a name by itself, it stays a generator. With `xs = [1, 2, 3, 4, 5]`:

| You write | `ys` holds |
| :--- | :--- |
| `ys = (x^2 for x in xs)` | a `Base.Generator`, with no values computed yet |
| `ys = [x^2 for x in xs]` | a `Vector{Int64}` |
| `ys = Set(x^2 for x in xs)` | a `Set{Int64}` |

Showing `ys` in the first case prints something like `Base.Generator{Vector{Int64}, var"#20#21"}(var"#20#21"(), [1, 2, 3, 4, 5])`. The `var"#20#21"` is the automatically generated name of the anonymous function holding `x^3`, and its number varies.

You can pass a generator to anything that iterates:

```julia
xs = [1, 2, 3, 4, 5]
ys = (x^3 for x in xs)
Set(ys)                      # Set([27, 1, 125, 64, 8])
collect(ys)                  # [1, 8, 27, 64, 125]
sum(ys)                      # 225
```

### Comprehension or generator?

A generator keeps a reference to the vector it reads from, not the name, and computes its values each time it is iterated. So mutating the contents of that vector affects the next iteration, while pointing the original name at a different vector does not. By contrast, a comprehension runs once and stores its results, so neither change affects them:

```julia
xs = [1, 2, 3]
g = (x^3 for x in xs)
v = [x^3 for x in xs]

xs[1] = 10                   # mutate the vector that g holds
collect(g)                   # [1000, 8, 27]
v                            # [1, 8, 27]

xs = [7, 8]                  # the name now points to a different vector
collect(g)                   # [1000, 8, 27]
v                            # [1, 8, 27]
```

Because a comprehension computes when its line runs and a generator only when it is iterated, they also differ in cost:

| Compared on | Comprehension | Generator |
| :--- | :--- | :--- |
| When it computes | once, on that line | on each iteration, only as far as needed |
| `sum` over $10^6$ values | allocates 8 MB | allocates 0 bytes |
| Going through 3 values twice | computes 3 values in total | computes 6 values in total |
| Taking the first value with `x[1]` | works | `MethodError` |

So use a comprehension when you need the values more than once or by position, and a generator when they go straight into one function such as `sum` or `Set`.

### Getting a `Set`

Julia has no comprehension syntax for sets. There is also no cast: `convert(Set, [1, 2])` is a `MethodError`. To create one, you call `Set` as a constructor, which takes anything that can be iterated over (see "Making a `Set`" on the Vectors and Containers page):

```julia
xs = [1, 2, 3, 4, 5]
Set(x^3 for x in xs)              # Set([27, 1, 125, 64, 8])
Set([x^3 for x in xs])            # the same set, but it builds a vector first
Set{Float64}(x^3 for x in xs)     # Set([27.0, 1.0, 125.0, 64.0, 8.0])
Set(x^3 for x in 1:5 if iseven(x))    # Set([64, 8])
```

Now the squares from above give the mathematical set:

```julia
xs = [-2, -1, 1, 2]
[x^2 for x in xs]            # [4, 1, 1, 4]
Set(x^2 for x in xs)         # Set([1, 4]): no order, no repeats
```

Each form addresses a different need:

- The vector lines up with its inputs: the output in each position belongs to the input in the same position of `xs`. That is what you want for a table of values or a plot.
- The set holds the values the function reaches on these inputs, which is the image of `xs` under the function.

Comparing sizes shows you whether two different inputs share an output, in other words whether the function is one-to-one on these inputs. If there is a repeat in `xs`, comparing to `length(xs)` gives the wrong answer. In that case, we need to compare to the number of different inputs by using `length(Set(xs))`, because `xs` itself holds repeats:

```julia
xs = [-2, -1, 1, 2]
length(Set(x^2 for x in xs)), length(Set(xs))    # (2, 4): not one-to-one
length(Set(x^3 for x in xs)), length(Set(xs))    # (4, 4): one-to-one

xs = [1, 1, 2]
length(Set(x^3 for x in xs)), length(xs)         # (2, 3): looks not one-to-one, but only because 1 is repeated, so use the second test
length(Set(x^3 for x in xs)), length(Set(xs))    # (2, 2): one-to-one
```

The test compares values exactly, so it inherits floating point's behaviour (see "Number Representation" on the Number Systems page). Mathematically $\sin(0)$ and $\sin(\pi)$ are both 0, but the computed values differ. A `Set` also keeps `0.0` and `-0.0` apart even though `==` calls them equal, because it stores its elements as the keys of a `Dict`, and `isequal(0.0, -0.0)` is false:

```julia
Set(sin(x) for x in [0, π])    # Set([1.2246467991473532e-16, 0.0])
0.0 == -0.0                    # true
Set([0.0, -0.0])               # Set([-0.0, 0.0])
```

Two sets are also equal whatever order they were built in, which is not true of vectors:

```julia
Set([1, 2]) == Set([2, 1])   # true
[1, 2] == [2, 1]             # false
```

### When the parentheses can be left out

A generator needs parentheses around it, but a function call's own parentheses can serve when the generator is the last argument:

| Form | Result |
| :--- | :--- |
| `ys = x^3 for x in xs` | `ParseError`: nothing encloses the generator |
| `ys = (x^3 for x in xs)` | works |
| `sum(x^3 for x in xs)` | works: it is the only argument |
| `f(1, x for x in 1:2)` | works: it is the last argument |
| `f(x for x in 1:2, 1)` | `ParseError`: another argument follows it |
| `f((x for x in 1:2), 1)` | works |

## Broadcasting

Below are some details about broadcasting created by Claude and edited by me. All run on Julia 1.13.3.

Verzani says the details of broadcasting allow for more flexibility than in the case he describes (one function applied to one vector). He then names three of these "more flexible" features in passing:

1. padding "different sized objects to the same shape",
2. fusing "combined function calls", and
3. treating "a container as a scalar-like argument".

This section gives more details on all three as well as other aspects of broadcasting.

### What the dot does

For a function `f`, writing `f.(args...)` is the same as calling `broadcast(f, args...)`. In contrast, an operator takes the dot in _front_, as in `xs .^ 2`. This works for any function, including your own, so you don't have to write a separate vector version of a function first. The manual puts it this way: "which functions are vectorizable need not be decided upon in advance by the library writer".

```julia
f(x) = x^2 + 1
xs = [1, 2, 3]
f.(xs)                       # [2, 5, 10]
broadcast(f, xs)             # [2, 5, 10]
xs .^ 2 .+ 1                 # [2, 5, 10]
```

A dotted operator has the same precedence as its undotted form. For example, `.+` binds as tightly as `+`, which is tighter than `:`. So `1:3 .+ 1` means `1:(3 .+ 1)`, which becomes `1:4`. Write `(1:3) .+ 1` to get `2:4`. For the dot's other parsing trap, see "`1.`, `2.*3` and the broadcasting dot" found on the Number Systems page.

### With and without the dot

The table below shows how functions and operators work with and without the dot. Without the dot, an operation that has no meaning for vectors gives a `MethodError` (the first four rows). Some operations on vectors and matrices already have a meaning in mathematics and work without a dot. For some of these that meaning gives the same result as the dot (the next three rows), but for others it gives a different answer with no warning (the last six rows).

The table assumes: `xs = [1, 2, 3]`, `ys = [10, 20, 30]` and `A = [1 2; 3 4]`:

| Without the dot | Gives | With the dot | Gives |
| :--- | :--- | :--- | :--- |
| `sin(xs)` | `MethodError` | `sin.(xs)` | the sine of each entry |
| `xs + 1` | `MethodError` | `xs .+ 1` | `[2, 3, 4]` |
| `xs ^ 2` | `MethodError` | `xs .^ 2` | `[1, 4, 9]` |
| `xs * ys` | `MethodError` | `xs .* ys` | `[10, 40, 90]` |
| `xs + ys` | `[11, 22, 33]` | `xs .+ ys` | `[11, 22, 33]` |
| `2 * xs` | `[2, 4, 6]` | `2 .* xs` | `[2, 4, 6]` |
| `xs / 2` | `[0.5, 1.0, 1.5]` | `xs ./ 2` | `[0.5, 1.0, 1.5]` |
| `2 / xs` | a 1×3 row `r` for which `r * xs` is approximately 2 | `2 ./ xs` | `[2.0, 1.0, 0.666…]` |
| `A * A` | the matrix product `[7 10; 15 22]` | `A .* A` | `[1 4; 9 16]`: the [Hadamard product](https://mathworld.wolfram.com/HadamardProduct.html), written $A \odot A$ |
| `A ^ 2` | the matrix product `[7 10; 15 22]` | `A .^ 2` | `[1 4; 9 16]` |
| `sqrt(A)` | a matrix `B` with `B * B` equal to `A`, complex here | `sqrt.(A)` | the square root of each entry |
| `xs == ys` | `false`: one answer for the whole vector | `xs .== ys` | `Bool[0, 0, 0]` |
| `[1, 5] < [2, 0]` | `true`: compared in dictionary order | `[1, 5] .< [2, 0]` | `Bool[1, 0]` |

!!! note "The 1×3 row from 2 / xs"
    The REPL shows `2 / xs` as `1×3 transpose(::Vector{Float64})`. A [transpose](https://fourm.info/linear_algebra/dev/Basics/02%20Matrices/#Transpose) turns rows into columns; Julia's `transpose(v)` returns the vector wrapped so it reads as one row, without copying it. `xs'` is the _adjoint_, a different wrapper shown as `adjoint`: it also takes the complex conjugate of each entry. For real numbers the two hold the same entries and `xs' == transpose(xs)` is `true`, but their types differ.

### The shape of the result

For his vector example, Verzani says broadcasting returns "a vector of the same size as `xs`". The size always follows the argument, but the result is not always a vector. With `f(x) = x^2`:

| Argument | `f.(argument)` | Result |
| :--- | :--- | :--- |
| `[1, 2, 3]` | `[1, 4, 9]` | a vector |
| `[1 2; 3 4]` | `[1 4; 9 16]` | a matrix |
| `(1, 2, 3)` | `(1, 4, 9)` | a tuple |
| `1:3` | `[1, 4, 9]` | a vector, not a range |
| `(x for x in 1:2)` | `[1, 4]` | a vector, computed at once |
| `Set([1, 2])` | `[4, 1]` | a vector, in the set's own order |
| `2` | `4` | a number |

The `broadcast` docstring gives the rule. If all the arguments are scalars or zero-dimensional arrays, the result is a scalar. If at least one is a tuple and the rest are scalars or zero-dimensional arrays, the result is a tuple. All other combinations give an `Array`, so `(1, 2) .+ [10, 20]` is the vector `[11, 22]`. The docstring also lets a collection type define its own result. Ranges do this for arithmetic, which is why `(1:3) .+ 1` is the range `2:4` while `f.(1:3)` above is a vector.

### Which arguments count as one value

Broadcasting goes through the entries of most arguments, but not all of them. The manual says: "By default, only some argument types are considered scalars, including (but not limited to) `Number`s, `String`s, `Symbol`s, `Type`s, `Function`s and some common singletons like `missing` and `nothing`. All other arguments are iterated over or indexed into elementwise." Base's `broadcastable` method also treats a `Pair` as one value.

So a string is a collection when you iterate over it, but broadcasting treats it as one value:

```julia
uppercase.("abc")                                    # "ABC": one string, not three characters
uppercase.(collect("abc"))                           # ['A', 'B', 'C']
"a" .* ["b", "c"]                                    # ["ab", "ac"]
string.(1:3, ". ", ["First", "Second", "Third"])     # ["1. First", "2. Second", "3. Third"]
first.("a" => 1)                                     # "a"
[1, missing] .+ 1                                    # Union{Missing, Int64}[2, missing]
```

Dictionaries and named tuples are in neither group: broadcasting doesn't work with them directly. To broadcast over what they hold, ask for `values` or `keys`:

```julia
d = Dict(:a => 4)
nt = (a = 4, b = 9)
sqrt.(d)                     # ArgumentError: broadcasting over dictionaries and `NamedTuple`s is reserved
sqrt.(nt)                    # ArgumentError: the same message
sqrt.(values(d))             # [2.0]
sqrt.(values(nt))            # (2.0, 3.0)
```

Keyword arguments are not broadcast either. The manual says they "are simply passed through to each call of the function":

```julia
round.([1.2345, 2.3456], digits = 2)    # [1.23, 2.35]
```

### How arguments of different sizes are combined

Verzani says broadcasting "will try to pad out different sized objects to the same shape". There is an important nuance here. Julia compares the sizes dimension by dimension. Two sizes fit only if:

1. they are equal or
2. one of them is 1.

A dimension of length 1 then acts as if its entries are repeated, without actually building it out. A dimension that is missing counts as length 1. The manual says broadcast "expands singleton dimensions in array arguments to match the corresponding dimension in the other array without using extra memory". Any other combination is an error:

| Expression | Sizes | Result |
| :--- | :--- | :--- |
| `[1, 2, 3] .+ 10` | (3,) and a number | `[11, 12, 13]` |
| `[1, 2, 3] .+ [10]` | (3,) and (1,) | `[11, 12, 13]` |
| `[1, 2, 3] .+ [10, 20]` | (3,) and (2,) | `DimensionMismatch` |
| `[1, 2, 3] .+ [10 20]` | (3,) and (1, 2) | `[11 21; 12 22; 13 23]`, a 3×2 matrix |
| `[1 2 3; 4 5 6] .+ [10, 20]` | (2, 3) and (2,) | `[11 12 13; 24 25 26]`: the column is added to each column |
| `[1 2 3; 4 5 6] .+ [10 20 30]` | (2, 3) and (1, 3) | `[11 22 33; 14 25 36]`: the row is added to each row |
| `[1 2 3; 4 5 6] .+ [10 20]` | (2, 3) and (1, 2) | `DimensionMismatch` |
| `(1, 2, 3) .+ (10,)` | (3,) and (1,) | `(11, 12, 13)` |
| `(1, 2, 3) .+ (10, 20)` | (3,) and (2,) | `DimensionMismatch` |

Rows 3 and 4 differ by one comma: `[10, 20]` is a column and `[10 20]` is a row, so one is an error and the other is a matrix. This is useful if it is what you intend to do, so it's important to pay attention. In the example below, we can see the same thing playing out: a column against a row gives a table of every combination, here the powers 1 to 3 of each of 1, 2 and 3:

```julia
[1, 2, 3] .^ [1 2 3]         # [1 1 1; 2 4 8; 3 9 27]
```

### Keeping a collection whole

Verzani says "there are times where it is desirable to treat a container as a scalar-like argument, a common idiom is to wrap that container in a 1-element tuple", but doesn't show an example. His sample variance example, `xs .- mean(xs)`, is a different case. `mean(xs)` is a number, and so is `base` in `log.(base, ys)`. Broadcasting already treats a number as one value. The idiom he mentions is for an argument that is itself a collection, which broadcasting would otherwise go through entry by entry. To wrap a vector, put a comma after it inside parentheses. Without the comma, the parentheses do nothing:

```julia
([2, 3, 4],)                 # ([2, 3, 4],): a tuple with one element, the vector
([2, 3, 4])                  # [2, 3, 4]: just the vector
```

The tuple has length 1, so by the rule above it stretches to fit, and every call gets the whole vector:

```julia
xs = [1, 2, 3]
in.(xs, ([2, 3, 4],))        # Bool[0, 1, 1]: is each x in the vector?
in.(xs, [2, 3, 4])           # Bool[0, 0, 0]: compares in(1, 2), in(2, 3), in(3, 4)
in.([1, 2, 3, 4], [2, 3])    # DimensionMismatch: lengths 4 and 2
```

The second line is the dangerous one. With equal lengths it is iterating element by element, so nothing fails and you get a wrong (or at least unintended) answer. It runs because a number iterates as itself, so e.g. `in(1, 2)` (the first comparison) is a legal call.

Evaluating one polynomial at several points needs the same wrapping. In the example below we use $1 + 2x^2$ with its coefficients listed from the constant term up:

```julia
evalpoly.([1, 2, 3], ([1, 0, 2],))    # [3, 9, 19]
evalpoly.([1, 2, 3], [1, 0, 2])       # MethodError: evalpoly(::Int64, ::Int64)
```

`Ref` does the same job, and the book uses both forms later: `find_zero.(f, Ref(I), 1:5)` in the Implications of Continuity chapter, and `(v,)` in the plotting code of the Surface Area chapter. A `Ref` has no dimensions at all, while the tuple has one dimension of length 1. When another argument is a collection, that argument sets the shape of the result, and the two wrappers give the same answer:

```julia
in.([1, 2, 3], ([2, 3, 4],))      # Bool[0, 1, 1]
in.([1, 2, 3], Ref([2, 3, 4]))    # Bool[0, 1, 1]: the same
```

When the wrapped collection is the only argument, the wrapper sets the shape: the tuple gives a one-element tuple, `Ref` gives the value itself:

```julia
length.(([2, 3, 4],))             # (3,): wrapped in a tuple
length.(Ref([2, 3, 4]))           # 3: just the number
```

### Fusing

Verzani says broadcasting "can also _fuse_ combined function calls" without saying what that means. Nested dotted calls run as one loop over the entries, and only the final result gets an array. The manual says `sin.(cos.(X))` is "similar to `[sin(cos(x)) for x in X]`: there is only a single loop over `X`, and a single array is allocated for the result", and that this "is not a compiler optimization that may or may not occur, it is a syntactic guarantee". Dotted operators fuse the same way (see `.&&` on the Inequalities and Logical Expressions page). The manual's example, run on three values:

```julia
X = [0, π/3, π]
sin.(cos.(X))                  # [0.8414709848078965, 0.4794255386042031, -0.8414709848078965]
[sin(cos(x)) for x in X]       # [0.8414709848078965, 0.4794255386042031, -0.8414709848078965]
sin.(cos.(X)) == [sin(cos(x)) for x in X]    # true
```

Here is the same calculation on 1000 values, fused and in separate steps:

```julia
fused(v) = sqrt.(abs2.(v .- 1.0))
steps(v) = (t = v .- 1.0; u = abs2.(t); sqrt.(u))
xs = collect(1.0:1000.0)
fused(xs); steps(xs);        # the first calls compile, so they aren't measured
@allocated fused(xs)         # 8256 bytes: one vector
@allocated steps(xs)         # 24768 bytes: three vectors
```

A call without a dot is not part of the loop. The manual says "the fusion stops as soon as a "non-dot" function call is encountered", and gives `sin.(sort(cos.(X)))` as an example, where `sort` needs the whole vector. So `cos.` runs as one loop, `sort` reorders its finished vector, and `sin.` runs as a second loop:

```julia
X = [0, π/3, π]
cos.(X)                        # [1.0, 0.5000000000000001, -1.0]
sort(cos.(X))                  # [-1.0, 0.5000000000000001, 1.0]
sin.(sort(cos.(X)))            # [-0.8414709848078965, 0.4794255386042031, 0.8414709848078965]
```

Verzani's sample variance shows all of this at once:

```julia
using Statistics: mean
xs = [1, 1, 2, 3, 5, 8, 13]
n = length(xs)
(1/(n-1)) * sum(abs2.(xs .- mean(xs)))    # 19.57142857142857
```

- The two dotted calls `abs2.` and `.-` fuse into one loop.
- The call `mean(xs)` has no dot, so it runs once, before the loop, and its value is used for every entry.
- The call `sum` has no dot either, so it receives the finished vector.

That also means the dot on a function with no arguments changes how many times it runs. In the manual's words, "All functions in the fused broadcast are always called for every element of the result":

```julia
xs = zeros(3)
allequal(xs .+ rand())       # true: rand() ran once, so every entry got the same number
allequal(xs .+ rand.())      # false: rand.() ran once per entry
```

### `@.` and `.=`

The macro `@.` puts in the dots for you. The manual says it converts "every function call, operation, and assignment in an expression into the "dotted" version". Verzani uses it in the Exponential and Logarithmic Functions chapter (`@. [n f(n) (a/n - e)]`) with the comment "`@.` just allows broadcasting". Every call means every call, which can be wrong with no warning. In this block `mean` gets dotted too, so each number is averaged with itself. A `$` in front of a function leaves it undotted:

```julia
using Statistics: mean
xs = [1, 2, 3]
@. sqrt(abs2(xs - 1))        # [0.0, 1.0, 2.0]: the same as sqrt.(abs2.(xs .- 1))
@. xs - mean(xs)             # [0.0, 0.0, 0.0]: wrong, this is xs .- mean.(xs)
@. xs - $mean(xs)            # [-1.0, 0.0, 1.0]: the same as xs .- mean(xs)
```

The assignment `.=` writes into a vector that already exists, while `=` points the name at a new one (see "Values, names and symbols" on the Vectors and Containers page). So `.=` changes what every name for that vector sees:

```julia
xs = [1, 2, 3]
ys = xs
ys .= xs .* 2                # overwrites the vector both names point to
xs                           # [2, 4, 6]
ys === xs                    # true

xs = [1, 2, 3]
ys = xs
ys = xs .* 2                 # a new vector, and only ys points to it
xs                           # [1, 2, 3]
ys === xs                    # false
```

It fuses as well, so with `v` already in existence, `v .= sqrt.(abs2.(xs .- 1.0))` allocated 0 bytes, where the fused version above allocated 8256. Since it writes into the existing vector, `.=` can't change that vector's size:

```julia
xs = [1, 2, 3]
xs .= 0                      # [0, 0, 0]: the 0 stretches to every entry
xs .+= 1                     # [1, 1, 1]: the same as xs .= xs .+ 1
xs .= [1, 2]                 # DimensionMismatch: lengths 3 and 2
```

## `map` and broadcasting

Below are some details about `map` created by Claude and edited by me. All run on Julia 1.13.3.

Verzani says `map` "is very much related to broadcasting" and that `map(sin, xs)` computes "the same things as `sin.(xs)`". He doesn't say where they differ, and they differ in ways that can give a wrong answer with no error.

### Where they agree

For one vector, or for vectors of the same length, they give the same values at the same cost (see the table in "Broadcast or `mapreduce`? The trade-offs" below):

```julia
xs = [1, 2, 3]
map(sin, xs) == sin.(xs)     # true
map(+, xs, [10, 20, 30])     # [11, 22, 33]
xs .+ [10, 20, 30]           # [11, 22, 33]
```

### Different sizes: `map` stops, broadcasting stretches

The docstring for `map` says it applies the function "elementwise, and stop when any of them is exhausted", and that `broadcast` "allows mismatched sizes". So where broadcasting stretches a length-1 argument or refuses, `map` takes only as many entries as the shortest argument has:

| `a` | `b` | `map(+, a, b)` | `a .+ b` |
| :--- | :--- | :--- | :--- |
| `[1, 2, 3]` | `[10, 20, 30]` | `[11, 22, 33]` | `[11, 22, 33]` |
| `[1, 2, 3]` | `[10, 20]` | `[11, 22]`: the third entry is dropped | `DimensionMismatch` |
| `[1, 2, 3]` | `[10]` | `[11]`: two entries are dropped | `[11, 12, 13]` |
| `[1, 2, 3]` | `10` | `[11]`: two entries are dropped | `[11, 12, 13]` |
| `[1, 2, 3]` | `[10 20 30]` | `[11, 22, 33]` | a 3×3 matrix |
| `[1 2; 3 4]` | `[10, 20]` | `[11, 23]`: down the first column only | `[11 12; 23 24]` |
| `[1 2; 3 4]` | `[10 20]` | `DimensionMismatch` | `[11 22; 13 24]` |
| `[1 2; 3 4]` | `[10 20; 30 40]` | `[11 22; 33 44]` | `[11 22; 33 44]` |

The fourth row is the one to watch. `map(+, xs, 10)` looks as if it adds 10 to each entry, but a number iterates as a collection of one, so `map` stops after the first entry and raises no error. To use a parameter, broadcast (`xs .+ 10`) or put the parameter inside the function (`map(x -> x + 10, xs)`).

### Which collections each one accepts

The two don't accept the same arguments, and on a string they don't even see the same thing: `map` goes through its characters, while broadcasting takes the whole string as one value (see "Which arguments count as one value" above).

| Argument | With `map` | With broadcasting |
| :--- | :--- | :--- |
| Named tuple | `map(sqrt, (a = 4, b = 9))` gives `(a = 2.0, b = 3.0)`, keeping the names | `sqrt.((a = 4, b = 9))` is an `ArgumentError` |
| `Dict` | `map(sqrt, Dict(:a => 4))` is an `ErrorException` | `sqrt.(Dict(:a => 4))` is an `ArgumentError` |
| `Set` | `map(abs2, Set([1, 2]))` is an `ErrorException` | `abs2.(Set([1, 2]))` gives the vector `[4, 1]` |
| String, returning a character each | `map(uppercase, "abc")` gives `"ABC"` | `uppercase.("abc")` gives `"ABC"` |
| String, returning anything else | `map(length, "abc")` is an `ArgumentError` | `length.("abc")` gives `3` |
| `missing` | `map(abs2, missing)` is a `MethodError` | `abs2.(missing)` gives `missing` |
| Generator or `zip` | `map(sum, zip([1, 2], [3, 4]))` gives `[4, 6]` | `sum.(zip([1, 2], [3, 4]))` gives `[4, 6]` |

### What only one of them can do

Nested `map` calls don't fuse, so each one builds its own vector:

```julia
with_dots(v) = sin.(cos.(v))
with_maps(v) = map(sin, map(cos, v))
xs = collect(range(0.0, 3.0, 1000))
with_dots(xs); with_maps(xs);    # the first calls compile, so they aren't measured
@allocated with_dots(xs)         # 8256: one vector
@allocated with_maps(xs)         # 16512: two vectors
```

`map` does have an in-place form, like `.=` (see "`@.` and `.=`" above): `map!(sin, w, v)` also allocated 0 bytes. It doesn't fuse, though, so it takes one function.

The 1-element tuple from "Keeping a collection whole" only works for broadcasting, because only broadcasting stretches it. In `map` the tuple is the shortest argument, so `map` stops after one entry. To keep a collection whole in `map`, put it inside the function:

```julia
in.([1, 2, 3], ([2, 3, 4],))           # Bool[0, 1, 1]
map(in, [1, 2, 3], ([2, 3, 4],))       # Bool[0]: stops after one entry
map(x -> x in [2, 3, 4], [1, 2, 3])    # Bool[0, 1, 1]
```

In the other direction, `map` can take a longer function written in place with a `do` block, which has no dotted form. The function has to be named first in order to broadcast it:

```julia
map([1, 2, 3]) do x
    y = x^2
    y + 1
end                          # [2, 5, 10]
```

### Which one to use

| Situation | Use | Why |
| :--- | :--- | :--- |
| One function over one collection | `sin.(xs)` | It costs the same as `map` and is shorter |
| A number or other parameter alongside a vector | `xs .+ 10` | `map(+, xs, 10)` drops entries with no error |
| Vectors that must have the same length | `xs .+ ys` | A length mismatch is an error, where `map` drops entries |
| Several steps in one expression | `sin.(cos.(xs))` | It fuses into one loop and one vector |
| A function longer than one line | `map(xs) do x … end` | It needs no separate name |
| A named tuple, keeping its names | `map(sqrt, nt)` | Broadcasting refuses it |
| Stopping at the shortest collection on purpose | `map(+, xs, ys)` | That's what `map` is defined to do |

## Reductions

Below are some details about reductions created by Claude and edited by me. All run on Julia 1.13.3.

### What a reduction is, and what Verzani leaves implicit

Verzani says "Reductions take a container with one or more dimensions and reduces the number of dimensions". Broadcasting keeps the shape of its arguments, while a reduction combines the entries of a collection into one value.

He introduces `map` "in combination with `reduce`, a reduction", then `mapreduce`, then "other specialized reduction functions" such as `sum` and `maximum`. This suggests that `reduce` and `mapreduce` are the tools to reach for, with the others as extras. It is closer to the opposite, though he never says so: **`reduce` is the general tool, and Julia gives the common reductions their own names, so you rarely need to write `reduce` or `mapreduce` at all.** The chapter itself never calls `reduce`. Its example of `map` in combination with `reduce` is `sum(map(sin, xs))`.

A named reduction and the operator behind it are different functions. Verzani's note on `max` and `maximum` makes this point for that one pair, and it holds for the others too. The operator combines its arguments, and the reduction combines the entries of a collection:

| Operator, on its arguments | Reduction, on a collection | The same reduction in general form |
| :--- | :--- | :--- |
| `+(1, 3, 2)` | `sum(xs)` | `reduce(+, xs)` |
| `*(1, 3, 2)` | `prod(xs)` | `reduce(*, xs)` |
| `max(1, 3, 2)` | `maximum(xs)` | `reduce(max, xs)` |
| `min(1, 3, 2)` | `minimum(xs)` | `reduce(min, xs)` |

So `+(xs)` is not a sum: it has one argument, nothing to add to it, and it returns `xs`. In the same way, `all` applies "and" across the entries of a collection and `any` applies "or".

### `+` and `sum`, `max` and `maximum`

`+` is to `sum` as `max` is to `maximum`: one combines its arguments, the other combines the entries of a collection. Each pair also connects through `reduce`, and each operator can do the reduction's job by splatting. With `xs = [1, 3, 2]`:

| Job | `+` and `sum` | `max` and `maximum` |
| :--- | :--- | :--- |
| On arguments | `+(1, 3, 2)` is `6` | `max(1, 3, 2)` is `3` |
| On a collection | `sum(xs)` is `6` | `maximum(xs)` is `3` |
| Through `reduce` | `reduce(+, xs)` is `6` | `reduce(max, xs)` is `3` |
| By splatting | `+(xs...)` is `6` | `max(xs...)` is `3` |
| With a function first | `sum(abs2, xs)` is `14` | `maximum(abs2, xs)` is `9` |

The two pairs differ in three places. With `ys = [10, 0, 5]`:

| Case | `+` and `sum` | `max` and `maximum` |
| :--- | :--- | :--- |
| The operator on one vector | `+(xs)` returns `xs` | `max(xs)` is a `MethodError` |
| The operator on two vectors | `+(xs, ys)` is `[11, 3, 7]`, entry by entry | `max(xs, ys)` is `[10, 0, 5]`, one of the two vectors |
| The reduction on an empty collection | `sum(Int[])` is `0` | `maximum(Int[])` is an `ArgumentError` |

These come from the same fact: `+` has a mathematical meaning on vectors, while `max` only picks one of its arguments (see "With and without the dot" above). So `max(xs, ys)` gives no error. It compares the two vectors in dictionary order and returns the larger one whole. For the larger value in each position, broadcast it:

```julia
xs = [1, 3, 2]
ys = [10, 0, 5]
+(xs, ys)                    # [11, 3, 7]: entry by entry
max(xs, ys)                  # [10, 0, 5]: all of ys, since 1 < 10 decides it
max.(xs, ys)                 # [10, 3, 5]: the larger value in each position
```

### The reductions Julia already provides

Most of these also take a function as their first argument, which they apply to each entry on the way through. That one pass is what `mapreduce` does, without having to name the operator. With `xs = [1, 3, 2]`:

| Function | Gives | `f(xs)` | `f(abs2, xs)` |
| :--- | :--- | :--- | :--- |
| `sum` | the total | `6` | `14` |
| `prod` | the product | `6` | `36` |
| `maximum` | the largest value | `3` | `9` |
| `minimum` | the smallest value | `1` | `1` |
| `extrema` | the smallest and the largest | `(1, 3)` | `(1, 9)` |
| `findmax` | the largest value and its position | `(3, 2)` | `(9, 2)` |
| `findmin` | the smallest value and its position | `(1, 1)` | `(1, 1)` |
| `argmax` | see below | `2` | `3` |
| `argmin` | see below | `1` | `1` |
| `mean`, from `Statistics` | the average | `2.0` | `4.666…` |

`argmax` needs care, because the two forms answer different questions. `argmax(xs)` gives the position of the largest value. `argmax(f, xs)` gives the entry of `xs` for which `f` is largest, not its position. Verzani's `v = [1, 2, 3, 4]` hides this because each entry equals its own position, so a different order is needed to see it. To get the position when applying a function, use `findmax(f, xs)` or `argmax(f.(xs))`:

```julia
v = [3, 4, 1, 2]
argmax(sin, v)               # 2: the entry of v, since sin(2) is the largest
argmax(sin.(v))              # 4: the position of that entry
findmax(sin, v)              # (0.9092974268256817, 4): the value and the position
```

The functions for truth values work the same way. Verzani calls `iseven` a _predicate_ function, one that returns `true` or `false`:

| Function | Gives | On `[true, false, true]` | `f(iseven, [1, 3, 2])` |
| :--- | :--- | :--- | :--- |
| `any` | is at least one true? | `true` | `true` |
| `all` | are they all true? | `false` | `false` |
| `count` | how many are true? | `2` | `1` |

`any` and `all` also stop as soon as the answer is settled. Counting the calls on `[2, 1, 3, 5]`, `any(iseven, v)` called `iseven` once, while `reduce(|, iseven.(v))` called it 4 times.

For a matrix, these functions take `dims` to reduce along one dimension. The dimension stays, with length 1:

```julia
A = [1 2; 3 4]
sum(A)                       # 10
sum(A; dims = 1)             # [4 6]: one row, the total of each column
sum(A; dims = 2)             # [3; 7;;]: one column, the total of each row
maximum(A; dims = 1)         # [3 4]
```

An empty collection needs a starting value from somewhere. Verzani mentions this for `sum` and `prod`. `sum`, `prod`, `any`, `all` and `count` have an obvious answer for it. `maximum` has none, so you must supply `init`:

```julia
sum(Int[])                   # 0
prod(Int[])                  # 1
any(Bool[])                  # false
all(Bool[])                  # true
maximum(Int[])               # ArgumentError: reducing over an empty collection is not allowed
maximum(Int[]; init = 0)     # 0
```

### When you do need `reduce` or `mapreduce`

Use `reduce` when the operator has no named reduction, for example to join vectors into one:

```julia
reduce(vcat, [[1, 2], [3]])       # [1, 2, 3]
reduce(hcat, [[1, 2], [3, 4]])    # [1 3; 2 4]
```

It's worth checking for a named version first. `gcd` and `lcm` both take a vector directly, so `gcd([12, 18, 30])` gives `6` with no `reduce`, and `join(["a", "b"])` gives `"ab"`.

Use `mapreduce` when you also need to apply a function on the way, and the operator still has no named reduction:

```julia
mapreduce(collect, vcat, [1:2, 3:4])    # [1, 2, 3, 4]
```

If the operator is not associative, use neither. The docstring for `reduce` says "you can't use non-associative operations like `-` because it is undefined whether `reduce(-,[1,2,3])` should be evaluated as `(1-2)-3` or `1-(2-3)`", and points to `foldl` and `foldr` (the `mapreduce` docstring points to `mapfoldl` and `mapfoldr`):

```julia
foldl(-, [1, 2, 3])          # -4: (1 - 2) - 3
foldr(-, [1, 2, 3])          # 2: 1 - (2 - 3)
```

The book does use `reduce` directly later on, for example to repeat a step of Newton's method in `reduce((x, step) -> x - f(x)/f'(x), 1:4, init=2)`.

### Broadcast or `mapreduce`? The trade-offs

A broadcast in a reduction, such as `sum(sin.(xs))`, is shorter than `mapreduce(sin, +, xs)` and looks more like the mathematics. But `sum` has no dot, so fusion stops there (see "Fusing" above): `sin.(xs)` builds a whole vector, then `sum` goes through it. That's the "performance drawback" Verzani gives for `sum(map(sin, xs))`, the same two passes. `sum(sin, xs)` avoids it and is shorter than `mapreduce`:

```julia
with_dot(v) = sum(sin.(v))
with_mapreduce(v) = mapreduce(sin, +, v)
with_function(v) = sum(sin, v)
with_generator(v) = sum(sin(x) for x in v)
xs = collect(range(0.0, 3.0, 1000))
with_dot(xs); with_mapreduce(xs); with_function(xs); with_generator(xs);    # the first calls compile, so they aren't measured
@allocated with_dot(xs)           # 8256: a vector of 1000 values
@allocated with_mapreduce(xs)     # 0
@allocated with_function(xs)      # 0
@allocated with_generator(xs)     # 0
```

Most of the difference is memory rather than time. On $10^6$ values (an M2 Max, Julia 1.13.3, one thread, fastest of 30 runs):

| Task | Expression | Allocates | Time |
| :--- | :--- | :--- | :--- |
| Add up | `sum(sin.(xs))` | 8 MB | 3888 μs |
| Add up | `mapreduce(sin, +, xs)` | 0 | 3721 μs |
| Add up | `sum(sin, xs)` | 0 | 3727 μs |
| Add up | `sum(sin(x) for x in xs)` | 0 | 3688 μs |
| Largest | `maximum(sin.(xs))` | 8 MB | 3893 μs |
| Largest | `mapreduce(sin, max, xs)` | 0 | 3710 μs |
| Largest | `maximum(sin, xs)` | 0 | 3735 μs |
| Keep the vector | `sin.(xs)` | 8 MB | 3807 μs |
| Keep the vector | `map(sin, xs)` | 8 MB | 3798 μs |

The broadcast forms are 4–5% slower here, but `sin` does most of the work, so a cheaper function may show a larger gap. The fastest run also leaves out garbage collection, which a broadcast repeated in a loop would pay for. The total from the generator differs from the others in the last digits (663330.239428815 against 663330.2394288229).

So which to use depends on the calculation:

| Situation | Use | Why |
| :--- | :--- | :--- |
| You want the vector itself | `sin.(xs)` | It costs the same as `map(sin, xs)` and is shorter |
| One function, then a reduction | `sum(sin, xs)` | It's as short as the broadcast and allocates nothing |
| A formula of several steps, once | `sum(abs2.(xs .- mean(xs)))` | It reads like the formula, and the cost is one vector |
| A formula of several steps, repeatedly on large vectors | `m = mean(xs); sum(abs2(x - m) for x in xs)` | It allocates nothing |
| You need the values again | `ys = sin.(xs); sum(ys), maximum(ys)` | The vector is computed once and kept |
| Two collections | `sum(x * y for (x, y) in zip(xs, ys))` | `sum(*, xs, ys)` is a `MethodError`, and both `sum(xs .* ys)` and `mapreduce(*, +, xs, ys)` allocate a vector |

The generator in the fourth row needs `m` stored first. In a broadcast `mean(xs)` has no dot, so it runs once. In a generator it is part of the expression, so it runs once per entry:

```julia
using Statistics: mean
calls = Ref(0)
counted_mean(v) = (calls[] += 1; mean(v))
xs = collect(1.0:1000.0)

sum(abs2.(xs .- counted_mean(xs)))
calls[]                      # 1

calls[] = 0
sum(abs2(x - counted_mean(xs)) for x in xs)
calls[]                      # 1000
```
