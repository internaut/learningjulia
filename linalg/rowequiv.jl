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


function reducedechelon(m::Matrix, return_operations::Bool=false)

end

end
