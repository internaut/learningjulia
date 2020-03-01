module ResidueClasses

export RClass, +, -, *, /, inv, hasinv, ^, ==, !=, <=, <, >=, >, table, visualize_table

import Base: +, -, *, /, inv, ^, ==, !=, <=, <, >=, >
using Cairo

include("../cmap.jl")
include("../vishelpers.jl")
using .ColorMaps


"""
    RClass{N}

Residue class ā in ring ℤ modulo Nℤ
"""
struct RClass{N}
    a::Unsigned   # must be in [0, N-1]

    function RClass{N}(a) where {N}
        error("`a` must be an Integer type")
    end

    function RClass{N}(a::Integer) where {N}
        if !(typeof(N) <: Integer) || N < 2
            error("N must be integer > 1")
        end

        new(mod(a, N))
    end
end

# string representation

Base.show(io::IO, r::RClass{N}) where {N} = print(io, r.a, " in ℤ/", N, "ℤ")

# unary arithmetic operators

+(x::RClass{N}) where {N} = RClass{N}(x.a)
-(x::RClass{N}) where {N} = RClass{N}(-Int(x.a))

"""
    hasinv(x::RClass{N})

Return `true` when residual class `x` has inverse, otherwise `false`.
"""
hasinv(x::RClass{N}) where {N} = gcd(x.a, N) == 1

"""
    inv(x::RClass{N})

If an inverse of `x` exists, calculate and return it.
"""
function inv(x::RClass{N})::RClass{N} where {N}
    @assert 0 <= x.a < N

    d, s, t = gcdx(Int(x.a), N)
    d == 1 || error("residual class ", x, " has no inverse")

    modinv = s - fld(s, N) * N   # normalize
    @assert 0 <= modinv < N

    RClass{N}(modinv)
end

# binary arithmetic operators

+(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a + y.a)
-(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a + (-y).a)
*(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}(x.a * y.a)
/(x::RClass{N}, y::RClass{N}) where {N} = RClass{N}((x * inv(y)).a)
^(x::RClass{N}, y::Integer) where {N} = y >= 0 ? RClass{N}(x.a ^ y) : inv(RClass{N}(x.a ^ abs(y)))

# comparison operators
==(x::RClass{N}, y::RClass{N}) where {N} = x.a == y.a
!=(x::RClass{N}, y::RClass{N}) where {N} = x.a != y.a
<=(x::RClass{N}, y::RClass{N}) where {N} = x.a <= y.a
<(x::RClass{N}, y::RClass{N}) where {N} = x.a < y.a
>=(x::RClass{N}, y::RClass{N}) where {N} = x.a >= y.a
>(x::RClass{N}, y::RClass{N}) where {N} = x.a > y.a

# other functions

"""
    table(N::Integer, op::Function=*)

Make a table for applying operation `op` to all elements in residue ring ℤ/`N`ℤ.
This makes most sense for multiplication or addition tables, i.e. passing `*`
or `+` as `op`.
Returns a `N`x`N` integer array. Each row and column represents a residue class
for 0 to `N-1` and each cell is hence the result of the operation applied to
the respective residue classes.
You can visualize the result with `visualize_table()`.
"""
function table(N::Integer, op::Function=*)::Array{Integer, 2}
    N < 2 && error("N must be integer > 1")

    x = 0:(N-1)
    rclasses = map(RClass{N}, x)

    table = Array{RClass{N}}(undef, N, N)

    for i in axes(table, 1), j in axes(table, 2)
        table[i, j] = op(rclasses[i], rclasses[j])
    end


    map(r -> Int(r.a), table)
end

# for instances of RClass
table(::RClass{N}, op::Function=*) where {N} = table(N, op)
# for RClass types
table(::Type{RClass{N}}, op::Function=*) where {N} = table(N, op)

"""
    visualize_table(tab::Array{Integer, 2}, op_str::AbstractString;
                             imgw::Integer=256, imgh::Integer=256,
                             gray::Bool=false, drawlabels::Bool=true,
                             startnum::Integer=0)

Visualize a residue class multiplication or addition table (label it by `op_str`) `tab` on
image size `imgw`x`imgh` pixels.
"""
function visualize_table(tab::Array{Integer, 2}, op_str::AbstractString;
                         imgw::Integer=256, imgh::Integer=256,
                         gray::Bool=false, drawlabels::Bool=true,
                         startnum::Integer=0)::CairoSurface
    dim1, dim2 = size(tab)
    dim1 == dim2 || error("`tab` must be quadratic")
    N = dim1
    0 <= startnum < N || error("`startnum` must be a zero or positive number lesser than `N`
                                (i.e. number of rows/columns in `tab`)")

    # create surface and context
    surface = CairoRGBSurface(imgw, imgh)
    context = CairoContext(surface)

    ncells = N + Int(drawlabels) - startnum
    cellw = imgw / ncells
    cellh = imgh / ncells

    set_font_size(context, cellw / 3)

    # set background
    save(context)
    set_source_rgb(context, 1, 1, 1)
    rectangle(context, 0.0, 0.0, imgw, imgh)
    fill(context)
    restore(context)

    if gray
        colormap = Dict(
            0 => (0.0, 0.0, 0.0),
            1 => (1.0, 1.0, 1.0),
            nothing => (0.5, 0.5, 0.5)
        )
    else
        colormap = generate_colormap(N)
    end

    if drawlabels
        select_font_face(context, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD)

        # draw table row and column labels
        for i in startnum:N
            if i == startnum
                draw_string_centered(context, op_str, cellw / 2, cellh / 2)
            else
                draw_string_centered(context, string(i - 1),
                                    (i-startnum) * cellw + cellw / 2, cellh / 2)
                draw_string_centered(context, string(i - 1),
                                    cellw / 2, (i-startnum) * cellh + cellh / 2)
            end
        end
    end

    select_font_face(context, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)

    # draw table cells
    for i in axes(tab, 1), j in axes(tab, 2)
        if i <= startnum || j <= startnum
            continue
        end

        save(context)

        val = tab[i, j]
        if gray
            col = val < 2 ? colormap[val] : colormap[nothing]
        else
            col = colormap[val+1, :]
        end

        offset = Int(drawlabels) - startnum - 1
        posx, posy = (i+offset) * cellw, (j+offset) * cellh

        # draw colored cell background
        set_source_rgb(context, col...)
        rectangle(context, posx, posy, cellw, cellh)
        fill(context)

        # draw value
        if drawlabels
            if sum(col) / 3 < 0.3
                set_source_rgb(context, 1, 1, 1)
            else
                set_source_rgb(context, 0, 0, 0)
            end

            draw_string_centered(context, string(val), posx + cellw/2, posy + cellh/2)
        end

        restore(context)
    end

    surface
end

visualize_table(N::Integer, op::Function=*; imgw=256, imgh=256, gray=false,
                drawlabels=true, startnum=0) =
    visualize_table(table(N, op), string(op), imgw=imgw, imgh=imgh, gray=gray,
                    drawlabels=drawlabels, startnum=startnum)
visualize_table(::RClass{N}, op::Function=*; imgw=256, imgh=256, gray=false,
                    drawlabels=true, startnum=0) where {N} =
    visualize_table(table(N, op), string(op), imgw=imgw, imgh=imgh, gray=gray,
                    drawlabels=drawlabels, startnum=startnum)
visualize_table(::Type{RClass{N}}, op::Function=*; imgw=256, imgh=256, gray=false,
                drawlabels=true, startnum=0) where {N} =
    visualize_table(table(N, op), string(op), imgw=imgw, imgh=imgh, gray=gray,
                    drawlabels=drawlabels, startnum=startnum)


end
