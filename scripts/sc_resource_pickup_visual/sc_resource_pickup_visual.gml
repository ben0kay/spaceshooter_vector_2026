/*
RESOURCE PICKUP VISUALS

Ore pickups are drawn as small clusters of angular mineral chunks.
They are recoloured per resource and baked into cached sprites.
*/

/// @description Returns normalized points for one angular rock shape.
function sc_resource_pickup_shape_points(_variant)
{
    switch (_variant mod 4)
    {
        case 0:
            return [
                -0.92, 0.18,
                -0.70,-0.55,
                -0.15,-0.91,
                 0.48,-0.72,
                 0.91,-0.13,
                 0.68, 0.58,
                 0.12, 0.88,
                -0.57, 0.71
            ];

        case 1:
            return [
                -0.88,-0.18,
                -0.42,-0.82,
                 0.25,-0.91,
                 0.82,-0.47,
                 0.92, 0.23,
                 0.39, 0.82,
                -0.34, 0.73,
                -0.79, 0.42
            ];

        case 2:
            return [
                -0.91,-0.37,
                -0.28,-0.88,
                 0.38,-0.72,
                 0.87,-0.18,
                 0.71, 0.56,
                 0.08, 0.91,
                -0.58, 0.68
            ];

        case 3:
            return [
                -0.82, 0.34,
                -0.66,-0.46,
                -0.10,-0.89,
                 0.55,-0.69,
                 0.91,-0.02,
                 0.52, 0.73,
                -0.21, 0.84
            ];
    }

    return [];
}

/// @description Returns a rotated local X coordinate.
function sc_resource_pickup_point_x(_x, _local_x, _local_y, _angle)
{
    return _x
        + lengthdir_x(_local_x, _angle)
        + lengthdir_x(_local_y, _angle + 90);
}

/// @description Returns a rotated local Y coordinate.
function sc_resource_pickup_point_y(_y, _local_x, _local_y, _angle)
{
    return _y
        + lengthdir_y(_local_x, _angle)
        + lengthdir_y(_local_y, _angle + 90);
}

/// @description Draws one rotated, irregular polygon.
function sc_resource_pickup_polygon_draw(
    _x,
    _y,
    _radius,
    _angle,
    _points,
    _colour
)
{
    var _count = array_length(_points) div 2;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_x, _y, _colour, 1);

    for (var _i = 0; _i <= _count; _i++)
    {
        var _index = (_i mod _count) * 2;
        var _local_x = _points[_index] * _radius;
        var _local_y = _points[_index + 1] * _radius;

        draw_vertex_colour(
            sc_resource_pickup_point_x(
                _x,
                _local_x,
                _local_y,
                _angle
            ),
            sc_resource_pickup_point_y(
                _y,
                _local_x,
                _local_y,
                _angle
            ),
            _colour,
            1
        );
    }

    draw_primitive_end();
}

/// @description Draws the outline of one rotated rock.
function sc_resource_pickup_outline_draw(
    _x,
    _y,
    _radius,
    _angle,
    _points,
    _colour
)
{
    var _count = array_length(_points) div 2;

    draw_set_colour(_colour);

    for (var _i = 0; _i < _count; _i++)
    {
        var _next = (_i + 1) mod _count;
        var _index_a = _i * 2;
        var _index_b = _next * 2;

        var _ax = _points[_index_a] * _radius;
        var _ay = _points[_index_a + 1] * _radius;
        var _bx = _points[_index_b] * _radius;
        var _by = _points[_index_b + 1] * _radius;

        draw_line_width(
            sc_resource_pickup_point_x(_x, _ax, _ay, _angle),
            sc_resource_pickup_point_y(_y, _ax, _ay, _angle),
            sc_resource_pickup_point_x(_x, _bx, _by, _angle),
            sc_resource_pickup_point_y(_y, _bx, _by, _angle),
            1
        );
    }
}

