/// @description Registers the first complete Twin Fighter.
function sc_enemy_register_twin_fighter()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_twin_fighter",
            name: "Twin Fighter",
            faction: Faction.SIMULANT
        },

        stats_base: {
            shield_max: 50,
            armour_max: 200,
            hull_max: 60,

            handling: {
                speed_max: 5.5,
                acceleration: 0.3,
                friction_coeff: 0.985,
                turn_speed: 4,
                directional: true,
                directional_speed_min: 0.48,
                directional_thrust_min: 0.58
            },

		range: {
            detection: 1080,
            combat: 840,
			retreat: 300,
            forget: 1280,
			wander: 500,
			alert_share: 1200			
		},

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        visual: sc_enemy_twin_fighter_visual_data(),

        collision: {
            radius_forward_scale: 1.35,
            radius_side_scale: 0.82,
            blocks_player: true
        },

        hardpoints: [
            { key: "cannon_left", group: "cannons", forward: 0.48, side: -0.56, angle: 0, muzzle_forward: 0.82, draw_script: sc_enemy_twin_fighter_cannon_draw },
            { key: "cannon_right", group: "cannons", forward: 0.48, side: 0.56, angle: 0, muzzle_forward: 0.82, draw_script: sc_enemy_twin_fighter_cannon_draw }
        ],

        thrusters: [
            { key: "thruster_left", forward: -0.92, side: -0.29, angle: 180, scale: 0.82 },
            { key: "thruster_right", forward: -0.92, side: 0.29, angle: 180, scale: 0.82 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "alternating_cannons",
                    weight: 100,
                    hardpoint_group: "cannons",
                    weapon_key: "weapon_simulant_pulse",

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 2
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 10,
                        volley_max: 16,
                        cooldown: 120
                    }
                }
            ]
        }
    });
}

/// @description Returns the complete visual definition for the Twin Fighter.
function sc_enemy_twin_fighter_visual_data()
{
    return {
        radius: 58,
		visual_mass: 1.15,
		motion_strength: 3,
        palette: sc_faction_palette_get(Faction.SIMULANT),
		core: { forward: -0.23, side: 0 },

        draw: {
            body: sc_enemy_twin_fighter_body_draw,
            core: sc_enemy_twin_fighter_core_draw
        },

        death: {
            script: sc_enemy_twin_fighter_death,
            draw_scripts: [
                sc_enemy_twin_fighter_fragment_front_draw,
                sc_enemy_twin_fighter_fragment_left_draw,
                sc_enemy_twin_fighter_fragment_right_draw
            ]
        },

        thrust: {
	    draw_script: sc_enemy_simulant_thrust_draw,
	    ignition_script: sc_particles_enemy_thrust_ignition,
	    particle_script: sc_particles_enemy_thrust_emit
	},

        bake: {
            body_canvas_size: 256,
            core_canvas_size: 128,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 192
        }
    };
}

