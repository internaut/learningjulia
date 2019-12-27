using Test: @test, @testset, @test_throws

include("rclass.jl")

using .ResidueClasses: RClass, +, -, *

@testset "RClass" begin
    for (x, expected) in zip(-3:3, Iterators.cycle([1, 0]))
        @test RClass{2}(x).a == expected
    end

    for n = 2:5, k = -3:3, r = 0:(n-1)
        @test RClass{n}(n * k + r).a == r
    end

    # N must be > 1
    @test_throws ErrorException RClass{1}(0)
    @test_throws ErrorException RClass{0}(0)
    @test_throws ErrorException RClass{-1}(0)

    # a must be Integer
    @test_throws ErrorException RClass{2}(0.0)
end

@testset "RClass unary arithmetic operators" begin
    z = RClass{3}(2)
    @test z.a == (+z).a
    @test (-z).a == 1
    @test (-(-z)).a == z.a == 2

    @testset "random inputs for unary arithmetic operators" for i = 1:100
        a = rand(1:1000)
        N = rand(2:100)
        z = RClass{N}(a)

        # comparing z.a here to make it indep. of comparison operator == implementation
        @test (+z).a == (-(-z)).a == z.a
    end
end

@testset "RClass binary arithmetic operators" begin
    # arithmetic must happen in same ring (i.e. N must be the same)
    @test_throws MethodError RClass{2}(0) + RClass{3}(0)
    @test_throws MethodError RClass{2}(0) - RClass{3}(0)
    @test_throws MethodError RClass{2}(0) * RClass{3}(0)

    x = RClass{3}(2)
    y = RClass{3}(1)

    @test (x + y).a == (y + x).a == 0
    @test (x - y).a == (-(y - x)).a == 1
    @test (x * y).a == (y * x).a == 2

    @testset "random inputs for binary arithmetic operators" for i = 1:100
        N = rand(2:100)
        x = RClass{N}(rand(1:100))
        y = RClass{N}(rand(1:100))

        @test 0 <= (x + y).a == (y + x).a < N
        @test 0 <= (x - y).a == (-(y - x)).a < N
        @test 0 <= (x * y).a == (y * x).a < N
    end
end
