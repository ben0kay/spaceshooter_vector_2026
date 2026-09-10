/// @description Generates and bakes one richly coloured nebula sprite.
function sc_space_nebula_sprite_create(_visual)
{
    var _size = _visual.canvas_size;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _blur_width = max(1, sprite_get_width(s_blur));
    var _blur_height = max(1, sprite_get_height(s_blur));
    var _seed = _visual.seed;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    // Broad dark masses give the nebula body and an irregular silhouette.
    for (var _i = 0; _i < _visual.body_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 17.31) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 43.73),
            1.45
        ) * _size * 0.39;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);
        var _diameter = lerp(
            _size * 0.13,
            _size * 0.39,
            sc_space_hash(_seed + _i * 67.91)
        );

        var _stretch = lerp(
            0.75,
            2.25,
            sc_space_hash(_seed + _i * 89.17)
        );

        var _mix = sc_space_hash(_seed + _i * 127.53);
        var _colour = merge_colour(
            _visual.colour_dark,
            _visual.colour_primary,
            _mix
        );

        draw_sprite_ext(
            s_blur,
            0,
            _x,
            _y,
            (_diameter / _blur_width) * _stretch,
            (_diameter / _blur_height) / _stretch,
            sc_space_hash(_seed + _i * 101.39) * 360,
            _colour,
            lerp(
                0.1,
                0.25,
                sc_space_hash(_seed + _i * 149.21)
            )
        );
    }

    // Curved chains form the long wispy structures.
    for (var _arm = 0; _arm < _visual.wisp_arms; ++_arm)
    {
        var _arm_seed = _seed + _arm * 311.73;
        var _base_angle = sc_space_hash(_arm_seed) * 360;
        var _curve = lerp(
            -95,
            95,
            sc_space_hash(_arm_seed + 19.17)
        );

        var _length = lerp(
            _size * 0.24,
            _size * 0.44,
            sc_space_hash(_arm_seed + 41.83)
        );

        for (var _point = 0; _point < _visual.wisp_points; ++_point)
        {
            var _progress = _point / max(1, _visual.wisp_points - 1);
            var _angle = _base_angle + _curve * _progress;
            var _distance = _length * _progress;

            var _bend = dsin(
                _progress * 180
                + sc_space_hash(_arm_seed + 73.11) * 180
            ) * _size * 0.055;

            var _x = _centre
                + lengthdir_x(_distance, _angle)
                + lengthdir_x(_bend, _angle + 90);

            var _y = _centre
                + lengthdir_y(_distance * 0.7, _angle)
                + lengthdir_y(_bend * 0.7, _angle + 90);

            var _diameter = lerp(
                _size * 0.12,
                _size * 0.035,
                _progress
            );

            var _colour_mix = sc_space_hash(
                _arm_seed + _point * 59.47
            );

            var _colour = merge_colour(
                _visual.colour_primary,
                _visual.colour_secondary,
                _colour_mix
            );

            draw_sprite_ext(
                s_blur,
                0,
                _x,
                _y,
                (_diameter / _blur_width) * 2.8,
                (_diameter / _blur_height) * 0.72,
                _angle,
                _colour,
                lerp(0.045, 0.14, 1 - _progress)
            );
        }
    }

    // Additive coloured knots create luminous ionized regions.
    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.glow_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 173.11) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 191.37),
            1.8
        ) * _size * 0.3;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.68, _direction);
        var _diameter = lerp(
            _size * 0.025,
            _size * 0.11,
            sc_space_hash(_seed + _i * 211.63)
        );

        var _stretch = lerp(
            1.2,
            3.8,
            sc_space_hash(_seed + _i * 229.87)
        );

        var _colour = merge_colour(
            _visual.colour_secondary,
            _visual.colour_highlight,
            sc_space_hash(_seed + _i * 239.29)
        );

        draw_sprite_ext(
            s_blur,
            0,
            _x,
            _y,
            (_diameter / _blur_width) * _stretch,
            (_diameter / _blur_height) / _stretch,
            sc_space_hash(_seed + _i * 251.43) * 360,
            _colour,
            lerp(
                0.08,
                0.22,
                sc_space_hash(_seed + _i * 269.71)
            )
        );
    }

    // A few compact bright areas provide visual focal points.
    for (var _i = 0; _i < _visual.core_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 283.19) * 360;
        var _distance = sc_space_hash(
            _seed + _i * 307.53
        ) * _size * 0.22;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.65, _direction);
        var _diameter = lerp(
            _size * 0.018,
            _size * 0.05,
            sc_space_hash(_seed + _i * 331.71)
        );

        draw_sprite_ext(
            s_blur,
            0,
            _x,
            _y,
            _diameter / _blur_width,
            _diameter / _blur_height,
            0,
            _visual.colour_core,
            0.4
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0,
        0,
        _size,
        _size,
        false,
        false,
        _centre,
        _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Draws one visible baked background nebula.
function sc_space_nebula_draw(
    _nebula,
    _camera_x,
    _camera_y,
    _view_w,
    _view_h
)
{
    var _padding = max(_nebula.radius_x, _nebula.radius_y) * 1.15;

    if (_nebula.x + _padding < _camera_x
    || _nebula.x - _padding > _camera_x + _view_w
    || _nebula.y + _padding < _camera_y
    || _nebula.y - _padding > _camera_y + _view_h)
        return;

    var _scale_x = (_nebula.radius_x * 2) / _nebula.canvas_size;
    var _scale_y = (_nebula.radius_y * 2) / _nebula.canvas_size;
    var _time = current_time * 0.000004;

    // Broad foundation.
    draw_sprite_ext(
        _nebula.sprite,
        0,
        _nebula.x,
        _nebula.y,
        _scale_x,
        _scale_y,
        _nebula.angle,
        c_white,
        _nebula.alpha * 0.72
    );

    // Slightly offset layer gives the cloud additional internal depth.
    draw_sprite_ext(
        _nebula.sprite,
        0,
        _nebula.x + dcos(_nebula.phase + _time) * _nebula.radius_x * 0.018,
        _nebula.y + dsin(_nebula.phase + _time) * _nebula.radius_y * 0.018,
        _scale_x * 0.84,
        _scale_y * 0.9,
        _nebula.angle + 37,
        c_white,
        _nebula.alpha * 0.24
    );

    // Small counter-rotated interior breaks up obvious repetition.
    draw_sprite_ext(
        _nebula.sprite,
        0,
        _nebula.x - dcos(_nebula.phase + _time) * _nebula.radius_x * 0.012,
        _nebula.y - dsin(_nebula.phase + _time) * _nebula.radius_y * 0.012,
        _scale_x * 0.68,
        _scale_y * 0.72,
        _nebula.angle - 53,
        c_white,
        _nebula.alpha * 0.16
    );
}