/*
CORPORATION INTERCEPTOR

A fast light fighter with clean silver armour, swept wings,
twin engines and one rotating precision plasma turret.
*/

/// @description Registers the Corporation Interceptor.
function sc_enemy_register_corporation_interceptor()
{
    return sc_enemy_register({
        identity: {
            key: "e_corp_interceptor",
            name: "Corp Interceptor",
            faction: Faction.CORPORATION,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.LIGHT,
            rank: EnemyRank.COMMON,
            threat_value: 3
        },

        reward: { credits: 24 },

        stats_base: {
            shield_max: 60,
            armour_max: 55,
            hull_max: 40,
            mass: 0.78,

            handling: {
                speed_max: 9,
                acceleration: 0.4,
                friction_coeff: 0.988,
                turn_speed: 5.4,
                directional: true,
                directional_speed_min: 0.58,
                directional_thrust_min: 0.7
            },

            range: {
                detection: 1450,
                combat: 980,
                backaway: 0,
                forget: 2100,
                wander: 420,
                alert_share: 1400
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_movement_flyby,
            combat_script: sc_enemy_movement_flyby,

            runtime: {
                flyby: {
                    active: false,
                    destination_x: 0,
                    destination_y: 0,
                    side: 0,
                    next_run_tick: 0
                }
            },

            facing: {
                default_mode: EnemyFacingMode.MOVEMENT,
                backaway_mode: EnemyFacingMode.MOVEMENT,
                angle_offset: 0,
                turn_speed_scale: 1,
                spin_speed: 0
            },

            orbit: {
                range: 0,
                direction: 0,
                radial_strength: 0,
                direction_change_chance: 0
            },

            strafe: {
                amount: 0,
                speed: 0
            },

            flyby: {
                offset_min: 145,
                offset_max: 245,
                exit_distance: 720,
                arrival_radius: 70,
                turnaround_delay: 20,
                speed_scale: 1.08,
                alternate_side: true
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 600,
            arrival_radius: 80,
            search_duration: 180,
            speed_scale: 0.78
        },

        visual: sc_enemy_corporation_interceptor_visual_data(),

        collision: {
            radius_forward_scale: 1.05,
            radius_side_scale: 0.8,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "plasma_turret",
                group: "plasma",
                forward: 0.18,
                side: 0,
                angle: 0,
                muzzle_forward: 0.58,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 6,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_interceptor_turret_draw
            }
        ],

        thrusters: [
            { key: "engine_left", forward: -0.82, side: -0.3, angle: 180, scale: 0.82 },
            { key: "engine_right", forward: -0.82, side: 0.3, angle: 180, scale: 0.82 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "precision_plasma",
                    weight: 100,
                    hardpoint_group: "plasma",
                    weapon_key: "weapon_corporation_plasma",

                    conditions: {
                        line_of_sight: true,
                        range_min: 100,
                        range_max: 980
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 1.5,
                        fire_tolerance: 6
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 9,
                        volley_max: 5,
                        cooldown: 48
                    }
                }
            ]
        }
    });
}

