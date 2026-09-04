/// @description Registers the Simulant Skirmisher.
function sc_enemy_register_sim_skirmisher()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_skirmisher",
            name: "Simulant Skirmisher",
            faction: Faction.SIMULANT
        },

		reward: { credits: 5 },

        stats_base: {
            shield_max: 30,
            armour_max: 30,
            hull_max: 30,

            handling: {
                speed_max: 7,
                acceleration: 0.42,
                friction_coeff: 0.985,
                turn_speed: 5.5,
                directional: true,
                directional_speed_min: 0.7,
                directional_thrust_min: 0.78
            },

            range: {
		    detection: 1120,
		    combat: 760,
		    retreat: 260,
		    forget: 1320,
		    wander: 0,
		    alert_share: 1200
		},

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },
		
		movement_controller: {
			
			asteroid_response: AsteroidResponse.AVOID,
		    idle_script: sc_enemy_movement_hold,
		    chase_script: sc_enemy_movement_chase,
		    combat_script: sc_enemy_movement_pursue,

		    facing: {
		        default_mode: EnemyFacingMode.TARGET,
		        retreat_mode: EnemyFacingMode.TARGET,
		        angle_offset: 0,
		        turn_speed_scale: 1,
		        spin_speed: 0
		    },

    orbit: {
        range: 0,
        direction: 1,
        radial_strength: 0,
        direction_change_chance: 0
    },

    strafe: {
        amount: 0.25,
        speed: 0.035
    }
},

        visual: sc_enemy_sim_skirmisher_visual_data(),

        collision: {
            radius_forward_scale: 1.05,
            radius_side_scale: 0.82,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "cannon_centre",
                group: "cannon",
                forward: 0.72,
                side: 0,
                angle: 0,
                muzzle_forward: 0.54,
                draw_script: sc_enemy_sim_skirmisher_cannon_draw
            }
        ],

        thrusters: [
            { key: "thruster_left", forward: -0.78, side: -0.2, angle: 180, scale: 0.78 },
            { key: "thruster_right", forward: -0.78, side: 0.2, angle: 180, scale: 0.78 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "centre_pulse",
                    weight: 100,
                    hardpoint_group: "cannon",
                    weapon_key: "weapon_simulant_pulse",
					
					conditions: {
					    line_of_sight: true
					},

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 3,
						fire_tolerance: 8
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 0,
                        volley_max: 3,
                        cooldown: 90
                    }
                }
            ]
        }
    });
}

