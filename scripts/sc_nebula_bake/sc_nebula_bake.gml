/// @description Draws one source sprite at an exact size during nebula baking.
function sc_space_nebula_source_draw(_sprite, _x, _y, _width, _height, _angle, _colour, _alpha)
{
    draw_sprite_ext(
        _sprite, 0,
        _x, _y,
        _width / max(1, sprite_get_width(_sprite)),
        _height / max(1, sprite_get_height(_sprite)),
        _angle,
        _colour,
        _alpha
    );
}

/// @description Bakes a smooth high-resolution foundation for one nebula patch.
function sc_space_nebula_body_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _i = 0; _i < ceil(_visual.body_amount * 0.4); ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 17.31) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 43.73),
            1.55
        );

        var _x = _centre + lengthdir_x(
            _distance * _size * _visual.body_spread_x,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance * _size * _visual.body_spread_y,
            _direction
        );

        var _diameter = lerp(
            _size * _visual.body_size_min,
            _size * _visual.body_size_max,
            sc_space_hash(_seed + _i * 67.91)
        );

        var _stretch = lerp(
            _visual.body_stretch_min,
            _visual.body_stretch_max,
            sc_space_hash(_seed + _i * 89.17)
        );

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / _stretch,
            sc_space_hash(_seed + _i * 101.39) * 360,
            merge_colour(
                _visual.colour_dark,
                _visual.colour_primary,
                sc_space_hash(_seed + _i * 127.53)
            ),
            lerp(
                _visual.body_alpha_min,
                _visual.body_alpha_max,
                sc_space_hash(_seed + _i * 149.21)
            )
        );
    }
}

/// @description Bakes irregular cloud pieces around the nebula foundation.
function sc_space_nebula_clouds_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _i = 0; _i < _visual.body_amount; ++_i)
    {
        var _sprite = sc_space_hash(_seed + _i * 163.91) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        var _direction = sc_space_hash(_seed + _i * 181.37) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 199.73),
            1.25
        );

        var _x = _centre + lengthdir_x(
            _distance * _size * _visual.body_spread_x,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance * _size * _visual.body_spread_y,
            _direction
        );

        var _width = lerp(
            _size * 0.1,
            _size * 0.3,
            sc_space_hash(_seed + _i * 223.11)
        );

        var _height = _width * lerp(
            0.38,
            0.72,
            sc_space_hash(_seed + _i * 241.57)
        );

        var _colour = merge_colour(
            _visual.colour_dark,
            _visual.colour_secondary,
            sc_space_hash(_seed + _i * 263.17)
        );

        sc_space_nebula_source_draw(
            _sprite,
            _x,
            _y,
            _width,
            _height,
            sc_space_hash(_seed + _i * 281.49) * 360,
            _colour,
            lerp(
                _visual.body_alpha_min * 0.65,
                _visual.body_alpha_max * 0.85,
                sc_space_hash(_seed + _i * 307.83)
            )
        );
    }
}

/// @description Bakes soft curved smoky arms through a nebula patch.
function sc_space_nebula_arms_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _arm = 0; _arm < _visual.arm_amount; ++_arm)
    {
        var _arm_seed = _seed + _arm * 311.73;
        var _base_angle = sc_space_hash(_arm_seed) * 360;

        var _curve = lerp(
            _visual.arm_curve_min,
            _visual.arm_curve_max,
            sc_space_hash(_arm_seed + 19.17)
        );

        var _length = lerp(
            _size * _visual.arm_length_min,
            _size * _visual.arm_length_max,
            sc_space_hash(_arm_seed + 41.83)
        );

        for (var _point = 0; _point < _visual.arm_points; ++_point)
        {
            var _progress = _point / max(1, _visual.arm_points - 1);
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
                + lengthdir_y(_distance * 0.72, _angle)
                + lengthdir_y(_bend * 0.72, _angle + 90);

            var _width = lerp(
                _size * 0.15,
                _size * 0.045,
                _progress
            );

            var _height = _width * lerp(
                0.3,
                0.52,
                sc_space_hash(_arm_seed + _point * 47.13)
            );

            sc_space_nebula_source_draw(
                s_particle_smokey_wisp_001,
                _x,
                _y,
                _width,
                _height,
                _angle,
                merge_colour(
                    _visual.colour_primary,
                    _visual.colour_secondary,
                    sc_space_hash(_arm_seed + _point * 59.47)
                ),
                lerp(0.025, 0.105, 1 - _progress)
            );
        }
    }
}

