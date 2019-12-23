using Test: @test, @testset

include("gcd.jl")

using .GCD: gcd_euclid

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