/// @description Returns the complete visual definition for the Simulant Skirmisher.
function sc_enemy_sim_skirmisher_visual_data()
{
    return {
        radius: 52,
		visual_mass: 0.8,
		motion_strength: 4,
        palette: sc_faction_palette_get(Faction.SIMULANT),
		core: { forward: 0, side: 0 },

        draw: {
            body: sc_enemy_sim_skirmisher_body_draw,
            core: sc_enemy_sim_skirmisher_core_draw
        },

        death: {
            script: sc_enemy_sim_skirmisher_death,

            draw_scripts: [
                sc_enemy_sim_skirmisher_fragment_front_draw,
                sc_enemy_sim_skirmisher_fragment_left_draw,
                sc_enemy_sim_skirmisher_fragment_right_draw
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
            hardpoint_canvas_size: 128,
            thrust_canvas_size: 128,
            fragment_canvas_size: 192
        }
    };
}

/// @description Draws the compact crescent-bladed Simulant Skirmisher body.
function sc_enemy_sim_skirmisher_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;

    var _nose_x = _x + lengthdir_x(_radius * 1.14, _angle);
    var _nose_y = _y + lengthdir_y(_radius * 1.14, _angle);
    var _tail_x = _x + lengthdir_x(-_radius * 0.92, _angle);
    var _tail_y = _y + lengthdir_y(-_radius * 0.92, _angle);

    // Compact central hull.
    var _front_top_x = _x + lengthdir_x(_radius * 0.48, _angle) + lengthdir_x(-_radius * 0.27, _angle + 90);
    var _front_top_y = _y + lengthdir_y(_radius * 0.48, _angle) + lengthdir_y(-_radius * 0.27, _angle + 90);
    var _front_bottom_x = _x + lengthdir_x(_radius * 0.48, _angle) + lengthdir_x(_radius * 0.27, _angle + 90);
    var _front_bottom_y = _y + lengthdir_y(_radius * 0.48, _angle) + lengthdir_y(_radius * 0.27, _angle + 90);
    var _rear_top_x = _x + lengthdir_x(-_radius * 0.58, _angle) + lengthdir_x(-_radius * 0.29, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.58, _angle) + lengthdir_y(-_radius * 0.29, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.58, _angle) + lengthdir_x(_radius * 0.29, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.58, _angle) + lengthdir_y(_radius * 0.29, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_nose_x, _nose_y, _front_top_x, _front_top_y, _rear_top_x, _rear_top_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_top_x, _rear_top_y, _tail_x, _tail_y, false);
    draw_triangle(_nose_x, _nose_y, _tail_x, _tail_y, _rear_bottom_x, _rear_bottom_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_bottom_x, _rear_bottom_y, _front_bottom_x, _front_bottom_y, false);

    // Raised spear armour.
    var _plate_front_x = _x + lengthdir_x(_radius * 0.82, _angle);
    var _plate_front_y = _y + lengthdir_y(_radius * 0.82, _angle);
    var _plate_rear_x = _x + lengthdir_x(-_radius * 0.46, _angle);
    var _plate_rear_y = _y + lengthdir_y(-_radius * 0.46, _angle);
    var _plate_top_x = _x + lengthdir_x(_radius * 0.03, _angle) + lengthdir_x(-_radius * 0.17, _angle + 90);
    var _plate_top_y = _y + lengthdir_y(_radius * 0.03, _angle) + lengthdir_y(-_radius * 0.17, _angle + 90);
    var _plate_bottom_x = _x + lengthdir_x(_radius * 0.03, _angle) + lengthdir_x(_radius * 0.17, _angle + 90);
    var _plate_bottom_y = _y + lengthdir_y(_radius * 0.03, _angle) + lengthdir_y(_radius * 0.17, _angle + 90);

    draw_set_colour(_palette.hull_mid);
    draw_triangle(_plate_front_x, _plate_front_y, _plate_top_x, _plate_top_y, _plate_rear_x, _plate_rear_y, false);
    draw_triangle(_plate_front_x, _plate_front_y, _plate_rear_x, _plate_rear_y, _plate_bottom_x, _plate_bottom_y, false);

    draw_set_colour(_palette.hull_light);
    draw_line_width(_plate_front_x, _plate_front_y, _plate_top_x, _plate_top_y, 2);
    draw_line_width(_plate_top_x, _plate_top_y, _plate_rear_x, _plate_rear_y, 2);
    draw_line_width(_plate_rear_x, _plate_rear_y, _plate_bottom_x, _plate_bottom_y, 2);
    draw_line_width(_plate_bottom_x, _plate_bottom_y, _plate_front_x, _plate_front_y, 2);

    // Mirrored crescent blades.
    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        var _blade_front_x = _x + lengthdir_x(_radius * 0.48, _angle) + lengthdir_x(_radius * 0.25 * _side_sign, _angle + 90);
        var _blade_front_y = _y + lengthdir_y(_radius * 0.48, _angle) + lengthdir_y(_radius * 0.25 * _side_sign, _angle + 90);
        var _blade_tip_x = _x + lengthdir_x(_radius * 0.06, _angle) + lengthdir_x(_radius * 1.02 * _side_sign, _angle + 90);
        var _blade_tip_y = _y + lengthdir_y(_radius * 0.06, _angle) + lengthdir_y(_radius * 1.02 * _side_sign, _angle + 90);
        var _blade_rear_x = _x + lengthdir_x(-_radius * 0.67, _angle) + lengthdir_x(_radius * 0.72 * _side_sign, _angle + 90);
        var _blade_rear_y = _y + lengthdir_y(-_radius * 0.67, _angle) + lengthdir_y(_radius * 0.72 * _side_sign, _angle + 90);
        var _blade_inner_x = _x + lengthdir_x(-_radius * 0.38, _angle) + lengthdir_x(_radius * 0.3 * _side_sign, _angle + 90);
        var _blade_inner_y = _y + lengthdir_y(-_radius * 0.38, _angle) + lengthdir_y(_radius * 0.3 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_dark);
        draw_triangle(_blade_front_x, _blade_front_y, _blade_tip_x, _blade_tip_y, _blade_inner_x, _blade_inner_y, false);
        draw_triangle(_blade_tip_x, _blade_tip_y, _blade_rear_x, _blade_rear_y, _blade_inner_x, _blade_inner_y, false);

        // Raised blade plate.
        var _panel_front_x = _x + lengthdir_x(_radius * 0.34, _angle) + lengthdir_x(_radius * 0.31 * _side_sign, _angle + 90);
        var _panel_front_y = _y + lengthdir_y(_radius * 0.34, _angle) + lengthdir_y(_radius * 0.31 * _side_sign, _angle + 90);
        var _panel_tip_x = _x + lengthdir_x(_radius * 0.01, _angle) + lengthdir_x(_radius * 0.81 * _side_sign, _angle + 90);
        var _panel_tip_y = _y + lengthdir_y(_radius * 0.01, _angle) + lengthdir_y(_radius * 0.81 * _side_sign, _angle + 90);
        var _panel_rear_x = _x + lengthdir_x(-_radius * 0.51, _angle) + lengthdir_x(_radius * 0.6 * _side_sign, _angle + 90);
        var _panel_rear_y = _y + lengthdir_y(-_radius * 0.51, _angle) + lengthdir_y(_radius * 0.6 * _side_sign, _angle + 90);
        var _panel_inner_x = _x + lengthdir_x(-_radius * 0.28, _angle) + lengthdir_x(_radius * 0.34 * _side_sign, _angle + 90);
        var _panel_inner_y = _y + lengthdir_y(-_radius * 0.28, _angle) + lengthdir_y(_radius * 0.34 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_mid);
        draw_triangle(_panel_front_x, _panel_front_y, _panel_tip_x, _panel_tip_y, _panel_inner_x, _panel_inner_y, false);
        draw_triangle(_panel_tip_x, _panel_tip_y, _panel_rear_x, _panel_rear_y, _panel_inner_x, _panel_inner_y, false);

        // Blade edges.
        draw_set_colour(_palette.metal);
        draw_line_width(_blade_front_x, _blade_front_y, _blade_tip_x, _blade_tip_y, 2);
        draw_line_width(_blade_tip_x, _blade_tip_y, _blade_rear_x, _blade_rear_y, 2);

        draw_set_colour(_palette.outline);
        draw_line_width(_blade_rear_x, _blade_rear_y, _blade_inner_x, _blade_inner_y, 2);

        // Thin recessed energy trench.
        var _energy_front_x = _x + lengthdir_x(_radius * 0.27, _angle) + lengthdir_x(_radius * 0.4 * _side_sign, _angle + 90);
        var _energy_front_y = _y + lengthdir_y(_radius * 0.27, _angle) + lengthdir_y(_radius * 0.4 * _side_sign, _angle + 90);
        var _energy_rear_x = _x + lengthdir_x(-_radius * 0.4, _angle) + lengthdir_x(_radius * 0.53 * _side_sign, _angle + 90);
        var _energy_rear_y = _y + lengthdir_y(-_radius * 0.4, _angle) + lengthdir_y(_radius * 0.53 * _side_sign, _angle + 90);

        draw_set_colour(_palette.void);
        draw_line_width(_energy_front_x, _energy_front_y, _energy_rear_x, _energy_rear_y, 6);
        draw_set_colour(_palette.accent);
        draw_line_width(_energy_front_x, _energy_front_y, _energy_rear_x, _energy_rear_y, 2);

        // Rear blade hook.
        var _hook_outer_x = _x + lengthdir_x(-_radius * 0.58, _angle) + lengthdir_x(_radius * 0.63 * _side_sign, _angle + 90);
        var _hook_outer_y = _y + lengthdir_y(-_radius * 0.58, _angle) + lengthdir_y(_radius * 0.63 * _side_sign, _angle + 90);
        var _hook_tip_x = _x + lengthdir_x(-_radius * 0.88, _angle) + lengthdir_x(_radius * 0.47 * _side_sign, _angle + 90);
        var _hook_tip_y = _y + lengthdir_y(-_radius * 0.88, _angle) + lengthdir_y(_radius * 0.47 * _side_sign, _angle + 90);
        var _hook_inner_x = _x + lengthdir_x(-_radius * 0.56, _angle) + lengthdir_x(_radius * 0.35 * _side_sign, _angle + 90);
        var _hook_inner_y = _y + lengthdir_y(-_radius * 0.56, _angle) + lengthdir_y(_radius * 0.35 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_dark);
        draw_triangle(_hook_outer_x, _hook_outer_y, _hook_tip_x, _hook_tip_y, _hook_inner_x, _hook_inner_y, false);

        draw_set_colour(_palette.hull_light);
        draw_line_width(_hook_outer_x, _hook_outer_y, _hook_tip_x, _hook_tip_y, 2);
    }

    // Central core housing.
    draw_set_colour(_palette.void);
    draw_circle(_x, _y, _radius * 0.39, false);
    draw_set_colour(_palette.metal);
    draw_circle(_x, _y, _radius * 0.39, true);
    draw_set_colour(_palette.hull_light);
    draw_circle(_x, _y, _radius * 0.31, true);

    // Centre cannon mount.
    var _mount_x = _x + lengthdir_x(_radius * 0.72, _angle);
    var _mount_y = _y + lengthdir_y(_radius * 0.72, _angle);

    draw_set_colour(_palette.void);
    draw_circle(_mount_x, _mount_y, _radius * 0.18, false);
    draw_set_colour(_palette.metal);
    draw_circle(_mount_x, _mount_y, _radius * 0.18, true);
    draw_set_colour(_palette.energy);
    draw_circle(_mount_x, _mount_y, _radius * 0.075, true);

    // Central structural spine.
    draw_set_colour(_palette.metal);
    draw_line_width(_x + lengthdir_x(-_radius * 0.75, _angle), _y + lengthdir_y(-_radius * 0.75, _angle), _x + lengthdir_x(_radius * 1, _angle), _y + lengthdir_y(_radius * 1, _angle), 2);

    // Nose edge highlights.
    draw_set_colour(_palette.hull_light);
    draw_line_width(_nose_x, _nose_y, _front_top_x, _front_top_y, 2);
    draw_line_width(_nose_x, _nose_y, _front_bottom_x, _front_bottom_y, 2);

    // Rear energy trench.
    draw_set_colour(_palette.accent);
    draw_line_width(_x + lengthdir_x(-_radius * 0.7, _angle), _y + lengthdir_y(-_radius * 0.7, _angle), _x + lengthdir_x(-_radius * 0.36, _angle), _y + lengthdir_y(-_radius * 0.36, _angle), 3);

    // Twin rear engine housings.
    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        var _engine_x = _x + lengthdir_x(-_radius * 0.78, _angle) + lengthdir_x(_radius * 0.2 * _side_sign, _angle + 90);
        var _engine_y = _y + lengthdir_y(-_radius * 0.78, _angle) + lengthdir_y(_radius * 0.2 * _side_sign, _angle + 90);

        draw_set_colour(_palette.void);
        draw_circle(_engine_x, _engine_y, _radius * 0.15, false);
        draw_set_colour(_palette.hull_light);
        draw_circle(_engine_x, _engine_y, _radius * 0.15, true);
        draw_set_colour(_palette.energy);
        draw_circle(_engine_x, _engine_y, _radius * 0.07, false);
    }
}

