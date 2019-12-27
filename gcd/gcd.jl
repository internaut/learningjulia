module GCD

export gcd_euclid, gcd_euclid_extended

"""
Simple greatest common divisor (gcd) calculation of integers `a` and `b` using
the Euclidian algorithm.
"""
function gcd_euclid(a::Integer, b::Integer)::Unsigned
    a == 0 && b == 0 && return 0

    if a == 0    # swap
        a, b = b, a
    end

    # for b = q*a + r with r ∈ [0, |a|):
    # d = gcd(a, r) => gcd(a, b) = gcd(a, r) = d
    while true
        r = abs(mod(b, a))
        @assert 0 <= r < abs(a)
        r == 0 && return a   # remainder is 0 => return the gcd

        # otherwise continue but now substitute b with a and a with r, hence
        # calculating the remainder for the division a / r
        b = a
        a = r
    end
end


"""
Extended greatest common divisor (gcd) calculation of integers `a` and `b` using
the Euclidian algorithm. This function returns a tuple with integers `d, s, t`
such that `d = gcd(a, b) = a*s + b*t`.
"""
function gcd_euclid_extended(a::Integer, b::Integer)::NTuple{3, Integer}
    a == 0 && b == 0 && return 0, 0, 0


    if a == 0    # swap
        a, b = b, a
    end

    qs = Vector{promote_type(typeof(a), typeof(b))}()
    i = 0

    while true
        q = fld(b, a)
        r = mod(b, a)

        if r < 0     # make r always positive
            r -= a
            q += 1
        end

        @assert 0 <= r < abs(a)
        @assert b == q * a + r

        if r == 0    # residual is 0 => calculate s and t
            s, t = 0, 1
            for j in i:-1:1   # iterate backward through q factors
                # s_j = t_{j+1}
                # t_j = s_{j+1} - q_j * t_{j+1}
                s, t = t, s - qs[j] * t
            end

            return a, t, s
        end

        push!(qs, q)   # store q factor

        b = a
        a = r
        i += 1
    end
end

end
