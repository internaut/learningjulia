using Test: @test, @testset

include("gcd.jl")

using .GCD

@testset "gcd_euclid" begin
    @test gcd_euclid(0, 0) == 0
    @test gcd_euclid(1, 1) == 1
    @test gcd_euclid(0, 12) == gcd_euclid(12, 0) == 12
    @test gcd_euclid(-2002, 210) == gcd_euclid(210, -2002) == 14

    @testset "random inputs against Julia gcd impl." for i in 1:100
        a, b = rand(Int), rand(Int)
        @test gcd_euclid(a, b) == gcd(a, b)
    end
end


@testset "gcd_euclid_extended" begin
    @test gcd_euclid_extended(0, 0) == (0, 0, 0)
    @test gcd_euclid_extended(1, 1) == (1, 1, 0)

    d, s, t = gcd_euclid_extended(-2002, 210)
    @test gcd_euclid_extended(210, -2002) == (d, t, s) == (14, -19, -2)

    d, s, t = gcd_euclid_extended(128, 34)
    @test gcd_euclid_extended(34, 128) == (d, t, s) == (2, -15, 4)

    @testset "random inputs against Julia gcd impl." for i in 1:100
        a, b = rand(Int), rand(Int)
        d, s, t = gcd_euclid_extended(a, b)
        @test d == gcd(a, b)
        @test d == a*s + b*t
    end
end
