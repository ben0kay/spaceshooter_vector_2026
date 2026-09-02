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
            shield_max: 10,
            armour_max: 200,
            hull_max: 60,

            speed_max: 5.5,
            acceleration: 0.3,
            friction: 0.985,
            turn_speed: 4,

            detection_range: 1080,
            combat_range: 840,
            forget_range: 1280,

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        visual: {
            radius: 58,
            palette: sc_faction_palette_get(Faction.SIMULANT),

            draw: {
                body: sc_enemy_twin_fighter_body_draw,
                core: sc_enemy_twin_fighter_core_draw
            },

            thrust: {
                draw_script: sc_enemy_simulant_thrust_draw,
                ignition_script: sc_particles_simulant_ignition,
                particle_script: sc_particles_simulant_thrust
            },

            bake: {
                body_canvas_size: 256,
                core_canvas_size: 128,
                hardpoint_canvas_size: 128,
                thrust_canvas_size: 128
            }
        },

        collision: {
            radius_scale: 0.62,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "cannon_left",
                group: "cannons",
                forward: 0.83,
                side: -0.48,
                angle: 0,
                muzzle_forward: 0.48,
                draw_script: sc_enemy_twin_fighter_cannon_draw
            },
            {
                key: "cannon_right",
                group: "cannons",
                forward: 0.83,
                side: 0.48,
                angle: 0,
                muzzle_forward: 0.48,
                draw_script: sc_enemy_twin_fighter_cannon_draw
            }
        ],

        thrusters: [
            {
                key: "thruster_left",
                forward: -0.86,
                side: -0.32,
                angle: 180,
                scale: 0.9
            },
            {
                key: "thruster_right",
                forward: -0.86,
                side: 0.32,
                angle: 180,
                scale: 0.9
            }
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

/// @description Draws the longer Twin Fighter layered gunmetal body.
function sc_enemy_twin_fighter_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _palette = _visual.palette;

    var _nose_x = _x + lengthdir_x(_radius * 1.32, _angle);
    var _nose_y = _y + lengthdir_y(_radius * 1.32, _angle);
    var _tail_x = _x + lengthdir_x(-_radius * 1.14, _angle);
    var _tail_y = _y + lengthdir_y(-_radius * 1.14, _angle);

    // Main elongated central hull.
    var _front_top_x = _x + lengthdir_x(_radius * 0.62, _angle) + lengthdir_x(-_radius * 0.31, _angle + 90);
    var _front_top_y = _y + lengthdir_y(_radius * 0.62, _angle) + lengthdir_y(-_radius * 0.31, _angle + 90);
    var _front_bottom_x = _x + lengthdir_x(_radius * 0.62, _angle) + lengthdir_x(_radius * 0.31, _angle + 90);
    var _front_bottom_y = _y + lengthdir_y(_radius * 0.62, _angle) + lengthdir_y(_radius * 0.31, _angle + 90);
    var _rear_top_x = _x + lengthdir_x(-_radius * 0.82, _angle) + lengthdir_x(-_radius * 0.38, _angle + 90);
    var _rear_top_y = _y + lengthdir_y(-_radius * 0.82, _angle) + lengthdir_y(-_radius * 0.38, _angle + 90);
    var _rear_bottom_x = _x + lengthdir_x(-_radius * 0.82, _angle) + lengthdir_x(_radius * 0.38, _angle + 90);
    var _rear_bottom_y = _y + lengthdir_y(-_radius * 0.82, _angle) + lengthdir_y(_radius * 0.38, _angle + 90);

    draw_set_colour(_palette.hull_dark);
    draw_triangle(_nose_x, _nose_y, _front_top_x, _front_top_y, _rear_top_x, _rear_top_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_top_x, _rear_top_y, _tail_x, _tail_y, false);
    draw_triangle(_nose_x, _nose_y, _tail_x, _tail_y, _rear_bottom_x, _rear_bottom_y, false);
    draw_triangle(_nose_x, _nose_y, _rear_bottom_x, _rear_bottom_y, _front_bottom_x, _front_bottom_y, false);

    // Raised central armour.
    var _plate_front_x = _x + lengthdir_x(_radius * 0.78, _angle);
    var _plate_front_y = _y + lengthdir_y(_radius * 0.78, _angle);
    var _plate_rear_x = _x + lengthdir_x(-_radius * 0.68, _angle);
    var _plate_rear_y = _y + lengthdir_y(-_radius * 0.68, _angle);
    var _plate_top_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(-_radius * 0.24, _angle + 90);
    var _plate_top_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(-_radius * 0.24, _angle + 90);
    var _plate_bottom_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.24, _angle + 90);
    var _plate_bottom_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.24, _angle + 90);

    draw_set_colour(_palette.hull_mid);
    draw_triangle(_plate_front_x, _plate_front_y, _plate_top_x, _plate_top_y, _plate_rear_x, _plate_rear_y, false);
    draw_triangle(_plate_front_x, _plate_front_y, _plate_rear_x, _plate_rear_y, _plate_bottom_x, _plate_bottom_y, false);

    draw_set_colour(_palette.hull_light);
    draw_line_width(_plate_front_x, _plate_front_y, _plate_top_x, _plate_top_y, 2);
    draw_line_width(_plate_top_x, _plate_top_y, _plate_rear_x, _plate_rear_y, 2);
    draw_line_width(_plate_rear_x, _plate_rear_y, _plate_bottom_x, _plate_bottom_y, 2);
    draw_line_width(_plate_bottom_x, _plate_bottom_y, _plate_front_x, _plate_front_y, 2);

    // Mirrored segmented wings.
    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        var _wing_front_x = _x + lengthdir_x(_radius * 0.62, _angle) + lengthdir_x(_radius * 0.42 * _side_sign, _angle + 90);
        var _wing_front_y = _y + lengthdir_y(_radius * 0.62, _angle) + lengthdir_y(_radius * 0.42 * _side_sign, _angle + 90);
        var _wing_tip_x = _x + lengthdir_x(_radius * 0.06, _angle) + lengthdir_x(_radius * 1.07 * _side_sign, _angle + 90);
        var _wing_tip_y = _y + lengthdir_y(_radius * 0.06, _angle) + lengthdir_y(_radius * 1.07 * _side_sign, _angle + 90);
        var _wing_rear_x = _x + lengthdir_x(-_radius * 0.98, _angle) + lengthdir_x(_radius * 0.78 * _side_sign, _angle + 90);
        var _wing_rear_y = _y + lengthdir_y(-_radius * 0.98, _angle) + lengthdir_y(_radius * 0.78 * _side_sign, _angle + 90);
        var _wing_inner_x = _x + lengthdir_x(-_radius * 0.66, _angle) + lengthdir_x(_radius * 0.37 * _side_sign, _angle + 90);
        var _wing_inner_y = _y + lengthdir_y(-_radius * 0.66, _angle) + lengthdir_y(_radius * 0.37 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_dark);
        draw_triangle(_wing_front_x, _wing_front_y, _wing_tip_x, _wing_tip_y, _wing_inner_x, _wing_inner_y, false);
        draw_triangle(_wing_tip_x, _wing_tip_y, _wing_rear_x, _wing_rear_y, _wing_inner_x, _wing_inner_y, false);

        // Raised wing armour.
        var _panel_front_x = _x + lengthdir_x(_radius * 0.43, _angle) + lengthdir_x(_radius * 0.48 * _side_sign, _angle + 90);
        var _panel_front_y = _y + lengthdir_y(_radius * 0.43, _angle) + lengthdir_y(_radius * 0.48 * _side_sign, _angle + 90);
        var _panel_outer_x = _x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.87 * _side_sign, _angle + 90);
        var _panel_outer_y = _y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.87 * _side_sign, _angle + 90);
        var _panel_rear_x = _x + lengthdir_x(-_radius * 0.78, _angle) + lengthdir_x(_radius * 0.66 * _side_sign, _angle + 90);
        var _panel_rear_y = _y + lengthdir_y(-_radius * 0.78, _angle) + lengthdir_y(_radius * 0.66 * _side_sign, _angle + 90);
        var _panel_inner_x = _x + lengthdir_x(-_radius * 0.48, _angle) + lengthdir_x(_radius * 0.42 * _side_sign, _angle + 90);
        var _panel_inner_y = _y + lengthdir_y(-_radius * 0.48, _angle) + lengthdir_y(_radius * 0.42 * _side_sign, _angle + 90);

        draw_set_colour(_palette.hull_mid);
        draw_triangle(_panel_front_x, _panel_front_y, _panel_outer_x, _panel_outer_y, _panel_inner_x, _panel_inner_y, false);
        draw_triangle(_panel_outer_x, _panel_outer_y, _panel_rear_x, _panel_rear_y, _panel_inner_x, _panel_inner_y, false);

        draw_set_colour(_palette.hull_light);
        draw_line_width(_wing_front_x, _wing_front_y, _wing_tip_x, _wing_tip_y, 2);
        draw_line_width(_wing_tip_x, _wing_tip_y, _wing_rear_x, _wing_rear_y, 2);
        draw_line_width(_panel_front_x, _panel_front_y, _panel_outer_x, _panel_outer_y, 2);
        draw_line_width(_panel_outer_x, _panel_outer_y, _panel_rear_x, _panel_rear_y, 2);

        // Recessed energy trench.
        var _energy_front_x = _x + lengthdir_x(_radius * 0.35, _angle) + lengthdir_x(_radius * 0.53 * _side_sign, _angle + 90);
        var _energy_front_y = _y + lengthdir_y(_radius * 0.35, _angle) + lengthdir_y(_radius * 0.53 * _side_sign, _angle + 90);
        var _energy_rear_x = _x + lengthdir_x(-_radius * 0.58, _angle) + lengthdir_x(_radius * 0.58 * _side_sign, _angle + 90);
        var _energy_rear_y = _y + lengthdir_y(-_radius * 0.58, _angle) + lengthdir_y(_radius * 0.58 * _side_sign, _angle + 90);

        draw_set_colour(_palette.accent);
        draw_line_width(_energy_front_x, _energy_front_y, _energy_rear_x, _energy_rear_y, 3);

        // Cannon housing aligned with hardpoint forward 0.83, side 0.48.
        var _mount_x = _x + lengthdir_x(_radius * 0.83, _angle) + lengthdir_x(_radius * 0.48 * _side_sign, _angle + 90);
        var _mount_y = _y + lengthdir_y(_radius * 0.83, _angle) + lengthdir_y(_radius * 0.48 * _side_sign, _angle + 90);

        draw_set_colour(_palette.void);
        draw_circle(_mount_x, _mount_y, _radius * 0.2, false);

        draw_set_colour(_palette.metal);
        draw_circle(_mount_x, _mount_y, _radius * 0.2, true);

        draw_set_colour(_palette.energy);
        draw_circle(_mount_x, _mount_y, _radius * 0.09, true);
    }

    // Central mechanical spine.
    var _spine_front_x = _x + lengthdir_x(_radius * 1, _angle);
    var _spine_front_y = _y + lengthdir_y(_radius * 1, _angle);
    var _spine_rear_x = _x + lengthdir_x(-_radius * 0.96, _angle);
    var _spine_rear_y = _y + lengthdir_y(-_radius * 0.96, _angle);

    draw_set_colour(_palette.metal);
    draw_line_width(_spine_rear_x, _spine_rear_y, _spine_front_x, _spine_front_y, 2);

    // Rear energy channel.
    draw_set_colour(_palette.accent);
    draw_line_width(
        _x + lengthdir_x(-_radius * 0.74, _angle),
        _y + lengthdir_y(-_radius * 0.74, _angle),
        _x + lengthdir_x(-_radius * 0.39, _angle),
        _y + lengthdir_y(-_radius * 0.39, _angle),
        3
    );

    // Nose armour highlights.
    draw_set_colour(_palette.metal);
    draw_line_width(_nose_x, _nose_y, _front_top_x, _front_top_y, 2);
    draw_line_width(_nose_x, _nose_y, _front_bottom_x, _front_bottom_y, 2);

    // Two rear engine housings aligned with registered thrusters.
    for (var _side_sign = -1; _side_sign <= 1; _side_sign += 2)
    {
        var _engine_x = _x + lengthdir_x(-_radius * 0.86, _angle) + lengthdir_x(_radius * 0.32 * _side_sign, _angle + 90);
        var _engine_y = _y + lengthdir_y(-_radius * 0.86, _angle) + lengthdir_y(_radius * 0.32 * _side_sign, _angle + 90);

        draw_set_colour(_palette.void);
        draw_circle(_engine_x, _engine_y, _radius * 0.17, false);

        draw_set_colour(_palette.hull_light);
        draw_circle(_engine_x, _engine_y, _radius * 0.17, true);

        draw_set_colour(_palette.metal);
        draw_circle(_engine_x, _engine_y, _radius * 0.12, true);

        draw_set_colour(_palette.energy);
        draw_circle(_engine_x, _engine_y, _radius * 0.065, false);

        draw_set_colour(_palette.core);
        draw_circle(_engine_x, _engine_y, _radius * 0.025, false);
    }
}

