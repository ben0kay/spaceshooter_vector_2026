/// @description Registers the fast silver-aqua Shard chassis.
function sc_ship_register_shard()
{
    return sc_ship_register({
        identity: { key: "ship_shard", name: "Shard", description: "A fast silver-aqua interceptor with adaptive swept wings." },

        stats_base: {
            hull_max: 75, armour_max: 25, shield_max: 40,
            shield_recharge_delay: 150, shield_recharge_rate: 0.35, shield_energy_cost: 1,

            energy_max: 100, energy_regeneration: 0.2, energy_recharge_delay: 45,
            fuel_max: 100, fuel_regeneration: 0,
            fuel_movement_cost: 0.015, fuel_boost_cost: 0.06, fuel_dash_cost: 8,

            bullets_max: 600, explosives_max: 24,
            cargo_capacity: 12,

            speed_max: 10, acceleration: 0.6, deceleration: 0.7, turn_speed: 10,
            damage_multiplier: 1, fire_rate_multiplier: 1,

            boost_speed_multiplier: 1.35, dash_speed: 22, dash_duration: 16, dash_cooldown: 90,
            dash_double_tap_window: 15, dash_exit_speed_multiplier: 0.45, dash_invulnerable: 1,
            weapons_while_boosting: 0, weapons_while_dashing: 0
        },

        collision: {
            radius_forward: 76,
            radius_side: 36
        },

        visual: sc_ship_shard_visual_data(),

        hardpoints: {
            primary: [
                { key: "primary_left", x: 13, y: -21, angle: 0, muzzle_forward: 32, scale: 1 },
                { key: "primary_right", x: 13, y: 21, angle: 0, muzzle_forward: 32, scale: 1 }
            ],

            utility: []
        },

        starting_loadout: {
            primary: "weapon_shard_pulse",
            primary_slot: 0,

            primary_slots: [
                "weapon_shard_pulse",
                "weapon_shard_minigun",
                "weapon_shard_laser",
                "weapon_shard_rocket"
            ],

            secondary: undefined
        }
    });
}

/// @description Returns the complete visual definition for the Shard chassis.
function sc_ship_shard_visual_data()
{
    return {
        radius: 46,

        // Compatibility fields used by ship-selection previews.
        scale: 1,
        colour_primary: make_colour_rgb(25, 225, 255),
        colour_secondary: make_colour_rgb(175, 220, 228),

        palette: {
            void: make_colour_rgb(2, 7, 12),
            hull_dark: make_colour_rgb(10, 23, 31),
            hull_mid: make_colour_rgb(28, 56, 68),
            hull_light: make_colour_rgb(75, 126, 140),
            metal: make_colour_rgb(175, 220, 228),
            accent: make_colour_rgb(25, 135, 255),
            energy: make_colour_rgb(25, 225, 255),
            core: make_colour_rgb(220, 255, 255),
            glow: make_colour_rgb(0, 115, 195)
        },

        wing: {
            hinge_forward: -0.08, hinge_side: 0.3,
            fold_idle: -4, fold_moving: 7, fold_boost: 15, fold_dash: 23,
            fold_response: 0.14
        },

        core: {
            forward: -0.08, side: 0,
            idle_speed: 0.45, movement_speed: 4.5,
            boost_multiplier: 1.35, dash_multiplier: 1.75,
            response: 0.12
        },

        draw: {
            hull: sc_ship_shard_hull_draw,
            armour: sc_ship_shard_armour_draw,
            wing_hull: sc_ship_shard_wing_hull_draw,
            wing_armour: sc_ship_shard_wing_armour_draw,
            core: sc_ship_shard_core_draw,
            hardpoint: sc_ship_shard_cannon_draw,
            muzzle_flash: sc_ship_shard_muzzle_flash_draw,
            shield: sc_ship_shard_shield_draw,
            thrust: sc_ship_shard_thrust_draw
        },

        death_script: sc_ship_shard_death,

        bake: {
            body_canvas_size: 224, wing_canvas_size: 160,
            core_canvas_size: 96, hardpoint_canvas_size: 96,
            muzzle_canvas_size: 96, muzzle_frames: 4,
            shield_canvas_size: 224, thrust_canvas_size: 128,
            damage_stages: 4
        }
    };
}

