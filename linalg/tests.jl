using Test: @test, @testset, @test_throws

include("rowequiv.jl")

using .RowEquivalence

@testset "reducedechelon examples" begin
    mat = [0 1 2 -1  2 1  1;
           0 0 0  0  1 0  1;
           0 0 0  3 -6 3 -3;
           0 0 0  5  0 5  5]
    mat_float = convert(Matrix{Float64}, mat)
    mat_rational = convert(Matrix{Rational}, mat)

    rnf = [0 1 2 0 0 2 0;
           0 0 0 1 0 1 1;
           0 0 0 0 1 0 1;
           0 0 0 0 0 0 0]

    @test isapprox(reducedechelon(mat_float), rnf)
    @test isapprox(reducedechelon(mat_rational), rnf)

    calc_rnf, mat_rank = reducedechelon(mat_float, return_rank=true)
    @test isapprox(calc_rnf, rnf)
    @test mat_rank == 3

    calc_rnf, mat_rank = reducedechelon(mat_rational, return_rank=true)
    @test isapprox(calc_rnf, rnf)
    @test mat_rank == 3

    calc_rnf, ops = reducedechelon(mat_float, return_operations=true)
    @test isapprox(calc_rnf, rnf)
    @test typeof(ops) == Vector{Matrix{Float64}}
    @test length(ops) > 0

    calc_rnf, mat_rank, ops = reducedechelon(mat_rational,
                                             return_rank=true,
                                             return_operations=true)
    @test isapprox(calc_rnf, rnf)
    @test mat_rank == 3
    @test typeof(ops) == Vector{Matrix{Rational}}
    @test length(ops) > 0
end


@testset "reducedechelon extreme dimensions" begin
    @test reducedechelon(ones((0, 0))) == ones((0, 0))

    @testset "random matrices with one zero-dimension" for i = 1:10
        mat = ones((rand(1:10), 0))
        @test reducedechelon(mat) == mat
        mat = ones(0, (rand(1:10)))
        @test reducedechelon(mat) == mat
    end

    @testset "random 1x1 matrices" for i = 1:100
        t = rand([Float64, Rational])
        mat = t == Float64 ?
            rand(Float64, (1, 1)) : fill(rand(-10:10)//rand(1:10), 1, 1)
        expected = isapprox(mat[1, 1], 0) ? zeros(t, 1, 1) : ones(t, 1, 1)

        @test isapprox(reducedechelon(mat), expected)
    end

    @testset "random 1xN  or Nx1 matrices" for i = 1:100
        t = rand([Float64, Rational])
        n = rand(1:100)
        rowmat = rand(Bool)
        shape = rowmat ? (1, n) : (n, 1)
        mat = t == Float64 ?
              rand(Float64, shape) :
              reshape([rand(-10:10)//rand(1:10) for i in 1:n], shape)

        if all(isapprox.(mat, 0))
            expected = zeros(t, shape)
        else
            nonzero_idx = findfirst(.!isapprox.(mat, 0))[convert(Int, rowmat)+1]
            if rowmat
                expected = hcat(
                    zeros(t, (1, nonzero_idx-1)),
                    [1],
                    transpose(mat[1, nonzero_idx+1:end]
                              * inv(mat[1, nonzero_idx])))
            else
                expected = vcat(
                    zeros(t, (nonzero_idx-1, 1)),
                    [1],
                    mat[nonzero_idx+1:end, 1] * inv(mat[nonzero_idx, 1]))
            end
        end

        @test isapprox(reducedechelon(mat), expected)
    end
end