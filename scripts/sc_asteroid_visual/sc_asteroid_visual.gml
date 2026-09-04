/*
ASTEROID VISUALS

Six reusable vector shapes are baked for every material and damage stage.
Runtime scale, stretching, mirroring and rotation add further variation.
*/

/// @description Returns normalized polygon points for one asteroid shape.
function sc_asteroid_shape_points(_variant)
{
    switch (_variant)
    {
        case 0: return [-0.82,-0.28,-0.55,-0.72,-0.08,-0.91,0.42,-0.76,0.83,-0.37,0.91,0.12,0.66,0.63,0.15,0.86,-0.39,0.72,-0.88,0.28];
        case 1: return [-0.94,-0.11,-0.61,-0.45,-0.42,-0.83,0.02,-0.64,0.37,-0.91,0.55,-0.48,0.92,-0.18,0.66,0.25,0.77,0.66,0.21,0.78,-0.24,0.91,-0.48,0.49,-0.87,0.36];
        case 2: return [-0.91,-0.39,-0.42,-0.79,0.06,-0.72,0.51,-0.88,0.83,-0.42,0.71,-0.02,0.91,0.38,0.43,0.72,-0.03,0.89,-0.55,0.65,-0.78,0.18];
        case 3: return [-0.91,-0.18,-0.66,-0.65,-0.23,-0.78,0.03,-0.48,0.33,-0.78,0.78,-0.55,0.91,-0.08,0.63,0.25,0.74,0.61,0.25,0.86,-0.05,0.55,-0.41,0.81,-0.83,0.45];
        case 4: return [-0.98,-0.26,-0.46,-0.54,0.08,-0.47,0.59,-0.62,0.96,-0.22,0.83,0.19,0.49,0.53,-0.08,0.47,-0.61,0.61,-0.94,0.21];
        case 5: return [-0.84,-0.43,-0.44,-0.76,-0.05,-0.61,0.31,-0.87,0.47,-0.49,0.84,-0.32,0.72,0.12,0.91,0.45,0.38,0.67,0.03,0.91,-0.28,0.62,-0.75,0.51,-0.91,0.05];
    }

    return [];
}

/// @description Draws one filled asteroid polygon and its outline.
function sc_asteroid_polygon_draw(_x, _y, _radius, _points, _fill, _outline)
{
    var _count = array_length(_points) div 2;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_x, _y, _fill, 1);

    for (var _i = 0; _i <= _count; _i++)
    {
        var _index = (_i mod _count) * 2;
        draw_vertex_colour(_x + _points[_index] * _radius, _y + _points[_index + 1] * _radius, _fill, 1);
    }

    draw_primitive_end();
    draw_set_colour(_outline);

    for (var _i = 0; _i < _count; _i++)
    {
        var _next = (_i + 1) mod _count;
        draw_line_width(
            _x + _points[_i * 2] * _radius, _y + _points[_i * 2 + 1] * _radius,
            _x + _points[_next * 2] * _radius, _y + _points[_next * 2 + 1] * _radius, 3
        );
    }
}

/// @description Draws deterministic craters for one asteroid shape.
function sc_asteroid_craters_draw(_x, _y, _radius, _variant, _palette)
{
    var _craters;

    switch (_variant)
    {
        case 0: _craters = [-0.32,-0.27,0.18,0.34,0.16,0.13,0.05,-0.48,0.09]; break;
        case 1: _craters = [-0.45,0.12,0.14,0.25,-0.31,0.17,0.43,0.35,0.09]; break;
        case 2: _craters = [-0.28,-0.39,0.12,0.37,-0.24,0.16,-0.05,0.31,0.19]; break;
        case 3: _craters = [-0.48,-0.17,0.15,0.42,-0.18,0.12,0.15,0.39,0.14]; break;
        case 4: _craters = [-0.51,0.03,0.13,0.16,-0.21,0.17,0.51,0.13,0.11]; break;
        default: _craters = [-0.33,-0.26,0.14,0.35,0.02,0.18,-0.12,0.43,0.10]; break;
    }

    for (var _i = 0; _i < array_length(_craters); _i += 3)
    {
        var _cx = _x + _craters[_i] * _radius;
        var _cy = _y + _craters[_i + 1] * _radius;
        var _cr = _craters[_i + 2] * _radius;

        draw_set_colour(_palette.void);
        draw_circle(_cx, _cy, _cr, false);

        draw_set_colour(_palette.dark);
        draw_circle(_cx - _cr * 0.12, _cy - _cr * 0.12, _cr * 0.68, false);

        draw_set_colour(_palette.light);
        draw_set_alpha(0.45);
        draw_circle(_cx, _cy, _cr, true);
        draw_set_alpha(1);
    }
}

