module VecSpace

struct Vectorspace{T, N}
    basis::Vector{T}   # TODO: change constructors

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


identityvector(j::Integer, n::Integer, t::Type{T}) where {T<:Vector} =
    1 <= j <= n ?
        [convert(eltype(t), i == j) for i = 1:n] :
        error("`i` must be in range [1,", n ,"]")
identityvector(k::Integer, n::Integer, t::Type{T}) where {T<:Matrix} =
    1 <= k <= n^2 ?
        [convert(eltype(t), k == (i-1) * n + j) for i = 1:n, j = 1:n] :
        error("`k` must be in range [1,", n^2 ,"]")
identityvector(j::Integer, n::Integer, t::Type{T}) where {T<:Number} =
    identityvector(j, n, Vector{t})
identityvector(j::Integer, n::Integer) = identityvector(j, n, Vector{Float64})

identitybasis(n::Integer, t::Type{T}) where {T<:Vector} = n > 0 ?
    [identityvector(i, n, t) for i = 1:n] :
    error("`n` must be greater than 0")
identitybasis(n, t::Type{T}) where {T<:Matrix} = n > 0 ?
    [identityvector(i, n, t) for i = 1:n^2] :
    error("`n` must be greater than 0")
identitybasis(n) = identitybasis(n, Vector{Float64})

identitymatrix(n, t::Type{T}) where {T} =
    [convert(t, i == j) for i = 1:n, j = 1:n]
identitymatrix(n) = identitymatrix(n, Float64)


end
