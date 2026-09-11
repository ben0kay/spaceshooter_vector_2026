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

/// @description Bakes the smooth broad foundation for one nebula.
function sc_space_nebula_body_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _amount = ceil(
        _visual.body_amount * 0.58
    );

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _direction =
            sc_space_hash(
                _seed + _i * 17.31
            ) * 360;

        var _distance = power(
            sc_space_hash(
                _seed + _i * 43.73
            ),
            1.65
        );

        var _x = _centre + lengthdir_x(
            _distance
            * _size
            * _visual.body_spread_x,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance
            * _size
            * _visual.body_spread_y,
            _direction
        );

        var _diameter = lerp(
            _size * 0.2,
            _size * 0.5,
            sc_space_hash(
                _seed + _i * 67.91
            )
        );

        var _stretch = lerp(
            0.8,
            1.75,
            sc_space_hash(
                _seed + _i * 89.17
            )
        );

        var _colour_mix =
            sc_space_hash(
                _seed + _i * 127.53
            );

        var _colour = merge_colour(
            _visual.colour_primary,
            _visual.colour_secondary,
            _colour_mix
        );

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / _stretch,
            sc_space_hash(
                _seed + _i * 101.39
            ) * 360,
            _colour,
            lerp(
                0.055,
                0.14,
                sc_space_hash(
                    _seed + _i * 149.21
                )
            )
        );
    }
}

