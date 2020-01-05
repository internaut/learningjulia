module ResidueClasses

export RClass, +, -, *, /, inv, hasinv, ^, ==, !=, <=, <, >=, >

import Base: +, -, *, /, inv, ^, ==, !=, <=, <, >=, >

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

end
