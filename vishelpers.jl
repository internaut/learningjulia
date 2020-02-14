using Cairo


"""
    draw_string_centered(context::CairoContext, s::AbstractString, posx::Real=0, posy::Real=0

Helper for drawing text `s` centered at `posx`, `posy` in cairo context `context`.
"""
function draw_string_centered(context::CairoContext, s::AbstractString, posx::Real=0, posy::Real=0)
    save(context)

    extents = text_extents(context, s)
    move_to(context, posx - extents[3]/2 - extents[1],
                     posy - extents[4]/2 - extents[2])

    show_text(context, s)

    restore(context)
end
