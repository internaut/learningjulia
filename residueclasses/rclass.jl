"""
Residue class ā in ring ℤ modulo nℤ
"""
struct RClass
    a::Unsigned   # must be in [0, n-1]
    n::Unsigned   # must be > 1

    function RClass(a, n)
        if n < 2
            error("n must be > 1")
        end

        new(a % n, n)
    end
end

Base.show(io::IO, r::RClass) = print(io, r.a, " in ℤ/", r.n, "ℤ")
