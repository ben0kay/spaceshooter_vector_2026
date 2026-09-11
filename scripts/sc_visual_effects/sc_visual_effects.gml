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

/// @description Draws one configurable layered beam between two explicit points.
function sc_visual_beam_layered_draw(_x1, _y1, _x2, _y2, _base_width, _style, _palette, _alpha = 1, _phase = 0)
{
    var _length = point_distance(_x1, _y1, _x2, _y2);
    if (_length <= 0.01 || _alpha <= 0) return;

    var _direction = point_direction(_x1, _y1, _x2, _y2);
    var _pulse = 1
        + sin(GAME_TICK * _style.pulse_speed + _phase) * _style.pulse_amount
        + sin(GAME_TICK * _style.pulse_secondary_speed + _phase) * _style.pulse_secondary_amount;

    var _glow_colour = _palette.glow;
    var _body_colour = merge_colour(_palette.accent, _palette.energy, _style.body_colour_mix);
    var _inner_colour = merge_colour(_palette.energy, _palette.core, _style.inner_colour_mix);
    var _hot_colour = merge_colour(_palette.core, c_white, _style.hot_colour_mix);
    var _segments = max(2, ceil(_length / _style.segment_length));
    var _previous_x = _x1;
    var _previous_y = _y1;

    gpu_set_blendmode(bm_add);

    for (var _i = 1; _i <= _segments; ++_i)
    {
        var _progress = _i / _segments;
        var _distance = _length * _progress;
        var _width_scale = lerp(_style.width_start, _style.width_end, _progress);
        var _width = _base_width * _width_scale * _pulse;
        var _wobble = sin(
            GAME_TICK * _style.wobble_speed
            + _i * _style.wobble_step
            + _phase
        ) * _base_width * _style.wobble_amount * sin(_progress * pi);

        var _current_x = _x1
            + lengthdir_x(_distance, _direction)
            + lengthdir_x(_wobble, _direction + 90);

        var _current_y = _y1
            + lengthdir_y(_distance, _direction)
            + lengthdir_y(_wobble, _direction + 90);

        draw_set_alpha(_alpha * _style.glow_alpha);
        draw_set_colour(_glow_colour);
        draw_line_width(
            _previous_x, _previous_y,
            _current_x, _current_y,
            _width * _style.glow_width
        );

        draw_set_alpha(_alpha * _style.body_alpha);
        draw_set_colour(_body_colour);
        draw_line_width(
            _previous_x, _previous_y,
            _current_x, _current_y,
            _width * _style.body_width
        );

        draw_set_alpha(_alpha * _style.inner_alpha);
        draw_set_colour(_inner_colour);
        draw_line_width(
            _previous_x, _previous_y,
            _current_x, _current_y,
            max(1, _width * _style.inner_width)
        );

        draw_set_alpha(_alpha * _style.hot_alpha);
        draw_set_colour(_hot_colour);
        draw_line_width(
            _previous_x, _previous_y,
            _current_x, _current_y,
            max(1, _width * _style.hot_width)
        );

        _previous_x = _current_x;
        _previous_y = _current_y;
    }

    if (_style.band_alpha > 0)
    {
        var _spacing = max(1, _style.band_spacing);
        var _offset = (GAME_TICK * _style.band_speed + _phase) mod _spacing;
        if (_offset < 0) _offset += _spacing;

        draw_set_colour(_hot_colour);
        draw_set_alpha(_alpha * _style.band_alpha);

        for (var _distance = _offset; _distance < _length; _distance += _spacing)
        {
            var _band_end = min(_length, _distance + _style.band_length);
            var _progress = _distance / _length;
            var _width = _base_width
                * lerp(_style.width_start, _style.width_end, _progress)
                * _style.band_width;

            draw_line_width(
                _x1 + lengthdir_x(_distance, _direction),
                _y1 + lengthdir_y(_distance, _direction),
                _x1 + lengthdir_x(_band_end, _direction),
                _y1 + lengthdir_y(_band_end, _direction),
                max(1, _width)
            );
        }
    }

    if (_style.source_flare_alpha > 0)
    {
        var _source_radius = _base_width * _style.source_flare_radius * _pulse;

        draw_set_alpha(_alpha * _style.source_flare_alpha * 0.3);
        draw_set_colour(_glow_colour);
        draw_circle(_x1, _y1, _source_radius * 2.2, false);

        draw_set_alpha(_alpha * _style.source_flare_alpha);
        draw_set_colour(_inner_colour);
        draw_circle(_x1, _y1, _source_radius, false);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates one reusable baked shield-break visual.
function sc_shield_break_effect_create(_entity, _sprite, _palette)
{
    if (!sprite_exists(_sprite)) return false;

    return instance_create_layer(_entity.x, _entity.y, _entity.layer, o_shield_break_effect, {
        shield_break_create: {
            sprite: _sprite,
            angle: _entity.draw_angle,
            energy_colour: _palette.energy,
            glow_colour: _palette.glow,
            life: global.config.visual.shield.break_effect.life,
            remaining: global.config.visual.shield.break_effect.life,
            depth: _entity.depth - 1
        }
    });
}

/// @description Creates a shield-break effect only on a positive-to-zero transition.
function sc_shield_break_effect_try(_entity, _shield_before, _result, _sprite, _palette)
{
    if (_shield_before <= 0 || _result.shield > 0 || _result.dealt.shield <= 0)
        return false;

    return sc_shield_break_effect_create(_entity, _sprite, _palette);
}