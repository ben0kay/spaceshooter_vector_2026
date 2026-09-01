/// @description Returns a rotated local-space X coordinate.
function sc_visual_x(_x, _radius, _angle, _forward, _side)
{
    return _x + lengthdir_x(_radius * _forward, _angle) + lengthdir_x(_radius * _side, _angle + 90);
}

/// @description Returns a rotated local-space Y coordinate.
function sc_visual_y(_y, _radius, _angle, _forward, _side)
{
    return _y + lengthdir_y(_radius * _forward, _angle) + lengthdir_y(_radius * _side, _angle + 90);
}

/// @description Draws one filled or outlined local-space triangle.
function sc_visual_triangle(_x, _y, _radius, _angle, _f1, _s1, _f2, _s2, _f3, _s3, _colour, _outline)
{
    draw_set_colour(_colour);

    draw_triangle(
        sc_visual_x(_x, _radius, _angle, _f1, _s1), sc_visual_y(_y, _radius, _angle, _f1, _s1),
        sc_visual_x(_x, _radius, _angle, _f2, _s2), sc_visual_y(_y, _radius, _angle, _f2, _s2),
        sc_visual_x(_x, _radius, _angle, _f3, _s3), sc_visual_y(_y, _radius, _angle, _f3, _s3),
        _outline
    );
}

/// @description Draws one filled local-space quadrilateral as two triangles.
function sc_visual_quad(_x, _y, _radius, _angle, _f1, _s1, _f2, _s2, _f3, _s3, _f4, _s4, _colour)
{
    sc_visual_triangle(_x, _y, _radius, _angle, _f1, _s1, _f2, _s2, _f3, _s3, _colour, false);
    sc_visual_triangle(_x, _y, _radius, _angle, _f1, _s1, _f3, _s3, _f4, _s4, _colour, false);
}

/// @description Draws one local-space line.
function sc_visual_line(_x, _y, _radius, _angle, _f1, _s1, _f2, _s2, _width, _colour)
{
    draw_set_colour(_colour);

    draw_line_width(
        sc_visual_x(_x, _radius, _angle, _f1, _s1), sc_visual_y(_y, _radius, _angle, _f1, _s1),
        sc_visual_x(_x, _radius, _angle, _f2, _s2), sc_visual_y(_y, _radius, _angle, _f2, _s2),
        _width
    );
}

/// @description Draws one local-space circle.
function sc_visual_circle(_x, _y, _radius, _angle, _forward, _side, _scale, _colour, _outline)
{
    draw_set_colour(_colour);

    draw_circle(
        sc_visual_x(_x, _radius, _angle, _forward, _side),
        sc_visual_y(_y, _radius, _angle, _forward, _side),
        _radius * _scale,
        _outline
    );
}