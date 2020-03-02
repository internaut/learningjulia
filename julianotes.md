# Notes on Julia

... with special focus on differences to Python

Author: Markus Konrad <post@mkonrad.net>


## Julia Interactive Console

- `?` enters help
    - `?func` gives help for `func`
- `;` enters shell (can use shell commands like `cd`)
- `]` enters package manager
    - `activate` sets virtual environment
    - `status` shows installed packages
    - `add <package>` / `remove <package>` adds / removes packages


## General syntax

- new line ends statement, alternatively use `;`
- comments with `#`
- code blocks are introduced *without* `:` / indentation doesn't matter / `end` ends block

```julia
begin
    ...
end

if x == y    # no ":" here!
    ...
end
```

- conditions with `&&` and `||`
- short-circuit evaluation often used:

```julia
a == 0 && b == 0 && return 0
0 <= x < N || error("x must be in [0, N)")
```

- `elseif` instead `elif`
- ternary operator: `x = a ? b : c`
- assertions with macro `@assert <condition>`

### for loops

- for loop construct can iterate over any container
- equivalent:

    for i = <container> ... end
    for i in <container> ... end
    for i ∈ <container> ... end

- nested for loops can be combined into a single outer loop, forming the cartesian product of its iterables:

    for i = 1:2, j = 3:4
        println((i, j))
    end

### Exceptions

- standard `ErrorException` via `error("<message>")`
- otherwise `throw(<exception>)`
    - e.g. `throw(DomainError(x, "argument must be nonnegative"))`


## Packages, modules, imports & exports

- modules are namespaces `module Name ... end`
- imports:
  - `using Mod[: obj1, obj2]`: import [specific] or all names from `Mod`
  - `import Mod[: obj1, obj2]`: also allows to *extend* functions from `Mod` by adding new methods
- exports: `export obj1, obj2, ...`: make `obj1`, `obj2` available for import from "outside"
- standard modules (always imported): `Core`, `Base`, `Main` (module when Julia is loaded)
- modules can contain submodules, e.g. `Main.MyMod`
- module loading quite slow:

  "Large modules can take several seconds to load because executing all of the statements in a module often involves compiling a large amount of code. Julia creates precompiled caches of the module to reduce this time."

  https://docs.julialang.org/en/v1/manual/modules/#Module-initialization-and-precompilation-1


## Types in general

- `::` operator can be used to attach type annotations to expressions and variables in programs
    - e.g. `(1+2)::Int`
    - as assertion and/or performance improvement
- or: type declaration
    - e.g. `x::Int8 = 100`
- or: function return type
    - e.g. `function f(x)::Float64`
- *abstract types* `Number`, `Real`, `Integer`, etc. form hierarchy but cannot be instantiated
- *primitive types*: concrete types of N bits, e.g. `Float64`
- *type unions*: `T1orT2 = Union{T1, T2}`

### Booleans

- `true` and `false` *not* `True` and `False`

### NULL Value

- Python's `NoneType` is `Nothing` singleton type with value `nothing`
- e.g. allow `nothing` as function argument (and use it as default value): `f(foo::Union{Real,Nothing}=nothing)`

### Strings and characters

- single characters *only* with `'c'`
- strings *only* with `"foo"`
- multiline strings via `""" ... """`

### Composite types: structs

- introduce new type consisting of fields

    struct Foo
        bar
        baz::Int
        qux::Float64
    end

- by default not mutable; prepend `mutable` to change that
- parametric composite types: `struct Foo{T} field::T end` makes `Foo` parametric by type `T`
- when using parametric types in function, `where` keyword must be used (here with short function definition):

    hasinv(x::RClass{N}) where {N} = gcd(x.a, N) == 1

### Composite type constructors

- default constructors: simply call struct name with arguments in field def. order, e.g. `Foo("bar", 2, 3.14)`
- inner constructors:
    - defined inside `struct` with same name as struct
    - multiple dispatch possible (i.e. several inner constructors w/ different arg types)
    - must return type instance created with special function `new()`
- outer constructors: defined outside `struct` and create new method for default constructor, e.g. `Foo(x, y) = Foo("bar", x, y)`

### Composite type string representations

