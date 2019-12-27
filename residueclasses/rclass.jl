module ResidueClasses

import Base: +, -, *

"""
Residue class ā in ring ℤ modulo Nℤ
"""
struct RClass{N}
    a::Unsigned   # must be in [0, N-1]

    function RClass{N}(a) where {N}
        error("`a` must be an Integer type")
    end

    function RClass{N}(a::Integer) where {N}
        if N < 2
            error("N must be > 1")
        end

        new(mod(a, N))
    end
end

# string representation

Base.show(io::IO, r::RClass{N}) where {N} = print(io, r.a, " in ℤ/", N, "ℤ")

# unary arithmetic operators

+(x::RClass{N}) where {N} = RClass{N}(x.a)
-(x::RClass{N}) where {N} = RClass{N}(-Int(x.a))

# TODO: inv() and helper hasinv()

# binary arithmetic operators

+(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a + y.a)
-(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a + (-y).a)
*(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a * y.a)

# TODO: / as x*inv(y)

# TODO binary comparison operators

end