/// @description Draws the heavy dark twin-nacelle Simulant Fighter body.
function sc_enemy_twin_fighter_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    // Main compact central chassis.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.18, 0, 0.57, -0.29, 0.57, 0.29, _p.hull_dark, false);
    sc_visual_quad(_x, _y, _radius, _angle, 0.57, -0.29, -0.5, -0.36, -0.5, 0.36, 0.57, 0.29, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -0.5, -0.36, -1.01, -0.23, -1.01, 0.23, -0.5, 0.36, _p.hull_dark);

    // Raised central armour.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.08, 0, 0.48, -0.18, -0.48, -0.17, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.08, 0, -0.48, 0.17, 0.48, 0.18, _p.hull_mid, false);
    sc_visual_quad(_x, _y, _radius, _angle, 0.36, -0.13, -0.44, -0.14, -0.73, 0, 0.36, 0, _p.hull_light);
    sc_visual_quad(_x, _y, _radius, _angle, 0.36, 0, -0.73, 0, -0.44, 0.14, 0.36, 0.13, _p.hull_light);

    // Sharp nose armour.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.18, 0, 0.67, -0.11, 0.78, 0, _p.metal, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.18, 0, 0.78, 0, 0.67, 0.11, _p.metal, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.09, 0, 0.73, -0.065, 0.59, 0, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.09, 0, 0.59, 0, 0.73, 0.065, _p.hull_dark, false);

    // Rear shoulder machinery and armour.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle, 0.42, 0.25 * _side, 0.02, 0.48 * _side, -0.62, 0.51 * _side, -0.79, 0.29 * _side, _p.hull_dark);
        sc_visual_quad(_x, _y, _radius, _angle, 0.3, 0.28 * _side, -0.04, 0.41 * _side, -0.52, 0.43 * _side, -0.66, 0.29 * _side, _p.hull_mid);

        sc_visual_line(_x, _y, _radius, _angle, 0.42, 0.25 * _side, 0.02, 0.48 * _side, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 0.02, 0.48 * _side, -0.62, 0.51 * _side, 2, _p.outline);

        // Purple recessed trench.
        sc_visual_line(_x, _y, _radius, _angle, 0.17, 0.36 * _side, -0.46, 0.39 * _side, 6, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.16, 0.36 * _side, -0.45, 0.39 * _side, 2, _p.accent);
    }

    // Short upper/lower swept stabilizer fins.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(_x, _y, _radius, _angle, 0.13, 0.43 * _side, -0.18, 0.78 * _side, -0.61, 0.47 * _side, _p.hull_dark, false);
        sc_visual_triangle(_x, _y, _radius, _angle, 0.06, 0.45 * _side, -0.18, 0.68 * _side, -0.5, 0.47 * _side, _p.hull_mid, false);

        sc_visual_line(_x, _y, _radius, _angle, 0.13, 0.43 * _side, -0.18, 0.78 * _side, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, -0.18, 0.78 * _side, -0.61, 0.47 * _side, 2, _p.outline);

        // Small violet fin detail.
        sc_visual_line(_x, _y, _radius, _angle, -0.06, 0.51 * _side, -0.31, 0.62 * _side, 2, _p.accent);
    }

    // Heavy mounting shoulders for the two long side cannons.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle, 0.64, 0.38 * _side, 0.35, 0.66 * _side, -0.18, 0.66 * _side, -0.39, 0.42 * _side, _p.void);
        sc_visual_quad(_x, _y, _radius, _angle, 0.57, 0.41 * _side, 0.32, 0.59 * _side, -0.11, 0.59 * _side, -0.29, 0.43 * _side, _p.hull_mid);

        sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.41 * _side, 0.32, 0.59 * _side, 2, _p.hull_light);
        sc_visual_line(_x, _y, _radius, _angle, -0.11, 0.59 * _side, -0.29, 0.43 * _side, 2, _p.metal);

        // Circular hardpoint collar.
        sc_visual_circle(_x, _y, _radius, _angle, 0.48, 0.56 * _side, 0.17, _p.void, false);
        sc_visual_circle(_x, _y, _radius, _angle, 0.48, 0.56 * _side, 0.17, _p.metal, true);
        sc_visual_circle(_x, _y, _radius, _angle, 0.48, 0.56 * _side, 0.075, _p.energy, true);
    }

    // Central reactor housing, deliberately slightly rearward.
    sc_visual_circle(_x, _y, _radius, _angle, -0.23, 0, 0.34, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.23, 0, 0.34, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.23, 0, 0.27, _p.hull_light, true);

    // Structural spine.
    sc_visual_line(_x, _y, _radius, _angle, -0.92, 0, 1.05, 0, 5, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, -0.81, 0, 0.72, 0, 2, _p.metal);

    // Small central violet conduit.
    sc_visual_line(_x, _y, _radius, _angle, 0.07, 0, 0.52, 0, 4, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.08, 0, 0.51, 0, 2, _p.accent);

    // Twin rear engine housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle, -0.55, 0.16 * _side, -0.78, 0.34 * _side, -1.02, 0.3 * _side, -1.03, 0.13 * _side, _p.hull_mid);
        sc_visual_line(_x, _y, _radius, _angle, -0.73, 0.23 * _side, -1, 0.21 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.76, 0.23 * _side, -1.01, 0.21 * _side, 3, _p.energy);
        sc_visual_circle(_x, _y, _radius, _angle, -1.01, 0.21 * _side, 0.045, _p.core, false);
    }

    // Neutral silhouette and armour highlights.
    sc_visual_line(_x, _y, _radius, _angle, 1.18, 0, 0.57, -0.29, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 1.18, 0, 0.57, 0.29, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.57, -0.29, -0.5, -0.36, 1, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.29, -0.5, 0.36, 1, _p.outline);
}