/*
SHARD VISUAL FUNCTIONS
Contains all primitive drawing and visual-effect functions unique to the Shard chassis.
Primitive components are baked into reusable sprites during game initialization.
Hull, armour, wings, guns, muzzle flash, shield and thrust are drawn separately.
Dynamic components can then move, recoil, animate or change damage stage during gameplay.
sc_ship_shard_death() assembles cached components into the generic death-fragment effect.
*/


/// @description Draws the Shard's compact dark arrowhead hull.
function sc_ship_shard_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Main narrow arrowhead silhouette.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.73, 0, 0.58, -0.2, 0.58, 0.2, _p.hull_dark, false);
    sc_visual_quad(_x, _y, _radius, _angle, 0.58, -0.2, -0.27, -0.36, -0.27, 0.36, 0.58, 0.2, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -0.27, -0.36, -0.88, -0.29, -0.88, 0.29, -0.27, 0.36, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -0.88, -0.29, -1.2, -0.15, -1.2, 0.15, -0.88, 0.29, _p.void);

    // Raised central spear.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.67, 0, 0.42, -0.13, -0.82, 0, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.67, 0, -0.82, 0, 0.42, 0.13, _p.hull_mid, false);

    sc_visual_triangle(_x, _y, _radius, _angle, 1.57, 0, 0.56, -0.09, 0.16, 0, _p.hull_light, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.57, 0, 0.16, 0, 0.56, 0.09, _p.hull_light, false);

    // Dark cockpit.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.43, 0, 0.67, -0.115, 0.32, 0, _p.void, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.43, 0, 0.32, 0, 0.67, 0.115, _p.void, false);
    sc_visual_line(_x, _y, _radius, _angle, 1.43, 0, 0.67, -0.115, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 1.43, 0, 0.67, 0.115, 1, _p.energy);

    // Compact side machinery.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            0.48, 0.17 * _side,
            0.02, 0.3 * _side,
            -0.57, 0.29 * _side,
            -0.86, 0.19 * _side,
            _p.hull_mid
        );

        sc_visual_quad(_x, _y, _radius, _angle,
            0.28, 0.19 * _side,
            -0.06, 0.265 * _side,
            -0.46, 0.25 * _side,
            -0.65, 0.17 * _side,
            _p.hull_light
        );

        sc_visual_line(_x, _y, _radius, _angle, 0.42, 0.2 * _side, -0.04, 0.29 * _side, 1, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, -0.04, 0.29 * _side, -0.56, 0.28 * _side, 1, _p.hull_light);

        // Blue inset machinery.
        sc_visual_line(_x, _y, _radius, _angle, 0.2, 0.225 * _side, -0.26, 0.255 * _side, 5, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.18, 0.225 * _side, -0.24, 0.25 * _side, 2, _p.accent);
    }

    // Twin rear engine housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            -0.49, 0.13 * _side,
            -0.73, 0.25 * _side,
            -1.16, 0.18 * _side,
            -1.15, 0.07 * _side,
            _p.hull_mid
        );

        sc_visual_line(_x, _y, _radius, _angle, -0.64, 0.17 * _side, -1.12, 0.125 * _side, 6, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.68, 0.17 * _side, -1.14, 0.125 * _side, 3, _p.energy);
        sc_visual_circle(_x, _y, _radius, _angle, -1.14, 0.125 * _side, 0.055, _p.core, false);
    }

    // Reactor socket behind the separately rotating core.
    sc_visual_circle(_x, _y, _radius, _angle, -0.08, 0, 0.235, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.08, 0, 0.235, _p.hull_light, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.08, 0, 0.175, _p.glow, true);

    // Central spine.
    sc_visual_line(_x, _y, _radius, _angle, -0.72, 0, 1.62, 0, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.28, 0, 1.57, 0, 1, _p.energy);

    // Thin aqua silhouette identifier.
    sc_visual_line(_x, _y, _radius, _angle, 1.73, 0, 0.58, -0.2, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 0.58, -0.2, -0.27, -0.36, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -0.27, -0.36, -0.88, -0.29, 1, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, -0.88, -0.29, -1.2, -0.15, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -1.2, -0.15, -1.2, 0.15, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -1.2, 0.15, -0.88, 0.29, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -0.88, 0.29, -0.27, 0.36, 1, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, -0.27, 0.36, 0.58, 0.2, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 0.58, 0.2, 1.73, 0, 1, _p.energy);

    // Hull damage remains visible beneath armour.
    if (_stage >= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.38, -0.19, 0.13, -0.31, 3, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.27, -0.25, 0.18, -0.1, 2, _p.void);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.43, 0.25, 0.14, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.43, 0.25, -0.65, 0.31, 2, _p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.91, -0.16, 0.17, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.9, -0.16, -1.16, -0.25, 2, _p.energy);
    }
}

