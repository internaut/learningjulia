module RowEquivalence

include("common.jl")

export identitymatrix, swapop_matrix, multop_matrix, addop_matrix,
    reducedechelon, reducedechelon_steps, rank, hasinv, inv

import Base: inv

"""
Generate elementary n×n matrix of type `t` that swaps rows `i` and `j`.
"""
function swapop_matrix(n::Integer, i::Integer, j::Integer, t::Type=Float64)
    n > 0 || error("`n` must be greater than 0")
    0 < i <= n || error("`i` must be in range [1, ", n , "]")
    0 < j <= n || error("`j` must be in range [1, ", n , "]")

    m = identitymatrix(n, t)

    if i != j
        m[j,:], m[i,:] = m[i,:], m[j,:]
    end

    m
end

"""
Generate elementary n×n matrix of type `t` that multiplies row `i` by non-zero
scalar `r`.
"""
function multop_matrix(n::Integer, i::Integer, r::Number, t::Type=Float64)
    n > 0 || error("`n` must be greater than 0")
    0 < i <= n || error("`i` must be in range [1, ", n , "]")
    r != 0 || error("`r` must be non-zero")

    m = identitymatrix(n, t)
    m[i,:] *= r
    m
end

"""
Generate elementary n×n matrix of type `t` that multiplies row `j` with scalar
`s` and adds this to row `i`.
"""
function addop_matrix(n::Integer, i::Integer, j::Integer, s::Number,
                       t::Type=Float64)
    n > 0 || error("`n` must be greater than 0")
    0 < i <= n || error("`i` must be in range [1, ", n , "]")
    0 < j <= n || error("`j` must be in range [1, ", n , "]")

    m = identitymatrix(n, t)
    m[i,j] = s
    m
end

"""
Calculate the reduced echelon form (REF) of m×n matrix `mat` using Gaussian
elimination. Will return the REF and optionally the rank of `mat` and/or a
vector of elementary matrices which represents the chain of elementary row
transformations performed to arrive at the REF.

To be able to calculate the REF, it is necessary that all elements in `mat`
other than zero are invertible. In other words, `mat` must be defined
over an integral domain.

Optionally return matrix rank (number of pivot elements) when `return_rank=true`
and/or vector of elementary matrices used in the elimination steps when
`return_operations=true`.
"""
function reducedechelon(mat::Matrix;
                        return_rank::Bool=false,
                        return_operations::Bool=false)
    m, n = size(mat)     # rows by cols
    type = eltype(mat)

    if return_operations
        op = Vector{Matrix{type}}()             # elementary matrices
    end

    r = 0          # current rank
    for t in 1:n   # iterate through columns
        # values in current column below current rank
        below = mat[(r+1):m,t]
        if !all(isapprox.(below, 0))  # there is a nonzero element in the rest
                                      # of the column
            if isapprox(below[1], 0)  # element at rank position in current
                                      # column is zero
                # i is index for first nonzero element
                i = r + (.!isapprox.(below, 0) |> findfirst)

                # swap current rank row with nonzero row
                swapmat = swapop_matrix(m, i, r+1, type)
                mat = swapmat * mat

                if return_operations
                    push!(op, swapmat)
                end
            end

            # value at current rank in current row
            val = mat[r+1, t]

            # scale current rank row by col[r+1]^-1
            if !isapprox(val, 1)
                scalemat = multop_matrix(m, r+1, inv(val), type)
                mat = scalemat * mat

                if return_operations
                    push!(op, scalemat)
                end
            end

            # bring all other values to zero in this column
            col = mat[:, t]
            nonzerorows = .!isapprox.(col, 0) |>
                findall |>
                x->setdiff(x, [r+1])

            for (i, val) in zip(nonzerorows, col[nonzerorows])
                subtract_mat = addop_matrix(m, i, r+1, -val, type)
                mat = subtract_mat * mat

                if return_operations
                    push!(op, subtract_mat)
                end
            end

            r += 1   # increase rank
        end
    end

    if return_rank && return_operations
        return mat, r, op
    elseif return_rank
        return mat, r
    elseif return_operations
        return mat, op
    else
        return mat
    end
end

"""
Calculate the reduced echelon form (REF) of m×n matrix `mat` using Gaussian
elimination as in `reducedechelon`, but return vector of matrices, where each
element in this vector represents one elimination step.

Optionally return vector of elementary matrices used in the elimination steps
when `return_operations=true`.
"""
function reducedechelon_steps(mat::Matrix; return_operations::Bool=false)
    ref, ops = reducedechelon(mat, return_operations=true)

    # there's probably a way to directly allocate the needed space since
    # we know the number of step matrices needed and their size
    steps = Vector{Matrix{eltype(mat)}}()
    cur_step = mat
    for op in ops
        cur_step = op * cur_step
        push!(steps, cur_step)
    end

    isapprox(steps[end], ref) || error("last step result should equal REF")

    return_operations ? (steps, ops) : steps
end


"""
Matrix rank of `mat` deduced from reduced echelon form.
"""
rank(mat::Matrix)::Int = reducedechelon(mat, return_rank=true)[2]

"""
Returns true if matrix `mat` has inverse, i.e. if it is a square matrix with
full rank, otherwise returns false.
"""
function hasinv(mat::Matrix)::Bool
    m, n = size(mat)
    m == n && rank(mat) == m
end

"""
Calculate the inverse of an invertible square matrix `mat`.
Overwrites `Base.inv`.
"""
function inv(mat::Matrix)
    m, n = size(mat)
    m == n || error("`mat` must be square matrix")

    _, r, op = reducedechelon(mat, return_rank=true, return_operations=true)
    rank(mat) == m || error("`mat` is not invertible")
    convert(Matrix{eltype(mat)}, prod(reverse(op)))
end

end
