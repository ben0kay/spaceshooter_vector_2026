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

/// @description Bakes the broad underlying cloud body.
function sc_space_nebula_body_bake(_visual, _centre, _blur_width, _blur_height)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    for (var _i = 0; _i < _visual.body_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 17.31) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 43.73), 1.45);
        var _x = _centre + lengthdir_x(_distance * _size * _visual.body_spread_x, _direction);
        var _y = _centre + lengthdir_y(_distance * _size * _visual.body_spread_y, _direction);

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

        var _colour = merge_colour(
            _visual.colour_dark,
            _visual.colour_primary,
            sc_space_hash(_seed + _i * 127.53)
        );

        draw_sprite_ext(
            s_blur, 0, _x, _y,
            (_diameter / _blur_width) * _stretch,
            (_diameter / _blur_height) / _stretch,
            sc_space_hash(_seed + _i * 101.39) * 360,
            _colour,
            lerp(
                _visual.body_alpha_min,
                _visual.body_alpha_max,
                sc_space_hash(_seed + _i * 149.21)
            )
        );
    }
}

/// @description Bakes soft curved arms from chains of blurred colour.
function sc_space_nebula_arms_bake(_visual, _centre, _blur_width, _blur_height)
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

            var _diameter = lerp(_size * 0.11, _size * 0.028, _progress);
            var _colour = merge_colour(
                _visual.colour_primary,
                _visual.colour_secondary,
                sc_space_hash(_arm_seed + _point * 59.47)
            );

            draw_sprite_ext(
                s_blur, 0, _x, _y,
                (_diameter / _blur_width) * 2.8,
                (_diameter / _blur_height) * 0.72,
                _angle,
                _colour,
                lerp(0.035, 0.13, 1 - _progress)
            );
        }
    }
}

/// @description Bakes the imported crescent wisp into sweeping cloud ribbons.
function sc_space_nebula_wisps_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _sprite_width = max(1, sprite_get_width(s_particle_wisp_001));
    var _sprite_height = max(1, sprite_get_height(s_particle_wisp_001));

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.wisp_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 173.31) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 191.47), 1.35)
            * _size * _visual.wisp_distance;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);

        var _width = lerp(
            _size * _visual.wisp_width_min,
            _size * _visual.wisp_width_max,
            sc_space_hash(_seed + _i * 211.63)
        );

        var _height = lerp(
            _size * _visual.wisp_height_min,
            _size * _visual.wisp_height_max,
            sc_space_hash(_seed + _i * 229.87)
        );

        var _colour = merge_colour(
            _visual.colour_primary,
            _visual.colour_highlight,
            sc_space_hash(_seed + _i * 239.29)
        );

        draw_sprite_ext(
            s_particle_wisp_001, 0, _x, _y,
            _width / _sprite_width,
            _height / _sprite_height,
            _direction + 90 + lerp(
                -35,
                35,
                sc_space_hash(_seed + _i * 251.43)
            ),
            _colour,
            lerp(
                _visual.wisp_alpha_min,
                _visual.wisp_alpha_max,
                sc_space_hash(_seed + _i * 269.71)
            )
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Bakes small imported lightning, cloud and rift accents.
function sc_space_nebula_streaks_bake(_visual, _centre)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _sprites = _visual.streak_sprites;
    var _sprite_amount = array_length(_sprites);

    if (_sprite_amount <= 0 || _visual.streak_amount <= 0)
        return;

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.streak_amount; ++_i)
    {
        var _sprite_index = clamp(
            floor(sc_space_hash(_seed + _i * 283.19) * _sprite_amount),
            0,
            _sprite_amount - 1
        );

        var _sprite = _sprites[_sprite_index];
        var _sprite_width = max(1, sprite_get_width(_sprite));
        var _sprite_height = max(1, sprite_get_height(_sprite));
        var _direction = sc_space_hash(_seed + _i * 307.53) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 331.71), 1.65)
            * _size * _visual.streak_distance;

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);

        var _diameter = lerp(
            _size * _visual.streak_size_min,
            _size * _visual.streak_size_max,
            sc_space_hash(_seed + _i * 353.17)
        );

        var _stretch = lerp(
            _visual.streak_stretch_min,
            _visual.streak_stretch_max,
            sc_space_hash(_seed + _i * 379.61)
        );

        var _angle = _visual.streak_angle_bias + lerp(
            -_visual.streak_angle_spread,
            _visual.streak_angle_spread,
            sc_space_hash(_seed + _i * 397.43)
        );

        var _colour = merge_colour(
            _visual.colour_secondary,
            _visual.colour_core,
            sc_space_hash(_seed + _i * 419.77)
        );

        draw_sprite_ext(
            _sprite, 0, _x, _y,
            (_diameter / _sprite_width) * _stretch,
            (_diameter / _sprite_height) / _stretch,
            _angle,
            _colour,
            lerp(
                _visual.streak_alpha_min,
                _visual.streak_alpha_max,
                sc_space_hash(_seed + _i * 443.29)
            )
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Bakes rare large branching lightning structures.
function sc_space_nebula_major_streaks_bake(_visual, _centre)
{
    if (_visual.major_streak_sprite == -1
    || _visual.major_streak_amount <= 0)
        return;

    var _size = _visual.canvas_size;
    var _seed = _visual.seed;
    var _sprite = _visual.major_streak_sprite;
    var _sprite_width = max(1, sprite_get_width(_sprite));
    var _sprite_height = max(1, sprite_get_height(_sprite));

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.major_streak_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 467.53) * 360;
        var _distance = sc_space_hash(_seed + _i * 487.91) * _size * 0.16;
        var _diameter = lerp(
            _size * _visual.major_streak_size_min,
            _size * _visual.major_streak_size_max,
            sc_space_hash(_seed + _i * 509.37)
        );

        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.72, _direction);

        draw_sprite_ext(
            _sprite, 0, _x, _y,
            _diameter / _sprite_width,
            _diameter / _sprite_height,
            sc_space_hash(_seed + _i * 541.13) * 360,
            _visual.colour_highlight,
            _visual.major_streak_alpha
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Bakes compact coloured glows and brilliant focal points.
function sc_space_nebula_glows_bake(_visual, _centre, _blur_width, _blur_height)
{
    var _size = _visual.canvas_size;
    var _seed = _visual.seed;

    gpu_set_blendmode(bm_add);

    for (var _i = 0; _i < _visual.glow_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 563.11) * 360;
        var _distance = power(sc_space_hash(_seed + _i * 587.37), 1.8) * _size * 0.3;
        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.68, _direction);

        var _diameter = lerp(
            _size * 0.025,
            _size * 0.11,
            sc_space_hash(_seed + _i * 611.63)
        );

        var _stretch = lerp(
            1.2,
            3.8,
            sc_space_hash(_seed + _i * 631.87)
        );

        draw_sprite_ext(
            s_blur, 0, _x, _y,
            (_diameter / _blur_width) * _stretch,
            (_diameter / _blur_height) / _stretch,
            sc_space_hash(_seed + _i * 653.43) * 360,
            merge_colour(
                _visual.colour_secondary,
                _visual.colour_highlight,
                sc_space_hash(_seed + _i * 677.29)
            ),
            lerp(
                0.07,
                0.2,
                sc_space_hash(_seed + _i * 691.71)
            )
        );
    }

    for (var _i = 0; _i < _visual.core_amount; ++_i)
    {
        var _direction = sc_space_hash(_seed + _i * 719.19) * 360;
        var _distance = sc_space_hash(_seed + _i * 743.53) * _size * 0.22;
        var _x = _centre + lengthdir_x(_distance, _direction);
        var _y = _centre + lengthdir_y(_distance * 0.65, _direction);

        var _diameter = lerp(
            _size * 0.018,
            _size * 0.05,
            sc_space_hash(_seed + _i * 761.71)
        );

        draw_sprite_ext(
            s_blur, 0, _x, _y,
            _diameter / _blur_width,
            _diameter / _blur_height,
            0,
            _visual.colour_core,
            0.42
        );
    }

    gpu_set_blendmode(bm_normal);
}