/// @description Draws the Skirmisher's centre-mounted pulse cannon.
function sc_enemy_sim_skirmisher_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _length = _radius * 0.54;
    var _half_width = _radius * 0.12;
    var _front_x = _x + lengthdir_x(_length, _angle);
    var _front_y = _y + lengthdir_y(_length, _angle);
    var _rear_x = _x + lengthdir_x(-_length * 0.2, _angle);
    var _rear_y = _y + lengthdir_y(-_length * 0.2, _angle);

    draw_set_alpha(_alpha);

    // Mechanical gun housing.
    draw_set_colour(_palette.hull_dark);
    draw_triangle(_rear_x + lengthdir_x(-_half_width, _angle + 90), _rear_y + lengthdir_y(-_half_width, _angle + 90), _front_x + lengthdir_x(-_half_width * 0.65, _angle + 90), _front_y + lengthdir_y(-_half_width * 0.65, _angle + 90), _front_x + lengthdir_x(_half_width * 0.65, _angle + 90), _front_y + lengthdir_y(_half_width * 0.65, _angle + 90), false);
    draw_triangle(_rear_x + lengthdir_x(-_half_width, _angle + 90), _rear_y + lengthdir_y(-_half_width, _angle + 90), _front_x + lengthdir_x(_half_width * 0.65, _angle + 90), _front_y + lengthdir_y(_half_width * 0.65, _angle + 90), _rear_x + lengthdir_x(_half_width, _angle + 90), _rear_y + lengthdir_y(_half_width, _angle + 90), false);

    // Barrel rails.
    draw_set_colour(_palette.metal);
    draw_line_width(_rear_x + lengthdir_x(-_half_width * 0.6, _angle + 90), _rear_y + lengthdir_y(-_half_width * 0.6, _angle + 90), _front_x + lengthdir_x(-_half_width * 0.45, _angle + 90), _front_y + lengthdir_y(-_half_width * 0.45, _angle + 90), 2);
    draw_line_width(_rear_x + lengthdir_x(_half_width * 0.6, _angle + 90), _rear_y + lengthdir_y(_half_width * 0.6, _angle + 90), _front_x + lengthdir_x(_half_width * 0.45, _angle + 90), _front_y + lengthdir_y(_half_width * 0.45, _angle + 90), 2);

    // Active conduit.
    draw_set_colour(_palette.energy);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, 3);

    // Barrel segmentation.
    for (var _i = 1; _i <= 2; _i++)
    {
        var _segment_x = _x + lengthdir_x(_length * (_i * 0.31), _angle);
        var _segment_y = _y + lengthdir_y(_length * (_i * 0.31), _angle);

        draw_set_colour(_i == 1 ? _palette.outline : _palette.accent);
        draw_line_width(_segment_x + lengthdir_x(-_half_width * 0.72, _angle + 90), _segment_y + lengthdir_y(-_half_width * 0.72, _angle + 90), _segment_x + lengthdir_x(_half_width * 0.72, _angle + 90), _segment_y + lengthdir_y(_half_width * 0.72, _angle + 90), 2);
    }

    // Muzzle aperture.
    draw_set_colour(_palette.void);
    draw_circle(_front_x, _front_y, _radius * 0.11, false);
    draw_set_colour(_palette.metal);
    draw_circle(_front_x, _front_y, _radius * 0.11, true);
    draw_set_colour(_palette.energy);
    draw_circle(_front_x, _front_y, _radius * 0.065, false);
    draw_set_colour(_palette.core);
    draw_circle(_front_x, _front_y, _radius * 0.027, false);

    draw_set_alpha(1);
}

