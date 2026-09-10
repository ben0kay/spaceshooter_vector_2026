/*
PROCEDURAL BACKGROUND NEBULAS

Nebulas are visual-only background artwork. Each preset is assembled from
blurred cloud masses, curved wisps and optional bright particle streaks,
then baked into one reusable sprite.
*/

/// @description Returns one visual recipe for a background nebula type.
function sc_space_nebula_preset_get(_type, _seed)
{
    var _visual = {
        canvas_size: 1024,
        seed: _seed,

        colour_dark: make_colour_rgb(8, 8, 28),
        colour_primary: make_colour_rgb(55, 35, 125),
        colour_secondary: make_colour_rgb(165, 55, 190),
        colour_highlight: make_colour_rgb(95, 145, 255),
        colour_core: make_colour_rgb(230, 240, 255),

        body_amount: 76,
        body_spread_x: 0.38,
        body_spread_y: 0.28,
        body_size_min: 0.12,
        body_size_max: 0.36,
        body_stretch_min: 0.75,
        body_stretch_max: 2.2,
        body_alpha_min: 0.09,
        body_alpha_max: 0.23,

        arm_amount: 7,
        arm_points: 13,
        arm_length_min: 0.22,
        arm_length_max: 0.44,
        arm_curve_min: -100,
        arm_curve_max: 100,

        wisp_amount: 18,
        wisp_distance: 0.35,
        wisp_width_min: 0.08,
        wisp_width_max: 0.24,
        wisp_height_min: 0.025,
        wisp_height_max: 0.07,
        wisp_alpha_min: 0.045,
        wisp_alpha_max: 0.13,

        glow_amount: 26,
        core_amount: 6,

        streak_sprites: [
            s_particle_streak_002,
            s_particle_streak_003,
            s_particle_streak_004
        ],

        streak_amount: 8,
        streak_distance: 0.27,
        streak_size_min: 0.055,
        streak_size_max: 0.15,
        streak_stretch_min: 0.75,
        streak_stretch_max: 1.8,
        streak_angle_bias: 0,
        streak_angle_spread: 360,
        streak_alpha_min: 0.09,
        streak_alpha_max: 0.24,

        major_streak_sprite: -1,
        major_streak_amount: 0,
        major_streak_size_min: 0.32,
        major_streak_size_max: 0.55,
        major_streak_alpha: 0.16
    };

    switch (_type)
    {
        case "violet_storm":
            _visual.colour_dark = make_colour_rgb(9, 4, 32);
            _visual.colour_primary = make_colour_rgb(58, 25, 145);
            _visual.colour_secondary = make_colour_rgb(205, 45, 205);
            _visual.colour_highlight = make_colour_rgb(105, 125, 255);
            _visual.colour_core = make_colour_rgb(240, 225, 255);

            _visual.body_amount = 84;
            _visual.arm_amount = 8;
            _visual.wisp_amount = 20;
            _visual.glow_amount = 34;

            _visual.streak_sprites = [
                s_particle_streak_002,
                s_particle_streak_004
            ];

            _visual.streak_amount = 11;
            _visual.streak_alpha_max = 0.3;
            _visual.major_streak_sprite = s_particle_streak_001;
            _visual.major_streak_amount = 2;
            _visual.major_streak_alpha = 0.2;
        break;

        case "crimson_rift":
            _visual.colour_dark = make_colour_rgb(34, 3, 23);
            _visual.colour_primary = make_colour_rgb(125, 12, 65);
            _visual.colour_secondary = make_colour_rgb(235, 35, 110);
            _visual.colour_highlight = make_colour_rgb(255, 105, 175);
            _visual.colour_core = make_colour_rgb(255, 225, 235);

            _visual.body_spread_x = 0.43;
            _visual.body_spread_y = 0.2;
            _visual.body_stretch_min = 1.2;
            _visual.body_stretch_max = 3.2;

            _visual.arm_amount = 5;
            _visual.arm_curve_min = -35;
            _visual.arm_curve_max = 35;

            _visual.wisp_amount = 14;
            _visual.streak_sprites = [s_particle_streak_003];
            _visual.streak_amount = 13;
            _visual.streak_size_min = 0.09;
            _visual.streak_size_max = 0.24;
            _visual.streak_stretch_min = 1.4;
            _visual.streak_stretch_max = 3.2;
            _visual.streak_angle_bias = 0;
            _visual.streak_angle_spread = 32;
            _visual.streak_alpha_max = 0.3;
        break;

        case "cyan_veil":
            _visual.colour_dark = make_colour_rgb(2, 22, 37);
            _visual.colour_primary = make_colour_rgb(8, 82, 125);
            _visual.colour_secondary = make_colour_rgb(18, 190, 205);
            _visual.colour_highlight = make_colour_rgb(75, 145, 255);
            _visual.colour_core = make_colour_rgb(220, 250, 255);

            _visual.body_amount = 65;
            _visual.body_alpha_min = 0.065;
            _visual.body_alpha_max = 0.18;

            _visual.arm_amount = 10;
            _visual.arm_points = 16;
            _visual.arm_curve_min = -145;
            _visual.arm_curve_max = 145;

            _visual.wisp_amount = 34;
            _visual.wisp_width_min = 0.13;
            _visual.wisp_width_max = 0.32;
            _visual.wisp_alpha_max = 0.17;

            _visual.glow_amount = 20;
            _visual.streak_amount = 3;
            _visual.streak_alpha_max = 0.14;
        break;

        case "azure_tempest":
            _visual.colour_dark = make_colour_rgb(2, 8, 34);
            _visual.colour_primary = make_colour_rgb(18, 62, 155);
            _visual.colour_secondary = make_colour_rgb(30, 170, 235);
            _visual.colour_highlight = make_colour_rgb(120, 90, 255);
            _visual.colour_core = make_colour_rgb(225, 245, 255);

            _visual.body_amount = 92;
            _visual.body_spread_x = 0.34;
            _visual.body_spread_y = 0.34;

            _visual.arm_amount = 9;
            _visual.wisp_amount = 22;
            _visual.glow_amount = 38;

            _visual.streak_sprites = [
                s_particle_streak_002,
                s_particle_streak_004
            ];

            _visual.streak_amount = 15;
            _visual.streak_alpha_min = 0.12;
            _visual.streak_alpha_max = 0.34;
            _visual.major_streak_sprite = s_particle_streak_001;
            _visual.major_streak_amount = 1;
            _visual.major_streak_alpha = 0.18;
        break;

        case "solar_bloom":
            _visual.colour_dark = make_colour_rgb(40, 8, 3);
            _visual.colour_primary = make_colour_rgb(145, 38, 10);
            _visual.colour_secondary = make_colour_rgb(245, 105, 25);
            _visual.colour_highlight = make_colour_rgb(255, 195, 70);
            _visual.colour_core = make_colour_rgb(255, 245, 205);

            _visual.body_amount = 88;
            _visual.body_spread_x = 0.32;
            _visual.body_spread_y = 0.32;
            _visual.body_stretch_min = 0.7;
            _visual.body_stretch_max = 1.65;

            _visual.arm_amount = 11;
            _visual.arm_curve_min = -165;
            _visual.arm_curve_max = 165;

            _visual.wisp_amount = 24;
            _visual.glow_amount = 42;
            _visual.core_amount = 10;

            _visual.streak_sprites = [s_particle_streak_004];
            _visual.streak_amount = 12;
            _visual.streak_size_min = 0.08;
            _visual.streak_size_max = 0.2;
            _visual.streak_alpha_max = 0.28;
        break;

        case "ghost_cloud":
            _visual.colour_dark = make_colour_rgb(5, 10, 25);
            _visual.colour_primary = make_colour_rgb(34, 60, 105);
            _visual.colour_secondary = make_colour_rgb(85, 85, 160);
            _visual.colour_highlight = make_colour_rgb(80, 150, 185);
            _visual.colour_core = make_colour_rgb(190, 225, 235);

            _visual.body_amount = 54;
            _visual.body_spread_x = 0.42;
            _visual.body_spread_y = 0.3;
            _visual.body_alpha_min = 0.045;
            _visual.body_alpha_max = 0.13;

            _visual.arm_amount = 6;
            _visual.wisp_amount = 27;
            _visual.wisp_alpha_min = 0.025;
            _visual.wisp_alpha_max = 0.085;

            _visual.glow_amount = 12;
            _visual.core_amount = 2;
            _visual.streak_amount = 2;
            _visual.streak_alpha_min = 0.035;
            _visual.streak_alpha_max = 0.08;
        break;
    }

    return _visual;
}

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

