/// @description Registers the fast silver-aqua Shard chassis.
function sc_ship_register_shard()
{
    return sc_ship_register({
        identity: { key: "ship_shard", name: "Shard", description: "A fast silver-aqua interceptor with adaptive swept wings." },

        stats_base: {
			mass: 1,
            hull_max: 75, armour_max: 25, shield_max: 40,
            shield_recharge_delay: 150, shield_recharge_rate: 0.35, shield_energy_cost: 1,

            energy_max: 500, energy_regeneration: 0.2, energy_recharge_delay: 45,
            fuel_max: 1000, fuel_regeneration: 0,
            fuel_movement_cost: 0.015, fuel_boost_cost: 0.06, fuel_dash_cost: 8,

            bullets_max: 1500, explosives_max: 100,
            cargo_capacity: 100,

            speed_max: 10, acceleration: 0.6, deceleration: 0.7, turn_speed: 10,
            directional_speed_min: 0.72, directional_thrust_min: 0.28,
            damage_multiplier: 1, fire_rate_multiplier: 1,

            boost_speed_multiplier: 1.35, dash_speed: 22, dash_duration: 16, dash_cooldown: 90,
            dash_double_tap_window: 15, dash_exit_speed_multiplier: 0.45, dash_invulnerable: 1,
            weapons_while_boosting: 0, weapons_while_dashing: 0,
			
			resource_yield_multiplier: 1,
        },

        collision: {
            radius_forward: 76,
            radius_side: 36
        },
		systems: sc_ship_systems_standard(),
        visual: sc_ship_shard_visual_data(),

        hardpoints: {
            primary: [
                { key: "primary_left", x: 5, y: -32, angle: 0, muzzle_forward: 25, scale: 0.9 },
                { key: "primary_right", x: 5, y: 32, angle: 0, muzzle_forward: 25, scale: 0.9 }
            ],

            utility: []
        },

        starting_loadout: {
            primary: "weapon_shard_pulse",
            primary_slot: 0,

            primary_slots: [
                "weapon_shard_pulse",
                "weapon_minigun",
                "weapon_shard_laser",
                "weapon_shard_rocket"
            ],

            mining: "weapon_shard_mining_beam",
			secondary: undefined
        }
    });
}

