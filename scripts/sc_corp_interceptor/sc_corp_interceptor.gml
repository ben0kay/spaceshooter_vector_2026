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
            radius_side_scale: 1,
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

/// @description Draws the long narrow scissor-wing Corporation Interceptor.
function sc_enemy_corporation_interceptor_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    // Long narrow manufactured underframe.
    sc_visual_triangle(_x,_y,_radius,_angle, 1.46,0, 0.34,-0.18, -0.94,-0.2,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_radius,_angle, 1.46,0, -0.94,0.2, 0.34,0.18,_p.hull_dark,false);

    // Thin swept scissor wings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        // Long narrow dark wing silhouette.
        sc_visual_quad(_x,_y,_radius,_angle,
            0.18,0.17*_side,
            -0.25,0.7*_side,
            -0.55,0.65*_side,
            -0.38,0.26*_side,
            _p.hull_dark
        );

        // Silver upper blade.
        sc_visual_quad(_x,_y,_radius,_angle,
            0.12,0.19*_side,
            -0.26,0.62*_side,
            -0.48,0.58*_side,
            -0.33,0.28*_side,
            _p.hull_light
        );

        // Bright leading-edge strip.
        sc_visual_quad(_x,_y,_radius,_angle,
            0.1,0.2*_side,
            -0.25,0.59*_side,
            -0.37,0.57*_side,
            -0.24,0.3*_side,
            _p.metal
        );

        // Dark inner wing recess.
        sc_visual_triangle(_x,_y,_radius,_angle,
            -0.02,0.23*_side,
            -0.25,0.52*_side,
            -0.35,0.31*_side,
            _p.hull_mid,false
        );

        // Small rear inner scissor blade.
        sc_visual_triangle(_x,_y,_radius,_angle,
            -0.31,0.23*_side,
            -0.57,0.42*_side,
            -0.7,0.27*_side,
            _p.hull_dark,false
        );

        sc_visual_triangle(_x,_y,_radius,_angle,
            -0.36,0.26*_side,
            -0.55,0.37*_side,
            -0.62,0.28*_side,
            _p.hull_mid,false
        );

        // Thin blue powered trench.
        sc_visual_line(_x,_y,_radius,_angle, -0.02,0.25*_side, -0.3,0.5*_side, 5,_p.void);
        sc_visual_line(_x,_y,_radius,_angle, -0.02,0.25*_side, -0.3,0.5*_side, 2,_p.energy);

        // Small blue tip marking.
        sc_visual_line(_x,_y,_radius,_angle, -0.29,0.56*_side, -0.4,0.57*_side, 2,_p.accent);

        // Sharp neutral outer edge.
        sc_visual_line(_x,_y,_radius,_angle, 0.18,0.17*_side, -0.25,0.7*_side, 2,_p.metal);
        sc_visual_line(_x,_y,_radius,_angle, -0.25,0.7*_side, -0.55,0.65*_side, 1,_p.outline);
    }

    // Slim central silver fuselage.
    sc_visual_triangle(_x,_y,_radius,_angle, 1.46,0, 0.4,-0.145, -0.79,-0.14,_p.hull_light,false);
    sc_visual_triangle(_x,_y,_radius,_angle, 1.46,0, -0.79,0.14, 0.4,0.145,_p.metal,false);

    // Narrow dark centre spine.
    sc_visual_quad(_x,_y,_radius,_angle,
        0.45,-0.075,
        -0.82,-0.09,
        -0.82,0.09,
        0.45,0.075,
        _p.hull_mid
    );

    // Raised nose armour.
    sc_visual_triangle(_x,_y,_radius,_angle, 1.43,0, 0.7,-0.085, 0.7,0.085,_p.metal,false);
    sc_visual_triangle(_x,_y,_radius,_angle, 1.3,0, 0.74,-0.05, 0.86,0,_p.hull_light,false);
    sc_visual_triangle(_x,_y,_radius,_angle, 1.3,0, 0.86,0, 0.74,0.05,_p.hull_light,false);

    // Long narrow blue cockpit.
    sc_visual_quad(_x,_y,_radius,_angle, 0.78,-0.09, 1.05,-0.045, 1.13,0, 0.78,0,_p.void);
    sc_visual_quad(_x,_y,_radius,_angle, 0.78,0, 1.13,0, 1.05,0.045, 0.78,0.09,_p.void);

    sc_visual_quad(_x,_y,_radius,_angle, 0.8,-0.055, 1.01,-0.025, 1.07,0, 0.8,0,_p.energy);
    sc_visual_quad(_x,_y,_radius,_angle, 0.8,0, 1.07,0, 1.01,0.025, 0.8,0.055,_p.accent);

    // Cockpit divider.
    sc_visual_line(_x,_y,_radius,_angle, 0.81,-0.065, 0.81,0.065, 2,_p.core);

    // Forward targeting strip.
    sc_visual_line(_x,_y,_radius,_angle, 1.13,0, 1.38,0, 4,_p.void);
    sc_visual_line(_x,_y,_radius,_angle, 1.15,0, 1.37,0, 2,_p.energy);

    // Existing rotating plasma turret mounting plate.
    sc_visual_circle(_x,_y,_radius,_angle, 0.18,0,0.19,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle, 0.18,0,0.165,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_radius,_angle, 0.18,0,0.145,_p.metal,true);

    // Rear reactor housing.
    sc_visual_circle(_x,_y,_radius,_angle, -0.42,0,0.24,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle, -0.42,0,0.21,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_radius,_angle, -0.42,0,0.19,_p.metal,true);

    // Twin compact rear engine nacelles.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_radius,_angle,
            -0.45,0.14*_side,
            -0.78,0.16*_side,
            -0.98,0.3*_side,
            -0.52,0.3*_side,
            _p.hull_dark
        );

        sc_visual_quad(_x,_y,_radius,_angle,
            -0.5,0.17*_side,
            -0.79,0.18*_side,
            -0.9,0.27*_side,
            -0.55,0.27*_side,
            _p.hull_light
        );

        sc_visual_line(_x,_y,_radius,_angle, -0.65,0.23*_side, -0.96,0.23*_side, 8,_p.void);
        sc_visual_line(_x,_y,_radius,_angle, -0.67,0.23*_side, -0.95,0.23*_side, 4,_p.energy);
        sc_visual_circle(_x,_y,_radius,_angle, -0.96,0.23*_side,0.045,_p.core,false);
    }

    // Slim rear spine between engines.
    sc_visual_triangle(_x,_y,_radius,_angle, -0.52,-0.075, -1,0, -0.52,0.075,_p.hull_dark,false);
    sc_visual_line(_x,_y,_radius,_angle, -0.52,0, -0.91,0, 2,_p.accent);

    // Small structural details.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_line(_x,_y,_radius,_angle, 0.5,0.12*_side, 0.25,0.14*_side, 1,_p.outline);
        sc_visual_line(_x,_y,_radius,_angle, 0.02,0.13*_side, -0.24,0.14*_side, 1,_p.outline);
        sc_visual_line(_x,_y,_radius,_angle, -0.49,0.12*_side, -0.71,0.12*_side, 2,_p.energy);
    }

    // Clean long outer nose edges.
    sc_visual_line(_x,_y,_radius,_angle, 1.46,0, 0.4,-0.145, 2,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 1.46,0, 0.4,0.145, 2,_p.outline);
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