/// @description Draws the Skirmisher's rotating central reactor.
function sc_enemy_sim_skirmisher_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _outer_radius = _radius * 0.34;
    var _middle_radius = _radius * 0.235;
    var _inner_radius = _radius * 0.115;

    draw_set_alpha(_alpha);

    // Dark reactor socket.
    draw_set_colour(_palette.void);
    draw_circle(_x, _y, _outer_radius, false);

    draw_set_colour(_palette.metal);
    draw_circle(_x, _y, _outer_radius, true);

    draw_set_colour(_palette.hull_light);
    draw_circle(_x, _y, _middle_radius, true);

    // Four rotating machine blades.
    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _angle + 45 + _i * 90;
        var _inner_x = _x + lengthdir_x(_inner_radius * 0.75, _direction);
        var _inner_y = _y + lengthdir_y(_inner_radius * 0.75, _direction);
        var _outer_x = _x + lengthdir_x(_outer_radius * 1.08, _direction + 12);
        var _outer_y = _y + lengthdir_y(_outer_radius * 1.08, _direction + 12);

        draw_set_colour((_i mod 2) == 0 ? _palette.energy : _palette.accent);
        draw_line_width(_inner_x, _inner_y, _outer_x, _outer_y, 3);
    }

    draw_set_colour(_palette.accent);
    draw_circle(_x, _y, _inner_radius * 1.5, true);

    draw_set_colour(_palette.energy);
    draw_circle(_x, _y, _inner_radius, false);

    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _inner_radius * 0.45, false);

    draw_set_alpha(1);
}