/// @description Draws one layered mechanical Twin Fighter cannon.
function sc_enemy_twin_fighter_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _length = _radius * 0.48;
    var _half_width = _radius * 0.115;
    var _front_x = _x + lengthdir_x(_length, _angle);
    var _front_y = _y + lengthdir_y(_length, _angle);
    var _rear_x = _x + lengthdir_x(-_length * 0.22, _angle);
    var _rear_y = _y + lengthdir_y(-_length * 0.22, _angle);
    var _front_top_x = _front_x + lengthdir_x(-_half_width, _angle + 90);
    var _front_top_y = _front_y + lengthdir_y(-_half_width, _angle + 90);
    var _front_bottom_x = _front_x + lengthdir_x(_half_width, _angle + 90);
    var _front_bottom_y = _front_y + lengthdir_y(_half_width, _angle + 90);
    var _rear_top_x = _rear_x + lengthdir_x(-_half_width * 1.15, _angle + 90);
    var _rear_top_y = _rear_y + lengthdir_y(-_half_width * 1.15, _angle + 90);
    var _rear_bottom_x = _rear_x + lengthdir_x(_half_width * 1.15, _angle + 90);
    var _rear_bottom_y = _rear_y + lengthdir_y(_half_width * 1.15, _angle + 90);

    draw_set_alpha(_alpha);
    draw_set_colour(_palette.hull_dark);
    draw_triangle(_rear_top_x, _rear_top_y, _front_top_x, _front_top_y, _front_bottom_x, _front_bottom_y, false);
    draw_triangle(_rear_top_x, _rear_top_y, _front_bottom_x, _front_bottom_y, _rear_bottom_x, _rear_bottom_y, false);

    draw_set_colour(_palette.hull_light);
    draw_line_width(_rear_top_x, _rear_top_y, _front_top_x, _front_top_y, 2);
    draw_line_width(_rear_bottom_x, _rear_bottom_y, _front_bottom_x, _front_bottom_y, 2);

    // Twin metallic barrel rails.
    var _rail_offset = _half_width * 0.62;

    draw_set_colour(_palette.metal);
    draw_line_width(
        _rear_x + lengthdir_x(-_rail_offset, _angle + 90),
        _rear_y + lengthdir_y(-_rail_offset, _angle + 90),
        _front_x + lengthdir_x(-_rail_offset, _angle + 90),
        _front_y + lengthdir_y(-_rail_offset, _angle + 90),
        2
    );
    draw_line_width(
        _rear_x + lengthdir_x(_rail_offset, _angle + 90),
        _rear_y + lengthdir_y(_rail_offset, _angle + 90),
        _front_x + lengthdir_x(_rail_offset, _angle + 90),
        _front_y + lengthdir_y(_rail_offset, _angle + 90),
        2
    );

    // Central active conduit.
    draw_set_colour(_palette.energy);
    draw_line_width(_rear_x, _rear_y, _front_x, _front_y, 3);

    // Segmented barrel rings.
    for (var _i = 1; _i <= 3; _i++)
    {
        var _segment_distance = _length * (_i * 0.22);
        var _segment_x = _x + lengthdir_x(_segment_distance, _angle);
        var _segment_y = _y + lengthdir_y(_segment_distance, _angle);

        draw_set_colour(_i == 2 ? _palette.accent : _palette.outline);
        draw_line_width(
            _segment_x + lengthdir_x(-_half_width, _angle + 90),
            _segment_y + lengthdir_y(-_half_width, _angle + 90),
            _segment_x + lengthdir_x(_half_width, _angle + 90),
            _segment_y + lengthdir_y(_half_width, _angle + 90),
            2
        );
    }

    // Bright muzzle aperture.
    draw_set_colour(_palette.void);
    draw_circle(_front_x, _front_y, _radius * 0.105, false);
    draw_set_colour(_palette.metal);
    draw_circle(_front_x, _front_y, _radius * 0.105, true);
    draw_set_colour(_palette.core);
    draw_circle(_front_x, _front_y, _radius * 0.045, false);

    draw_set_alpha(1);
}