/// @description Returns the complete visual definition for the Shard chassis.
function sc_ship_shard_visual_data()
{
    return {
        radius: 46,
		motion_strength: 3,

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
            outline: make_colour_rgb(45, 105, 120),
            accent: make_colour_rgb(25, 135, 255),
            energy: make_colour_rgb(25, 225, 255),
            core: make_colour_rgb(220, 255, 255),
            glow: make_colour_rgb(0, 115, 195)
        },

        wing: {
            hinge_forward: -0.03, hinge_side: 0.34,
            fold_idle: -2, fold_moving: 4, fold_boost: 10, fold_dash: 16,
            fold_response: 0.14
        },

        core: {
            forward: -0.18, side: 0,
            idle_speed: 0.45, movement_speed: 4.5,
            boost_multiplier: 1.35, dash_multiplier: 1.75,
            response: 0.12
        },

        thrust: {
            mounts: [
                { forward: -1.08, side: -0.13, scale: 0.72, phase: 0 },
                { forward: -1.08, side: 0.13, scale: 0.72, phase: 0 }
            ],

            ignition_script: sc_particles_shard_ignition,
            particle_script: sc_particles_shard_thrust
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


/// @description Draws the Shard's compact twin-engine interceptor hull.
function sc_ship_shard_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Compact main fuselage.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.18, 0, 0.48, -0.25, 0.48, 0.25, _p.hull_dark, false);
    sc_visual_quad(_x, _y, _radius, _angle, 0.48, -0.25, -0.37, -0.31, -0.37, 0.31, 0.48, 0.25, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -0.37, -0.31, -0.92, -0.23, -0.92, 0.23, -0.37, 0.31, _p.hull_dark);

    // Distinct raised nose wedge.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.18, 0, 0.53, -0.16, 0.53, 0.16, _p.hull_light, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.12, 0, 0.67, -0.105, 0.27, 0, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.12, 0, 0.27, 0, 0.67, 0.105, _p.hull_mid, false);

    // Cockpit.
    sc_visual_triangle(_x, _y, _radius, _angle, 0.98, 0, 0.62, -0.09, 0.34, 0, _p.void, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.98, 0, 0.34, 0, 0.62, 0.09, _p.void, false);
    sc_visual_line(_x, _y, _radius, _angle, 0.98, 0, 0.62, -0.09, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 0.98, 0, 0.62, 0.09, 1, _p.energy);

    // Shoulder structure joining fuselage to wings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle, 0.48, 0.18 * _side, 0.15, 0.36 * _side, -0.48, 0.41 * _side, -0.71, 0.24 * _side, _p.hull_mid);
        sc_visual_quad(_x, _y, _radius, _angle, 0.33, 0.21 * _side, 0.08, 0.31 * _side, -0.41, 0.34 * _side, -0.58, 0.22 * _side, _p.hull_light);

        sc_visual_line(_x, _y, _radius, _angle, 0.45, 0.2 * _side, 0.12, 0.34 * _side, 1, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 0.06, 0.31 * _side, -0.43, 0.34 * _side, 2, _p.accent);
    }

    // Large separated rear engine pods.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle, -0.27, 0.18 * _side, -0.47, 0.39 * _side, -1.02, 0.34 * _side, -1.08, 0.15 * _side, _p.void);
        sc_visual_quad(_x, _y, _radius, _angle, -0.33, 0.2 * _side, -0.5, 0.34 * _side, -0.94, 0.3 * _side, -0.99, 0.17 * _side, _p.hull_mid);

        sc_visual_line(_x, _y, _radius, _angle, -0.51, 0.31 * _side, -0.93, 0.27 * _side, 2, _p.metal);

        // Engine aperture.
        sc_visual_line(_x, _y, _radius, _angle, -0.78, 0.22 * _side, -1.04, 0.19 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.8, 0.22 * _side, -1.05, 0.19 * _side, 3, _p.energy);
        sc_visual_circle(_x, _y, _radius, _angle, -1.04, 0.19 * _side, 0.055, _p.core, false);
    }

    // Central reactor socket.
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.22, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.22, _p.hull_light, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.16, _p.glow, true);

    // Strong central spine.
    sc_visual_line(_x, _y, _radius, _angle, -0.72, 0, 1.08, 0, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.17, 0, 1.08, 0, 2, _p.energy);

    // Cyan silhouette highlights.
    sc_visual_line(_x, _y, _radius, _angle, 1.18, 0, 0.48, -0.25, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 1.18, 0, 0.48, 0.25, 1, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 0.48, -0.25, -0.37, -0.31, 1, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, 0.48, 0.25, -0.37, 0.31, 1, _p.outline);

    // Damage.
    if (_stage >= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.34, -0.18, 0.07, -0.29, 3, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.21, -0.23, 0.12, -0.07, 2, _p.void);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.43, 0.26, 0.13, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.43, 0.26, -0.62, 0.36, 2, _p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.82, -0.18, 0.17, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.82, -0.18, -1.04, -0.3, 2, _p.energy);
    }
}

/// @description Draws one compact wing-mounted Shard pulse cannon.
function sc_ship_shard_cannon_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Low-profile mounting block.
    sc_visual_quad(_x, _y, _radius, _angle, -0.2, -0.12, 0.13, -0.11, 0.13, 0.11, -0.2, 0.12, _p.hull_dark);
    sc_visual_line(_x, _y, _radius, _angle, -0.17, -0.12, 0.14, -0.11, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.17, 0.12, 0.14, 0.11, 1, _p.metal);

    // Energy-fed breech.
    sc_visual_circle(_x, _y, _radius, _angle, -0.09, 0, 0.135, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.09, 0, 0.135, _p.hull_light, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.09, 0, 0.045, _p.energy, false);

    // Short heavy barrel.
    sc_visual_line(_x, _y, _radius, _angle, 0, 0, 0.47, 0, 7, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0, 0.48, 0, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.1, 0, 0.46, 0, 1, _p.energy);

    // Muzzle.
    sc_visual_circle(_x, _y, _radius, _angle, 0.49, 0, 0.07, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.49, 0, 0.07, _p.energy, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.49, 0, 0.024, _p.core, false);
}