/// @description Creates smaller visual patches distributed throughout a nebula.
function sc_space_nebula_patches_create(_seed, _amount)
{
    var _patches = [];

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 19.31) * 360;
        var _distance = power(
            sc_space_hash(_seed + _i * 43.77),
            0.74
        ) * 0.68;

        array_push(
            _patches,
            {
                local_x: lengthdir_x(_distance, _direction),
                local_y: lengthdir_y(_distance, _direction),

                scale_x: lerp(
                    0.16,
                    0.3,
                    sc_space_hash(_seed + _i * 67.93)
                ),

                scale_y: lerp(
                    0.17,
                    0.32,
                    sc_space_hash(_seed + _i * 89.17)
                ),

                angle: sc_space_hash(_seed + _i * 103.41) * 360,

                alpha: lerp(
                    0.5,
                    1,
                    sc_space_hash(_seed + _i * 127.59)
                ),

                phase: sc_space_hash(_seed + _i * 149.83) * 360
            }
        );
    }

    return _patches;
}

/// @description Creates separately drawn stars embedded throughout a nebula.
function sc_space_nebula_stars_create(_visual, _amount)
{
    var _stars = [];
    var _seed = _visual.seed;

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 971.17) * 360;
        var _distance = sqrt(
            sc_space_hash(_seed + _i * 991.43)
        ) * 0.78;

        array_push(
            _stars,
            {
                local_x: lengthdir_x(_distance, _direction),
                local_y: lengthdir_y(_distance, _direction),

                size: lerp(
                    18,
                    54,
                    sc_space_hash(_seed + _i * 1013.71)
                ),

                angle: sc_space_hash(_seed + _i * 1031.29) * 360,

                alpha: lerp(
                    0.25,
                    0.75,
                    sc_space_hash(_seed + _i * 1051.83)
                ),

                phase: sc_space_hash(_seed + _i * 1069.37) * 360,

                speed: lerp(
                    0.08,
                    0.2,
                    sc_space_hash(_seed + _i * 1091.61)
                ),

                colour: merge_colour(
                    _visual.colour_core,
                    c_white,
                    sc_space_hash(_seed + _i * 1117.43) * 0.7
                )
            }
        );
    }

    return _stars;
}

