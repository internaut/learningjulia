module RowEquivalence

include("common.jl")

export identitymatrix, swaprow_matrix, multrow_matrix, rowadd_matrix

"""
Generate elementary n×n matrix of type `t` that swaps rows `i` and `j`.
"""
function swaprow_matrix(n::Integer, i::Integer, j::Integer, t::Type=Float64)
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
function multrow_matrix(n::Integer, i::Integer, r::Number, t::Type=Float64)
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
function rowadd_matrix(n::Integer, i::Integer, j::Integer, s::Number,
                       t::Type=Float64)
    n > 0 || error("`n` must be greater than 0")
    0 < i <= n || error("`i` must be in range [1, ", n , "]")
    0 < j <= n || error("`j` must be in range [1, ", n , "]")

    m = identitymatrix(n, t)
    m[i,j] = s
    m
end


function reducedechelon(mat::Matrix,
                        return_rank::Bool=false,
                        return_operations::Bool=false)
    m, n = size(mat)     # rows by cols
    type = eltype(mat)
    mat_ = mat

    if return_operations
        op = Vector{Matrix{type}}()             # elementary matrices
    end

    r = 0          # current rank
    for t in 1:n   # iterate through columns
        # values in current column below current rank
        below = mat_[(r+1):m,t]]
        if !all(isapprox.(below, 0))  # there is a nonzero element in the rest of the column
            if isapprox(below[1], 0)  # element at rank position in current column is zero
                # i is index for first nonzero element
                i = r + findfirst(broadcast(!, isapprox.(below, 0)))[1]

                # swap current rank row with nonzero row
                swapmat = swaprow_matrix(m, i, r+1, type)
                mat_ = swapmat * mat_

                if return_operations
                    push!(op, swapmat)
                end
            end

            # values in current column
            col = mat_[:, t]

            # TODO: scale current rank row by col[r+1]^-1
            col[r+1]
            # TODO: bring all other values to zero in this column

            r += 1   # increase rank
        end

    end
end

end
