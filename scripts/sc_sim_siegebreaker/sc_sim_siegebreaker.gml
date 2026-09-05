/*
SIMULANT SIEGEBREAKER

Bulky Simulant heavy assault ship facing east at draw_angle 0.
Carries two shoulder rocket launchers and one central pulse cannon.
Designed to stop and destroy obstructing asteroids rather than navigate around them.
*/

/// @description Registers the heavy Simulant Siegebreaker.
function sc_enemy_register_sim_siegebreaker()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_siegebreaker",
            name: "Simulant Siegebreaker",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.HEAVY,
            rank: EnemyRank.ELITE,
            threat_value: 14
        },

        reward: { credits: 110 },

        stats_base: {
            shield_max: 150,
            armour_max: 520,
            hull_max: 290,
            mass: 2.4,

            handling: {
                speed_max: 2.8,
                acceleration: 0.11,
                friction_coeff: 0.992,
                turn_speed: 0.9,
                directional: true,
                directional_speed_min: 0.3,
                directional_thrust_min: 0.42
            },

            range: {
                detection: 1320,
                combat: 980,
                backaway: 390,
                forget: 1540,
                wander: 0,
                alert_share: 1550
            },

            damage_multiplier: 1.15,
            fire_rate_multiplier: 0.9
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.DESTROY,
            idle_script: sc_enemy_movement_hold,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_hold_line_of_sight,

            facing: {
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.MOVEMENT,
                angle_offset: 0,
                turn_speed_scale: 0.7,
                spin_speed: 0
            },

            orbit: {
                range: 0,
                direction: 1,
                radial_strength: 0,
                direction_change_chance: 0
            },

            strafe: {
                amount: 0,
                speed: 0
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 600,
            arrival_radius: 90,
            search_duration: 180,
            speed_scale: 0.6
        },

        visual: sc_enemy_sim_siegebreaker_visual_data(),

        collision: {
            radius_forward_scale: 1.08,
            radius_side_scale: 0.9,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "rocket_left",
                group: "rockets",
                forward: 0.18,
                side: -0.57,
                angle: 0,
                muzzle_forward: 0.38,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 1.7,
                    arc: 50,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_siegebreaker_rocket_draw
            },
            {
                key: "pulse_centre",
                group: "pulse",
                forward: 0.69,
                side: 0,
                angle: 0,
                muzzle_forward: 0.42,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 2.1,
                    arc: 55,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_siegebreaker_pulse_draw
            },
            {
                key: "rocket_right",
                group: "rockets",
                forward: 0.18,
                side: 0.57,
                angle: 0,
                muzzle_forward: 0.38,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 1.7,
                    arc: 50,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_siegebreaker_rocket_draw
            }
        ],

        thrusters: [
            { key: "thruster_left", forward: -0.76, side: -0.43, angle: 180, scale: 0.9 },
            { key: "thruster_centre", forward: -0.88, side: 0, angle: 180, scale: 1.05 },
            { key: "thruster_right", forward: -0.76, side: 0.43, angle: 180, scale: 0.9 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "twin_rocket_launch",
                    weight: 42,
                    hardpoint_group: "rockets",
                    weapon_key: "weapon_simulant_rocket",

                    conditions: {
                        line_of_sight: true,
                        range_min: 300,
                        range_max: 940
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 3,
                        fire_tolerance: 9
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 190
                    }
                },
                {
                    key: "centre_pulse_burst",
                    weight: 58,
                    hardpoint_group: "pulse",
                    weapon_key: "weapon_simulant_pulse",

                    conditions: {
                        line_of_sight: true,
                        range_min: 140,
                        range_max: 900
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 2,
                        fire_tolerance: 8
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 8,
                        volley_max: 6,
                        cooldown: 120
                    }
                }
            ]
        }
    });
}