/// @description Generates and bakes one complete coloured nebula sprite.
function sc_space_nebula_sprite_create(_visual)
{
    var _size = _visual.canvas_size;
    var _centre = _size * 0.5;
    var _surface = surface_create(_size, _size);

    if (!surface_exists(_surface))
        return -1;

    var _blur_width = max(1, sprite_get_width(s_blur));
    var _blur_height = max(1, sprite_get_height(s_blur));

    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);

    sc_space_nebula_body_bake(_visual, _centre, _blur_width, _blur_height);
    sc_space_nebula_arms_bake(_visual, _centre, _blur_width, _blur_height);
    sc_space_nebula_wisps_bake(_visual, _centre);
    sc_space_nebula_glows_bake(_visual, _centre, _blur_width, _blur_height);
    sc_space_nebula_streaks_bake(_visual, _centre);
    sc_space_nebula_major_streaks_bake(_visual, _centre);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
    surface_reset_target();

    var _sprite = sprite_create_from_surface(
        _surface,
        0, 0,
        _size, _size,
        false, false,
        _centre, _centre
    );

    surface_free(_surface);
    return _sprite;
}

/// @description Creates one placed visual-only background nebula.
function sc_space_nebula_create(_type, _seed, _x, _y, _radius_x, _radius_y, _angle, _alpha)
{
    var _visual = sc_space_nebula_preset_get(_type, _seed);

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
        phase: sc_space_hash(_seed + 811.37) * 360
    };
}

/// @description Draws one visible baked background nebula.
function sc_space_nebula_draw(_nebula, _camera_x, _camera_y, _view_w, _view_h)
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
        _nebula.sprite, 0,
        _nebula.x,
        _nebula.y,
        _scale_x,
        _scale_y,
        _nebula.angle,
        c_white,
        _nebula.alpha * 0.72
    );

    // Offset layer provides slow internal movement and visual depth.
    draw_sprite_ext(
        _nebula.sprite, 0,
        _nebula.x + dcos(_nebula.phase + _time) * _nebula.radius_x * 0.018,
        _nebula.y + dsin(_nebula.phase + _time) * _nebula.radius_y * 0.018,
        _scale_x * 0.84,
        _scale_y * 0.9,
        _nebula.angle + 37,
        c_white,
        _nebula.alpha * 0.23
    );

    // Counter-rotated interior breaks up the repeated baked shape.
    draw_sprite_ext(
        _nebula.sprite, 0,
        _nebula.x - dcos(_nebula.phase + _time) * _nebula.radius_x * 0.012,
        _nebula.y - dsin(_nebula.phase + _time) * _nebula.radius_y * 0.012,
        _scale_x * 0.68,
        _scale_y * 0.72,
        _nebula.angle - 53,
        c_white,
        _nebula.alpha * 0.16
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}