/// @description Draws one compact independent Shard cannon.
function sc_ship_shard_cannon_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Compact dark mount.
    sc_visual_quad(_x, _y, _radius, _angle,
        -0.2, -0.13,
        0.14, -0.12,
        0.14, 0.12,
        -0.2, 0.13,
        _p.hull_dark
    );

    sc_visual_circle(_x, _y, _radius, _angle, -0.1, 0, 0.15, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.1, 0, 0.15, _p.hull_light, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.1, 0, 0.055, _p.energy, false);

    // Short twin barrel rails.
    sc_visual_line(_x, _y, _radius, _angle, -0.08, -0.075, 0.53, -0.075, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.08, 0.075, 0.53, 0.075, 2, _p.metal);

    sc_visual_line(_x, _y, _radius, _angle, -0.05, 0, 0.55, 0, 6, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0, 0.55, 0, 2, _p.energy);

    // Barrel segmentation.
    sc_visual_line(_x, _y, _radius, _angle, 0.18, -0.1, 0.18, 0.1, 1, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.38, -0.09, 0.38, 0.09, 1, _p.hull_light);

    // Bright muzzle aperture.
    sc_visual_circle(_x, _y, _radius, _angle, 0.55, 0, 0.072, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.55, 0, 0.072, _p.energy, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.55, 0, 0.025, _p.core, false);
}

/// @description Draws compact Shard armour and fixed inner stabilizer blades.
function sc_ship_shard_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Thin silver nose cap.
    if (_stage <= 2)
    {
        var _nose_colour = _stage == 0 ? _p.metal : (_stage == 1 ? _p.hull_light : _p.hull_mid);

        sc_visual_triangle(_x, _y, _radius, _angle, 1.68, 0, 0.73, -0.1, 1.03, 0, _nose_colour, false);
        sc_visual_triangle(_x, _y, _radius, _angle, 1.68, 0, 1.03, 0, 0.73, 0.1, _nose_colour, false);

        sc_visual_line(_x, _y, _radius, _angle, 1.68, 0, 0.73, -0.1, 1, _p.core);
        sc_visual_line(_x, _y, _radius, _angle, 1.68, 0, 0.73, 0.1, 1, _p.core);
    }

    // Small layered shoulder plates.
    if (_stage <= 1)
    {
        var _plate_colour = _stage == 0 ? _p.hull_light : _p.hull_mid;

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle,
                0.55, 0.145 * _side,
                0.16, 0.245 * _side,
                -0.5, 0.245 * _side,
                -0.7, 0.15 * _side,
                _plate_colour
            );

            sc_visual_line(_x, _y, _radius, _angle, 0.55, 0.145 * _side, 0.16, 0.245 * _side, 1, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.06, 0.225 * _side, -0.42, 0.225 * _side, 2, _p.accent);
        }
    }

    // Small fixed blades close to the fuselage.
    if (_stage <= 2)
    {
        var _fin_colour = _stage == 0 ? _p.hull_mid : (_stage == 1 ? _p.hull_dark : _p.void);

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_triangle(_x, _y, _radius, _angle,
                0.05, 0.28 * _side,
                -0.36, 0.52 * _side,
                -0.7, 0.29 * _side,
                _fin_colour,
                false
            );

            sc_visual_line(_x, _y, _radius, _angle, 0.05, 0.28 * _side, -0.36, 0.52 * _side, 1, _p.energy);
            sc_visual_line(_x, _y, _radius, _angle, -0.36, 0.52 * _side, -0.7, 0.29 * _side, 1, _p.outline);
        }
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.08, 0, 0.26, _p.hull_light, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.08, 0, 0.2, _p.accent, true);
    }
}