/// @description Returns the complete Siegebreaker visual definition.
function sc_enemy_sim_siegebreaker_visual_data()
{
    return {
        radius: 84,
        motion_strength: 2,
        palette: sc_faction_palette_get(Faction.SIMULANT),
        core: { forward: -0.12, side: 0 },

        draw: {
            body: sc_enemy_sim_siegebreaker_body_draw,
            core: sc_enemy_sim_siegebreaker_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_sim_siegebreaker_hull_draw,
            armour_draw_script: sc_enemy_sim_siegebreaker_armour_draw
        },

        death: {
            script: sc_enemy_sim_siegebreaker_death,
            draw_scripts: [
                sc_enemy_sim_siegebreaker_fragment_centre_draw,
                sc_enemy_sim_siegebreaker_fragment_left_draw,
                sc_enemy_sim_siegebreaker_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 256,
            core_canvas_size: 160,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 256
        }
    };
}

/// @description Draws the intact Siegebreaker fallback body.
function sc_enemy_sim_siegebreaker_body_draw(_x, _y, _radius, _angle, _visual)
{
    sc_enemy_sim_siegebreaker_hull_draw(_x, _y, _radius, _angle, _visual, 0);
    sc_enemy_sim_siegebreaker_armour_draw(_x, _y, _radius, _angle, _visual, 0);
}

/// @description Draws the permanent bulky mechanical hull.
function sc_enemy_sim_siegebreaker_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Heavy central silhouette.
    sc_visual_triangle(_x, _y, _radius, _angle,
        1.08, 0, 0.42, -0.5, -0.92, -0.43,
        _p.hull_dark, false);

    sc_visual_triangle(_x, _y, _radius, _angle,
        1.08, 0, -0.92, -0.43, -0.92, 0.43,
        _p.hull_dark, false);

    sc_visual_triangle(_x, _y, _radius, _angle,
        1.08, 0, -0.92, 0.43, 0.42, 0.5,
        _p.hull_dark, false);

    // Inner mechanical body.
    sc_visual_quad(_x, _y, _radius, _angle,
        0.75, -0.27, 0.24, -0.42,
        -0.72, -0.33, -0.72, 0.33,
        _p.hull_mid);

    sc_visual_quad(_x, _y, _radius, _angle,
        0.75, -0.27, -0.72, 0.33,
        0.24, 0.42, 0.75, 0.27,
        _p.hull_mid);

    // Side machinery and rocket beds.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            0.42, 0.31 * _side,
            0.19, 0.72 * _side,
            -0.54, 0.69 * _side,
            -0.76, 0.35 * _side,
            _p.hull_dark);

        sc_visual_quad(_x, _y, _radius, _angle,
            0.29, 0.37 * _side,
            0.12, 0.61 * _side,
            -0.45, 0.58 * _side,
            -0.62, 0.38 * _side,
            _p.hull_mid);

        sc_visual_line(_x, _y, _radius, _angle,
            0.24, 0.43 * _side,
            -0.53, 0.48 * _side,
            7, _p.void);

        sc_visual_line(_x, _y, _radius, _angle,
            0.19, 0.43 * _side,
            -0.48, 0.48 * _side,
            2, _p.energy);

        sc_visual_circle(_x, _y, _radius, _angle,
            -0.38, 0.52 * _side,
            0.11, _p.void, false);

        sc_visual_circle(_x, _y, _radius, _angle,
            -0.38, 0.52 * _side,
            0.07, _p.accent, true);

        sc_visual_line(_x, _y, _radius, _angle,
            0.43, 0.31 * _side,
            0.18, 0.71 * _side,
            2, _p.outline);

        sc_visual_line(_x, _y, _radius, _angle,
            0.18, 0.71 * _side,
            -0.54, 0.68 * _side,
            2, _p.energy);
    }

    // Central energy trench.
    sc_visual_line(_x, _y, _radius, _angle,
        -0.82, 0, 0.87, 0,
        10, _p.void);

    sc_visual_line(_x, _y, _radius, _angle,
        -0.72, 0, 0.82, 0,
        4, _p.accent);

    sc_visual_line(_x, _y, _radius, _angle,
        0.16, 0, 0.83, 0,
        2, _p.core);

    // Reactor socket.
    sc_visual_circle(_x, _y, _radius, _angle,
        -0.12, 0, 0.27, _p.void, false);

    sc_visual_circle(_x, _y, _radius, _angle,
        -0.12, 0, 0.27, _p.metal, true);

    sc_visual_circle(_x, _y, _radius, _angle,
        -0.12, 0, 0.2, _p.hull_light, true);

    // Hardpoint sockets.
    var _mount_forward = [0.18, 0.69, 0.18];
    var _mount_side = [-0.57, 0, 0.57];

    for (var _i = 0; _i < 3; _i++)
    {
        sc_visual_circle(_x, _y, _radius, _angle,
            _mount_forward[_i], _mount_side[_i],
            0.14, _p.void, false);

        sc_visual_circle(_x, _y, _radius, _angle,
            _mount_forward[_i], _mount_side[_i],
            0.14, _p.metal, true);
    }

    // Engine housings.
    var _engine_side = [-0.43, 0, 0.43];

    for (var _i = 0; _i < 3; _i++)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            -0.58, _engine_side[_i] - 0.08,
            -0.89, _engine_side[_i] - 0.07,
            -0.89, _engine_side[_i] + 0.07,
            -0.58, _engine_side[_i] + 0.08,
            _p.hull_mid);

        sc_visual_line(_x, _y, _radius, _angle,
            -0.63, _engine_side[_i],
            -0.9, _engine_side[_i],
            7, _p.void);

        sc_visual_line(_x, _y, _radius, _angle,
            -0.65, _engine_side[_i],
            -0.88, _engine_side[_i],
            3, _p.energy);
    }

    // Progressive hull damage.
    if (_stage >= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle,
            0.22, -0.23, -0.08, -0.39,
            4, _p.void);

        sc_visual_line(_x, _y, _radius, _angle,
            0.2, -0.23, -0.04, -0.35,
            2, _p.accent);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle,
            -0.42, 0.28, 0.16,
            _p.void, false);

        sc_visual_line(_x, _y, _radius, _angle,
            -0.42, 0.28, -0.61, 0.41,
            2, _p.energy);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle,
            0.16, 0.42, 0.14,
            _p.void, false);

        sc_visual_circle(_x, _y, _radius, _angle,
            -0.58, -0.34, 0.18,
            _p.void, false);

        sc_visual_line(_x, _y, _radius, _angle,
            -0.58, -0.34, -0.78, -0.44,
            3, _p.accent);
    }
}

