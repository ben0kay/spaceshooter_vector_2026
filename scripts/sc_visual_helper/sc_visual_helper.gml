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

/// @description Draws one upgradeable frontal elliptical shield arc.
function sc_visual_shield_focus_draw(
    _x,
    _y,
    _angle,
    _collision,
    _arc,
    _palette,
    _charge_ratio,
    _hit_alpha,
    _draw_alpha,
    _config
)
{
    var _half_arc = clamp(_arc * 0.5, 1, 179);
    var _forward = _collision.radius_forward
        * _config.radius_forward_scale;

    var _side = _collision.radius_side
        * _config.radius_side_scale;

    var _pulse = 1
        + sin(GAME_TICK * _config.pulse_speed)
        * _config.pulse_amount;

    var _alpha = clamp(
        _config.arc_alpha
        * lerp(0.45, 1, _charge_ratio)
        * _pulse,
        0,
        1
    ) * _draw_alpha;

    gpu_set_blendmode(bm_add);

    // Soft layered arcs create the concentrated forward field.
    for (var _layer = _config.arc_layers - 1;
    _layer >= 0;
    --_layer)
    {
        var _layer_forward = _forward
            + _layer * _config.arc_spacing;

        var _layer_side = _side
            + _layer * _config.arc_spacing;

        var _layer_alpha = _alpha
            / (_layer + 1);

        var _previous_x = 0;
        var _previous_y = 0;

        for (var _i = 0;
        _i <= _config.arc_segments;
        ++_i)
        {
            var _progress = _i
                / _config.arc_segments;

            var _local_angle = lerp(
                -_half_arc,
                _half_arc,
                _progress
            );

            var _local_forward =
                dcos(_local_angle)
                * _layer_forward;

            var _local_side =
                dsin(_local_angle)
                * _layer_side;

            var _point_x = _x
                + lengthdir_x(
                    _local_forward,
                    _angle
                )
                + lengthdir_x(
                    _local_side,
                    _angle + 90
                );

            var _point_y = _y
                + lengthdir_y(
                    _local_forward,
                    _angle
                )
                + lengthdir_y(
                    _local_side,
                    _angle + 90
                );

            if (_i > 0)
            {
                draw_set_alpha(_layer_alpha);
                draw_set_colour(
                    _layer == 0
                        ? _palette.core
                        : _palette.energy
                );

                draw_line_width(
                    _previous_x,
                    _previous_y,
                    _point_x,
                    _point_y,
                    _config.arc_thickness
                );
            }

            _previous_x = _point_x;
            _previous_y = _point_y;
        }
    }

    // Draw the two edge projectors toward the arc endpoints.
    for (var _edge = -1;
    _edge <= 1;
    _edge += 2)
    {
        var _edge_angle = _half_arc * _edge;

        var _edge_forward =
            dcos(_edge_angle)
            * _forward;

        var _edge_side =
            dsin(_edge_angle)
            * _side;

        var _edge_x = _x
            + lengthdir_x(_edge_forward, _angle)
            + lengthdir_x(_edge_side, _angle + 90);

        var _edge_y = _y
            + lengthdir_y(_edge_forward, _angle)
            + lengthdir_y(_edge_side, _angle + 90);

        var _projector_x = _x
            + lengthdir_x(
                _collision.radius_forward * 0.84,
                _angle
            )
            + lengthdir_x(
                _collision.radius_side * 0.38 * _edge,
                _angle + 90
            );

        var _projector_y = _y
            + lengthdir_y(
                _collision.radius_forward * 0.84,
                _angle
            )
            + lengthdir_y(
                _collision.radius_side * 0.38 * _edge,
                _angle + 90
            );

        draw_set_alpha(
            _config.endpoint_alpha
            * _draw_alpha
        );

        draw_set_colour(_palette.energy);

        draw_line_width(
            _projector_x,
            _projector_y,
            _edge_x,
            _edge_y,
            1
        );

        draw_set_colour(_palette.core);

        draw_circle(
            _edge_x,
            _edge_y,
            2.5,
            false
        );
    }

    // A frontal glow makes the protected region feel denser.
    var _nose_x = _x
        + lengthdir_x(_forward, _angle);

    var _nose_y = _y
        + lengthdir_y(_forward, _angle);

    draw_set_alpha(
        (
            _config.field_alpha
            + _hit_alpha * 0.35
        ) * _draw_alpha
    );

    draw_set_colour(_palette.glow);

    draw_circle(
        _nose_x,
        _nose_y,
        max(8, _collision.radius_side * 0.42),
        false
    );

    draw_set_alpha(
        (
            _config.inner_alpha
            + _hit_alpha * 0.6
        ) * _draw_alpha
    );

    draw_set_colour(_palette.core);

    draw_circle(
        _nose_x,
        _nose_y,
        max(3, _collision.radius_side * 0.13),
        false
    );

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}