/// @description Returns visual patch and twinkling-star amounts for a type.
function sc_space_nebula_runtime_amounts_get(_type)
{
    switch (_type)
    {
        case "violet_storm":
            return { patches: 14, stars: 20 };

        case "crimson_rift":
            return { patches: 12, stars: 13 };

        case "cyan_veil":
            return { patches: 15, stars: 18 };

        case "azure_tempest":
            return { patches: 14, stars: 22 };

        case "solar_bloom":
            return { patches: 13, stars: 16 };

        case "ghost_cloud":
            return { patches: 11, stars: 9 };
    }

    return { patches: 12, stars: 14 };
}

/// @description Creates one placed visual-only background nebula.
function sc_space_nebula_create(_type, _seed, _x, _y, _radius_x, _radius_y, _angle, _alpha)
{
    var _visual = sc_space_nebula_preset_get(_type, _seed);
    var _amounts = sc_space_nebula_runtime_amounts_get(_type);

    return {
        type: _type,
        sprite: sc_space_nebula_sprite_create(_visual),
        canvas_size: _visual.canvas_size,

        x: _x,
        y: _y,
        radius_x: _radius_x,
        radius_y: _radius_y,
        angle: _angle,
        alpha: _alpha,

        patches: sc_space_nebula_patches_create(
            _seed + 1139.17,
            _amounts.patches
        ),

        stars: sc_space_nebula_stars_create(
            _visual,
            _amounts.stars
        )
    };
}