/// @description Draws removable silver armour over the permanent hull.
function sc_enemy_sim_siegebreaker_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    for (var _side = -1; _side <= 1; _side += 2)
    {
        // Final inner armour remains at stage 3.
        sc_visual_quad(_x, _y, _radius, _angle,
            0.42, 0.18 * _side,
            0.12, 0.31 * _side,
            -0.23, 0.3 * _side,
            -0.38, 0.17 * _side,
            _p.metal);

        sc_visual_line(_x, _y, _radius, _angle,
            0.42, 0.18 * _side,
            0.12, 0.31 * _side,
            1, _p.core);

        // Mid-body armour disappears after stage 2.
        if (_stage <= 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle,
                0.36, 0.36 * _side,
                0.14, 0.59 * _side,
                -0.29, 0.56 * _side,
                -0.47, 0.37 * _side,
                _p.hull_light);

            sc_visual_line(_x, _y, _radius, _angle,
                0.36, 0.36 * _side,
                0.14, 0.59 * _side,
                1, _p.metal);
        }

        // Rear armour disappears after stage 1.
        if (_stage <= 1)
        {
            sc_visual_quad(_x, _y, _radius, _angle,
                -0.31, 0.37 * _side,
                -0.46, 0.58 * _side,
                -0.68, 0.49 * _side,
                -0.63, 0.28 * _side,
                _p.metal);
        }

        // Outer heavy armour exists only when intact.
        if (_stage == 0)
        {
            sc_visual_triangle(_x, _y, _radius, _angle,
                0.16, 0.65 * _side,
                -0.53, 0.65 * _side,
                -0.7, 0.48 * _side,
                _p.hull_light, false);

            sc_visual_line(_x, _y, _radius, _angle,
                0.16, 0.65 * _side,
                -0.53, 0.65 * _side,
                2, _p.core);
        }
    }

    // Armoured forward prow.
    if (_stage <= 2)
    {
        sc_visual_triangle(_x, _y, _radius, _angle,
            1.02, 0,
            0.58, -0.18,
            0.58, 0.18,
            _p.metal, false);

        sc_visual_line(_x, _y, _radius, _angle,
            1.02, 0, 0.58, -0.18,
            2, _p.core);

        sc_visual_line(_x, _y, _radius, _angle,
            1.02, 0, 0.58, 0.18,
            2, _p.core);
    }
}