- create string representation for "pretty printing" by defining method of `Base.show` for new type, e.g.

    Base.show(io::IO, foo::Foo) = print(io, "a Foo object with bar = ", foo.bar)

### Tuples, Arrays and other sequence types

#### Tuples

- tuple with parentheses `(1, 2, 3)`
- order, types and length are fixed
- tuple unpacking like in Python:
    - function return: x, y = f()`
    - swap: `y, x = x, y`
    - unpack into function args: `f(tup...)` unpacks all values in `tup` as function arguments
- named tuples: `(a=1, b="hello")`

#### Arrays and vectors

- arrays are of type `Array{T, N}` where `T` is element type and `N` is number of dimensions
    - type can be `Any` so that array can contain mixed types
- short form of creation with square brackets: `[1, 2, 3]` creates integer array with one dimension (`Array{Int64,1}`)
- array comprehensions like list comprehensions in Python possible: `[x^2 for x in 1:5]`
- multidimensional array creation: `;` or new line creates new row, space *without comma* creates new element *in row*:

    julia> [1 2 3]
    1×3 Array{Int64,2}:
    1  2  3
    
    julia> [[1 2 3]; [4 5 6]]
    2×3 Array{Int64,2}:
    1  2  3
    4  5  6

- however, `,` creates nested arrays or *vectors* (compare types!):

    julia> [[1 2 3], [4 5 6]]
    2-element Array{Array{Int64,2},1}:
    [1 2 3]
    [4 5 6]

- `Vector{T}` is array with single dimension
- `eltype(arr)` gives element type
- create new empty array with undefined values: `Array{T}(undef, N1, N2, ...)` where `T` is element type and `Nx` are number of elements along each axis
- most operations that work on scalar values work on arrays of same dimensions in element-wise fashion (e.g. `arr1 + arr2` performs element-wise addition)

#### Indexing

- all sequences are one-indexed, not zero-indexed!
- single element indexing `seq[i]`
- multiple element indexing via:
    - array of integer indices `seq[[2, 1, 3]]`
    - array of boolean mask with same length `seq[[false, true, true]]`
- multidimensional indexing:
    - `mat[[1, 3], [2]]` selects column 2 in rows 1 and 3 of `mat`
    - to take all elements along axis use `:`

#### Iteration

- `for i in eachindex(seq)` iterates through indices for sequence `seq` (if multidimensional array, returns flat indices)
- `for i in axes(seq, dim)` iterates through indices along dimension `dim`

#### Ranges

- ranges: `a:b` creates range `a, a+1, ..., b`
- alternatively: `range()` function with `step` and `length` arguments
- ranges are *generators* like in Python
- `collect()` creates array from generators


## Multiple dispatch: types, functions and methods

- no object oriented programming!
- instead: *multiple dispatch*
- *methods* are specialized functions for specific argument type configurations
- e.g. three methods for function `f`:

    f(a::Any, b::Any)           # most general: accepts any types of a, b
    f(a::Real, b::Integer)      # more specific: accepts real a and integer b
    f(a::Integer, b::Integer)   # more specific: both a and b must be ints

- short function definitions with `=`: `f(x) = x^2`
- arithmetic / comparison operators like `+`, `==` are simply functions which can be specialized for new types


## Randomness

- `rand()`: uniform random float in [0, 1]
- `rand(a:b)`: uniform random integer in [a, b]
- `rand(T)`: uniform random value of type `T`, e.g. `rand(Int)`


## Automated testing

- with macros from built-in `Test` module
- define named *testsets* via `@testset`
- in each testset, define test assertions via `@test`
- define assertion about exception via `@test_throws`
- template:

    using Test: @test, @testset, @test_throws

    include("mycode.jl")
    using .MyModule

    @testset "MyTestset" begin
        @test myfunc(2) == 5
        @test_throws ErrorException myfunc(-1)
    end

- apparently no *property based testing* (like Python hypothesis package) available
- run tests by including test file(s)


## Documentation

- above function / type / module as multiline string block
- markdown support

  "Always show the signature of a function at the top of the documentation, with a four-space indent so that it is printed as Julia code."

  https://docs.julialang.org/en/v1/manual/documentation/
