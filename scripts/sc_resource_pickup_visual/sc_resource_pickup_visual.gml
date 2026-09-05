/*
RESOURCE PICKUP VISUALS

Four reusable ore-fragment shapes are recoloured using each item's
registered colour palette, then baked into cached sprites at startup.
*/

/// @description Returns normalized polygon points for one ore-fragment shape.
function sc_resource_pickup_shape_points(_variant)
{
    switch (_variant)
    {
        case 0:
            return [
                -0.88,-0.22, -0.51,-0.72, 0.08,-0.87,
                 0.69,-0.55,  0.91, 0.03, 0.52, 0.72,
                -0.18, 0.86, -0.81, 0.43
            ];

        case 1:
            return [
                -0.91,-0.08, -0.58,-0.68, 0.03,-0.73,
                 0.44,-0.91,  0.83,-0.41, 0.72, 0.22,
                 0.31, 0.82, -0.47, 0.69
            ];

        case 2:
            return [
                -0.74,-0.57, -0.09,-0.91, 0.61,-0.67,
                 0.89,-0.13,  0.63, 0.53, 0.12, 0.87,
                -0.51, 0.66, -0.93, 0.08
            ];

        case 3:
            return [
                -0.83,-0.38, -0.31,-0.79, 0.17,-0.58,
                 0.59,-0.86,  0.48,-0.31, 0.91, 0.18,
                 0.47, 0.76, -0.16, 0.91, -0.72, 0.51
            ];
    }

    return [];
}

/// @description Draws one filled irregular ore polygon.
function sc_resource_pickup_polygon_draw(_x, _y, _radius, _points, _colour)
{
    var _count = array_length(_points) div 2;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_x, _y, _colour, 1);

    for (var _i = 0; _i <= _count; _i++)
    {
        var _index = (_i mod _count) * 2;

        draw_vertex_colour(
            _x + _points[_index] * _radius,
            _y + _points[_index + 1] * _radius,
            _colour,
            1
        );
    }

    draw_primitive_end();
}

/// @description Draws one ore-fragment outline.
function sc_resource_pickup_outline_draw(_x, _y, _radius, _points, _colour)
{
    var _count = array_length(_points) div 2;

    draw_set_colour(_colour);

    for (var _i = 0; _i < _count; _i++)
    {
        var _next = (_i + 1) mod _count;
        var _index_a = _i * 2;
        var _index_b = _next * 2;

        draw_line_width(
            _x + _points[_index_a] * _radius,
            _y + _points[_index_a + 1] * _radius,
            _x + _points[_index_b] * _radius,
            _y + _points[_index_b + 1] * _radius,
            2
        );
    }
}

/// @description Draws one complete coloured ore fragment for startup baking.
function sc_resource_pickup_primitive_draw(_x, _y, _radius, _variant, _visual)
{
    var _points = sc_resource_pickup_shape_points(_variant);
    var _dark = merge_colour(_visual.colour, c_black, 0.72);
    var _mid = merge_colour(_visual.colour, c_black, 0.38);
    var _light = merge_colour(_visual.colour, c_white, 0.34);

    // Baked mineral glow.
    gpu_set_blendmode(bm_add);

    draw_set_colour(_visual.glow);
    draw_set_alpha(0.12);
    draw_circle(_x, _y, _radius * 1.9, false);

    draw_set_alpha(0.24);
    draw_circle(_x, _y, _radius * 1.35, false);

    gpu_set_blendmode(bm_normal);

    // Asteroid-like fragment body.
    draw_set_alpha(1);
    sc_resource_pickup_polygon_draw(_x, _y, _radius, _points, _dark);
    sc_resource_pickup_polygon_draw(_x, _y, _radius * 0.78, _points, _mid);
    sc_resource_pickup_outline_draw(_x, _y, _radius, _points, _light);

    // Mineral seams.
    draw_set_colour(_visual.glow);
    draw_set_alpha(0.42);
    draw_line_width(
        _x - _radius * 0.58, _y + _radius * 0.18,
        _x - _radius * 0.10, _y - _radius * 0.04,
        4
    );

    draw_line_width(
        _x - _radius * 0.10, _y - _radius * 0.04,
        _x + _radius * 0.46, _y - _radius * 0.31,
        4
    );

    draw_set_colour(_visual.colour);
    draw_set_alpha(1);
    draw_line_width(
        _x - _radius * 0.58, _y + _radius * 0.18,
        _x - _radius * 0.10, _y - _radius * 0.04,
        2
    );

    draw_line_width(
        _x - _radius * 0.10, _y - _radius * 0.04,
        _x + _radius * 0.46, _y - _radius * 0.31,
        2
    );

    // Small reflective facet.
    draw_set_colour(_light);
    draw_set_alpha(0.82);
    draw_line_width(
        _x - _radius * 0.38, _y - _radius * 0.42,
        _x + _radius * 0.10, _y - _radius * 0.58,
        2
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}