/// @description Draws one heavy Simulant rocket pod.
function sc_enemy_sim_siegebreaker_rocket_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _radius, _angle,
        0, 0, 0.15, _p.void, false);

    sc_visual_circle(_x, _y, _radius, _angle,
        0, 0, 0.15, _p.metal, true);

    sc_visual_quad(_x, _y, _radius, _angle,
        -0.05, -0.13,
        0.3, -0.11,
        0.38, 0.11,
        -0.05, 0.13,
        _p.hull_light);

    // Twin launch channels inside each pod.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_line(_x, _y, _radius, _angle,
            0.02, 0.055 * _side,
            0.4, 0.055 * _side,
            6, _p.void);

        sc_visual_line(_x, _y, _radius, _angle,
            0.08, 0.055 * _side,
            0.38, 0.055 * _side,
            2, _p.energy);

        sc_visual_circle(_x, _y, _radius, _angle,
            0.4, 0.055 * _side,
            0.035, _p.core, false);
    }

    sc_visual_line(_x, _y, _radius, _angle,
        0.12, -0.13, 0.12, 0.13,
        2, _p.outline);

    draw_set_alpha(1);
}

/// @description Draws the Siegebreaker's central pulse cannon.
function sc_enemy_sim_siegebreaker_pulse_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _radius, _angle,
        0, 0, 0.14, _p.void, false);

    sc_visual_circle(_x, _y, _radius, _angle,
        0, 0, 0.14, _p.metal, true);

    sc_visual_circle(_x, _y, _radius, _angle,
        0, 0, 0.085, _p.accent, true);

    sc_visual_quad(_x, _y, _radius, _angle,
        -0.03, -0.075,
        0.34, -0.055,
        0.34, 0.055,
        -0.03, 0.075,
        _p.hull_light);

    sc_visual_line(_x, _y, _radius, _angle,
        0.04, 0, 0.43, 0,
        7, _p.void);

    sc_visual_line(_x, _y, _radius, _angle,
        0.08, 0, 0.43, 0,
        2, _p.energy);

    sc_visual_circle(_x, _y, _radius, _angle,
        0.43, 0, 0.065,
        _p.metal, true);

    sc_visual_circle(_x, _y, _radius, _angle,
        0.43, 0, 0.028,
        _p.core, false);

    draw_set_alpha(1);
}

