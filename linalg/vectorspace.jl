module VecSpace

struct Vectorspace{T}   # type T
    basis::Vector{T}
    dimension::Integer

    function Vectorspace{T}(n::Integer) where {T}
        n > 0 || error("`n` must be greater than 0")
        b = identitybasis(n, T)
        d = size(b)[1]
        d > 0 || error("invalid generated identity basis")
        new(b, d)
    end

    function Vectorspace{T}(b::Vector{T}) where {T}
        # TODO: check for linear independence of b

        d = size(b)[1]
        d > 0 || error("invalid generated identity basis")
        new(b, d)
    end
end

Vectorspace(b) = Vectorspace{eltype(b)}(b)

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

identitybasis(n::Integer, t::Type{T}) where {T<:Union{Vector, Number}} = n > 0 ?
    [identityvector(i, n, t) for i = 1:n] :
    error("`n` must be greater than 0")
identitybasis(n, t::Type{T}) where {T<:Matrix} = n > 0 ?
    [identityvector(i, n, t) for i = 1:n^2] :
    error("`n` must be greater than 0")
identitybasis(n) = identitybasis(n, Vector{Float64})


end