/// @description Returns the complete Corporation Interceptor visual definition.
function sc_enemy_corporation_interceptor_visual_data()
{
    return {
        radius: 56,
        motion_strength: 3.2,
        palette: sc_faction_palette_get(Faction.CORPORATION),
        core: { forward: -0.42, side: 0 },

        draw: {
            body: sc_enemy_corporation_interceptor_body_draw,
            core: sc_enemy_corporation_interceptor_core_draw
        },

        death: {
            script: sc_enemy_corporation_interceptor_death,

            draw_scripts: [
                sc_enemy_corporation_interceptor_fragment_front_draw,
                sc_enemy_corporation_interceptor_fragment_left_draw,
                sc_enemy_corporation_interceptor_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_corporation_thrust_draw,
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

/// @description Draws the clean swept Corporation Interceptor body.
function sc_enemy_corporation_interceptor_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    // Dark manufactured underframe.
    sc_visual_triangle(_x,_y,_radius,_angle, 1.14,0, -0.77,-0.68, -0.94,0,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_radius,_angle, 1.14,0, -0.94,0, -0.77,0.68,_p.hull_dark,false);

    // Swept interceptor wings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.5,0.18*_side,
            0.04,0.76*_side,
            -0.78,0.66*_side,
            -0.46,0.2*_side,
            _p.hull_mid
        );

        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.34,0.23*_side,
            -0.02,0.61*_side,
            -0.6,0.53*_side,
            -0.35,0.25*_side,
            _p.hull_light
        );

        // Recessed blue wing conduit.
        sc_visual_line(_x,_y,_radius,_angle, 0.25,0.31*_side, -0.5,0.48*_side, 6,_p.void);
        sc_visual_line(_x,_y,_radius,_angle, 0.24,0.31*_side, -0.49,0.48*_side, 2,_p.energy);

        // Bright manufactured leading edge.
        sc_visual_line(_x,_y,_radius,_angle, 0.5,0.18*_side, 0.04,0.76*_side, 2,_p.metal);
        sc_visual_line(_x,_y,_radius,_angle, 0.04,0.76*_side, -0.78,0.66*_side, 2,_p.outline);
    }

    // Central silver fuselage.
    sc_visual_quad(_x,_y,_radius,_angle, 1.14,0, 0.48,-0.25, -0.72,-0.2, -0.94,0,_p.hull_light);
    sc_visual_quad(_x,_y,_radius,_angle, 1.14,0, -0.94,0, -0.72,0.2, 0.48,0.25,_p.metal);

    // Raised nose armour.
    sc_visual_triangle(_x,_y,_radius,_angle, 1.02,0, 0.31,-0.16, 0.31,0.16,_p.hull_light,false);
    sc_visual_line(_x,_y,_radius,_angle, 1.08,0, 0.32,-0.16, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, 1.08,0, 0.32,0.16, 2,_p.outline);

    // Blue cockpit and targeting strip.
    sc_visual_quad(_x,_y,_radius,_angle, 0.62,-0.1, 0.83,0, 0.62,0.1, 0.17,0.12,_p.void);
    sc_visual_quad(_x,_y,_radius,_angle, 0.62,-0.06, 0.75,0, 0.62,0.06, 0.28,0.07,_p.energy);
    sc_visual_line(_x,_y,_radius,_angle, 0.88,0, 1.04,0, 2,_p.core);

    // Central armour spine.
    sc_visual_line(_x,_y,_radius,_angle, 0.1,0, -0.67,0, 7,_p.hull_mid);
    sc_visual_line(_x,_y,_radius,_angle, 0.08,0, -0.65,0, 2,_p.outline);

    // Twin engine housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(
            _x,_y,_radius,_angle,
            -0.38,0.19*_side,
            -0.77,0.2*_side,
            -0.91,0.39*_side,
            -0.42,0.39*_side,
            _p.hull_dark
        );

        sc_visual_line(_x,_y,_radius,_angle, -0.47,0.3*_side, -0.87,0.3*_side, 5,_p.energy);
        sc_visual_line(_x,_y,_radius,_angle, -0.45,0.39*_side, -0.91,0.39*_side, 2,_p.metal);
    }

    // Precise outer silhouette.
    sc_visual_line(_x,_y,_radius,_angle, 1.14,0, 0.5,-0.18, 2,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 1.14,0, 0.5,0.18, 2,_p.outline);
}

/// @description Draws the Interceptor's rotating single-shot plasma turret.
function sc_enemy_corporation_interceptor_turret_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_radius,_angle, -0.08,0,0.22,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle, -0.08,0,0.2,_p.metal,false);
    sc_visual_circle(_x,_y,_radius,_angle, -0.08,0,0.13,_p.hull_mid,false);

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.04,-0.11,
        0.48,-0.075,
        0.48,0.075,
        -0.04,0.11,
        _p.hull_dark
    );

    sc_visual_line(_x,_y,_radius,_angle, 0.02,-0.075, 0.5,-0.052, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, 0.02,0.075, 0.5,0.052, 2,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 0.05,0, 0.53,0, 3,_p.energy);

    sc_visual_circle(_x,_y,_radius,_angle, 0.5,0,0.09,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle, 0.5,0,0.05,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the Interceptor's rear Corporation reactor.
function sc_enemy_corporation_interceptor_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _pulse = 0.9 + sin(GAME_TICK * 0.08) * 0.1;

    draw_set_alpha(_alpha * 0.22);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _radius * 0.34 * _pulse, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _radius * 0.23, false);
    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _radius * 0.23, true);
    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _radius * 0.14, false);
    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _radius * 0.09 * _pulse, false);
    draw_set_colour(_p.core);
    draw_circle(_x, _y, _radius * 0.035, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one clean Corporation engine flame.
function sc_enemy_corporation_thrust_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha * 0.24);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.24, 0.88,0, 0,0.24,_p.glow,false);

    draw_set_alpha(_alpha * 0.72);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.14, 0.68,0, 0,0.14,_p.energy,false);

    draw_set_alpha(_alpha);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.055, 0.46,0, 0,0.055,_p.core,false);

    draw_set_alpha(1);
}