/// @description Bakes colourful textured clouds throughout the nebula.
function sc_space_nebula_clouds_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _i = 0;
    _i < _visual.body_amount;
    ++_i)
    {
        var _entry_seed = _seed
            + _i * 163.91;

        var _sprite =
            sc_space_hash(_entry_seed) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        var _direction =
            sc_space_hash(
                _entry_seed + 17.46
            ) * 360;

        var _distance = power(
            sc_space_hash(
                _entry_seed + 35.82
            ),
            1.35
        );

        var _x = _centre + lengthdir_x(
            _distance
            * _size
            * _visual.body_spread_x,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance
            * _size
            * _visual.body_spread_y,
            _direction
        );

        var _width = lerp(
            _size * 0.13,
            _size * 0.38,
            sc_space_hash(
                _entry_seed + 59.2
            )
        );

        var _height = _width * lerp(
            0.42,
            0.82,
            sc_space_hash(
                _entry_seed + 77.66
            )
        );

        var _colour_roll =
            sc_space_hash(
                _entry_seed + 99.26
            );

        var _colour;

        if (_colour_roll < 0.34)
        {
            _colour = merge_colour(
                _visual.colour_dark,
                _visual.colour_primary,
                0.72
            );
        }
        else if (_colour_roll < 0.76)
        {
            _colour = merge_colour(
                _visual.colour_primary,
                _visual.colour_secondary,
                0.62
            );
        }
        else
        {
            _colour = merge_colour(
                _visual.colour_secondary,
                _visual.colour_highlight,
                0.42
            );
        }

        sc_space_nebula_source_draw(
            _sprite,
            _x,
            _y,
            _width,
            _height,
            sc_space_hash(
                _entry_seed + 117.58
            ) * 360,
            _colour,
            lerp(
                0.055,
                0.15,
                sc_space_hash(
                    _entry_seed + 143.92
                )
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

/// @description Bakes a colourful bloom around one bright streak.
function sc_space_nebula_streak_cloud_bake(
    _visual,
    _x,
    _y,
    _diameter,
    _seed
)
{
    var _cloud =
        sc_space_hash(_seed + 13.71) < 0.5
        ? s_particle_cloud_002
        : s_particle_cloud_003;

    var _width = _diameter * lerp(
        4.2,
        7.2,
        sc_space_hash(_seed + 29.53)
    );

    var _height = _width * lerp(
        0.48,
        0.82,
        sc_space_hash(_seed + 47.19)
    );

    var _cloud_colour = merge_colour(
        _visual.colour_primary,
        _visual.colour_secondary,
        0.62
    );

    sc_space_nebula_source_draw(
        _cloud,
        _x,
        _y,
        _width,
        _height,
        sc_space_hash(_seed + 61.37) * 360,
        _cloud_colour,
        0.13
    );

    gpu_set_blendmode(bm_add);

    sc_space_nebula_source_draw(
        s_particle_blur_1024,
        _x,
        _y,
        _diameter * 4.6,
        _diameter * 3.2,
        0,
        _visual.colour_secondary,
        0.11
    );

    sc_space_nebula_source_draw(
        s_particle_blur_1024,
        _x,
        _y,
        _diameter * 2.25,
        _diameter * 1.55,
        0,
        _visual.colour_highlight,
        0.17
    );

    gpu_set_blendmode(bm_normal);
}

/// @description Bakes small bright streaks surrounded by coloured clouds.
function sc_space_nebula_streaks_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _sprites = _visual.streak_sprites;
    var _sprite_amount = array_length(_sprites);

    if (_sprite_amount <= 0
    || _visual.streak_amount <= 0)
        return;

    for (var _i = 0;
    _i < _visual.streak_amount;
    ++_i)
    {
        var _entry_seed = _seed
            + _i * 487.19;

        var _sprite_index = clamp(
            floor(
                sc_space_hash(_entry_seed)
                * _sprite_amount
            ),
            0,
            _sprite_amount - 1
        );

        var _sprite = _sprites[
            _sprite_index
        ];

        var _direction =
            sc_space_hash(
                _entry_seed + 22.34
            ) * 360;

        var _distance = power(
            sc_space_hash(
                _entry_seed + 54.52
            ),
            1.8
        )
        * _size
        * _visual.streak_distance;

        var _x = _centre + lengthdir_x(
            _distance,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance * 0.72,
            _direction
        );

        var _diameter = lerp(
            _size
                * _visual.streak_size_min,
            _size
                * _visual.streak_size_max,
            sc_space_hash(
                _entry_seed + 76.16
            )
        ) * 0.58;

        var _stretch = lerp(
            _visual.streak_stretch_min,
            _visual.streak_stretch_max,
            sc_space_hash(
                _entry_seed + 100.42
            )
        );

        var _angle =
            _visual.streak_angle_bias
            + lerp(
                -_visual.streak_angle_spread,
                _visual.streak_angle_spread,
                sc_space_hash(
                    _entry_seed + 124.24
                )
            );

        sc_space_nebula_streak_cloud_bake(
            _visual,
            _x,
            _y,
            _diameter,
            _entry_seed + 146.58
        );

        gpu_set_blendmode(bm_add);

        sc_space_nebula_source_draw(
            _sprite,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / max(1, _stretch),
            _angle,
            merge_colour(
                _visual.colour_highlight,
                _visual.colour_core,
                0.68
            ),
            clamp(
                lerp(
                    _visual.streak_alpha_min,
                    _visual.streak_alpha_max,
                    sc_space_hash(
                        _entry_seed + 168.32
                    )
                ) * 1.9,
                0,
                0.72
            )
        );

        gpu_set_blendmode(bm_normal);
    }
}

/// @description Bakes concentrated major streaks and surrounding blooms.
function sc_space_nebula_major_streaks_bake(
    _visual,
    _centre
)
{
    if (_visual.major_streak_sprite == -1
    || _visual.major_streak_amount <= 0)
        return;

    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _i = 0;
    _i < _visual.major_streak_amount;
    ++_i)
    {
        var _entry_seed = _seed
            + _i * 691.53;

        var _direction =
            sc_space_hash(_entry_seed)
            * 360;

        var _distance =
            sc_space_hash(
                _entry_seed + 28.38
            )
            * _size
            * 0.18;

        var _diameter = lerp(
            _size
                * _visual.major_streak_size_min,
            _size
                * _visual.major_streak_size_max,
            sc_space_hash(
                _entry_seed + 51.84
            )
        ) * 0.68;

        var _x = _centre + lengthdir_x(
            _distance,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance * 0.72,
            _direction
        );

        sc_space_nebula_streak_cloud_bake(
            _visual,
            _x,
            _y,
            _diameter * 0.65,
            _entry_seed + 74.76
        );

        gpu_set_blendmode(bm_add);

        sc_space_nebula_source_draw(
            _visual.major_streak_sprite,
            _x,
            _y,
            _diameter,
            _diameter,
            sc_space_hash(
                _entry_seed + 101.32
            ) * 360,
            _visual.colour_core,
            clamp(
                _visual.major_streak_alpha
                * 2.1,
                0,
                0.72
            )
        );

        gpu_set_blendmode(bm_normal);
    }
}

/// @description Bakes compact colourful glow pockets.
function sc_space_nebula_glows_bake(
    _visual,
    _centre
)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    gpu_set_blendmode(bm_add);

    for (var _i = 0;
    _i < _visual.glow_amount;
    ++_i)
    {
        var _entry_seed = _seed
            + _i * 811.11;

        var _direction =
            sc_space_hash(_entry_seed)
            * 360;

        var _distance = power(
            sc_space_hash(
                _entry_seed + 28.26
            ),
            1.9
        )
        * _size
        * 0.3;

        var _x = _centre + lengthdir_x(
            _distance,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance * 0.68,
            _direction
        );

        var _diameter = lerp(
            _size * 0.018,
            _size * 0.075,
            sc_space_hash(
                _entry_seed + 52.52
            )
        );

        var _stretch = lerp(
            1.1,
            2.5,
            sc_space_hash(
                _entry_seed + 76.76
            )
        );

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _x,
            _y,
            _diameter * _stretch,
            _diameter / _stretch,
            sc_space_hash(
                _entry_seed + 100.34
            ) * 360,
            merge_colour(
                _visual.colour_secondary,
                _visual.colour_core,
                sc_space_hash(
                    _entry_seed + 126.18
                )
            ),
            lerp(
                0.12,
                0.3,
                sc_space_hash(
                    _entry_seed + 148.62
                )
            )
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Returns the shared directional flow for one nebula.
function sc_space_nebula_flow_get(_visual)
{
    var _seed = _visual.seed;

    return {
        angle:
            sc_space_hash(
                _seed + 1201.17
            ) * 360,

        curve:
            lerp(
                -1,
                1,
                sc_space_hash(
                    _seed + 1237.53
                )
            ),

        phase:
            sc_space_hash(
                _seed + 1271.89
            ) * 360
    };
}

/// @description Returns one position along the shared curved nebula flow.
function sc_space_nebula_flow_position_get(
    _visual,
    _centre,
    _progress,
    _side
)
{
    var _size = _visual.canvas_size;
    var _flow = sc_space_nebula_flow_get(
        _visual
    );

    var _along =
        _progress
        * _size
        * 0.38;

    var _curve =
        dsin(
            _progress * 150
            + _flow.phase
        )
        * _size
        * 0.085
        * _flow.curve;

    var _side_offset =
        _side
        + _curve;

    return {
        x: _centre
            + lengthdir_x(
                _along,
                _flow.angle
            )
            + lengthdir_x(
                _side_offset,
                _flow.angle + 90
            ),

        y: _centre
            + lengthdir_y(
                _along,
                _flow.angle
            )
            + lengthdir_y(
                _side_offset,
                _flow.angle + 90
            ),

        angle: _flow.angle
    };
}

/// @description Bakes the large continuous atmospheric foundation.
function sc_space_nebula_cohesive_foundation_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _amount = 38;

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _entry_seed = _seed + _i * 43.73;
        var _progress = lerp(-1, 1, sc_space_hash(_entry_seed + 1));
        var _side = lerp(-_size * 0.13, _size * 0.13, sc_space_hash(_entry_seed + 2));

        _side *= lerp(1, 0.55, abs(_progress));

        var _position = sc_space_nebula_flow_position_get(_visual, _centre, _progress, _side);
        var _diameter = lerp(_size * 0.28, _size * 0.5, sc_space_hash(_entry_seed + 3));
        var _stretch = lerp(1.05, 1.7, sc_space_hash(_entry_seed + 4));
        var _colour_roll = sc_space_hash(_entry_seed + 5);
        var _colour;

        if (_colour_roll < 0.45)
            _colour = merge_colour(_visual.colour_dark, _visual.colour_primary, 0.72);
        else
            _colour = merge_colour(_visual.colour_primary, _visual.colour_secondary, 0.48);

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _position.x, _position.y,
            _diameter * _stretch, _diameter,
            _position.angle + lerp(-18, 18, sc_space_hash(_entry_seed + 6)),
            _colour,
            lerp(0.032, 0.072, sc_space_hash(_entry_seed + 7))
        );
    }

    var _bloom_amount = 9;

    for (var _i = 0; _i < _bloom_amount; ++_i)
    {
        var _entry_seed = _seed + _i * 307.19 + 5000;
        var _progress = lerp(-0.82, 0.82, _i / max(1, _bloom_amount - 1));
        _progress += lerp(-0.08, 0.08, sc_space_hash(_entry_seed + 1));

        var _side = lerp(-_size * 0.07, _size * 0.07, sc_space_hash(_entry_seed + 2));
        var _position = sc_space_nebula_flow_position_get(_visual, _centre, _progress, _side);
        var _sprite = sc_space_hash(_entry_seed + 3) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        var _width = lerp(_size * 0.32, _size * 0.48, sc_space_hash(_entry_seed + 4));
        var _height = _width * lerp(0.58, 0.88, sc_space_hash(_entry_seed + 5));

        sc_space_nebula_source_draw(
            _sprite,
            _position.x, _position.y,
            _width, _height,
            _position.angle + lerp(-30, 30, sc_space_hash(_entry_seed + 6)),
            merge_colour(
                _visual.colour_primary,
                _visual.colour_secondary,
                sc_space_hash(_entry_seed + 7)
            ),
            lerp(0.018, 0.045, sc_space_hash(_entry_seed + 8))
        );
    }
}

