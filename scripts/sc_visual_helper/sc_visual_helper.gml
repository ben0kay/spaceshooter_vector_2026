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
    draw_circle(sc_visual_x(_x, _radius, _angle, _forward, _side), sc_visual_y(_y, _radius, _angle, _forward, _side), _radius * _scale, _outline);
}

/// @description Draws one reusable segmented elliptical arc.
function sc_visual_arc(_x, _y, _radius_x, _radius_y, _angle_start, _angle_end, _segments, _width, _colour, _alpha)
{
    if (_angle_end <= _angle_start) _angle_end += 360;

    var _step = (_angle_end - _angle_start) / _segments;
    var _previous_x = _x + lengthdir_x(_radius_x, _angle_start);
    var _previous_y = _y + lengthdir_y(_radius_y, _angle_start);

    draw_set_colour(_colour);
    draw_set_alpha(_alpha);

    for (var _i = 1; _i <= _segments; _i++)
    {
        var _direction = _angle_start + _step * _i;
        var _current_x = _x + lengthdir_x(_radius_x, _direction);
        var _current_y = _y + lengthdir_y(_radius_y, _direction);
        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width);
        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one filled rotated ellipse with centre and edge colours.
function sc_visual_ellipse_colour(_x, _y, _radius_forward, _radius_side, _angle, _centre_colour, _edge_colour, _alpha)
{
    var _segments = 48;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_x, _y, _centre_colour, _alpha);

    for (var _i = 0; _i <= _segments; _i++)
    {
        var _direction = (_i / _segments) * 360;
        var _cos = dcos(_direction);
        var _sin = dsin(_direction);

        var _point_x = _x
            + lengthdir_x(_radius_forward * _cos, _angle)
            + lengthdir_x(_radius_side * _sin, _angle + 90);

        var _point_y = _y
            + lengthdir_y(_radius_forward * _cos, _angle)
            + lengthdir_y(_radius_side * _sin, _angle + 90);

        draw_vertex_colour(_point_x, _point_y, _edge_colour, _alpha);
    }

    draw_primitive_end();
}