/// @description Creates the Corporation Interceptor destruction visual.
function sc_enemy_corporation_interceptor_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _fragments = [];

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[0],
        _x + lengthdir_x(_radius*0.38,_angle),
        _y + lengthdir_y(_radius*0.38,_angle),
        _angle + random_range(-12,12),
        random_range(2.8,4.2),
        _angle, choose(-8,8), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[1],
        _x + lengthdir_x(-_radius*0.12,_angle) + lengthdir_x(-_radius*0.42,_angle+90),
        _y + lengthdir_y(-_radius*0.12,_angle) + lengthdir_y(-_radius*0.42,_angle+90),
        _angle - 55,
        random_range(3.2,4.8),
        _angle, -10, 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[2],
        _x + lengthdir_x(-_radius*0.12,_angle) + lengthdir_x(_radius*0.42,_angle+90),
        _y + lengthdir_y(-_radius*0.12,_angle) + lengthdir_y(_radius*0.42,_angle+90),
        _angle + 55,
        random_range(3.2,4.8),
        _angle, 10, 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.core,
        _x + lengthdir_x(-_radius*0.42,_angle),
        _y + lengthdir_y(-_radius*0.42,_angle),
        random(360),
        random_range(1.8,2.8),
        _angle, choose(-11,11), 0.9
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _x + lengthdir_x(_hardpoint.forward*_radius,_angle)
            + lengthdir_x(_hardpoint.side*_radius,_angle+90);
        var _hardpoint_y = _y + lengthdir_y(_hardpoint.forward*_radius,_angle)
            + lengthdir_y(_hardpoint.side*_radius,_angle+90);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x, _hardpoint_y,
            random(360),
            random_range(3.4,5),
            _angle, choose(-12,12), 0.95
        ));
    }

    sc_death_fragment_create(
        _x, _y, _fragments,
        _visual.palette.core,
        _visual.palette.glow,
        _radius, 38
    );

    // Add dedicated Corporation destruction particles here later.
    return true;
}

/// @description Draws the broken Interceptor nose fragment.
function sc_enemy_corporation_interceptor_fragment_front_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x,_y,_radius,_angle, 1.08,0, 0.08,-0.27, 0.08,0.27,_p.hull_light,false);
    sc_visual_line(_x,_y,_radius,_angle, 1.08,0, 0.08,-0.27, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, 1.08,0, 0.08,0.27, 2,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 0.84,0, 0.25,0, 2,_p.energy);
}

/// @description Draws the broken Interceptor left wing fragment.
function sc_enemy_corporation_interceptor_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x,_y,_radius,_angle, 0.45,-0.18, 0,-0.76, -0.78,-0.66,_p.hull_mid,false);
    sc_visual_line(_x,_y,_radius,_angle, 0.45,-0.18, 0,-0.76, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, 0.2,-0.32, -0.52,-0.54, 2,_p.energy);
}

/// @description Draws the broken Interceptor right wing fragment.
function sc_enemy_corporation_interceptor_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x,_y,_radius,_angle, 0.45,0.18, -0.78,0.66, 0,0.76,_p.hull_light,false);
    sc_visual_line(_x,_y,_radius,_angle, 0.45,0.18, 0,0.76, 2,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 0.2,0.32, -0.52,0.54, 2,_p.energy);
}