/// @description Bakes overlapping cloud texture without isolated stamps.
function sc_space_nebula_cohesive_clouds_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _amount = max(70, _visual.body_amount);

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _entry_seed = _seed + _i * 163.91 + 9000;
        var _progress = lerp(-0.94, 0.94, sc_space_hash(_entry_seed + 1));
        var _side = lerp(-_size * 0.105, _size * 0.105, sc_space_hash(_entry_seed + 2));

        _side *= lerp(1, 0.52, abs(_progress));

        var _position = sc_space_nebula_flow_position_get(_visual, _centre, _progress, _side);
        var _sprite = sc_space_hash(_entry_seed + 3) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        var _width = lerp(_size * 0.12, _size * 0.24, sc_space_hash(_entry_seed + 4));
        var _height = _width * lerp(0.48, 0.78, sc_space_hash(_entry_seed + 5));
        var _colour_roll = sc_space_hash(_entry_seed + 6);
        var _colour;

        if (_colour_roll < 0.4)
            _colour = merge_colour(_visual.colour_dark, _visual.colour_primary, 0.78);
        else if (_colour_roll < 0.82)
            _colour = merge_colour(_visual.colour_primary, _visual.colour_secondary, 0.55);
        else
            _colour = merge_colour(_visual.colour_secondary, _visual.colour_highlight, 0.28);

        sc_space_nebula_source_draw(
            _sprite,
            _position.x, _position.y,
            _width, _height,
            _position.angle + lerp(-38, 38, sc_space_hash(_entry_seed + 7)),
            _colour,
            lerp(0.018, 0.052, sc_space_hash(_entry_seed + 8))
        );
    }
}
/// @description Bakes thin luminous wisps along the connected cloud mass.
function sc_space_nebula_cohesive_wisps_bake(
    _visual,
    _centre
)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _amount = max(
        18,
        _visual.wisp_amount
    );

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _entry_seed =
            _seed
            + _i * 331.31
            + 13000;

        var _progress = lerp(
            -0.84,
            0.84,
            sc_space_hash(
                _entry_seed + 1
            )
        );

        var _side = lerp(
            -_size * 0.07,
            _size * 0.07,
            sc_space_hash(
                _entry_seed + 2
            )
        );

        var _position =
            sc_space_nebula_flow_position_get(
                _visual,
                _centre,
                _progress,
                _side
            );

        var _width = lerp(
            _size * 0.09,
            _size * 0.23,
            sc_space_hash(
                _entry_seed + 3
            )
        );

        var _height = lerp(
            _size * 0.018,
            _size * 0.052,
            sc_space_hash(
                _entry_seed + 4
            )
        );

        sc_space_nebula_source_draw(
            s_particle_wisp_001,
            _position.x,
            _position.y,
            _width,
            _height,
            _position.angle
                + lerp(
                    -22,
                    22,
                    sc_space_hash(
                        _entry_seed + 5
                    )
                ),
            merge_colour(
                _visual.colour_secondary,
                _visual.colour_highlight,
                sc_space_hash(
                    _entry_seed + 6
                ) * 0.65
            ),
            lerp(
                0.045,
                0.115,
                sc_space_hash(
                    _entry_seed + 7
                )
            )
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Bakes small bright streaks embedded inside the cloudy flow.
function sc_space_nebula_cohesive_streaks_bake(
    _visual,
    _centre
)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _sprites = _visual.streak_sprites;
    var _sprite_amount = array_length(
        _sprites
    );

    if (_sprite_amount <= 0
    || _visual.streak_amount <= 0)
        return;

    var _flow = sc_space_nebula_flow_get(
        _visual
    );

    for (var _i = 0;
    _i < _visual.streak_amount;
    ++_i)
    {
        var _entry_seed =
            _seed
            + _i * 487.19
            + 17000;

        var _sprite_index = clamp(
            floor(
                sc_space_hash(
                    _entry_seed + 1
                ) * _sprite_amount
            ),
            0,
            _sprite_amount - 1
        );

        var _progress = lerp(
            -0.7,
            0.7,
            sc_space_hash(
                _entry_seed + 2
            )
        );

        var _side = lerp(
            -_size * 0.045,
            _size * 0.045,
            sc_space_hash(
                _entry_seed + 3
            )
        );

        var _position =
            sc_space_nebula_flow_position_get(
                _visual,
                _centre,
                _progress,
                _side
            );

        var _diameter = lerp(
            _size
                * _visual.streak_size_min,
            _size
                * _visual.streak_size_max,
            sc_space_hash(
                _entry_seed + 4
            )
        ) * 0.42;

        var _stretch = lerp(
            _visual.streak_stretch_min,
            _visual.streak_stretch_max,
            sc_space_hash(
                _entry_seed + 5
            )
        );

        var _cloud =
            sc_space_hash(
                _entry_seed + 6
            ) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        sc_space_nebula_source_draw(
            _cloud,
            _position.x,
            _position.y,
            _diameter * 4.2,
            _diameter * 2.7,
            _flow.angle,
            merge_colour(
                _visual.colour_primary,
                _visual.colour_secondary,
                0.62
            ),
            0.035
        );

        gpu_set_blendmode(bm_add);

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _position.x,
            _position.y,
            _diameter * 2.8,
            _diameter * 1.7,
            _flow.angle,
            _visual.colour_highlight,
            0.055
        );

        sc_space_nebula_source_draw(
            _sprites[_sprite_index],
            _position.x,
            _position.y,
            _diameter * _stretch,
            _diameter / max(
                1,
                _stretch
            ),
            _flow.angle
                + lerp(
                    -20,
                    20,
                    sc_space_hash(
                        _entry_seed + 7
                    )
                ),
            merge_colour(
                _visual.colour_highlight,
                _visual.colour_core,
                0.3
            ),
            clamp(
                lerp(
                    _visual.streak_alpha_min,
                    _visual.streak_alpha_max,
                    sc_space_hash(
                        _entry_seed + 8
                    )
                ) * 1.35,
                0,
                0.42
            )
        );

        gpu_set_blendmode(bm_normal);
    }
}