/// @description Creates the complete Simulant Skirmisher destruction visual.
function sc_enemy_sim_skirmisher_death(_enemy)
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

    array_push(_fragments, sc_death_fragment_data(_cache.fragments[0], _x + lengthdir_x(_radius * 0.36, _angle), _y + lengthdir_y(_radius * 0.36, _angle), _angle + random_range(-16, 16), random_range(2.4, 3.6), _angle, choose(-7, 7), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[1], _x + lengthdir_x(-_radius * 0.06, _angle) + lengthdir_x(-_radius * 0.43, _angle + 90), _y + lengthdir_y(-_radius * 0.06, _angle) + lengthdir_y(-_radius * 0.43, _angle + 90), _angle - 70 + random_range(-14, 14), random_range(2.8, 4.2), _angle, random_range(-10, -6), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[2], _x + lengthdir_x(-_radius * 0.06, _angle) + lengthdir_x(_radius * 0.43, _angle + 90), _y + lengthdir_y(-_radius * 0.06, _angle) + lengthdir_y(_radius * 0.43, _angle + 90), _angle + 70 + random_range(-14, 14), random_range(2.8, 4.2), _angle, random_range(6, 10), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.core, _x, _y, irandom(359), random_range(1.5, 2.5), _angle, choose(-12, 12), 0.9));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _x + lengthdir_x(_hardpoint.forward * _radius, _angle) + lengthdir_x(_hardpoint.side * _radius, _angle + 90);
        var _hardpoint_y = _y + lengthdir_y(_hardpoint.forward * _radius, _angle) + lengthdir_y(_hardpoint.side * _radius, _angle + 90);

        array_push(_fragments, sc_death_fragment_data(_cache.hardpoints[_i], _hardpoint_x, _hardpoint_y, _angle + random_range(-22, 22), random_range(3.2, 4.6), _angle, choose(-12, 12), 0.95));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _velocity_x * 0.35;
        _fragments[_i].velocity_y += _velocity_y * 0.35;
    }

    sc_death_fragment_create(_x, _y, _fragments, _palette.core, _palette.glow, _radius, 40);
    return true;
}

