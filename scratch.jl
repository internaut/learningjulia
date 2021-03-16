include("linalg/rowequiv.jl")

using .RowEquivalence

identitymatrix(2)

m = transpose(reshape(collect(1:9), 3, 3))
t = eltype(m)

swaprow_matrix(3, 1, 2, t) * m
multrow_matrix(3, 1, 10, t) * m
rowadd_matrix(3, 1, 2, 100, t) * m
