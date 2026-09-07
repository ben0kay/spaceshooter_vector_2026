/// @description Draws one reusable expanding pulse made from rotating arcs.
function sc_visual_effect_arc_pulse(_x, _y, _config, _progress, _palette, _angle = 0)
{
    _progress = clamp(_progress, 0, 1);

    var _radius = lerp(
        _config.radius_min,
        _config.radius_max,
        _progress
    );

    var _alpha = sin(_progress * pi) * _config.alpha;
    var _rotation = _angle
        + GAME_TICK * _config.rotation_speed;

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _config.arc_amount; _i++)
    {
        var _start = _rotation
            + (_i / _config.arc_amount) * 360;

        sc_visual_arc(
            _x,
            _y,
            _radius,
            _radius,
            _start,
            _start + _config.arc_length,
            _config.segments,
            _config.thickness,
            _palette.energy,
            _alpha
        );

        sc_visual_arc(
            _x,
            _y,
            _radius - _config.inner_offset,
            _radius - _config.inner_offset,
            _start + _config.inner_angle_offset,
            _start + _config.inner_angle_offset
                + _config.arc_length * 0.72,
            _config.segments,
            max(1, _config.thickness * 0.5),
            _palette.core,
            _alpha * 0.55
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws staggered signal arcs travelling toward one target.
function sc_visual_effect_signal_arcs(_x, _y, _target_x, _target_y, _config, _progress, _palette)
{
    _progress = clamp(_progress, 0, 1);

    var _direction = point_direction(_x, _y, _target_x, _target_y);
    var _distance = point_distance(_x, _y, _target_x, _target_y);
    var _launch_total = (_config.arc_amount - 1) * _config.launch_spacing;
    var _travel_duration = max(0.01, 1 - _launch_total);

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _config.arc_amount; ++_i)
    {
        var _local = clamp(
            (_progress - _i * _config.launch_spacing)
            / _travel_duration,
            0,
            1
        );

        if (_local <= 0 || _local >= 1)
            continue;

        var _travel = lerp(_config.start_distance, _distance, _local);
        var _arc_radius = lerp(_config.radius_min, _config.radius_max, _local);
        var _arc_x = _x + lengthdir_x(_travel, _direction);
        var _arc_y = _y + lengthdir_y(_travel, _direction);
        var _alpha = sin(_local * pi) * _config.alpha;
        var _half_angle = _config.arc_angle * 0.5;

        sc_visual_arc(
            _arc_x,
            _arc_y,
            _arc_radius,
            _arc_radius,
            _direction - _half_angle,
            _direction + _half_angle,
            _config.segments,
            _config.thickness + 3,
            _palette.glow,
            _alpha * 0.35
        );

        sc_visual_arc(
            _arc_x,
            _arc_y,
            _arc_radius,
            _arc_radius,
            _direction - _half_angle,
            _direction + _half_angle,
            _config.segments,
            _config.thickness,
            _palette.energy,
            _alpha
        );

        sc_visual_arc(
            _arc_x,
            _arc_y,
            _arc_radius - 3,
            _arc_radius - 3,
            _direction - _half_angle * 0.78,
            _direction + _half_angle * 0.78,
            _config.segments,
            1,
            _palette.core,
            _alpha * 0.75
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}