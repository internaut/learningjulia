identitymatrix(n, t::Type{T}) where {T} = n > 0 ?
    [convert(t, i == j) for i = 1:n, j = 1:n] :
    error("`n` must be greater than 0")
identitymatrix(n) = identitymatrix(n, Float64)
