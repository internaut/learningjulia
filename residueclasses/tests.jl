using Test: @test, @testset, @test_throws

include("rclass.jl")

using .ResidueClasses

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
    @test inv(z).a == 2

    @testset "random inputs for unary arithmetic operators" for i = 1:100
        a = rand(0:1000)
        N = rand(2:100)
        z = RClass{N}(a)

        # comparing z.a here to make it indep. of comparison operator == implementation
        @test (+z).a == (-(-z)).a == z.a
        if hasinv(z)
            @test inv(inv(z)).a == z.a
        else
            @test_throws ErrorException inv(z)
        end
    end
end

@testset "RClass binary arithmetic operators" begin
    # arithmetic must happen in same ring (i.e. N must be the same)
    @test_throws MethodError RClass{2}(0) + RClass{3}(0)
    @test_throws MethodError RClass{2}(0) - RClass{3}(0)
    @test_throws MethodError RClass{2}(0) * RClass{3}(0)
    @test_throws MethodError RClass{2}(0) / RClass{3}(0)

    x = RClass{3}(2)
    y = RClass{3}(1)

    @test (x + y).a == (y + x).a == 0
    @test (x - y).a == (-(y - x)).a == 1
    @test (x * y).a == (y * x).a == 2
    @test (x / y).a == (x * inv(y)).a == inv(y / x).a == 2
    @test (x^-2).a == inv(x * x).a == 1
    @test (x^-1).a == inv(x).a == 2
    @test (x^0).a == 1
    @test (x^1).a == x.a == 2
    @test (x^2).a == (x * x).a == 1

    @testset "random inputs for binary arithmetic operators" for i = 1:100
        N = rand(2:100)
        x = RClass{N}(rand(0:100))
        y = RClass{N}(rand(0:100))

        @test 0 <= (x + y).a == (y + x).a < N
        @test 0 <= (x - y).a == (-(y - x)).a < N
        @test 0 <= (x * y).a == (y * x).a < N

        if hasinv(x)
            x_inv = inv(x)
            @test (x * x_inv).a == 1
        else
            x_inv = missing
            @test_throws ErrorException inv(x)
        end

        if hasinv(y)
            y_inv = inv(y)
            @test (y * y_inv).a == 1
            @test 0 <= (x / y).a == (x * y_inv).a < N
        else
            y_inv = missing
            @test_throws ErrorException inv(y)
        end

        if !(ismissing(x_inv) || ismissing(y_inv))
            @test (x / y).a == inv((y / x)).a
        end

        for p = -5:5
            if p == 0
                z = RClass{N}(1)
            else
                z = RClass{N}(x.a)
                for j = 2:abs(p)
                    z = z * x
                end
            end

            if p < 0
                if hasinv(x)
                    @test (x^p).a == inv(z).a
                else
                    @test_throws ErrorException x^p
                end
            else
                @test (x^p).a == z.a
            end
        end
    end
end


@testset "RClass comparison operators" begin
    # comparison must happen in same ring (i.e. N must be the same)
    # TODO: the following two tests should throw an error, but they don't!
    #@test_throws MethodError RClass{2}(0) == RClass{3}(0)
    #@test_throws MethodError RClass{2}(0) != RClass{3}(0)
    @test_throws MethodError RClass{2}(0) <= RClass{3}(0)
    @test_throws MethodError RClass{2}(0) < RClass{3}(0)
    @test_throws MethodError RClass{2}(0) >= RClass{3}(0)
    @test_throws MethodError RClass{2}(0) > RClass{3}(0)

    x = RClass{3}(2)
    y = RClass{3}(2)
    z = RClass{3}(1)

    @test x == y
    @test x != z
    @test !(x == z)
    @test !(x != y)
    @test x <= y
    @test z <= x
    @test z < x
    @test x >= y
    @test x >= z
    @test x > z

    @testset "random inputs for binary arithmetic operators" for i = 1:100
        N = rand(2:100)
        x = RClass{N}(rand(0:100))
        y = RClass{N}(rand(0:100))
        z = RClass{N}(rand(0:100))

        @test x == x && y == y && z == z

        if x == y
            @test y == x && x <= y && y <= x && x >= y && y >= x
            x == z && @test y == z
        else
            @test x != y && y != x
            @test x < y || x > y
            x < y && @test y > x
            x > y && @test y < x
            x < y < z && @test x < z
            x > y > z && @test x > z
        end
    end
end


@testset "table" begin
    @test_throws ErrorException table(-1)
    @test_throws ErrorException table(0)
    @test_throws ErrorException table(1)
    @test table(3, *) == [[0 0 0]; [0 1 2]; [0 2 1]]
    @test table(3, +) == [[0 1 2]; [1 2 0]; [2 0 1]]

    @testset "random inputs for multiplication table" for i = 1:50, op in (+, *)
        N = rand(2:20)
        res = table(N, op)
        @test res == table(RClass{N}, op) == table(RClass{N}(0), op)
        @test isa(res, Array{Integer,2})
        @test size(res) == (N, N)
        @test all(i -> 0 <= i < N, res)
    end
end
