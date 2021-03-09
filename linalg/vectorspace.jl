module VecSpace

identitymatrix(n, T)::Matrix{T} where {T} =
    [convert(T, i == j) for i = 1:n, j = 1:n]
identitymatrix(n) = identitymatrix(n, Float64)


struct Vectorspace{T, N}
    basis::Matrix{T}

    function Vectorspace{T, N}() where {T, N}
        new(identitymatrix(N, T))
    end

    function Vectorspace{T, N}(basismatrix) where {T, N}
        eltype(basismatrix) == T || error("basis matrix must be of type ", T)
        ndims(basismatrix) == 2 || error("basis matrix must be two-dimensional")
        n = size(basismatrix)
        n[1] == n[2] == N || error("basis matrix must be square ",
                                   N, " by ", N, " matrix")

        new(basismatrix)
    end
end

Vectorspace(basismatrix) =
    Vectorspace{eltype(basismatrix), size(basismatrix)[1]}(basismatrix)


struct Subspace
    of::Vectorspace
end

end
