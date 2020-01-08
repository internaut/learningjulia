module ResidueClasses

export RClass, +, -, *, /, inv, hasinv, ^, ==, !=, <=, <, >=, >, table

import Base: +, -, *, /, inv, ^, ==, !=, <=, <, >=, >
using Cairo

"""
Residue class ā in ring ℤ modulo Nℤ
"""
struct RClass{N}
    a::Unsigned   # must be in [0, N-1]

    function RClass{N}(a) where {N}
        error("`a` must be an Integer type")
    end

    function RClass{N}(a::Integer) where {N}
        if !(typeof(N) <: Integer) || N < 2
            error("N must be integer > 1")
        end

        new(mod(a, N))
    end
end

# string representation

Base.show(io::IO, r::RClass{N}) where {N} = print(io, r.a, " in ℤ/", N, "ℤ")

# unary arithmetic operators

+(x::RClass{N}) where {N} = RClass{N}(x.a)
-(x::RClass{N}) where {N} = RClass{N}(-Int(x.a))

"Returns `true` when residual class `x` has inverse, otherwise `false`."
hasinv(x::RClass{N}) where {N} = gcd(x.a, N) == 1

function inv(x::RClass{N})::RClass{N} where {N}
    @assert 0 <= x.a < N

    d, s, t = gcdx(Int(x.a), N)
    d == 1 || error("residual class ", x, " has no inverse")

    modinv = s - fld(s, N) * N   # normalize
    @assert 0 <= modinv < N

    RClass{N}(modinv)
end

# binary arithmetic operators

+(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a + y.a)
-(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a + (-y).a)
*(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a * y.a)
/(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}((x * inv(y)).a)
^(x::RClass{N}, y::Integer) where {N} = y >= 0 ? RClass{N}(x.a ^ y) : inv(RClass{N}(x.a ^ abs(y)))

# comparison operators
==(x::RClass{N}, y::RClass{N}) where {N} = x.a == y.a
!=(x::RClass{N}, y::RClass{N}) where {N} = x.a != y.a
<=(x::RClass{N}, y::RClass{N}) where {N} = x.a <= y.a
<(x::RClass{N}, y::RClass{N}) where {N} = x.a < y.a
>=(x::RClass{N}, y::RClass{N}) where {N} = x.a >= y.a
>(x::RClass{N}, y::RClass{N}) where {N} = x.a > y.a

# other functions

"""
Make a table for applying operation `op` to all elements in residue ring ℤ/`N`ℤ.
This makes most sense for multiplication or addition tables, i.e. passing `*`
or `+` as `op`.
Returns a `N`x`N` integer array. Each row and column represents a residue class
for 0 to `N-1` and each cell is hence the result of the operation applied to
the respective residue classes.
You can visualize the result with `visualize_table()`.
"""
function table(N::Integer, op::Function=*)::Array{Integer, 2}  # TODO: tests
    N < 2 && error("N must be integer > 1")

    x = 0:(N-1)
    rclasses = map(RClass{N}, x)

    table = Array{RClass{N}}(undef, N, N)

    for i in axes(table, 1), j in axes(table, 2)
        table[i, j] = op(rclasses[i], rclasses[j])
    end


    map(r -> Int(r.a), table)
end

# for instances of RClass
table(::RClass{N}, op::Function=*) where {N} = table(N, op)
# for RClass types
table(::Type{RClass{N}}, op::Function=*) where {N} = table(N, op)

function visualize_table(tab::Array{Integer, 2}, imgw=256, imgh=256)::CairoSurface
    # TODO
end

visualize_table(N::Integer, op::Function=*, imgw=256, imgh=256) = visualize_table(table(N, op), imgw=imgw, imgh=imgh)
visualize_table(::RClass{N}, op::Function=*, imgw=256, imgh=256) where {N} = visualize_table(table(N, op), imgw=imgw, imgh=imgh)
visualize_table(::Type{RClass{N}}, op::Function=*, imgw=256, imgh=256) where {N} = visualize_table(table(N, op), imgw=imgw, imgh=imgh)