/// @description Draws one rotated elliptical outline.
function sc_visual_ellipse_outline(_x, _y, _radius_forward, _radius_side, _angle, _segments, _width, _colour, _alpha)
{
    draw_set_colour(_colour);
    draw_set_alpha(_alpha);

    var _previous_x = _x + lengthdir_x(_radius_forward, _angle);
    var _previous_y = _y + lengthdir_y(_radius_forward, _angle);

    for (var _i = 1; _i <= _segments; _i++)
    {
        var _direction = (_i / _segments) * 360;
        var _cos = dcos(_direction);
        var _sin = dsin(_direction);

        var _current_x = _x
            + lengthdir_x(_radius_forward * _cos, _angle)
            + lengthdir_x(_radius_side * _sin, _angle + 90);

        var _current_y = _y
            + lengthdir_y(_radius_forward * _cos, _angle)
            + lengthdir_y(_radius_side * _sin, _angle + 90);

        draw_line_width(_previous_x, _previous_y, _current_x, _current_y, _width);
        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the shared baked elliptical shield using collision proportions.
function sc_visual_shield_bake_draw(_x, _y, _radius_forward, _radius_side, _palette)
{
    var _config = global.config.visual.shield;
    var _forward = _radius_forward * _config.radius_scale;
    var _side = _radius_side * _config.radius_scale;
    var _field_centre = merge_colour(_palette.void, _palette.glow, _config.field_centre_mix);
    var _field_edge = merge_colour(_palette.glow, _palette.energy, _config.field_edge_mix);

    sc_visual_ellipse_colour(_x, _y, _forward, _side, 0, _field_centre, _field_edge, _config.field_alpha);
    sc_visual_ellipse_colour(_x, _y, _forward * _config.inner_scale, _side * _config.inner_scale, 0, _palette.glow, _palette.energy, _config.inner_alpha);

    for (var _i = 0; _i < _config.glow_layers; _i++)
    {
        var _alpha = max(0, _config.glow_alpha - _i * _config.glow_alpha_falloff);
        sc_visual_ellipse_outline(_x, _y, _forward + _i * _config.glow_spacing, _side + _i * _config.glow_spacing, 0, 48, 1, _palette.glow, _alpha);
    }

    sc_visual_ellipse_outline(_x, _y, _forward, _side, 0, 48, 2, _palette.energy, _config.outline_alpha);
    sc_visual_ellipse_outline(_x, _y, _forward - _config.inner_outline_offset, _side - _config.inner_outline_offset, 0, 48, 1, _palette.core, _config.inner_outline_alpha);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one cached shield sprite using shared runtime tuning.
function sc_visual_shield_sprite_draw(_sprite, _x, _y, _angle, _palette, _charge_ratio, _hit_alpha, _draw_alpha)
{
    var _config = global.config.visual.shield;
    var _pulse = _config.idle_pulse_base + sin(GAME_TICK * _config.idle_pulse_speed) * _config.idle_pulse_amount;
    var _alpha = clamp(_config.runtime_alpha_base + _charge_ratio * _config.runtime_alpha_charge * _pulse, 0, _config.runtime_alpha_max);
    var _scale = 1 + sin(GAME_TICK * _config.idle_scale_speed) * _config.idle_scale_amount;

    draw_sprite_ext(_sprite, 0, _x, _y, _scale, _scale, _angle, c_white, _alpha * _draw_alpha);

    if (_hit_alpha > 0.01)
    {
        var _hit_scale = _scale + _hit_alpha * _config.hit_scale_amount;

        gpu_set_blendmode(bm_add);
        draw_sprite_ext(_sprite, 0, _x, _y, _hit_scale, _hit_scale, _angle, _palette.energy, _hit_alpha * _config.hit_flash_alpha * _draw_alpha);
        gpu_set_blendmode(bm_normal);
    }
}

/// @description Draws one close broad crescent shield with moving energy streaks.
function sc_visual_shield_focus_draw(_x, _y, _angle, _collision, _arc, _palette, _charge_ratio, _hit_alpha, _draw_alpha, _config)
{
    var _half = clamp(_arc * 0.5, 1, 175);
    var _forward = _collision.radius_forward * _config.radius_forward_scale;
    var _side = _collision.radius_side * _config.radius_side_scale;
    var _offset = _collision.radius_forward * _config.offset_forward_scale;
    var _pulse = 1 + sin(GAME_TICK * _config.pulse_speed) * _config.pulse_amount;
    var _field_alpha = clamp(_config.field_alpha * lerp(0.5, 1, _charge_ratio) * _pulse + _hit_alpha * 0.18, 0, 0.72) * _draw_alpha;
    var _edge_alpha = clamp(_config.edge_alpha * lerp(0.65, 1, _charge_ratio) * _pulse + _hit_alpha * 0.45, 0, 1) * _draw_alpha;

    // Animated horizontal energy streaks travelling out from the rim.
    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _config.streak_amount; ++_i)
    {
        var _amount = _i / max(1, _config.streak_amount - 1);
        var _local_angle = lerp(-_half * 0.92, _half * 0.92, _amount);
        var _phase = frac(GAME_TICK * _config.streak_speed + _i * 0.317);
        var _local_forward = _offset + dcos(_local_angle) * _forward;
        var _local_side = dsin(_local_angle) * _side;
        var _travel = _phase * _config.streak_travel;
        var _length = lerp(_config.streak_length_min, _config.streak_length_max, 0.5 + sin(_i * 2.17) * 0.5);
        var _alpha = sin(_phase * pi) * _config.streak_alpha * _draw_alpha;

        var _rim_x = _x + lengthdir_x(_local_forward, _angle) + lengthdir_x(_local_side, _angle + 90);
        var _rim_y = _y + lengthdir_y(_local_forward, _angle) + lengthdir_y(_local_side, _angle + 90);
        var _start_x = _rim_x + lengthdir_x(_travel, _angle);
        var _start_y = _rim_y + lengthdir_y(_travel, _angle);

        draw_set_alpha(_alpha * 0.35);
        draw_set_colour(_palette.glow);
        draw_line_width(_start_x, _start_y, _start_x + lengthdir_x(_length + 5, _angle), _start_y + lengthdir_y(_length + 5, _angle), _config.streak_width + 2);

        draw_set_alpha(_alpha);
        draw_set_colour(_i mod 3 == 0 ? _palette.core : _palette.energy);
        draw_line_width(_start_x, _start_y, _start_x + lengthdir_x(_length, _angle), _start_y + lengthdir_y(_length, _angle), _config.streak_width);
    }

    // Transparent energy between the outer and inner crescent curves.
    gpu_set_blendmode(bm_normal);
    draw_primitive_begin(pr_trianglestrip);

    for (var _i = 0; _i <= _config.arc_segments; ++_i)
    {
        var _progress = _i / _config.arc_segments;
        var _local_angle = lerp(-_half, _half, _progress);
        var _thickness = power(sin(_progress * pi), 0.7) * _forward * _config.crescent_depth;
        var _outer_forward = _offset + dcos(_local_angle) * _forward;
        var _outer_side = dsin(_local_angle) * _side;
        var _inner_forward = _outer_forward - _thickness;

        var _outer_x = _x + lengthdir_x(_outer_forward, _angle) + lengthdir_x(_outer_side, _angle + 90);
        var _outer_y = _y + lengthdir_y(_outer_forward, _angle) + lengthdir_y(_outer_side, _angle + 90);
        var _inner_x = _x + lengthdir_x(_inner_forward, _angle) + lengthdir_x(_outer_side, _angle + 90);
        var _inner_y = _y + lengthdir_y(_inner_forward, _angle) + lengthdir_y(_outer_side, _angle + 90);

        draw_vertex_colour(_outer_x, _outer_y, _palette.energy, _field_alpha);
        draw_vertex_colour(_inner_x, _inner_y, _palette.glow, _field_alpha * 0.42);
    }

    draw_primitive_end();
    gpu_set_blendmode(bm_add);

    // Wide outer glow.
    var _previous_x = 0, _previous_y = 0;

    for (var _i = 0; _i <= _config.arc_segments; ++_i)
    {
        var _progress = _i / _config.arc_segments;
        var _local_angle = lerp(-_half, _half, _progress);
        var _local_forward = _offset + dcos(_local_angle) * _forward;
        var _local_side = dsin(_local_angle) * _side;
        var _point_x = _x + lengthdir_x(_local_forward, _angle) + lengthdir_x(_local_side, _angle + 90);
        var _point_y = _y + lengthdir_y(_local_forward, _angle) + lengthdir_y(_local_side, _angle + 90);

        if (_i > 0)
        {
            draw_set_alpha(_config.outer_alpha * _draw_alpha);
            draw_set_colour(_palette.glow);
            draw_line_width(_previous_x, _previous_y, _point_x, _point_y, _config.outer_glow_width);
        }

        _previous_x = _point_x;
        _previous_y = _point_y;
    }

    // Sharp outer edge.
    _previous_x = 0;
    _previous_y = 0;

    for (var _i = 0; _i <= _config.arc_segments; ++_i)
    {
        var _progress = _i / _config.arc_segments;
        var _local_angle = lerp(-_half, _half, _progress);
        var _local_forward = _offset + dcos(_local_angle) * _forward;
        var _local_side = dsin(_local_angle) * _side;
        var _point_x = _x + lengthdir_x(_local_forward, _angle) + lengthdir_x(_local_side, _angle + 90);
        var _point_y = _y + lengthdir_y(_local_forward, _angle) + lengthdir_y(_local_side, _angle + 90);

        if (_i > 0)
        {
            draw_set_alpha(_edge_alpha);
            draw_set_colour(_palette.core);
            draw_line_width(_previous_x, _previous_y, _point_x, _point_y, _config.outer_width);
        }

        _previous_x = _point_x;
        _previous_y = _point_y;
    }

    // Dimmer concave inner edge.
    _previous_x = 0;
    _previous_y = 0;

    for (var _i = 0; _i <= _config.arc_segments; ++_i)
    {
        var _progress = _i / _config.arc_segments;
        var _local_angle = lerp(-_half, _half, _progress);
        var _thickness = power(sin(_progress * pi), 0.7) * _forward * _config.crescent_depth;
        var _local_forward = _offset + dcos(_local_angle) * _forward - _thickness;
        var _local_side = dsin(_local_angle) * _side;
        var _point_x = _x + lengthdir_x(_local_forward, _angle) + lengthdir_x(_local_side, _angle + 90);
        var _point_y = _y + lengthdir_y(_local_forward, _angle) + lengthdir_y(_local_side, _angle + 90);

        if (_i > 0)
        {
            draw_set_alpha(_config.inner_alpha * _draw_alpha * _pulse);
            draw_set_colour(_palette.energy);
            draw_line_width(_previous_x, _previous_y, _point_x, _point_y, _config.inner_width);
        }

        _previous_x = _point_x;
        _previous_y = _point_y;
    }

    var _nose_x = _x + lengthdir_x(_offset + _forward, _angle);
    var _nose_y = _y + lengthdir_y(_offset + _forward, _angle);

    draw_set_alpha((0.18 + _hit_alpha * 0.5) * _draw_alpha);
    draw_set_colour(_palette.energy);
    draw_circle(_nose_x, _nose_y, 8 + _hit_alpha * 5, false);

    draw_set_alpha((0.65 + _hit_alpha * 0.35) * _draw_alpha);
    draw_set_colour(_palette.core);
    draw_circle(_nose_x, _nose_y, 2.5 + _hit_alpha * 2, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}