/// @description Draws resource seams and damage-stage fractures.
function sc_asteroid_damage_draw(_x, _y, _radius, _stage, _palette)
{
    var _alpha = 0.32 + _stage * 0.18;

    draw_set_colour(_palette.glow);
    draw_set_alpha(_alpha);
    draw_line_width(_x - _radius * 0.62, _y - _radius * 0.08, _x - _radius * 0.18, _y + _radius * 0.04, 5);
    draw_line_width(_x - _radius * 0.18, _y + _radius * 0.04, _x + _radius * 0.19, _y - _radius * 0.19, 5);
    draw_line_width(_x + _radius * 0.19, _y - _radius * 0.19, _x + _radius * 0.58, _y - _radius * 0.08, 5);

    draw_set_colour(_palette.resource);
    draw_set_alpha(min(1, _alpha + 0.25));
    draw_line_width(_x - _radius * 0.62, _y - _radius * 0.08, _x - _radius * 0.18, _y + _radius * 0.04, 2);
    draw_line_width(_x - _radius * 0.18, _y + _radius * 0.04, _x + _radius * 0.19, _y - _radius * 0.19, 2);
    draw_line_width(_x + _radius * 0.19, _y - _radius * 0.19, _x + _radius * 0.58, _y - _radius * 0.08, 2);

    if (_stage >= 1)
    {
        draw_line_width(_x - _radius * 0.18, _y + _radius * 0.04, _x - _radius * 0.39, _y + _radius * 0.39, 2);
        draw_line_width(_x + _radius * 0.19, _y - _radius * 0.19, _x + _radius * 0.36, _y - _radius * 0.51, 2);
    }

    if (_stage >= 2)
    {
        draw_line_width(_x - _radius * 0.39, _y + _radius * 0.39, _x - _radius * 0.63, _y + _radius * 0.57, 2);
        draw_line_width(_x + _radius * 0.02, _y - _radius * 0.08, _x + _radius * 0.31, _y + _radius * 0.31, 2);
    }

    if (_stage >= 3)
    {
        draw_set_alpha(0.22);
        draw_circle(_x, _y, _radius * 0.54, false);

        draw_set_alpha(0.9);
        draw_line_width(_x + _radius * 0.31, _y + _radius * 0.31, _x + _radius * 0.59, _y + _radius * 0.55, 3);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one complete asteroid for startup baking.
function sc_asteroid_primitive_draw(_x, _y, _radius, _variant, _stage, _palette)
{
    var _points = sc_asteroid_shape_points(_variant);

    draw_set_alpha(1);
    sc_asteroid_polygon_draw(_x, _y, _radius, _points, _palette.dark, _palette.light);

    draw_set_colour(_palette.mid);
    draw_set_alpha(0.62);
    draw_circle(_x - _radius * 0.05, _y - _radius * 0.05, _radius * 0.62, false);

    draw_set_alpha(1);
    sc_asteroid_craters_draw(_x, _y, _radius, _variant, _palette);
    sc_asteroid_damage_draw(_x, _y, _radius, _stage, _palette);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}