/// @description Draws compact interceptor armour over the Shard fuselage.
function sc_ship_shard_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Bright angular nose cap.
    if (_stage <= 2)
    {
        var _nose_colour = _stage == 0 ? _p.metal : (_stage == 1 ? _p.hull_light : _p.hull_mid);

        sc_visual_triangle(_x, _y, _radius, _angle, 1.16, 0, 0.73, -0.095, 0.97, 0, _nose_colour, false);
        sc_visual_triangle(_x, _y, _radius, _angle, 1.16, 0, 0.97, 0, 0.73, 0.095, _nose_colour, false);

        sc_visual_line(_x, _y, _radius, _angle, 1.16, 0, 0.73, -0.095, 1, _p.core);
        sc_visual_line(_x, _y, _radius, _angle, 1.16, 0, 0.73, 0.095, 1, _p.core);
    }

    // Broad shoulder armour.
    if (_stage <= 1)
    {
        var _plate_colour = _stage == 0 ? _p.hull_light : _p.hull_mid;

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle, 0.51, 0.17 * _side, 0.14, 0.3 * _side, -0.45, 0.32 * _side, -0.63, 0.19 * _side, _plate_colour);
            sc_visual_line(_x, _y, _radius, _angle, 0.51, 0.17 * _side, 0.14, 0.3 * _side, 1, _p.metal);
            sc_visual_line(_x, _y, _radius, _angle, 0.03, 0.27 * _side, -0.38, 0.28 * _side, 2, _p.energy);
        }
    }

    // Rear engine armour collars.
    if (_stage <= 2)
    {
        var _engine_colour = _stage == 0 ? _p.hull_mid : (_stage == 1 ? _p.hull_dark : _p.void);

        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle, -0.38, 0.22 * _side, -0.52, 0.34 * _side, -0.82, 0.31 * _side, -0.72, 0.2 * _side, _engine_colour);
            sc_visual_line(_x, _y, _radius, _angle, -0.52, 0.34 * _side, -0.82, 0.31 * _side, 1, _p.metal);
        }
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.25, _p.hull_light, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.18, 0, 0.19, _p.accent, true);
    }
}

/// @description Draws one broad swept fighter wing with mechanical attachment.
function sc_ship_shard_wing_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Mechanical wing root.
    sc_visual_quad(_x, _y, _radius, _angle, 0.31, -0.05, 0.21, 0.2, -0.3, 0.28, -0.48, 0.04, _p.void);
    sc_visual_quad(_x, _y, _radius, _angle, 0.26, 0, 0.17, 0.17, -0.27, 0.23, -0.4, 0.06, _p.hull_mid);

    sc_visual_circle(_x, _y, _radius, _angle, 0.02, 0.12, 0.09, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.02, 0.12, 0.09, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.02, 0.12, 0.035, _p.energy, false);

    // Broad swept wing silhouette.
    sc_visual_triangle(_x, _y, _radius, _angle, 0.3, 0.08, 0.03, 0.44, -0.74, 0.78, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.3, 0.08, -0.74, 0.78, -0.63, 0.13, _p.hull_dark, false);

    // Raised inner wing.
    sc_visual_triangle(_x, _y, _radius, _angle, 0.2, 0.13, 0.01, 0.37, -0.61, 0.67, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.2, 0.13, -0.61, 0.67, -0.54, 0.17, _p.hull_mid, false);

    // Wing edges.
    sc_visual_line(_x, _y, _radius, _angle, 0.3, 0.08, 0.03, 0.44, 2, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 0.03, 0.44, -0.74, 0.78, 2, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, -0.74, 0.78, -0.63, 0.13, 1, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, -0.63, 0.13, 0.3, 0.08, 1, _p.metal);

    // Powered wing channel.
    sc_visual_line(_x, _y, _radius, _angle, 0.05, 0.32, -0.48, 0.59, 6, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.05, 0.32, -0.47, 0.585, 2, _p.accent);
    sc_visual_circle(_x, _y, _radius, _angle, -0.47, 0.585, 0.03, _p.core, false);

    // Panel division.
    sc_visual_line(_x, _y, _radius, _angle, -0.18, 0.34, -0.32, 0.59, 1, _p.hull_light);

    if (_stage >= 1)
        sc_visual_line(_x, _y, _radius, _angle, -0.12, 0.31, -0.32, 0.49, 3, _p.void);

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.45, 0.55, 0.12, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.45, 0.55, -0.64, 0.7, 2, _p.accent);
    }

    if (_stage >= 3)
        sc_visual_triangle(_x, _y, _radius, _angle, -0.52, 0.65, -0.74, 0.78, -0.63, 0.58, _p.void, false);
}