/// @description Draws the rotating Siegebreaker reactor.
function sc_enemy_sim_siegebreaker_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.22;
    var _inner = _radius * 0.08;

    draw_set_alpha(_alpha * 0.25);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _outer * 1.5, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _outer, false);

    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _outer, true);

    for (var _i = 0; _i < 6; _i++)
    {
        var _direction = _angle + _i * 60;

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.outline);
        draw_line_width(
            _x + lengthdir_x(_inner, _direction),
            _y + lengthdir_y(_inner, _direction),
            _x + lengthdir_x(_outer * 0.85, _direction + 18),
            _y + lengthdir_y(_outer * 0.85, _direction + 18),
            3
        );
    }

    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _inner * 1.55, true);

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _inner, false);

    draw_set_colour(_p.core);
    draw_circle(_x, _y, _inner * 0.4, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the complete Siegebreaker destruction visual.
function sc_enemy_sim_siegebreaker_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _palette = _visual.palette;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _fragments = [];

    sc_particles_simulant_enemy_death(_enemy.x, _enemy.y, _radius);

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[0],
        _enemy.x + lengthdir_x(_radius * 0.18, _angle),
        _enemy.y + lengthdir_y(_radius * 0.18, _angle),
        _angle + random_range(-8, 8),
        random_range(2, 3),
        _angle, choose(-7, 7), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[1],
        _enemy.x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(-_radius * 0.48, _angle + 90),
        _enemy.y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(-_radius * 0.48, _angle + 90),
        _angle - 65 + random_range(-10, 10),
        random_range(2.5, 3.8),
        _angle, random_range(-9, -5), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[2],
        _enemy.x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.48, _angle + 90),
        _enemy.y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.48, _angle + 90),
        _angle + 65 + random_range(-10, 10),
        random_range(2.5, 3.8),
        _angle, random_range(5, 9), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.core, _enemy.x, _enemy.y,
        irandom(359), random_range(1.5, 2.4),
        _angle, choose(-10, 10), 0.95
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _enemy.x
            + lengthdir_x(_hardpoint.forward * _radius, _angle)
            + lengthdir_x(_hardpoint.side * _radius, _angle + 90);

        var _hardpoint_y = _enemy.y
            + lengthdir_y(_hardpoint.forward * _radius, _angle)
            + lengthdir_y(_hardpoint.side * _radius, _angle + 90);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x, _hardpoint_y,
            _angle + random_range(-20, 20),
            random_range(2.5, 4),
            _angle, choose(-11, 11), 0.95
        ));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _data.movement.velocity_x * 0.3;
        _fragments[_i].velocity_y += _data.movement.velocity_y * 0.3;
    }

    sc_death_fragment_create(
        _enemy.x, _enemy.y,
        _fragments,
        _palette.core,
        _palette.glow,
        _radius,
        50
    );

    return true;
}

/// @description Draws the broken central Siegebreaker fragment.
function sc_enemy_sim_siegebreaker_fragment_centre_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.98, 0, 0.3, -0.34, -0.74, 0,
        _p.hull_dark, false);

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.98, 0, -0.74, 0, 0.3, 0.34,
        _p.hull_mid, false);

    sc_visual_line(_x, _y, _radius, _angle,
        -0.68, 0, 0.82, 0,
        3, _p.accent);
}

/// @description Draws the broken left Siegebreaker section.
function sc_enemy_sim_siegebreaker_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle,
        0.4, -0.25,
        0.13, -0.69,
        -0.55, -0.65,
        -0.76, -0.31,
        _p.hull_dark);

    sc_visual_quad(_x, _y, _radius, _angle,
        0.26, -0.35,
        0.07, -0.58,
        -0.46, -0.54,
        -0.61, -0.34,
        _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle,
        0.13, -0.68, -0.55, -0.64,
        2, _p.energy);
}

/// @description Draws the broken right Siegebreaker section.
function sc_enemy_sim_siegebreaker_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle,
        0.4, 0.25,
        -0.76, 0.31,
        -0.55, 0.65,
        0.13, 0.69,
        _p.hull_dark);

    sc_visual_quad(_x, _y, _radius, _angle,
        0.26, 0.35,
        -0.61, 0.34,
        -0.46, 0.54,
        0.07, 0.58,
        _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle,
        0.13, 0.68, -0.55, 0.64,
        2, _p.energy);
}