/// @description Draws one short swept folding Shard wing.
function sc_ship_shard_wing_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Mechanical attachment remains visible at the fuselage edge.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.28, -0.06,
        0.17, 0.18,
        -0.34, 0.24,
        -0.49, 0.04,
        _p.void
    );

    sc_visual_quad(_x, _y, _radius, _angle,
        0.22, -0.015,
        0.13, 0.15,
        -0.3, 0.19,
        -0.4, 0.055,
        _p.hull_mid
    );

    sc_visual_circle(_x, _y, _radius, _angle, 0.02, 0.1, 0.085, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.02, 0.1, 0.085, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.02, 0.1, 0.032, _p.energy, false);

    // Short rear-swept blade.
    sc_visual_triangle(_x, _y, _radius, _angle,
        0.2, 0.08,
        -0.02, 0.28,
        -0.9, 0.55,
        _p.hull_dark,
        false
    );

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.2, 0.08,
        -0.9, 0.55,
        -0.49, 0.08,
        _p.hull_dark,
        false
    );

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.14, 0.11,
        -0.04, 0.24,
        -0.77, 0.48,
        _p.hull_mid,
        false
    );

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.14, 0.11,
        -0.77, 0.48,
        -0.43, 0.12,
        _p.hull_mid,
        false
    );

    // Thin aqua outline.
    sc_visual_line(_x, _y, _radius, _angle, 0.2, 0.08, -0.02, 0.28, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -0.02, 0.28, -0.9, 0.55, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -0.9, 0.55, -0.49, 0.08, 1, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, -0.49, 0.08, 0.2, 0.08, 1, _p.energy);

    // Narrow powered wing channel.
    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0.21, -0.63, 0.42, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0.21, -0.62, 0.415, 2, _p.accent);
    sc_visual_circle(_x, _y, _radius, _angle, -0.62, 0.415, 0.026, _p.core, false);

    if (_stage >= 1)
        sc_visual_line(_x, _y, _radius, _angle, -0.14, 0.22, -0.32, 0.34, 3, _p.void);

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.52, 0.38, 0.11, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.52, 0.38, -0.69, 0.49, 2, _p.accent);
    }

    if (_stage >= 3)
        sc_visual_triangle(_x, _y, _radius, _angle, -0.65, 0.45, -0.9, 0.55, -0.76, 0.43, _p.void, false);
}

/// @description Draws the thin armour cap for one folding Shard wing.
function sc_ship_shard_wing_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    if (_stage >= 3) return;

    var _p = _visual.palette;
    var _colour = _stage == 0 ? _p.hull_light : (_stage == 1 ? _p.hull_mid : _p.hull_dark);

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.14, 0.1,
        -0.02, 0.23,
        -0.68, 0.44,
        _colour,
        false
    );

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.14, 0.1,
        -0.68, 0.44,
        -0.4, 0.13,
        _colour,
        false
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.14, 0.1, -0.02, 0.23, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.02, 0.23, -0.68, 0.44, 1, _p.core);

    if (_stage <= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.01, 0.2, -0.48, 0.355, 4, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.01, 0.2, -0.47, 0.35, 1, _p.energy);
    }

    if (_stage == 2)
        sc_visual_line(_x, _y, _radius, _angle, -0.24, 0.27, -0.44, 0.37, 2, _p.void);
}

/// @description Bakes the Shard shield using its registered collision ellipse.
function sc_ship_shard_shield_draw(_x, _y, _radius, _angle, _visual, _collision)
{
    sc_visual_shield_bake_draw(_x, _y, _collision.radius_forward, _collision.radius_side, _visual.palette);
}