/// @description Draws the broken Skirmisher nose and centre fuselage fragment.
function sc_enemy_sim_skirmisher_fragment_front_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _tip_x = _x + lengthdir_x(_radius * 0.76, _angle);
    var _tip_y = _y + lengthdir_y(_radius * 0.76, _angle);
    var _rear_top_x = _x + lengthdir_x(-_radius * 0.12, _angle) + lengthdir_x(-_radius * 0.24, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.12, _angle) + lengthdir_y(-_radius * 0.24, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.12, _angle) + lengthdir_x(_radius * 0.24, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.12, _angle) + lengthdir_y(_radius * 0.24, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_tip_x, _tip_y, _rear_top_x, _rear_top_y, _rear_bottom_x, _rear_bottom_y, false);

    draw_set_colour(_palette.hull_light);
    draw_line_width(_tip_x, _tip_y, _rear_top_x, _rear_top_y, 2);
    draw_line_width(_tip_x, _tip_y, _rear_bottom_x, _rear_bottom_y, 2);

    draw_set_colour(_palette.energy);
    draw_line_width(_x, _y, _tip_x, _tip_y, 2);
}

/// @description Draws the broken left crescent blade fragment.
function sc_enemy_sim_skirmisher_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _inner_x = _x + lengthdir_x(_radius * 0.22, _angle) + lengthdir_x(-_radius * 0.18, _angle + 90);
    var _inner_y = _y + lengthdir_y(_radius * 0.22, _angle) + lengthdir_y(-_radius * 0.18, _angle + 90);
    var _tip_x = _x + lengthdir_x(-_radius * 0.02, _angle) + lengthdir_x(-_radius * 0.82, _angle + 90);
    var _tip_y = _y + lengthdir_y(-_radius * 0.02, _angle) + lengthdir_y(-_radius * 0.82, _angle + 90);
    var _rear_x = _x + lengthdir_x(-_radius * 0.62, _angle) + lengthdir_x(-_radius * 0.42, _angle + 90);
    var _rear_y = _y + lengthdir_y(-_radius * 0.62, _angle) + lengthdir_y(-_radius * 0.42, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_inner_x, _inner_y, _tip_x, _tip_y, _rear_x, _rear_y, false);

    draw_set_colour(_palette.metal);
    draw_line_width(_inner_x, _inner_y, _tip_x, _tip_y, 2);
    draw_line_width(_tip_x, _tip_y, _rear_x, _rear_y, 2);

    draw_set_colour(_palette.accent);
    draw_line_width(_inner_x, _inner_y, _rear_x, _rear_y, 3);
}