/// @description Draws the armour plate over one broad Shard fighter wing.
function sc_ship_shard_wing_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    if (_stage >= 3) return;

    var _p = _visual.palette;
    var _colour = _stage == 0 ? _p.hull_light : (_stage == 1 ? _p.hull_mid : _p.hull_dark);

    sc_visual_triangle(_x, _y, _radius, _angle, 0.19, 0.12, 0.02, 0.36, -0.54, 0.64, _colour, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.19, 0.12, -0.54, 0.64, -0.48, 0.18, _colour, false);

    sc_visual_line(_x, _y, _radius, _angle, 0.19, 0.12, 0.02, 0.36, 1, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0.36, -0.54, 0.64, 1, _p.core);

    if (_stage <= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.01, 0.3, -0.39, 0.51, 5, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.01, 0.3, -0.38, 0.505, 1, _p.energy);
    }

    if (_stage == 2)
        sc_visual_line(_x, _y, _radius, _angle, -0.21, 0.39, -0.42, 0.54, 2, _p.void);
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

/// @description Draws the Shard's compact embedded rotating drive core.
function sc_ship_shard_core_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.195;
    var _middle = _radius * 0.135;
    var _inner = _radius * 0.06;

    // Soft reactor glow.
    draw_set_alpha(0.24);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _outer * 1.45, false);

    // Embedded socket.
    draw_set_alpha(1);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _outer, false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x, _y, _outer, true);

    // Rotating four-blade mechanism.
    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _angle + _i * 90;
        var _inner_x = _x + lengthdir_x(_inner, _direction);
        var _inner_y = _y + lengthdir_y(_inner, _direction);
        var _outer_x = _x + lengthdir_x(_outer * 0.86, _direction + 24);
        var _outer_y = _y + lengthdir_y(_outer * 0.86, _direction + 24);

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.accent);
        draw_line_width(_inner_x, _inner_y, _outer_x, _outer_y, 2);
    }

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _middle, true);
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

/// @description Registers all particle types used by the Shard engines.
function sc_particles_register_shard()
{
    var _outer = sc_particles_type_create();
    var _inner = sc_particles_type_create();
    var _fire = sc_particles_type_create();
    var _ring = sc_particles_type_create();
    var _flash = sc_particles_type_create();
    var _dash = sc_particles_type_create();

    if (!part_type_exists(_outer) || !part_type_exists(_inner) || !part_type_exists(_fire)
    || !part_type_exists(_ring) || !part_type_exists(_flash) || !part_type_exists(_dash))
    {
        show_debug_message("SHARD PARTICLE ERROR - type creation failed");
        return false;
    }

    // Short-lived overlapping flame avoids comb trails while turning.
    part_type_sprite(_outer, s_particle_trail_white_beam, false, false, false);
    part_type_colour3(_outer, make_colour_rgb(0, 65, 210), make_colour_rgb(0, 175, 255), make_colour_rgb(35, 235, 255));
    part_type_alpha3(_outer, 0.78, 0.52, 0);
    part_type_speed(_outer, 0.15, 0.55, -0.02, 0);
    part_type_life(_outer, 3, 5);
    part_type_orientation(_outer, 180, 180, 0, 0, true);
    part_type_blend(_outer, true);

    part_type_sprite(_inner, s_particle_trail_white_beam, false, false, false);
    part_type_colour3(_inner, c_white, make_colour_rgb(175, 255, 255), make_colour_rgb(15, 195, 255));
    part_type_alpha3(_inner, 1, 0.68, 0);
    part_type_speed(_inner, 0.2, 0.7, -0.025, 0);
    part_type_life(_inner, 2, 4);
    part_type_orientation(_inner, 180, 180, 0, 0, true);
    part_type_blend(_inner, true);

    // Softer fire is allowed to detach and linger slightly longer.
    part_type_sprite(_fire, s_particle_firesmoke_trail_color, false, false, false);
    part_type_colour1(_fire, c_white);
    part_type_alpha3(_fire, 0.3, 0.16, 0);
    part_type_speed(_fire, 0.4, 1, -0.025, 0);
    part_type_life(_fire, 7, 11);
    part_type_orientation(_fire, 180, 180, 0, 0, true);
    part_type_blend(_fire, false);

    part_type_sprite(_ring, s_particle_ring_v2, false, false, false);
    part_type_colour2(_ring, c_white, make_colour_rgb(25, 225, 255));
    part_type_alpha2(_ring, 0.95, 0);
    part_type_speed(_ring, 0, 0, 0, 0);
    part_type_life(_ring, 8, 12);
    part_type_orientation(_ring, 0, 359, 0, 2, false);
    part_type_blend(_ring, true);

    part_type_sprite(_flash, s_particle_exposion_star, false, false, false);
    part_type_colour2(_flash, c_white, make_colour_rgb(25, 225, 255));
    part_type_alpha3(_flash, 1, 0.65, 0);
    part_type_speed(_flash, 0, 0, 0, 0);
    part_type_life(_flash, 5, 8);
    part_type_orientation(_flash, 0, 359, 0, 5, false);
    part_type_blend(_flash, true);

    part_type_sprite(_dash, s_particle_trail_white_arrow, false, false, false);
    part_type_colour3(_dash, c_white, make_colour_rgb(40, 235, 255), make_colour_rgb(0, 80, 220));
    part_type_alpha3(_dash, 0.9, 0.58, 0);
    part_type_speed(_dash, 0.35, 0.9, -0.03, 0);
    part_type_life(_dash, 3, 5);
    part_type_orientation(_dash, 180, 180, 0, 0, true);
    part_type_blend(_dash, true);

    return sc_particles_group_register("shard", {
        outer: _outer, inner: _inner, fire: _fire,
        ring: _ring, flash: _flash, dash: _dash
    });
}

