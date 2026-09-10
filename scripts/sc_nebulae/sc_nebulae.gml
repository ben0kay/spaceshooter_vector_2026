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

/// @description Creates one localized visual-only background nebula.
function sc_space_nebula_create(_type, _seed, _x, _y, _width, _height, _angle, _alpha)
{
    var _visual = sc_space_nebula_preset_get(_type, _seed);

    return {
        type: _type,
        sprite: sc_space_nebula_sprite_create(_visual),
        canvas_size: _visual.canvas_size,

        x: _x,
        y: _y,
        width: max(256, _width),
        height: max(256, _height),
        angle: _angle,
        alpha: clamp(_alpha, 0, 1)
    };
}

/// @description Draws one visible localized background nebula.
function sc_space_nebula_draw(_nebula, _camera_x, _camera_y, _view_w, _view_h)
{
    var _padding = max(_nebula.width, _nebula.height) * 0.6;

    if (_nebula.x + _padding < _camera_x
    || _nebula.x - _padding > _camera_x + _view_w
    || _nebula.y + _padding < _camera_y
    || _nebula.y - _padding > _camera_y + _view_h)
        return;

    var _scale_x = _nebula.width / _nebula.canvas_size;
    var _scale_y = _nebula.height / _nebula.canvas_size;

    // Main clearly visible nebula artwork.
    draw_sprite_ext(
        _nebula.sprite,
        0,
        _nebula.x,
        _nebula.y,
        _scale_x,
        _scale_y,
        _nebula.angle,
        c_white,
        _nebula.alpha
    );

    // A faint offset layer gives depth without greatly enlarging the nebula.
    draw_sprite_ext(
        _nebula.sprite,
        0,
        _nebula.x + lengthdir_x(_nebula.width * 0.035, _nebula.angle + 90),
        _nebula.y + lengthdir_y(_nebula.width * 0.035, _nebula.angle + 90),
        _scale_x * 0.92,
        _scale_y * 0.88,
        _nebula.angle + 7,
        c_white,
        _nebula.alpha * 0.24
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
    gpu_set_blendmode(bm_normal);
}