/// @description Bakes brighter crescent wisps into sweeping nebula ribbons.
function sc_space_nebula_wisps_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.wisp_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 331.31) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 353.47),
            1.35
        ) * _size * _visual.wisp_distance;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);

        var _width = lerp(
            _size * _visual.wisp_width_min,
            _size * _visual.wisp_width_max,
            sc_space_hash(_seed + _i * 379.63)
        );

        var _height = lerp(
            _size * _visual.wisp_height_min,
            _size * _visual.wisp_height_max,
            sc_space_hash(_seed + _i * 397.87)
        );

        sc_space_nebula_source_draw(
            s_particle_wisp_001,
            _x,
            _y,
            _width,
            _height,
            _direction + 90 + lerp(
                -35,
                35,
                sc_space_hash(_seed + _i * 419.29)
            ),
            merge_colour(
                _visual.colour_primary,
                _visual.colour_highlight,
                sc_space_hash(_seed + _i * 443.71)
            ),
            lerp(
                _visual.wisp_alpha_min,
                _visual.wisp_alpha_max,
                sc_space_hash(_seed + _i * 467.37)
            )
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Bakes luminous cloud cover beneath bright energy streaks.
function sc_space_nebula_streak_cloud_bake(_visual, _x, _y, _diameter, _seed)
{
    var _cloud = sc_space_hash(_seed + 13.71) < 0.5
        ? s_particle_cloud_002
        : s_particle_cloud_003;

    var _width = _diameter * lerp(
        1.7,
        2.8,
        sc_space_hash(_seed + 29.53)
    );

    var _height = _width * lerp(
        0.42,
        0.72,
        sc_space_hash(_seed + 47.19)
    );

    sc_space_nebula_source_draw(
        _cloud,
        _x,
        _y,
        _width,
        _height,
        sc_space_hash(_seed + 61.37) * 360,
        merge_colour(
            _visual.colour_primary,
            _visual.colour_secondary,
            0.55
        ),
        0.15
    );

    sc_space_nebula_source_draw(
        s_particle_blur_1024,
        _x,
        _y,
        _diameter * 2.1,
        _diameter * 1.4,
        0,
        _visual.colour_highlight,
        0.1
    );
}

/// @description Bakes imported lightning and energetic cloud accents.
function sc_space_nebula_streaks_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _sprites = _visual.streak_sprites;
    var _sprite_amount = array_length(_sprites);

    if (_sprite_amount <= 0 || _visual.streak_amount <= 0)
        return;

    for (var _i = 0; _i < _visual.streak_amount; ++_i)
    {
        var _sprite_index = clamp(
            floor(
                sc_space_hash(_seed + _i * 487.19)
                * _sprite_amount
            ),
            0,
            _sprite_amount - 1
        );

        var _sprite = _sprites[_sprite_index];
        var _direction = sc_space_hash(_seed + _i * 509.53) * 360;

        var _distance = power(
            sc_space_hash(_seed + _i * 541.71),
            1.65
        ) * _size * _visual.streak_distance;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);

        var _diameter = lerp(
            _size * _visual.streak_size_min,
            _size * _visual.streak_size_max,
            sc_space_hash(_seed + _i * 563.17)
        );

        var _stretch = lerp(
            _visual.streak_stretch_min,
            _visual.streak_stretch_max,
            sc_space_hash(_seed + _i * 587.61)
        );

        var _angle = _visual.streak_angle_bias + lerp(
            -_visual.streak_angle_spread,
            _visual.streak_angle_spread,
            sc_space_hash(_seed + _i * 611.43)
        );

        sc_space_nebula_streak_cloud_bake(
            _visual,
            _x,
            _y,
            _diameter,
            _seed + _i * 631.77
        );

        gpu_set_blendmode(bm_add);

        sc_space_nebula_source_draw(
            _sprite,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / _stretch,
            _angle,
            merge_colour(
                _visual.colour_secondary,
                _visual.colour_core,
                sc_space_hash(_seed + _i * 653.29)
            ),
            lerp(
                _visual.streak_alpha_min,
                _visual.streak_alpha_max,
                sc_space_hash(_seed + _i * 677.71)
            )
        );

        gpu_set_blendmode(bm_normal);
    }
}

/// @description Bakes rare major branching lightning structures.
function sc_space_nebula_major_streaks_bake(_visual, _centre)
{
    if (_visual.major_streak_sprite == -1
    || _visual.major_streak_amount <= 0)
        return;

    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _i = 0; _i < _visual.major_streak_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 691.53) * 360;
        var _distance = sc_space_hash(
            _seed + _i * 719.91
        ) * _size * 0.16;

        var _diameter = lerp(
            _size * _visual.major_streak_size_min,
            _size * _visual.major_streak_size_max,
            sc_space_hash(_seed + _i * 743.37)
        );

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);

        sc_space_nebula_streak_cloud_bake(
            _visual,
            _x,
            _y,
            _diameter,
            _seed + _i * 761.13
        );

        gpu_set_blendmode(bm_add);

        sc_space_nebula_source_draw(
            _visual.major_streak_sprite,
            _x,
            _y,
            _diameter,
            _diameter,
            sc_space_hash(_seed + _i * 787.19) * 360,
            _visual.colour_highlight,
            _visual.major_streak_alpha
        );

        gpu_set_blendmode(bm_normal);
    }
}

/// @description Bakes compact coloured glows inside one nebula patch.
function sc_space_nebula_glows_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.glow_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 811.11) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 839.37),
            1.8
        ) * _size * 0.3;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.68, _direction);

        var _diameter = lerp(
            _size * 0.025,
            _size * 0.11,
            sc_space_hash(_seed + _i * 863.63)
        );

        var _stretch = lerp(
            1.2,
            3.2,
            sc_space_hash(_seed + _i * 887.87)
        );

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / _stretch,
            sc_space_hash(_seed + _i * 911.43) * 360,
            merge_colour(
                _visual.colour_secondary,
                _visual.colour_highlight,
                sc_space_hash(_seed + _i * 937.29)
            ),
            lerp(
                0.06,
                0.18,
                sc_space_hash(_seed + _i * 953.71)
            )
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Generates and bakes one detailed nebula patch sprite.
function sc_space_nebula_sprite_create(_visual)
{
    var _size = _visual.canvas_size;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    sc_space_nebula_body_bake(_visual, _centre);
    sc_space_nebula_clouds_bake(_visual, _centre);
    sc_space_nebula_arms_bake(_visual, _centre);
    sc_space_nebula_wisps_bake(_visual, _centre);
    sc_space_nebula_glows_bake(_visual, _centre);
    sc_space_nebula_streaks_bake(_visual, _centre);
    sc_space_nebula_major_streaks_bake(_visual, _centre);

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