/// @description Draws one long silver-gunmetal Twin Fighter pulse nacelle.
function sc_enemy_twin_fighter_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    // Dark attachment/breech.
    sc_visual_quad(_x, _y, _radius, _angle, -0.32, -0.2, 0.02, -0.22, 0.02, 0.22, -0.32, 0.2, _p.hull_dark);
    sc_visual_circle(_x, _y, _radius, _angle, -0.2, 0, 0.2, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.2, 0, 0.2, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.2, 0, 0.08, _p.energy, true);

    // Main long silver tube.
    sc_visual_quad(_x, _y, _radius, _angle, -0.02, -0.16, 0.75, -0.14, 0.75, 0.14, -0.02, 0.16, _p.hull_light);
    sc_visual_quad(_x, _y, _radius, _angle, 0.03, -0.1, 0.73, -0.09, 0.73, 0.09, 0.03, 0.1, _p.metal);

    // Dark central barrel channel.
    sc_visual_line(_x, _y, _radius, _angle, 0.04, 0, 0.82, 0, 8, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.11, 0, 0.79, 0, 2, _p.accent);

    // Segmented mechanical collars.
    sc_visual_line(_x, _y, _radius, _angle, 0.17, -0.17, 0.17, 0.17, 3, _p.hull_dark);
    sc_visual_line(_x, _y, _radius, _angle, 0.22, -0.15, 0.22, 0.15, 2, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.49, -0.15, 0.49, 0.15, 3, _p.hull_dark);
    sc_visual_line(_x, _y, _radius, _angle, 0.54, -0.13, 0.54, 0.13, 2, _p.outline);

    // Metallic outer rails.
    sc_visual_line(_x, _y, _radius, _angle, 0.02, -0.15, 0.74, -0.13, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0.15, 0.74, 0.13, 2, _p.metal);

    // Large square-ish muzzle housing.
    sc_visual_quad(_x, _y, _radius, _angle, 0.68, -0.2, 0.88, -0.18, 0.88, 0.18, 0.68, 0.2, _p.hull_dark);
    sc_visual_line(_x, _y, _radius, _angle, 0.69, -0.2, 0.88, -0.18, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.69, 0.2, 0.88, 0.18, 2, _p.metal);

    // Purple muzzle aperture.
    sc_visual_circle(_x, _y, _radius, _angle, 0.87, 0, 0.145, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.87, 0, 0.145, _p.metal, true);

    // Small machine-like emitter pattern.
    for (var _i = 0; _i < 6; _i++)
    {
        var _dir = _i * 60;
        var _f1 = 0.87 + dcos(_dir) * 0.055;
        var _s1 = dsin(_dir) * 0.055;
        var _f2 = 0.87 + dcos(_dir) * 0.105;
        var _s2 = dsin(_dir) * 0.105;
        sc_visual_line(_x, _y, _radius, _angle, _f1, _s1, _f2, _s2, 2, _p.energy);
    }

    sc_visual_circle(_x, _y, _radius, _angle, 0.87, 0, 0.055, _p.energy, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.87, 0, 0.022, _p.core, false);

    draw_set_alpha(1);
}