/// @description Draws the Twin Fighter's rotating mechanical energy core.
function sc_enemy_twin_fighter_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _palette = _visual.palette;
    var _outer_radius = _radius * 0.34;
    var _middle_radius = _radius * 0.24;
    var _inner_radius = _radius * 0.12;

    draw_set_alpha(_alpha);

    draw_set_colour(_palette.void);
    draw_circle(_x, _y, _outer_radius, false);

    draw_set_colour(_palette.metal);
    draw_circle(_x, _y, _outer_radius, true);

    draw_set_colour(_palette.hull_light);
    draw_circle(_x, _y, _middle_radius, true);

    // Rotating mechanical-energy spokes.
    for (var _i = 0; _i < 8; _i++)
    {
        var _direction = _angle + _i * 45;
        var _inner_x = _x + lengthdir_x(_middle_radius * 0.65, _direction);
        var _inner_y = _y + lengthdir_y(_middle_radius * 0.65, _direction);
        var _outer_x = _x + lengthdir_x(_outer_radius * 1.15, _direction);
        var _outer_y = _y + lengthdir_y(_outer_radius * 1.15, _direction);

        draw_set_colour((_i mod 2) == 0 ? _palette.energy : _palette.outline);
        draw_line_width(_inner_x, _inner_y, _outer_x, _outer_y, (_i mod 2) == 0 ? 3 : 2);
    }

    draw_set_colour(_palette.accent);
    draw_circle(_x, _y, _inner_radius * 1.45, true);

    draw_set_colour(_palette.energy);
    draw_circle(_x, _y, _inner_radius, false);

    draw_set_colour(_palette.core);
    draw_circle(_x, _y, _inner_radius * 0.48, false);

    draw_set_alpha(1);
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