/// @description Emits one powerful layered Shard engine ignition burst.
function sc_particles_shard_ignition(_x, _y, _direction, _scale, _power)
{
    var _types = sc_particles_group_get("shard");
    if (!is_struct(_types)) return false;

    var _strength = max(1, _power);
    part_type_size(_types.ring, 0.22 * _scale, 0.31 * _scale, 0.055 * _scale, 0);
    part_type_size(_types.flash, 0.24 * _scale, 0.34 * _scale, -0.022 * _scale, 0);
    part_type_size(_types.dash, 0.38 * _scale, 0.56 * _scale, -0.018 * _scale, 0);
    part_type_direction(_types.dash, _direction - 6, _direction + 6, 0, 0);

    part_particles_create(global.particles.system, _x, _y, _types.ring, 2);
    part_particles_create(global.particles.system, _x, _y, _types.flash, 2);
    part_particles_create(global.particles.system, _x, _y, _types.dash, _strength > 1 ? 5 : 3);
    return true;
}

/// @description Emits a dense powerful Shard exhaust responding to movement state.
function sc_particles_shard_thrust(_x, _y, _direction, _power, _scale, _boosting, _dashing)
{
    var _types = sc_particles_group_get("shard");
    if (!is_struct(_types)) return false;

    var _intensity = max(0.18, _power);
    if (_boosting) _intensity *= 1.35;
    if (_dashing) _intensity *= 1.7;

    var _outer_size = (0.38 + _intensity * 0.62) * _scale;
    var _inner_size = (0.2 + _intensity * 0.36) * _scale;
    var _outer_count = _dashing ? 4 : (_boosting ? 3 : 2);
    var _inner_count = _dashing ? 2 : 1;

    part_type_direction(_types.outer, _direction - 4, _direction + 4, 0, 0);
    part_type_direction(_types.inner, _direction - 2, _direction + 2, 0, 0);
    part_type_size(_types.outer, _outer_size * 0.82, _outer_size, -0.016 * _scale, 0.01);
    part_type_size(_types.inner, _inner_size * 0.86, _inner_size, -0.012 * _scale, 0.008);

    part_particles_create(global.particles.system, _x, _y, _types.outer, _outer_count);
    part_particles_create(global.particles.system, _x, _y, _types.inner, _inner_count);

    // Occasional warm flame inside the aqua exhaust.
    if (irandom(_boosting || _dashing ? 3 : 7) == 0)
    {
        var _fire_size = (0.18 + _intensity * 0.24) * _scale;
        part_type_direction(_types.fire, _direction - 5, _direction + 5, 0, 0);
        part_type_size(_types.fire, _fire_size * 0.82, _fire_size, -0.009 * _scale, 0);
        part_particles_create(global.particles.system, _x, _y, _types.fire, 1);
    }

    if (_boosting || _dashing)
    {
        var _dash_size = (0.3 + _intensity * 0.42) * _scale;
        part_type_direction(_types.dash, _direction - 3, _direction + 3, 0, 0);
        part_type_size(_types.dash, _dash_size * 0.85, _dash_size, -0.018 * _scale, 0.008);
        part_particles_create(global.particles.system, _x, _y, _types.dash, _dashing ? 3 : 2);
    }

    return true;
}