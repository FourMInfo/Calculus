# Vectors and Containers

Commentary on the CWJSN chapter [Vectors and Containers](https://fourm.info/cwjsn/basics/vectors.html).

## More in-depth coverage of Vectors

Many of the topics covered in this chapter are covered in greater depth in my Linear Algebra repository. Below is a table that links topics in this CWJSN chapter to coverage in the documentation of that repo. Note that most of the topics are covered in the _Vectors_ chapter of the _Basics_ section, but some are covered in two chapters of the _Geometry_ section, which is currently less well edited. Links to the _Geometry_ section are clearly marked.

| Topic in the CWJSN vectors chapter | Linear Algebra section |
| :--- | :--- |
| A vector as an arrow with a magnitude and a direction | [What is a Vector?](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#What-is-a-Vector%3F) |
| Components and the notation $\langle x,~y \rangle$ | [Vector Notation](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Vector-Notation) |
| Magnitude $\lVert \vec{v} \rVert = \sqrt{x^2 + y^2}$ | [Length (Magnitude) of a Vector](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Length-%28Magnitude%29-of-a-Vector) |
| Unit vector $\hat{v}$ | [Normalization and Unit Vectors](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Normalization-and-Unit-Vectors) |
| Julia's `norm`, and a unit vector as `v / norm(v)` | [Normalizing a Vector](https://fourm.info/linear_algebra/dev/Geometry/03%20Vectors%20and%20Geometry/#Normalizing-a-Vector) (Geometry) |
| Scalar multiplication $c\vec{v}$ | [Scalar Multiplication](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Scalar-Multiplication) |
| Vector addition $\vec{v} + \vec{w}$ | [Vector Addition](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Vector-Addition) |
| Vector subtraction $\vec{v} - \vec{w}$ | [Vector Subtraction](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Vector-Subtraction) |
| Standard unit vectors $e_x$, $e_y$ | [Standard Basis](https://fourm.info/linear_algebra/dev/Geometry/01%20Points%20and%20Coordinates/#Standard-Basis) (Geometry) |
| A vector written with any two non-parallel vectors | [Linear Combination](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Linear-Combination) |
| Polar form: the angle $\theta$ | [Polar Form of a Vector](https://fourm.info/linear_algebra/dev/Geometry/03%20Vectors%20and%20Geometry/#Polar-Form-of-a-Vector) (Geometry) |
| Finding the angle $\theta$ of $\langle x,~y \rangle$ with two-argument `atan` | [Recovering the Angle](https://fourm.info/linear_algebra/dev/Geometry/03%20Vectors%20and%20Geometry/#Recovering-the-Angle) (Geometry) |
| Higher dimensional vectors | [Components and Dimensions](https://fourm.info/linear_algebra/dev/Basics/01%20Vectors/#Components-and-Dimensions) |

## Julia Containers

### Values, names and symbols

Below are some details about values, names and symbols created by Claude and edited by me. These three words come up throughout this section, so we will occasionally need to refer to the sections below to clarify related points. "The manual" referred to throughout the text below is the Julia manual.

#### Values

A _value_ is what exists while a program runs: what a computation produces, what a name refers to and what a collection holds. The manual uses the word without giving it a formal definition, but it says two things about all values. In the chapter "Types":

> all values in Julia are true objects having a type
>
> Only values, not variables, have types – variables are simply names bound to values

Numbers and strings are values, but so are many other things that at first glance we wouldn't think of as data:

| Expression | Its value | `typeof` of the value |
| :--- | :--- | :--- |
| `5` | the number 5 | `Int64` |
| `2 + 3` | the number 5 | `Int64` |
| `2.5` | the number 2.5 | `Float64` |
| `"a"` | a string | `String` |
| `[1, 2]` | a vector | `Vector{Int64}` |
| `:x` | a symbol | `Symbol` |
| `sin` | the sine function | `typeof(sin)` |
| `Int64` | the type itself | `DataType` |

The first two rows show that a value is not the same as how it is written. This is the distinction between numbers and numerals from the [Numeric Literals](01 From Calculator to Computer.md#Numeric-Literals:-numerals-written-in-Julia-syntax) section: `5` is a numeric literal, `2 + 3` is an expression, and both produce the same number. A value does not need a name either: `2 + 3` and `[10, 20, 30][2]` both produce a value without naming it.

Because the type belongs to the value, the same variable can refer to values of different types:

```julia
x = 5
typeof(x)      # Int64
x = "hello"
typeof(x)      # String
```

#### Names

A _name_ is a word written in the source code. As we saw in the [Numeric Literals](01 From Calculator to Computer.md#Numeric-Literals:-numerals-written-in-Julia-syntax) section, names are bound to values in various ways. The manual's chapter "Variables" says:

> A variable, in Julia, is a name associated (or bound) to a value.

When you run a program that has a stand-alone name, or type the name in the REPL, you get the value bound to the name. If nothing is bound to it, there is nothing to give: typing a (random) name `neverbound` in the REPL throws an `UndefVarError`.

The manual's chapter "Variables" separates assignment "(giving a new "name" to a value)" from mutation "(changing a value)". The "Can be changed" column in the table of collections below is about mutation:

```julia
a = [1, 2]
b = a          # two names, one value:
a === b        # true
push!(b, 3)    # mutation: changes the value
a              # [1, 2, 3]
a = [9]        # assignment: a now refers to a new value
b              # still [1, 2, 3]
```

#### Symbols

A _symbol_ is a value of type `Symbol` that represents a name. The docstring for `Symbol` defines it as follows:

> The type of object used to represent identifiers in parsed julia code (ASTs). Also often used as a name or label to identify an entity (e.g. as a dictionary key).

The manual's chapter "Metaprogramming" calls it:

> an interned string used as one building-block of expressions

(See [Symbols are Interned strings](03 Number Systems.md#Symbols-are-Interned-strings) for what interned means.) You write one with `:`, or build one with `Symbol(...)`, which joins its arguments together:

```julia
:x                    # :x
typeof(:x)            # Symbol
Symbol("x") === :x    # true
Symbol("x", 1, :y)    # :x1y
```

Symbols are how Julia represents names in parsed code. `Meta.parse("x + 1").args` gives `[:+, :x, 1]`: the names `+` and `x` became symbols, and the numeric literal became the value `1`. When that code runs, the same chapter says:

> when an expression is evaluated, a symbol is replaced with the value bound to that symbol in the appropriate scope.

We can do that step ourselves with `eval`. Here `y` is a name, bound to a value which is the symbol `:x`:

```julia
x = 5
y = :x
y          # :x
eval(y)    # 5
```

A symbol does not need a variable behind it. In `linestyle = :dash` it is only a label. `s = :neverbound` works, and only `eval(s)` throws an `UndefVarError`. Its text does not need to be a valid name either: `Symbol("my key")` is a symbol (as can be seen by checking its `typeof`), though `my key` cannot be written as a plain name.

```@raw html
<!-- markdownlint-disable MD046 -->
```

!!! note "An aside"
    You rarely need a symbol like this in your own code, because you choose your own keys and can leave out the space. It mostly comes up when the names come from someone else's data, as when a CSV file is read into a `DataFrame`. A column header such as `my key` becomes a column name that cannot be written as a plain name:

    ```julia
    using CSV, DataFrames
    df = CSV.read(IOBuffer("my key,other\n1,2\n3,4\n"), DataFrame)
    propertynames(df)          # [Symbol("my key"), :other]
    df[!, Symbol("my key")]    # [1, 3]
    df[!, "my key"]            # [1, 3]: a string works too
    ```

    To avoid such names altogether, `CSV.read` with `normalizenames = true` turns the header into `my_key`.

```@raw html
<!-- markdownlint-enable MD046 -->
```

A symbol also does not pick out one particular variable, because scope decides that. `eval` works in global scope, so it does not see a local variable with the same name:

```julia
x = 5
let x = 99
    x          # 99
    eval(:x)   # 5
end
```

The docstring for `Symbol` also calls symbols immutable, although `ismutable(:x)` returns `true`, as does `ismutable("x")`. The docstring for `ismutable` says this is "For technical reasons".

#### Values, names and symbols side by side

In `x = 5`, the `x` is a name, the `5` gives the value, and `:x` is a separate value that represents the name.

| Question | Value | Name | Symbol |
| :--- | :--- | :--- | :--- |
| What is it? | What exists while the program runs | A word in the source code | A value that represents a name |
| Does it have a type? | Yes | No, only the value bound to it | Yes, `Symbol` |
| What does writing it give? | `5` gives 5 | `x` gives the value bound to it | `:x` gives `:x` |
| Can a collection hold it? | Yes | No: `[x]` holds the value of `x` | Yes: `[:x]` holds the symbol |
| Does it need a binding? | No | Yes, or `UndefVarError` | No |

#### What this means for collections

A collection holds values, never names. `[x, :x]` looks up `x` once and stores what it finds, so binding `x` to something else later does not affect the vector:

```julia
x = 5
v = [x, :x]    # Any[5, :x]
x = 6
v              # still Any[5, :x]
```

In a named tuple, the keys look like names, but no variable is created. They are stored as symbols, and they can only be symbols:

```julia
nt = (price = 10, qty = 2)
keys(nt)       # (:price, :qty)
nt[:price]     # 10
nt.price       # 10
price          # UndefVarError
("a" = 1,)     # syntax: invalid named tuple field name ""a""
```

A `Dict` has no such restriction, so symbols are only one choice of key, and one `Dict` can mix key types:

```julia
d = Dict(:price => 10, "qty" => 2)
d[:price]      # 10
d["qty"]       # 2
```

Destructuring by name, covered below, goes from the symbol back to a name: `(; price) = nt` looks up the key `:price` and binds the variable `price` to its value.

### Collections vs Containers in Julia

Below are some details about Collections and Containers created by Claude and edited by me.

#### What Collections and Containers are

A _container_ is a computer language value whose job it is to hold other values, its _elements_, and to hand them back. Verzani uses the term throughout this chapter but defines it only in passing. Where a programming language uses both words (Python, for one), _collections_ narrows the term to refer to containers with a set of operations, including count, iterate, and often add and remove.

The Julia manual just talks about collections, and that is the term I personally have seen in all the books and articles I've read about Julia. In what follows we will stick to that, and refer to "collections", although Verzani uses both terms interchangeably. Rather than define the word, the manual's chapter "Collections and Data Structures" groups them by what they let you do (the operations): every collection can be iterated (`for x in c`) and has a `length`; some can be indexed by position (`c[i]`); dictionaries look a value up by a key; sets only answer whether a value is a member; and some can grow and shrink.

#### Characteristics of Collections

Julia collections differ in four ways: how you get an element out, whether the collection can be changed after it is made, whether its elements share one type, and whether it keeps its elements in order. The table compares the collections in this chapter on those four points. `SVector` and `MVector` come from the `StaticArrays.jl` package; the rest are in Base Julia.

| Collection | Example | Get an element by | Can be changed | Elements share one type | Keeps order |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Vector` | `[1, 2, 3]` | position: `v[2]` | values, and it can grow or shrink | yes | yes |
| `Matrix` | `[1 2; 3 4]` | row and column: `m[2, 1]` | values only | yes | yes |
| `Tuple` | `(1, "a")` | position: `t[2]` | no | no, each position has its own type | yes |
| `NamedTuple` | `(a = 1, b = 2)` | name: `nt.a`, or position: `nt[2]` | no | no, each name has its own type | yes |
| `Dict` | `Dict("a" => 1)` | key: `d["a"]` | values, and it can grow or shrink | keys share one type, values share one type | no |
| `Set` | `Set([1, 2])` | no access; test membership: `2 in s` | it can grow or shrink | yes | no |
| range (see notes) | `1:3` | position: `r[2]` | no | yes | yes |
| `String` | `"abc"` | byte position: `s[1]` | no | yes, every element is a `Char` | yes |
| `Pair` | `"a" => 1` | `p.first`, `p.second`, or position: `p[1]` | no | no, first and second have their own types | yes |
| `SVector` | `SVector(1, 2, 3)` | position: `s[2]` | no | yes | yes |
| `MVector` | `MVector(1, 2, 3)` | position: `m[2]` | values only | yes | yes |

Notes, all run on Julia 1.13.3 (StaticArrays 1.9.24):

- "Share one type" means one _element type_, `eltype`. It may be an abstract type: `[1, "a"]` is a `Vector{Any}`, while `[1, 2.0]` promotes both entries and is a `Vector{Float64}`.
- Grow or shrink: `push!`, `pop!`, `deleteat!` on a vector; `d["b"] = 2` and `delete!(d, "a")` on a dictionary; `push!` and `delete!` on a set.
- "Can be changed" describes what these operations do, not what `ismutable` reports, which can mislead both ways. `ismutable(Set([1, 2]))` is `false`, yet `push!` adds to it (see section below about Sets). `ismutable("abc")` is `true`, yet a string has no operation that changes it (no `setindex!`, no `push!`).
- "range" is not a type name: ranges come in several types, all subtypes of `AbstractRange`. `1:3` is a `UnitRange`, `1:2:9` a `StepRange`, and `0:0.5:2` a `StepRangeLen`. Lowercase `range` is a function that builds one.
- A string is indexed by _byte_ position, not by character count. In `"abc"` the two agree, but `α` takes two bytes, so in `"αβγ"` the characters sit at indices 1, 3 and 5, and `"αβγ"[2]` throws a `StringIndexError`.
- A dictionary or a set keeps neither the order you inserted nor sorted order: `Dict("c" => 1, "a" => 2, "b" => 3)` iterates `"a"`, `"c"`, `"b"`.
- Every collection here can be iterated, but `for x in c` does not always hand you what you might expect. A dictionary gives you `Pair`s: `for x in Dict("a" => 1)` sets `x` to `"a" => 1`, so write `for (k, v) in d` to get the key and the value separately. A string gives you `Char`s, one per character however many bytes it takes: `"αβγ"` occupies 6 bytes but `for x in "αβγ"` runs 3 times.
- A static vector's length is part of its type, so even an `MVector` cannot grow (see section below about static vectors).

### `Set`s

Below are some details about `Set`s created by Claude and edited by me.

#### Making a `Set`

The constructor `Set` takes one argument, an existing collection (or anything else that can be iterated over), and builds a new set from its elements. You can't construct a set by passing the elements as separate arguments: `Set(1, 2)` is a `MethodError`. When constructing the set from the collection, duplicates collapse to one element and the order of the source collection is dropped, since a set keeps no order. The source collection is not changed; the set is a new object.

Taking a collection rather than separate elements is what lets `Set` turn any collection we already have—a vector in a variable, a range, a string—into a set. It also means a collection given to `Set` is always read as the _source_ of the elements, never as an element itself: a set whose one element is a vector needs the vector wrapped in another collection.

The other way to make a set is to start with an empty one and add elements with `push!`. Give the element type in braces, `Set{Int}()`; a bare `Set()` has element type `Any`.

| Call | Result | What happens |
| :--- | :--- | :--- |
| `Set([1, 2])` | `Set([2, 1])` | the elements of a vector |
| `Set((1, 2))` | `Set([2, 1])` | the elements of a tuple |
| `Set(1:3)` | `Set([3, 2, 1])` | the elements of a range |
| `Set("abba")` | `Set(['b', 'a'])` | the characters of a string, duplicates collapsed |
| `Set(v)` with `v = [1, 2, 2, 1]` | `Set([2, 1])` | duplicates collapsed; `v` is still `[1, 2, 2, 1]` |
| `Set([[1, 2]])` | `Set([[1, 2]])` | one element, the vector `[1, 2]` |
| `Set(1, 2)` | `MethodError` | no method takes the elements as separate arguments |
| `Set(1)` | `Set([1])` | works only because a number iterates as itself, a one-element collection |
| `Set{Int}()`, then `push!` 1, 2, 1 | `Set([2, 1])` | start empty, add elements; the second 1 is already there |
| `Set()` | `Set{Any}()` | empty, element type `Any` |

`Dict` differs here: it takes its pairs either way, as separate arguments, `Dict("a" => 1, "b" => 2)`, or as one collection, `Dict(["a" => 1, "b" => 2])`.

All run on Julia 1.13.3.

#### How a `Set` is stored

The two rules above, duplicates collapse and order is dropped, come from how Base Julia stores a set. This is an implementation detail: using a set never requires understanding this, which is why I placed this section after the previous one. However, how it is stored explains its behavior, so if you are interested, the details follow.

Base (`base/set.jl`) defines `Set` as a `struct` with one field, a `Dict`:

```julia
struct Set{T} <: AbstractSet{T}
    dict::Dict{T,Nothing}
end
```

The elements of the set are the _keys_ of that dictionary. Every value is `nothing`, so only the keys carry information:

```julia
s = Set([1, 2, 2, 1])
s.dict                 # Dict(2 => nothing, 1 => nothing)
```

This is where the two rules come from. Duplicates collapse because a dictionary cannot hold the same key twice: adding `2` again only sets `dict[2] = nothing` once more. Order is dropped because a `Dict` is a hash table: it places each key by its hash, not by when it was added.

Every set operation is a dictionary operation underneath, and `Set(itr)` itself starts from an empty dictionary and adds each element of `itr` as a key:

| Set operation | What Base does |
| :--- | :--- |
| `push!(s, x)` | `s.dict[x] = nothing` |
| `delete!(s, x)` | `delete!(s.dict, x)` |
| `x in s` | `haskey(s.dict, x)` |
| `length(s)` | `length(s.dict)` |
| `for x in s` | iterates over the keys of `s.dict` |

Because `Set` is a `struct`, not a `mutable struct`, its one field can never be made to point to a different `Dict`. Using `push!` does not contradict the immutability of the struct. What it does is add a key to the `Dict` the field already points to.

```julia
d = s.dict
push!(s, 3)
s.dict === d           # true: the same Dict, now with the key 3
```

So `ismutable(s)` is `false`, because it asks only whether the `Set` object itself can be changed, that is, whether its own field can be reassigned. The contents of the set can still change. The docstring of `Set` in Base calls sets "mutable containers" in this second sense, the sense of the column "Can be changed" in the collections table above.

`s.dict` is an internal field, used here only to show how a set is stored. Code that works with sets should use `push!`, `delete!`, `in` and the other set functions, never the field.

All run on Julia 1.13.3.

### `Pair`s

Below are some details about `Pair`s created by Claude and edited by me.

#### What a `Pair` is

A `Pair` is not a small `Dict`; it is what a `Dict` is made of. A dictionary is a collection of pairs together with fast lookup by key: its element type is `Pair`, and iterating over it hands back pairs. A single `Pair` has no lookup at all. It holds two values, `first` and `second`, which can be read by name or by position, and it cannot be changed once it is made.

So a `Pair` is closer to a tuple of two elements whose positions have names: `Tuple("a" => 1)` gives `("a", 1)`. Like a tuple, its two halves keep their own types (`Pair{String, Int64}`). The arrow `=>` suggests "key to value", and that is how `Dict` uses it, but a pair by itself means no more than "these two values, in this order".

The table was created assuming `p = "a" => 1` and `d = Dict("a" => 1)`:

| Call | Result | What it shows |
| :--- | :--- | :--- |
| `eltype(d)` | `Pair{String, Int64}` | the elements of a dictionary are pairs |
| `first(d) == p` | `true` | iterating over `d` gives back `"a" => 1` |
| `d["a"]` | `1` | a `Dict` looks a value up by its key |
| `p["a"]` | `MethodError` | a `Pair` has no keys, just two values |
| `p.first`, `p.second` | `"a"`, `1` | the two values, by name |
| `p[1]`, `p[2]` | `"a"`, `1` | or by position |
| `p.second = 2` | error: immutable struct of type `Pair` cannot be changed | a `Pair` is fixed once made |
| `Tuple(p)` | `("a", 1)` | the same two values as a tuple |
| `Dict(p)` | `Dict("a" => 1)` | a dictionary with one entry is built from a pair |

`=>` also appears outside dictionaries, wherever a function needs two values that belong together: `replace("abc", "a" => "x")` gives `"xbc"`, "replace this with that", with no dictionary involved.

All run on Julia 1.13.3.

#### When to use a `Pair` and when a `Tuple`

Use a `Pair` when two values stand in a _relation_ with a direction: e.g. this key to that value, this index to that entry, replace this with that. The arrow indicates which side is which, and functions that expect such a relation need a `Pair` (e.g. `replace` in the table below).

Use a `Tuple` for a fixed group (of any length) of values, with no direction between these values: e.g. the several results of one function, coordinates, the arguments to pass to a function. Functions that return more than one value return a tuple, which is then taken apart by assignment.

The two overlap more than the arrow suggests: a pair can be taken apart like a tuple (`k, v = "a" => 1`), and `Dict` also accepts tuples of two values (`Dict([("a", 1), ("b", 2)])` gives `Dict("a" => 1, "b" => 2)`). Choosing `=>` is then a signal to the _reader_ that the two values form a relation.

When the positions deserve names, use a `NamedTuple` rather than a `Pair`: `first` and `second` only say which came first.

| Situation | Use | Example |
| :--- | :--- | :--- |
| key and value | `Pair` | `Dict("a" => 1)`, and `Dict(x => x^2 for x in 1:3)` |
| replace this with that | `Pair` | `replace([1, 2, 1], 1 => 0)` gives `[0, 2, 0]` |
| replace this with that, given as a tuple | `Pair` only | `replace("abc", ("a", "x"))` is a `MethodError` |
| index and entry | `Pair` | `collect(pairs([10, 20]))` gives `[1 => 10, 2 => 20]` |
| several results of one function | `Tuple` | `divrem(7, 2)` gives `(3, 1)`; `q, r = divrem(7, 2)` |
| largest value and where it is | `Tuple` | `findmax([3, 9, 4])` gives `(9, 2)` |
| more than two values | `Tuple` | `(1, "a", 2.0)` |
| arguments to pass on | `Tuple` | `t = (1, 2)`, then `f(t...)` calls `f(1, 2)` |
| values with meaningful names | `NamedTuple` | `(x = 1, y = 2)`, then `.y` gives `2` |

All run on Julia 1.13.3.

### Static vectors: `SVector` and `MVector`

Below are some details about Static vectors created by Claude and edited by me.

#### What `SVector` and `MVector` are

`SVector` and `MVector` come from the `StaticArrays.jl` package. The _static_ in its name does not mean "unchangeable". It means the **length is fixed and is part of the type**: `SVector(1, 2, 3)` is an `SVector{3, Int64}`, and `MVector(1, 2, 3)` an `MVector{3, Int64}`. The package README says so directly:

> "statically sized" means that the size can be determined from the _type_, and "static" does **not** necessarily imply `immutable`.

So both kinds are static. They differ only in whether their values can change: an `SVector` is an immutable `struct`, an `MVector` a `mutable struct`. An `MVector` is a static vector whose values can change, but whose length still cannot.

| Property | `SVector` | `MVector` |
| :--- | :--- | :--- |
| Length fixed, part of the type | yes | yes |
| Change a value: `v[2] = 10` | no: `setindex!` is not defined | yes: gives `[1, 10, 3]` |
| Grow: `push!(v, 4)` | no | no: `MethodError` (no `resize!`) |
| `ismutable(v)` | `false` | `true` |
| `isbits(v)` | `true` | `false` |

To get a changed `SVector`, build a new one: `Base.setindex(s, 10, 2)` (no `!`) returns a new `SVector` `[1, 10, 3]` and leaves `s` as it was. `SVector(m)` and `MVector(s)` convert between the two kinds.

All run on Julia 1.13.3 (StaticArrays 1.9.24). Quotes from the StaticArrays README and documentation ([index](https://juliaarrays.github.io/StaticArrays.jl/stable/), [API: mutable arrays](https://juliaarrays.github.io/StaticArrays.jl/stable/api/)).

#### Implementation details of `SVector` and `MVector` and when to use each

Why have a fixed length at all in these static arrays? Because the length is in the type, the package's functions know this length when the code is compiled. The StaticArrays documentation explains why that is useful for small arrays (up to about 100 elements):

> [Fixed length allows c]ompletely unrolling to loop-free code. e.g. `v3 = v1 + v2` is just implemented as 3 scalar additions, with no loop overhead at all, if these are all `SVector{3, Float64}`.

The `isbits` row in the table is the implementation detail behind the difference between the two types: an `SVector` of numbers is a plain value, like a number, so it needs no separately allocated memory of its own, "[a]voiding heap (or even stack) allocations of temporary arrays."

By contrast `MVector`s according to the documentation "live on the heap, not the stack." They can still be faster than a `Vector` for small sizes, because their fixed length "allows for additional loop unrolling and inlining".

To sum up: an `SVector` suits small fixed-size values that are computed rather than edited, such as points in 2D or 3D; an `MVector` suits a small fixed-size vector that is filled in or updated entry by entry.

Quotes from the StaticArrays documentation ([index](https://juliaarrays.github.io/StaticArrays.jl/stable/), [API: mutable arrays](https://juliaarrays.github.io/StaticArrays.jl/stable/api/)).

### Destructuring in Julia

Below are some details about destructuring created by Claude and edited by me.

#### What destructuring is

Destructuring pulls several values out of one value and assigns them to several variables in a single statement. Julia has two kinds, and they work differently: one goes by position, the other by name.

| Aspect | By position | By name |
| :--- | :--- | :--- |
| Syntax | `a, b = v` | `(; x0, x1) = v` |
| How it works | iterates `v` | reads `v.x0` and `v.x1` |
| Works on | anything iterable | anything with fields of those names |
| Order of the variables | matters | does not matter |

A named tuple is one case where both work, since it is iterable and also has named fields.

Everything below was run on Julia 1.13.3. The manual covers this in the Functions chapter, under "Destructuring Assignment and Multiple Return Values".

#### Destructuring by position

Each variable receives the next value that iteration hands out:

```julia
a, b = [10, 20]                     # a = 10, b = 20
a, b = (10, "s")                    # a = 10, b = "s"
a, b = "xy"                         # a = 'x', b = 'y', two Chars
a, b = Dict(:p => 1, :q => 2)       # a and b are Pairs, not values
```

The number of variables need not match the number of values, as long as there are enough values:

```julia
a, b = 1:3                          # a = 1, b = 2, the 3 is dropped
a, b, c = [10, 20]                  # BoundsError: there is no third value
```

Some variations:

```julia
a, b... = [10, 20, 30]              # a = 10, b = [20, 30], the rest
a, _, c = (1, 2, 3)                 # a = 1, c = 3, _ skips a value
a, (b, c) = (1, (2, 3))             # a = 1, b = 2, c = 3, nested
a, b = b, a                         # swaps a and b
```

This is how you can extract the different parts of the value a function returns. `extrema([3, 1, 2])` returns one tuple, `(1, 3)`, and `lo, hi = extrema([3, 1, 2])` takes it apart (so `lo = 1` and `hi = 3`).

#### Destructuring by name

Each variable receives the field with the same name. The manual: "Instead of destructuring based on iteration, the right side of assignments can also be destructured using property names." A _property_ is what `v.name` reads; for most values it is simply a field.

```julia
nt = (x0 = 1, x1 = 4, y0 = 2, y1 = 6)
(; x0, x1) = nt                     # x0 = 1, x1 = 4, the other fields are ignored
(; x1, x0) = nt                     # the same values: order does not matter
(; z) = nt                          # FieldError: no field z
```

The variable must have the same name as the field; `(; x0 => a) = nt` is a syntax error. This destructuring is useful because it allows you to use these individual fields succinctly in subsequent expressions. You can write `x0` instead of `nt.x0`, which is useful when `x0` is referenced multiple times.

It works on any value with named fields, not only on named tuples, and the value need not be iterable:

```julia
struct Point2; x; y; end
(; y) = Point2(7, 8)                # y = 8, and a Point2 is not iterable
(; second) = "a" => 1               # second = 1
z = 3 + 4im
(; re) = z                          # re = 3
```

It fails on a vector, a dictionary and a plain tuple, because none of them has a field called `x0`. A dictionary's key is not a field:

```julia
(; x0) = [1, 2]                     # FieldError
(; x0) = Dict(:x0 => 1)             # FieldError
(; x0) = (1, 2)                     # FieldError
```

Destructuring assigns ordinary variables, so a field's name can hide something you still need. `im` is Julia's imaginary unit, and it is also a field name of a complex number:

```julia
2im                     # 0 + 2im
(; re, im) = 1 + 2im    # re = 1, im = 2
im                      # 2, no longer the imaginary unit
2im                     # 4
im = Base.im            # restores it
2im                     # 0 + 2im
```

Inside a `let` or a function, the same line throws an error, because the `im` on the right is already the new local variable:

```julia
let
    (; re, im) = 1 + 2im    # UndefVarError: `im` not defined in local scope
end
```

To stay safe, destructure only the fields whose names are not already in use. Here that means leaving out `im`, which would replace the imaginary unit. Get that part of `z` with `imag(z)` and then explicitly multiply by `im`:

```julia
z = 1 + 2im
(; re) = z              # re = 1
imag(z)                 # 2
re + imag(z)            # 3, not z
re + imag(z)*im         # 1 + 2im, which is z
```

#### Warning: by position on a named tuple

Without the `;` the names are ignored and no error warns you:

```julia
nt = (x0 = 1, x1 = 4, y0 = 2, y1 = 6)
x1, x0 = nt                         # x1 = 1, x0 = 4: swapped
(; x1, x0) = nt                     # x1 = 4, x0 = 1: correct
```

So when a value has names, destructure by name.

#### The reverse: building a named tuple

On the right of an assignment, the same syntax builds a named tuple from variables, using their names as the field names:

```julia
x0 = 5
x1 = 6
p = (; x0, x1)                      # (x0 = 5, x1 = 6)
```

#### Destructuring in function arguments and loops

Both kinds of destructuring also work in a function's argument list. Sometimes you might get a result back as a tuple and you can then destructure by position to use it as is, without taking it apart first yourself. See the `add` example below. The extra parentheses matter: they make it one argument that is taken apart.

In general the one-argument form below is for values that already come packaged together, such as the entries of a collection of tuples, or a tuple a function returns:

```julia
add((x, y)) = x + y
add2(x, y) = x + y

points = [(1, 2), (3, 4)]
map(add, points)                    # [3, 7]
map(add2, points)                   # MethodError: map hands add2 one tuple, not two values

add(extrema([3, 1, 2]))             # 4
add2(extrema([3, 1, 2]))            # MethodError, for the same reason
add2(extrema([3, 1, 2])...)         # 4, the ... splits the tuple into two arguments
```

Destructuring by name works the same way:

```julia
slope((; x0, x1, y0, y1)) = (y1 - y0) / (x1 - x0)
slope(nt)                           # 1.3333333333333333
```

This form suits the `f(x, p)` style, where a named tuple carries a function's parameters.

Both types of destructuring also work in a `for` loop:

```julia
for (k, v) in Dict("a" => 1)        # by position, from each Pair
    println(k, " ", v)              # a 1
end

for (i, x) in enumerate(["p", "q"]) # by position, from each (index, value) tuple
    println(i, " ", x)              # 1 p, then 2 q
end

for (; x0, x1) in [nt]              # by name
    println(x0, " ", x1)            # 1 4
end
```

### Associative arrays

Below are some details about associative arrays created by Claude and edited by me.

#### What the term means

Verzani writes that "an associative array associates to each key a value". This term is general programming vocabulary. For example, Perl's documentation (`perldata`) says:

> Perl has three built-in data types: scalars, arrays of scalars, and associative arrays of scalars, known as "hashes".

While the Julia documentation does not use the phrase "associative array", it uses close variants. The manual's chapter "Style Guide" says: "For associative collections, this is the key of the key-value pair(s)". Its chapter "Modules" stretches the term further, to "Associative collections (such as `Dict` and `Set`)", although a `Set` has keys but no values. Julia's own type once had the name as well. The release notes for Julia 0.7 say:

> `Associative` has been deprecated in favor of `AbstractDict`

Verzani's two kinds of associative array are separate types. A dictionary is an `AbstractDict`, but a named tuple is not:

```julia
Dict("a" => 1) isa AbstractDict    # true
(a = 1, b = 2) isa AbstractDict    # false
```

#### The other `AbstractDict` types

Verzani also writes "There are other types of associative arrays, specialized cases of the `AbstractDict` type with performance benefits for specific use cases." With no packages loaded, `subtypes(AbstractDict)` lists seven types (`subtypes` comes from `InteractiveUtils`, which the REPL loads for you). Neither CWJSN's chapters nor the source of the CWJS package mention `IdDict`, `WeakKeyDict`, `ImmutableDict` or `PersistentDict`, so what follows is background rather than something you need in order to follow the book.

| Type | What is different | Exported from `Base` |
| :--- | :--- | :--- |
| `Dict` | The standard one | yes |
| `IdDict` | Compares keys with `===` | yes |
| `WeakKeyDict` | Keys "may be garbage collected even when referenced in a hash table" | yes |
| `Base.ImmutableDict` | An immutable linked list, "optimal for small dictionaries that are constructed over many individual insertions" | no |
| `Base.PersistentDict` | Each operation "returns a new dictionary separate from the previous one", which may share storage with it | no |
| `Base.Pairs` | What `pairs(...)` and collected keyword arguments give you | no |
| `Base.EnvDict` | The type of `ENV`, your environment variables | no, but `ENV` is |

The quotes are from each type's docstring. "Performance benefits" describes only part of this table. `ImmutableDict` and `PersistentDict` are about efficiency, but `IdDict` and `WeakKeyDict` change how the dictionary behaves, as the next section shows for `IdDict`.

#### `IdDict`: when are two keys the same key?

A `Dict` treats two keys as the same if they are equal, so an equal key finds the entry. An `IdDict` treats them as the same only if they are `===`, which for vectors means the same object. Here `a` and `b` are two separate vectors with the same content:

```julia
a = [1]
b = [1]
a == b                       # true
a === b                      # false
Dict(a => 1)[b]              # 1: an equal key finds the entry
haskey(IdDict(a => 1), b)    # false: only the same object does
IdDict(a => 1)[a]            # 1
```

The docstring's own example shows the same difference. `true`, `1` and `1.0` are all equal as keys, so a `Dict` keeps only the last entry, while an `IdDict` keeps all three:

```julia
Dict(true => "yes", 1 => "no", 1.0 => "maybe")             # Dict{Real, String}(1.0 => "maybe")
length(IdDict(true => "yes", 1 => "no", 1.0 => "maybe"))   # 3
```

#### `Base.Pairs`: when do you get a type you didn't explicitly ask for?

When a function collects its keyword arguments with `kw...`, what it receives is an associative array whose keys are symbols:

```julia
f(; kw...) = kw
f(a = 1) isa AbstractDict    # true
keys(f(a = 1, b = 2))        # (:a, :b)
f(a = 1, b = 2)[:b]          # 2
collect(f(a = 1))            # [:a => 1]
```

`pairs` builds the same type from other collections. On a vector, the keys are the positions:

```julia
pairs([10, 20])[2]           # 20
collect(pairs([10, 20]))     # [1 => 10, 2 => 20]
```

#### `ImmutableDict` and `PersistentDict`: how do you add without changing?

Neither of these types allows for changes in place. Adding or removing gives you a new dictionary and leaves the old one as it was. Both need the `Base.` prefix, because they are not exported.

An `ImmutableDict` cannot remove a value, only hide it by adding the same key again:

```julia
x = Base.ImmutableDict(:a => 1)
y = Base.ImmutableDict(x, :b => 2)
length(x), length(y)         # (1, 2): x is unchanged
z = Base.ImmutableDict(y, :a => 9)
z[:a], y[:a]                 # (9, 1): the new value hides the old one in z only
length(z)                    # 3: the old entry is still there
```

A `PersistentDict` can remove one, but only by returning a new dictionary:

```julia
p = Base.PersistentDict(:a => 1)
q = Base.delete(p, :a)
length(p), length(q)         # (1, 0)
```

### Queues and stacks

Below are some details about queues and stacks created by Claude and edited by me. The results are from Julia 1.13.3 and DataStructures 0.19.6.

#### What makes a queue or a stack

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

#### Where the other types come from

Verzani writes "Vectors can be used as a queue, though for just that task, there are more performant structures available." That wording is a bit misleading, because it doesn't name those "structures" (he means types) and they aren't in Julia's `Base`. `Vector` is the only type in the table below that `Base` provides. The others, and the priority types further down, need the package [DataStructures](https://github.com/JuliaCollections/DataStructures.jl).

Neither CWJSN's chapters nor the source of the CWJS package mention DataStructures, and it isn't in this repo's `notebooks/Project.toml`, so add it to your own environment to run the examples that use it:

```julia
using Pkg
Pkg.add("DataStructures")
using DataStructures
```

#### Which operations each type allows

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

#### Types with a fixed capacity

`CircularBuffer` and `CircularDeque` both take a maximum size when you create them. They differ in what happens when they are full. A `CircularBuffer` overwrites its oldest item, which suits keeping the last $n$ items. A `CircularDeque` throws an error:

```julia
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

#### Removing by priority

`PriorityQueue` and the heaps, such as `BinaryMinHeap`, are a third kind. They remove by priority, not by position. In these two the smallest number comes off first:

```julia
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

#### Are they more performant?

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

#### Which one to choose

| What you need | Use |
| :--- | :--- |
| A simple queue or stack, or you aren't sure | `Vector` |
| Code that says what it means and rejects the wrong operation | `Queue` or `Stack` |
| Only the last $n$ items | `CircularBuffer` |
| A fixed maximum size, with an error when it is exceeded | `CircularDeque` |
| Storage that grows in linked blocks | `Deque` |
| The next item chosen by priority | `PriorityQueue` or a heap |

### Generators and sets

Below are some details about generators and sets created by Claude and edited by me. All run on Julia 1.13.3.

#### Set notation and comprehensions

Verzani describes the first five cubes in set notation:

$$\{x^3: x \text{ in } 1, 2,\dots, 5\}$$

He then writes "Comprehension notation is similar" and gives `[x^3 for x in xs]`.

A comprehension is the expression `[x^3 for x in xs]`: it goes through `xs`, evaluates `x^3` for each element, and stores the results in a new array. Julia's manual says "Comprehensions provide a general and powerful way to construct arrays." Written without the square brackets, the same form is a generator (see "What a generator is" below), and a comprehension is that generator passed to `collect`, so `[x^3 for x in xs]` and `collect(x^3 for x in xs)` give the same vector.

Similar is the right word, because the result is a vector and not a set. A mathematical set has no order and no repeats, while a vector has both. Cubes hide most of this, since no two of them are equal, but squares show it. The set of these squares is $\{1, 4\}$, while the comprehension gives:

```julia
xs = [-2, -1, 1, 2]
[x^2 for x in xs]            # [4, 1, 1, 4]: keeps the order and the repeats
```

Set notation often carries a condition as well, such as $\{x^3: x \text{ in } 1, 2,\dots, 5,\ x \text{ even}\}$. A comprehension can have one too, written with `if`:

```julia
[x^3 for x in 1:5 if iseven(x)]    # [8, 64]
```

#### What a generator is

Without the square brackets, `x^3 for x in xs` is a generator. **A generator is not a set, and it is not a vector either.** It is a recipe for producing values one at a time, and something else has to consume it. In `Set(x^3 for x in xs)` the generator is the input, and it is `Set` that makes the set. Assigned to a name by itself, it stays a generator. With `xs = [1, 2, 3, 4, 5]`:

| You write | `ys` holds |
| :--- | :--- |
| `ys = (x^3 for x in xs)` | a `Base.Generator`, with no values computed yet |
| `ys = [x^3 for x in xs]` | a `Vector{Int64}` |
| `ys = Set(x^3 for x in xs)` | a `Set{Int64}` |

Showing `ys` in the first case prints something like `Base.Generator{Vector{Int64}, var"#20#21"}(var"#20#21"(), [1, 2, 3, 4, 5])`. The `var"#20#21"` is the automatically generated name of the anonymous function holding `x^3`, and its number varies.

You can pass a generator to anything that iterates:

```julia
xs = [1, 2, 3, 4, 5]
ys = (x^3 for x in xs)
Set(ys)                      # Set([27, 1, 125, 64, 8])
collect(ys)                  # [1, 8, 27, 64, 125]
sum(ys)                      # 225
```

#### Comprehension or generator?

A generator keeps a reference to the vector it reads from and computes its values each time it is iterated. So changing the contents of that vector affects the next iteration, while pointing the name `xs` at a different vector does not. A comprehension runs once and stores its results, so neither change affects them:

```julia
xs = [1, 2, 3]
g = (x^3 for x in xs)
v = [x^3 for x in xs]

xs[1] = 10                   # changes the vector that g holds
collect(g)                   # [1000, 8, 27]
v                            # [1, 8, 27]

xs = [7, 8]                  # the name now points to a different vector
collect(g)                   # [1000, 8, 27]
v                            # [1, 8, 27]
```

Computing at different times also gives them different costs:

| Compared on | Comprehension | Generator |
| :--- | :--- | :--- |
| When it computes | once, on that line | on each iteration, only as far as needed |
| `sum` over $10^6$ values | allocates 8 MB | allocates 0 bytes |
| `any` that succeeds at the third of $10^6$ values | computes all $10^6$ | computes 3 |
| Going through 3 values twice | computes 3 values in total | computes 6 values in total |
| Taking the first value with `x[1]` | works | `MethodError` |

So use a comprehension when you need the values more than once or by position, and a generator when they go straight into one function such as `sum`, `any` or `Set`.

#### Getting a `Set`

Julia has no comprehension syntax for sets. You call `Set`, which takes anything that can be iterated over (see "Making a `Set`" above). There is no cast: `convert(Set, [1, 2])` is a `MethodError`.

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

Comparing sizes tells you whether two different inputs share an output, in other words whether the function is one-to-one on these inputs. Compare with the number of different inputs, `length(Set(xs))`, because `xs` itself may hold repeats:

```julia
length(Set(x^2 for x in xs)), length(Set(xs))    # (2, 4): not one-to-one
length(Set(x^3 for x in xs)), length(Set(xs))    # (4, 4): one-to-one

xs = [1, 1, 2]
length(Set(x^3 for x in xs)), length(xs)         # (2, 3): looks not one-to-one, but only because 1 is repeated
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

#### When the parentheses can be left out

A generator needs parentheses around it, but a function call's own parentheses can serve when the generator is the last argument:

| Form | Result |
| :--- | :--- |
| `ys = x^3 for x in xs` | `ParseError`: nothing encloses the generator |
| `ys = (x^3 for x in xs)` | works |
| `sum(x^3 for x in xs)` | works: it is the only argument |
| `f(1, x for x in 1:2)` | works: it is the last argument |
| `f(x for x in 1:2, 1)` | `ParseError`: another argument follows it |
| `f((x for x in 1:2), 1)` | works |
