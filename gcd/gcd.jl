module GCD

export gcd_euclid

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

end