/// @description Draws the broken right crescent blade fragment.
function sc_enemy_sim_skirmisher_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;
    var _inner_x = _x + lengthdir_x(_radius * 0.22, _angle) + lengthdir_x(_radius * 0.18, _angle + 90);
    var _inner_y = _y + lengthdir_y(_radius * 0.22, _angle) + lengthdir_y(_radius * 0.18, _angle + 90);
    var _tip_x = _x + lengthdir_x(-_radius * 0.02, _angle) + lengthdir_x(_radius * 0.82, _angle + 90);
    var _tip_y = _y + lengthdir_y(-_radius * 0.02, _angle) + lengthdir_y(_radius * 0.82, _angle + 90);
    var _rear_x = _x + lengthdir_x(-_radius * 0.62, _angle) + lengthdir_x(_radius * 0.42, _angle + 90);
    var _rear_y = _y + lengthdir_y(-_radius * 0.62, _angle) + lengthdir_y(_radius * 0.42, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_inner_x, _inner_y, _rear_x, _rear_y, _tip_x, _tip_y, false);

    draw_set_colour(_palette.metal);
    draw_line_width(_inner_x, _inner_y, _tip_x, _tip_y, 2);
    draw_line_width(_tip_x, _tip_y, _rear_x, _rear_y, 2);

    draw_set_colour(_palette.accent);
    draw_line_width(_inner_x, _inner_y, _rear_x, _rear_y, 3);
}