/// @description Draws one individual angular mineral chunk.
function sc_resource_pickup_rock_draw(
    _x,
    _y,
    _radius,
    _angle,
    _shape,
    _visual
)
{
    var _points = sc_resource_pickup_shape_points(_shape);

    var _shadow =
        merge_colour(_visual.colour, c_black, 0.82);

    var _body =
        merge_colour(_visual.colour, c_black, 0.54);

    var _surface =
        merge_colour(_visual.colour, c_white, 0.10);

    var _edge =
        merge_colour(_visual.colour, c_white, 0.42);

    // Dark lower rock body.
    sc_resource_pickup_polygon_draw(
        _x,
        _y + _radius * 0.13,
        _radius,
        _angle,
        _points,
        _shadow
    );

    // Raised upper surface.
    sc_resource_pickup_polygon_draw(
        _x,
        _y,
        _radius * 0.91,
        _angle,
        _points,
        _body
    );

    // Irregular bright upper facet.
    var _ax = sc_resource_pickup_point_x(
        _x,
        -_radius * 0.56,
        -_radius * 0.25,
        _angle
    );

    var _ay = sc_resource_pickup_point_y(
        _y,
        -_radius * 0.56,
        -_radius * 0.25,
        _angle
    );

    var _bx = sc_resource_pickup_point_x(
        _x,
        -_radius * 0.10,
        -_radius * 0.66,
        _angle
    );

    var _by = sc_resource_pickup_point_y(
        _y,
        -_radius * 0.10,
        -_radius * 0.66,
        _angle
    );

    var _cx = sc_resource_pickup_point_x(
        _x,
         _radius * 0.48,
        -_radius * 0.28,
        _angle
    );

    var _cy = sc_resource_pickup_point_y(
        _y,
         _radius * 0.48,
        -_radius * 0.28,
        _angle
    );

    draw_set_colour(_surface);
    draw_set_alpha(0.92);
    draw_triangle(_ax, _ay, _bx, _by, _cx, _cy, false);

    // Mineral seam.
    draw_set_colour(_visual.glow);
    draw_set_alpha(0.45);

    draw_line_width(
        _ax,
        _ay,
        _x + lengthdir_x(_radius * 0.18, _angle),
        _y + lengthdir_y(_radius * 0.18, _angle),
        2
    );

    draw_set_alpha(1);

    sc_resource_pickup_outline_draw(
        _x,
        _y,
        _radius * 0.91,
        _angle,
        _points,
        _edge
    );
}

/// @description Draws one clustered ore pickup for startup baking.
function sc_resource_pickup_primitive_draw(
    _x,
    _y,
    _radius,
    _variant,
    _visual
)
{
    // Soft mineral glow behind the complete cluster.
    gpu_set_blendmode(bm_add);

    draw_set_colour(_visual.glow);
    draw_set_alpha(0.09);
    draw_circle(_x, _y, _radius * 2.05, false);

    draw_set_alpha(0.16);
    draw_circle(_x, _y, _radius * 1.55, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    var _flip = (_variant mod 2 == 0) ? 1 : -1;
    var _turn = _variant * 17;

    // Rear/top chunk.
    sc_resource_pickup_rock_draw(
        _x + _radius * 0.04 * _flip,
        _y - _radius * 0.48,
        _radius * 0.72,
        _turn - 6,
        _variant,
        _visual
    );

    // Rear side chunks.
    sc_resource_pickup_rock_draw(
        _x - _radius * 0.50,
        _y - _radius * 0.05,
        _radius * 0.57,
        _turn - 22,
        _variant + 1,
        _visual
    );

    sc_resource_pickup_rock_draw(
        _x + _radius * 0.50,
        _y - _radius * 0.02,
        _radius * 0.55,
        _turn + 19,
        _variant + 2,
        _visual
    );

    // Front chunks overlap the rear chunks.
    sc_resource_pickup_rock_draw(
        _x - _radius * 0.31,
        _y + _radius * 0.42,
        _radius * 0.62,
        _turn + 8,
        _variant + 3,
        _visual
    );

    sc_resource_pickup_rock_draw(
        _x + _radius * 0.34,
        _y + _radius * 0.41,
        _radius * 0.59,
        _turn - 13,
        _variant + 1,
        _visual
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}