/// @description Draws the Twin Fighter's rear-set rotating mechanical energy core.
function sc_enemy_twin_fighter_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.32;
    var _middle = _radius * 0.23;
    var _inner = _radius * 0.105;

    draw_set_alpha(_alpha * 0.28);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _outer * 1.38, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _outer, false);

    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _outer, true);

    draw_set_colour(_p.hull_light);
    draw_circle(_x, _y, _middle, true);

    // Rotating mechanical vanes.
    for (var _i = 0; _i < 6; _i++)
    {
        var _dir = _angle + _i * 60;
        var _x1 = _x + lengthdir_x(_inner * 0.7, _dir);
        var _y1 = _y + lengthdir_y(_inner * 0.7, _dir);
        var _x2 = _x + lengthdir_x(_outer * 0.88, _dir + 15);
        var _y2 = _y + lengthdir_y(_outer * 0.88, _dir + 15);

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.outline);
        draw_line_width(_x1, _y1, _x2, _y2, 2);
    }

    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _inner * 1.55, true);

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _inner, false);

    draw_set_colour(_p.core);
    draw_circle(_x, _y, _inner * 0.45, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one substantial baked Simulant energy flame.
function sc_enemy_simulant_thrust_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;

    var _outer_length = _radius * 0.82;
    var _outer_width = _radius * 0.25;
    var _outer_tip_x = _x + lengthdir_x(_outer_length, _angle);
    var _outer_tip_y = _y + lengthdir_y(_outer_length, _angle);
    var _outer_top_x = _x + lengthdir_x(-_outer_width, _angle + 90);
    var _outer_top_y = _y + lengthdir_y(-_outer_width, _angle + 90);
    var _outer_bottom_x = _x + lengthdir_x(_outer_width, _angle + 90);
    var _outer_bottom_y = _y + lengthdir_y(_outer_width, _angle + 90);

    var _energy_length = _radius * 0.66;
    var _energy_width = _radius * 0.17;
    var _energy_tip_x = _x + lengthdir_x(_energy_length, _angle);
    var _energy_tip_y = _y + lengthdir_y(_energy_length, _angle);
    var _energy_top_x = _x + lengthdir_x(-_energy_width, _angle + 90);
    var _energy_top_y = _y + lengthdir_y(-_energy_width, _angle + 90);
    var _energy_bottom_x = _x + lengthdir_x(_energy_width, _angle + 90);
    var _energy_bottom_y = _y + lengthdir_y(_energy_width, _angle + 90);

    var _core_length = _radius * 0.46;
    var _core_width = _radius * 0.075;
    var _core_tip_x = _x + lengthdir_x(_core_length, _angle);
    var _core_tip_y = _y + lengthdir_y(_core_length, _angle);
    var _core_top_x = _x + lengthdir_x(-_core_width, _angle + 90);
    var _core_top_y = _y + lengthdir_y(-_core_width, _angle + 90);
    var _core_bottom_x = _x + lengthdir_x(_core_width, _angle + 90);
    var _core_bottom_y = _y + lengthdir_y(_core_width, _angle + 90);

    draw_set_alpha(_alpha * 0.38);
    draw_set_colour(_palette.glow);
    draw_triangle(_outer_top_x, _outer_top_y, _outer_tip_x, _outer_tip_y, _outer_bottom_x, _outer_bottom_y, false);

    draw_set_alpha(_alpha * 0.78);
    draw_set_colour(_palette.energy);
    draw_triangle(_energy_top_x, _energy_top_y, _energy_tip_x, _energy_tip_y, _energy_bottom_x, _energy_bottom_y, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.core);
    draw_triangle(_core_top_x, _core_top_y, _core_tip_x, _core_tip_y, _core_bottom_x, _core_bottom_y, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.accent);
    draw_line_width(_x, _y, _outer_tip_x, _outer_tip_y, 2);

    draw_set_alpha(1);
}

/// @description Creates the complete Twin Fighter destruction visual.
function sc_enemy_twin_fighter_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _palette = _visual.palette;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _velocity_x = _data.movement.velocity_x;
    var _velocity_y = _data.movement.velocity_y;
    var _fragments = [];

    sc_particles_simulant_enemy_death(_x, _y, _radius);

    array_push(_fragments, sc_death_fragment_data(_cache.fragments[0], _x + lengthdir_x(_radius * 0.38, _angle), _y + lengthdir_y(_radius * 0.38, _angle), _angle + random_range(-18, 18), random_range(2.2, 3.4), _angle, choose(-7, 7), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[1], _x + lengthdir_x(-_radius * 0.1, _angle) + lengthdir_x(-_radius * 0.42, _angle + 90), _y + lengthdir_y(-_radius * 0.1, _angle) + lengthdir_y(-_radius * 0.42, _angle + 90), _angle - 65 + random_range(-14, 14), random_range(2.4, 4), _angle, random_range(-9, -5), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[2], _x + lengthdir_x(-_radius * 0.1, _angle) + lengthdir_x(_radius * 0.42, _angle + 90), _y + lengthdir_y(-_radius * 0.1, _angle) + lengthdir_y(_radius * 0.42, _angle + 90), _angle + 65 + random_range(-14, 14), random_range(2.4, 4), _angle, random_range(5, 9), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.core, _x, _y, irandom(359), random_range(1.3, 2.3), _angle, choose(-11, 11), 0.9));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _x + lengthdir_x(_hardpoint.forward * _radius, _angle) + lengthdir_x(_hardpoint.side * _radius, _angle + 90);
        var _hardpoint_y = _y + lengthdir_y(_hardpoint.forward * _radius, _angle) + lengthdir_y(_hardpoint.side * _radius, _angle + 90);
        var _direction = _angle + (_hardpoint.side < 0 ? -48 : 48) + random_range(-12, 12);

        array_push(_fragments, sc_death_fragment_data(_cache.hardpoints[_i], _hardpoint_x, _hardpoint_y, _direction, random_range(3, 4.4), _angle, _hardpoint.side < 0 ? -12 : 12, 0.95));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _velocity_x * 0.35;
        _fragments[_i].velocity_y += _velocity_y * 0.35;
    }

    sc_death_fragment_create(_x, _y, _fragments, _palette.core, _palette.glow, _radius, 42);
    return true;
}