/// @description Returns whether a point and radius overlap the current camera.
function sc_space_nebula_element_visible(_x, _y, _radius, _camera_x, _camera_y, _view_w, _view_h)
{
    return _x + _radius >= _camera_x
        && _x - _radius <= _camera_x + _view_w
        && _y + _radius >= _camera_y
        && _y - _radius <= _camera_y + _view_h;
}

/// @description Converts normalized nebula-local coordinates into world space.
function sc_space_nebula_world_position_get(_nebula, _local_x, _local_y)
{
    var _x = _local_x * _nebula.radius_x;
    var _y = _local_y * _nebula.radius_y;

    return {
        x: _nebula.x
            + lengthdir_x(_x, _nebula.angle)
            + lengthdir_x(_y, _nebula.angle + 90),

        y: _nebula.y
            + lengthdir_y(_x, _nebula.angle)
            + lengthdir_y(_y, _nebula.angle + 90)
    };
}

/// @description Draws every visible cloudy patch belonging to one nebula.
function sc_space_nebula_patches_draw(_nebula, _camera_x, _camera_y, _view_w, _view_h)
{
    var _patches = _nebula.patches;

    for (var _i = 0; _i < array_length(_patches); ++_i)
    {
        var _patch = _patches[_i];
        var _position = sc_space_nebula_world_position_get(
            _nebula,
            _patch.local_x,
            _patch.local_y
        );

        var _width = _nebula.radius_x * 2 * _patch.scale_x;
        var _height = _nebula.radius_y * 2 * _patch.scale_y;
        var _radius = max(_width, _height) * 0.6;

        if (!sc_space_nebula_element_visible(
            _position.x,
            _position.y,
            _radius,
            _camera_x,
            _camera_y,
            _view_w,
            _view_h
        ))
            continue;

        var _pulse = 1 + dsin(
            current_time * 0.006
            + _patch.phase
        ) * 0.018;

        draw_sprite_ext(
            _nebula.sprite,
            0,
            _position.x,
            _position.y,
            (_width / _nebula.canvas_size) * _pulse,
            _height / _nebula.canvas_size,
            _nebula.angle + _patch.angle,
            c_white,
            _nebula.alpha * _patch.alpha
        );
    }
}

/// @description Draws independently twinkling starbursts inside one nebula.
function sc_space_nebula_stars_draw(_nebula, _camera_x, _camera_y, _view_w, _view_h)
{
    var _stars = _nebula.stars;
    var _sprite_width = max(
        1,
        sprite_get_width(s_particle_starburst_001)
    );

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < array_length(_stars); ++_i)
    {
        var _star = _stars[_i];
        var _position = sc_space_nebula_world_position_get(
            _nebula,
            _star.local_x,
            _star.local_y
        );

        if (!sc_space_nebula_element_visible(
            _position.x,
            _position.y,
            _star.size,
            _camera_x,
            _camera_y,
            _view_w,
            _view_h
        ))
            continue;

        var _twinkle = 0.68 + dsin(
            current_time * _star.speed
            + _star.phase
        ) * 0.32;

        var _scale = (_star.size / _sprite_width)
            * lerp(0.88, 1.08, _twinkle);

        draw_sprite_ext(
            s_particle_starburst_001,
            0,
            _position.x,
            _position.y,
            _scale,
            _scale,
            _star.angle,
            _star.colour,
            _star.alpha * _twinkle
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Draws one visible multi-patch background nebula.
function sc_space_nebula_draw(_nebula, _camera_x, _camera_y, _view_w, _view_h)
{
    var _padding = max(_nebula.radius_x, _nebula.radius_y) * 1.15;

    if (_nebula.x + _padding < _camera_x
    || _nebula.x - _padding > _camera_x + _view_w
    || _nebula.y + _padding < _camera_y
    || _nebula.y - _padding > _camera_y + _view_h)
        return;

    sc_space_nebula_patches_draw(
        _nebula,
        _camera_x,
        _camera_y,
        _view_w,
        _view_h
    );

    sc_space_nebula_stars_draw(
        _nebula,
        _camera_x,
        _camera_y,
        _view_w,
        _view_h
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}