/// @description Draws the Shard's attached twin aqua engine flames.
function sc_ship_shard_thrust_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _side_offset = _radius * 0.145 * _side;
        var _base_x = _x + lengthdir_x(_side_offset, _angle + 90);
        var _base_y = _y + lengthdir_y(_side_offset, _angle + 90);
        var _outer_tip_x = _base_x + lengthdir_x(_radius * 1.05, _angle);
        var _outer_tip_y = _base_y + lengthdir_y(_radius * 1.05, _angle);
        var _energy_tip_x = _base_x + lengthdir_x(_radius * 0.8, _angle);
        var _energy_tip_y = _base_y + lengthdir_y(_radius * 0.8, _angle);
        var _core_tip_x = _base_x + lengthdir_x(_radius * 0.48, _angle);
        var _core_tip_y = _base_y + lengthdir_y(_radius * 0.48, _angle);

        draw_set_alpha(0.32);
        draw_set_colour(_p.glow);
        draw_triangle(
            _base_x + lengthdir_x(-_radius * 0.15, _angle + 90),
            _base_y + lengthdir_y(-_radius * 0.15, _angle + 90),
            _outer_tip_x,
            _outer_tip_y,
            _base_x + lengthdir_x(_radius * 0.15, _angle + 90),
            _base_y + lengthdir_y(_radius * 0.15, _angle + 90),
            false
        );

        draw_set_alpha(0.82);
        draw_set_colour(_p.energy);
        draw_triangle(
            _base_x + lengthdir_x(-_radius * 0.09, _angle + 90),
            _base_y + lengthdir_y(-_radius * 0.09, _angle + 90),
            _energy_tip_x,
            _energy_tip_y,
            _base_x + lengthdir_x(_radius * 0.09, _angle + 90),
            _base_y + lengthdir_y(_radius * 0.09, _angle + 90),
            false
        );

        draw_set_alpha(1);
        draw_set_colour(_p.core);
        draw_triangle(
            _base_x + lengthdir_x(-_radius * 0.035, _angle + 90),
            _base_y + lengthdir_y(-_radius * 0.035, _angle + 90),
            _core_tip_x,
            _core_tip_y,
            _base_x + lengthdir_x(_radius * 0.035, _angle + 90),
            _base_y + lengthdir_y(_radius * 0.035, _angle + 90),
            false
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the Shard's small independently rotating drive core.
function sc_ship_shard_core_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.215;
    var _middle = _radius * 0.15;
    var _inner = _radius * 0.072;

    draw_set_alpha(0.28);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _outer * 1.5, false);

    draw_set_alpha(1);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _outer, false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x, _y, _outer, true);

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _middle, true);

    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _angle + _i * 90;
        var _inner_x = _x + lengthdir_x(_inner, _direction);
        var _inner_y = _y + lengthdir_y(_inner, _direction);
        var _outer_x = _x + lengthdir_x(_outer * 0.88, _direction + 22);
        var _outer_y = _y + lengthdir_y(_outer * 0.88, _direction + 22);

        draw_set_colour((_i mod 2) == 0 ? _p.core : _p.accent);
        draw_line_width(_inner_x, _inner_y, _outer_x, _outer_y, 2);
    }

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _inner, false);

    draw_set_colour(_p.core);
    draw_circle(_x, _y, _inner * 0.42, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one bright Shard muzzle-flash animation frame for startup baking.
function sc_ship_shard_muzzle_flash_draw(_x, _y, _radius, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _progress = _frame_count > 1 ? _frame / (_frame_count - 1) : 0;
    var _power = 1 - _progress * 0.72;
    var _length = _radius * lerp(0.72, 0.28, _progress);
    var _width = _radius * lerp(0.34, 0.13, _progress);
    var _tip_x = _x + lengthdir_x(_length, _angle);
    var _tip_y = _y + lengthdir_y(_length, _angle);

    draw_set_alpha(0.48 * _power);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _width * 1.9, false);

    draw_set_alpha(0.82 * _power);
    draw_set_colour(_p.energy);
    draw_triangle(
        _x + lengthdir_x(-_width, _angle + 90),
        _y + lengthdir_y(-_width, _angle + 90),
        _tip_x,
        _tip_y,
        _x + lengthdir_x(_width, _angle + 90),
        _y + lengthdir_y(_width, _angle + 90),
        false
    );

    var _side_length = _length * 0.55;
    var _side_width = _width * 1.35;

    draw_set_alpha(0.72 * _power);
    draw_set_colour(_p.energy);
    draw_triangle(
        _x,
        _y,
        _x + lengthdir_x(_side_length, _angle - 28),
        _y + lengthdir_y(_side_length, _angle - 28),
        _x + lengthdir_x(_side_width, _angle - 90),
        _y + lengthdir_y(_side_width, _angle - 90),
        false
    );
    draw_triangle(
        _x,
        _y,
        _x + lengthdir_x(_side_width, _angle + 90),
        _y + lengthdir_y(_side_width, _angle + 90),
        _x + lengthdir_x(_side_length, _angle + 28),
        _y + lengthdir_y(_side_length, _angle + 28),
        false
    );

    draw_set_alpha(_power);
    draw_set_colour(_p.core);
    draw_line_width(_x, _y, _tip_x, _tip_y, max(3, _width * 0.48));
    draw_circle(_x, _y, max(2, _width * 0.58), false);

    draw_set_colour(c_white);
    draw_circle(_x, _y, max(1, _width * 0.24), false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Shard's baked destruction fragments.
function sc_ship_shard_death(_player)
{
    var _ship = _player.ship;
    var _visual = _ship.visual;
    var _palette = _visual.palette;
    var _cache = _visual.runtime.cache;
    var _movement = _player.movement;
    var _angle = _player.draw_angle;
    var _radius = _visual.radius;
    var _wing = _visual.wing;
    var _fold = _visual.runtime.wing_fold;
    var _hull_stage = array_length(_cache.hull) - 1;
    var _fragments = [];

    array_push(_fragments, sc_death_fragment_data(
        _cache.hull[_hull_stage], _player.x, _player.y,
        _angle + random_range(-20, 20), random_range(0.8, 1.4),
        _angle, choose(-5, 5), 1, 1
    ));

    for (var _side = -1; _side <= 1; _side += 2)
    {
        var _hinge_x = _player.x + lengthdir_x(_wing.hinge_forward * _radius, _angle) + lengthdir_x(_wing.hinge_side * _radius * _side, _angle + 90);
        var _hinge_y = _player.y + lengthdir_y(_wing.hinge_forward * _radius, _angle) + lengthdir_y(_wing.hinge_side * _radius * _side, _angle + 90);
        var _direction = _angle + 90 * _side + random_range(-16, 16);

        array_push(_fragments, sc_death_fragment_data(
            _cache.wing_hull[_hull_stage], _hinge_x, _hinge_y,
            _direction, random_range(2, 3.2),
            _angle + _fold * _side, 7 * _side, 1, _side
        ));
    }

    var _core = _visual.core;
    var _core_x = _player.x + lengthdir_x(_core.forward * _radius, _angle) + lengthdir_x(_core.side * _radius, _angle + 90);
    var _core_y = _player.y + lengthdir_y(_core.forward * _radius, _angle) + lengthdir_y(_core.side * _radius, _angle + 90);

    array_push(_fragments, sc_death_fragment_data(
        _cache.core, _core_x, _core_y,
        irandom(359), random_range(1.8, 2.8),
        _angle + _visual.runtime.core_angle, choose(-13, 13), 1, 1
    ));

    var _hardpoints = _ship.hardpoints.primary;

    for (var _i = 0; _i < array_length(_hardpoints); _i++)
    {
        var _hardpoint = _hardpoints[_i];
        var _mount_x = _player.x + lengthdir_x(_hardpoint.x, _angle) + lengthdir_x(_hardpoint.y, _angle + 90);
        var _mount_y = _player.y + lengthdir_y(_hardpoint.x, _angle) + lengthdir_y(_hardpoint.y, _angle + 90);
        var _side = _hardpoint.y < 0 ? -1 : 1;
        var _direction = _angle + 55 * _side + random_range(-14, 14);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoint, _mount_x, _mount_y,
            _direction, random_range(2.5, 3.8),
            _angle + _hardpoint.angle, 10 * _side,
            _hardpoint.scale, _hardpoint.scale
        ));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _movement.velocity_x * 0.35;
        _fragments[_i].velocity_y += _movement.velocity_y * 0.35;
    }

    sc_death_fragment_create(_player.x, _player.y, _fragments, _palette.core, _palette.glow, _radius, 44);

    // Insert Shard destruction particles and audio here later.
    return true;
}