/// @description Draws the broken forward fuselage fragment.
function sc_enemy_twin_fighter_fragment_front_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _tip_x = _x + lengthdir_x(_radius * 0.84, _angle);
    var _tip_y = _y + lengthdir_y(_radius * 0.84, _angle);
    var _rear_top_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(-_radius * 0.26, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(-_radius * 0.26, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.26, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.26, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_tip_x, _tip_y, _rear_top_x, _rear_top_y, _rear_bottom_x, _rear_bottom_y, false);
    draw_set_colour(_palette.hull_light);
    draw_line_width(_tip_x, _tip_y, _rear_top_x, _rear_top_y, 2);
    draw_line_width(_tip_x, _tip_y, _rear_bottom_x, _rear_bottom_y, 2);
    draw_set_colour(_palette.energy);
    draw_line_width(_x, _y, _tip_x, _tip_y, 2);
}

/// @description Draws the broken left hull and wing fragment.
function sc_enemy_twin_fighter_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _inner_front_x = _x + lengthdir_x(_radius * 0.26, _angle) + lengthdir_x(-_radius * 0.18, _angle + 90);
    var _inner_front_y = _y + lengthdir_y(_radius * 0.26, _angle) + lengthdir_y(-_radius * 0.18, _angle + 90);
    var _outer_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(-_radius * 0.84, _angle + 90);
    var _outer_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(-_radius * 0.84, _angle + 90);
    var _rear_x = _x + lengthdir_x(-_radius * 0.7, _angle) + lengthdir_x(-_radius * 0.3, _angle + 90);
    var _rear_y = _y + lengthdir_y(-_radius * 0.7, _angle) + lengthdir_y(-_radius * 0.3, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_inner_front_x, _inner_front_y, _outer_x, _outer_y, _rear_x, _rear_y, false);
    draw_set_colour(_palette.metal);
    draw_line_width(_inner_front_x, _inner_front_y, _outer_x, _outer_y, 2);
    draw_line_width(_outer_x, _outer_y, _rear_x, _rear_y, 2);
    draw_set_colour(_palette.accent);
    draw_line_width(_inner_front_x, _inner_front_y, _rear_x, _rear_y, 3);
}

/// @description Draws the broken right hull and wing fragment.
function sc_enemy_twin_fighter_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _inner_front_x = _x + lengthdir_x(_radius * 0.26, _angle) + lengthdir_x(_radius * 0.18, _angle + 90);
    var _inner_front_y = _y + lengthdir_y(_radius * 0.26, _angle) + lengthdir_y(_radius * 0.18, _angle + 90);
    var _outer_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.84, _angle + 90);
    var _outer_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.84, _angle + 90);
    var _rear_x = _x + lengthdir_x(-_radius * 0.7, _angle) + lengthdir_x(_radius * 0.3, _angle + 90);
    var _rear_y = _y + lengthdir_y(-_radius * 0.7, _angle) + lengthdir_y(_radius * 0.3, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_inner_front_x, _inner_front_y, _rear_x, _rear_y, _outer_x, _outer_y, false);
    draw_set_colour(_palette.metal);
    draw_line_width(_inner_front_x, _inner_front_y, _outer_x, _outer_y, 2);
    draw_line_width(_outer_x, _outer_y, _rear_x, _rear_y, 2);
    draw_set_colour(_palette.accent);
    draw_line_width(_inner_front_x, _inner_front_y, _rear_x, _rear_y, 3);
}