/// @description Bakes a small restrained focal bloom.
function sc_space_nebula_cohesive_core_bake(
    _visual,
    _centre
)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    var _progress = lerp(
        -0.25,
        0.25,
        sc_space_hash(
            _seed + 19001
        )
    );

    var _position =
        sc_space_nebula_flow_position_get(
            _visual,
            _centre,
            _progress,
            0
        );

    gpu_set_blendmode(bm_add);

    sc_space_nebula_source_draw(
        s_particle_blur_1024,
        _position.x,
        _position.y,
        _size * 0.16,
        _size * 0.11,
        _position.angle,
        _visual.colour_secondary,
        0.075
    );

    sc_space_nebula_source_draw(
        s_particle_blur_1024,
        _position.x,
        _position.y,
        _size * 0.075,
        _size * 0.052,
        _position.angle,
        _visual.colour_highlight,
        0.12
    );

    gpu_set_blendmode(bm_normal);
}

/// @description Generates one cohesive detailed nebula sprite.
function sc_space_nebula_sprite_create(_visual)
{
    var _size = _visual.canvas_size;
    var _centre = _size * 0.5;

    var _surface = surface_create(
        _size,
        _size
    );

    if (!surface_exists(_surface))
        return -1;

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    sc_space_nebula_cohesive_foundation_bake(
        _visual,
        _centre
    );

    sc_space_nebula_cohesive_clouds_bake(
        _visual,
        _centre
    );

    sc_space_nebula_cohesive_wisps_bake(
        _visual,
        _centre
    );

    sc_space_nebula_cohesive_streaks_bake(
        _visual,
        _centre
    );

    sc_space_nebula_cohesive_core_bake(
        _visual,
        _centre
    );

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

/// @description Bakes large faint colourful cloud blooms.
function sc_space_nebula_blooms_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _amount = max(
        6,
        ceil(_visual.body_amount * 0.14)
    );

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _entry_seed = _seed
            + _i * 1049.37;

        var _sprite =
            sc_space_hash(_entry_seed + 1) < 0.5
            ? s_particle_cloud_002
            : s_particle_cloud_003;

        var _direction =
            sc_space_hash(_entry_seed + 2)
            * 360;

        var _distance = power(
            sc_space_hash(_entry_seed + 3),
            1.6
        );

        var _x = _centre + lengthdir_x(
            _distance
            * _size
            * _visual.body_spread_x
            * 0.85,
            _direction
        );

        var _y = _centre + lengthdir_y(
            _distance
            * _size
            * _visual.body_spread_y
            * 0.85,
            _direction
        );

        var _width = lerp(
            _size * 0.3,
            _size * 0.68,
            sc_space_hash(_entry_seed + 4)
        );

        var _height = _width * lerp(
            0.52,
            0.92,
            sc_space_hash(_entry_seed + 5)
        );

        var _colour = merge_colour(
            _visual.colour_primary,
            _visual.colour_secondary,
            sc_space_hash(_entry_seed + 6)
        );

        sc_space_nebula_source_draw(
            _sprite,
            _x,
            _y,
            _width,
            _height,
            sc_space_hash(_entry_seed + 7) * 360,
            _colour,
            lerp(
                0.045,
                0.11,
                sc_space_hash(_entry_seed + 8)
            )
        );

        gpu_set_blendmode(bm_add);

        sc_space_nebula_source_draw(
            s_particle_blur_1024,
            _x,
            _y,
            _width * 0.78,
            _height * 0.78,
            0,
            merge_colour(
                _visual.colour_secondary,
                _visual.colour_highlight,
                0.35
            ),
            lerp(
                0.025,
                0.065,
                sc_space_hash(_entry_seed + 9)
            )
        );

        gpu_set_blendmode(bm_normal);
    }
}