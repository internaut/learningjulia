module GCD

export gcd_euclid, gcd_euclid_extended

function gcd_euclid(a::Integer, b::Integer)
    a == 0 && b == 0 && return 0

    if a == 0    # swap
        a, b = b, a
    end

    while true
        r = abs(mod(b, a))
        @assert 0 <= r < abs(a)
        r == 0 && return a
        b = a
        a = r
    end
end

function gcd_euclid_extended(a::Integer, b::Integer)
    a == 0 && b == 0 && return 0, 0, 0


    if a == 0    # swap
        a, b = b, a
    end

    qs = Vector{promote_type(typeof(a), typeof(b))}()
    i = 0

    while true
        q = fld(b, a)
        r = mod(b, a)

        if r < 0
            r -= a
            q += 1
        end

        @assert 0 <= r < abs(a)
        @assert b == q * a + r

        if r == 0
            s, t = 0, 1
            for j in i:-1:1
                s, t = t, s - qs[j] * t
            end

            return a, t, s
        end

        push!(qs, q)

        b = a
        a = r
        i += 1
    end
end

end
