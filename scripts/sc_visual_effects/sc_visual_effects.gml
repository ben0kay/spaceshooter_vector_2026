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