/// @description Draws the broken long Interceptor nose fragment.
function sc_enemy_corporation_interceptor_fragment_front_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x,_y,_radius,_angle, 1.4,0, 0.15,-0.16, 0.15,0.16,_p.hull_light,false);
    sc_visual_triangle(_x,_y,_radius,_angle, 1.34,0, 0.55,-0.075, 0.55,0.075,_p.metal,false);

    sc_visual_quad(_x,_y,_radius,_angle, 0.78,-0.08, 1.03,-0.04, 1.1,0, 0.78,0,_p.void);
    sc_visual_quad(_x,_y,_radius,_angle, 0.78,0, 1.1,0, 1.03,0.04, 0.78,0.08,_p.energy);

    sc_visual_line(_x,_y,_radius,_angle, 1.4,0, 0.15,-0.16, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, 1.4,0, 0.15,0.16, 2,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 1.13,0, 1.34,0, 2,_p.core);
}

/// @description Draws the broken thin left scissor-wing fragment.
function sc_enemy_corporation_interceptor_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x,_y,_radius,_angle,
        0.16,-0.17,
        -0.24,-0.7,
        -0.54,-0.64,
        -0.37,-0.26,
        _p.hull_dark
    );

    sc_visual_quad(_x,_y,_radius,_angle,
        0.1,-0.2,
        -0.25,-0.61,
        -0.47,-0.57,
        -0.32,-0.29,
        _p.hull_light
    );

    sc_visual_line(_x,_y,_radius,_angle, 0.16,-0.17, -0.24,-0.7, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, -0.24,-0.7, -0.54,-0.64, 1,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, -0.03,-0.25, -0.3,-0.5, 2,_p.energy);
}

/// @description Draws the broken thin right scissor-wing fragment.
function sc_enemy_corporation_interceptor_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x,_y,_radius,_angle,
        0.16,0.17,
        -0.37,0.26,
        -0.54,0.64,
        -0.24,0.7,
        _p.hull_dark
    );

    sc_visual_quad(_x,_y,_radius,_angle,
        0.1,0.2,
        -0.32,0.29,
        -0.47,0.57,
        -0.25,0.61,
        _p.hull_light
    );

    sc_visual_line(_x,_y,_radius,_angle, 0.16,0.17, -0.24,0.7, 2,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, -0.24,0.7, -0.54,0.64, 1,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle, -0.03,0.25, -0.3,0.5, 2,_p.energy);
}