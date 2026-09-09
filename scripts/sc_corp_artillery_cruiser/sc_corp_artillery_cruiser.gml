/*
CORPORATION ARTILLERY CRUISER

Elite Superheavy long-range bombardment vessel.
Two centre-mounted heavy artillery barrels and four defensive plasma turrets.
*/

/// @description Registers the Corporation Artillery Cruiser.
function sc_enemy_register_corporation_artillery_cruiser()
{
    return sc_enemy_register({
        identity: {
            key: "e_corp_artillery_cruiser",
            name: "Corp Artillery Cruiser",
            faction: Faction.CORPORATION,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.SUPERHEAVY,
            rank: EnemyRank.ELITE,
            threat_value: 42
        },

        reward: {
            credits: 620
        },

        stats_base: {
            shield_max: 1050,
            armour_max: 2900,
            hull_max: 1350,
            mass: 9.5,

            handling: {
                speed_max: 1.75,
                acceleration: 0.045,
                friction_coeff: 0.996,
                turn_speed: 0.32,
                directional: true,
                directional_speed_min: 0.2,
                directional_thrust_min: 0.34
            },

            range: {
                detection: 4400,
                combat: 4200,
                backaway: 0,
                forget: 5600,
                wander: 0,
                alert_share: 2600
            },

            damage_multiplier: 1.2,
            fire_rate_multiplier: 0.85
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.BOMBARD,
            idle_script: sc_enemy_movement_hold,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_bombard_asteroid_field,

            bombard: {
                fallback_script: sc_enemy_movement_hold
            },

            runtime: {
                bombard: {
                    field_index: -1,
                    next_field_check_tick: 0
                }
            },

            facing: {
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.TARGET,
                angle_offset: 0,
                turn_speed_scale: 0.55,
                spin_speed: 0
            },

            strafe: {
                amount: 0,
                speed: 0
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 1000,
            arrival_radius: 190,
            search_duration: 280,
            speed_scale: 0.5
        },

        visual: sc_enemy_corporation_artillery_cruiser_visual_data(),

        collision: {
            radius_forward_scale: 1.55,
            radius_side_scale: 0.5,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "artillery_left",
                group: "artillery",
                forward: 0,
                side: -0.075,
                angle: 0,
                muzzle_forward: 1.68,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 1.15,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_artillery_barrel_draw
            },
            {
                key: "artillery_right",
                group: "artillery",
                forward: 0,
                side: 0.075,
                angle: 0,
                muzzle_forward: 1.68,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 1.15,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_artillery_barrel_draw
            },
            {
                key: "defence_front_left",
                group: "defence",
                forward: 0.48,
                side: -0.42,
                angle: 0,
                muzzle_forward: 0.17,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 5,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "defence_front_right",
                group: "defence",
                forward: 0.48,
                side: 0.42,
                angle: 0,
                muzzle_forward: 0.17,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 5,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "defence_rear_left",
                group: "defence",
                forward: -0.5,
                side: -0.42,
                angle: 180,
                muzzle_forward: 0.17,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 4.5,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "defence_rear_right",
                group: "defence",
                forward: -0.5,
                side: 0.42,
                angle: 180,
                muzzle_forward: 0.17,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 4.5,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            }
        ],

        thrusters: [
            { key: "engine_left", forward: -1.43, side: -0.2, angle: 180, scale: 1 },
            { key: "engine_right", forward: -1.43, side: 0.2, angle: 180, scale: 1 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                { key: "artillery", selection: AttackSelection.WEIGHTED },
                { key: "defence", selection: AttackSelection.WEIGHTED }
            ],

            attacks: [
                {
                    key: "twin_artillery_barrage",
                    channel: "artillery",
                    weight: 100,
                    hardpoint_group: "artillery",
                    weapon_key: "weapon_corporation_artillery_rocket",

                    conditions: {
                        line_of_sight: {
                            solids: true,
                            asteroids: false
                        },

                        range_min: 950,
                        range_max: 4200
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 1.2,
                        fire_tolerance: 3
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 18,
                        volley_max: 1,
                        cooldown: 190
                    }
                },
                {
                    key: "defensive_plasma_miniguns",
                    channel: "defence",
                    weight: 100,
                    hardpoint_group: "defence",
                    weapon_key: "weapon_corporation_plasma",

                    conditions: {
                        line_of_sight: true,
                        range_min: 0,
                        range_max: 1750
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 3.5,
                        fire_tolerance: 8
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 5,
                        volley_max: 12,
                        cooldown: 48
                    }
                }
            ]
        }
    });
}

/// @description Returns the Artillery Cruiser's elite layered visual definition.
function sc_enemy_corporation_artillery_cruiser_visual_data()
{
    return {
        radius: 190,
        motion_strength: 0.65,
        palette: sc_faction_palette_elite_get(Faction.CORPORATION),
        core: { forward: -0.92, side: 0 },

        draw: {
            body: sc_enemy_corporation_artillery_cruiser_body_draw,
            core: sc_enemy_corporation_artillery_cruiser_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_corporation_artillery_cruiser_hull_draw,
            armour_draw_script: sc_enemy_corporation_artillery_cruiser_armour_draw
        },

        death: {
            script: sc_enemy_corporation_artillery_cruiser_death,

            draw_scripts: [
                sc_enemy_corporation_artillery_fragment_front_draw,
                sc_enemy_corporation_artillery_fragment_left_draw,
                sc_enemy_corporation_artillery_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_corporation_thrust_draw,
            ignition_script: sc_particles_corporation_thrust_ignition,
            particle_script: sc_particles_corporation_thrust_emit
        },

        bake: {
            body_canvas_size: 768,
            core_canvas_size: 384,
            hardpoint_canvas_size: 768,
            thrust_canvas_size: 384,
            fragment_canvas_size: 512
        }
    };
}

/// @description Draws the complete intact Artillery Cruiser.
function sc_enemy_corporation_artillery_cruiser_body_draw(_x,_y,_r,_a,_v)
{
    sc_enemy_corporation_artillery_cruiser_hull_draw(_x,_y,_r,_a,_v,0);
    sc_enemy_corporation_artillery_cruiser_armour_draw(_x,_y,_r,_a,_v,0);
}

/// @description Draws the Artillery Cruiser's narrow permanent chassis.
function sc_enemy_corporation_artillery_cruiser_hull_draw(_x,_y,_r,_a,_v,_stage)
{
    var _p = _v.palette;

    // Long central keel.
    sc_visual_quad(_x,_y,_r,_a,
        1.58,-0.09,
        -1.32,-0.16,
        -1.48,0,
        1.58,0.09,
        _p.recess
    );

    sc_visual_quad(_x,_y,_r,_a,
        1.46,-0.055,
        -1.22,-0.11,
        -1.38,0,
        1.46,0.055,
        _p.hull_dark
    );

    // Narrow symmetric main hull.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a,
            1.45,0.08*_side,
            0.86,0.29*_side,
            0.12,0.38*_side,
            0.28,0.12*_side,
            _p.hull_mid
        );

        sc_visual_quad(_x,_y,_r,_a,
            0.22,0.13*_side,
            0.02,0.39*_side,
            -0.75,0.43*_side,
            -0.58,0.14*_side,
            _p.hull_mid
        );

        sc_visual_quad(_x,_y,_r,_a,
            -0.62,0.14*_side,
            -0.82,0.4*_side,
            -1.34,0.27*_side,
            -1.31,0.11*_side,
            _p.hull_dark
        );

        // Sharp outer fins.
        sc_visual_triangle(_x,_y,_r,_a,
            0.85,0.27*_side,
            0.18,0.52*_side,
            -0.16,0.38*_side,
            _p.recess,false
        );

        sc_visual_triangle(_x,_y,_r,_a,
            -0.48,0.4*_side,
            -1.12,0.56*_side,
            -1.3,0.24*_side,
            _p.recess,false
        );

        // Artillery feed conduits.
        sc_corp_visual_armour_rib(
            _x,_y,_r,_a,
            1.14,0.13*_side,
            -0.68,0.17*_side,
            8,_p
        );

        sc_corp_visual_energy_strip(
            _x,_y,_r,_a,
            0.93,0.2*_side,
            0.35,0.3*_side,
            3,_p
        );

        sc_corp_visual_energy_strip(
            _x,_y,_r,_a,
            -0.43,0.31*_side,
            -1.02,0.28*_side,
            3,_p
        );

        sc_corp_visual_vent_bank(
            _x,_y,_r,_a,
            -0.72,0.21*_side,
            0.28,0.026,5,_p
        );
    }

    // Central rotating turret well.
    sc_visual_circle(_x,_y,_r,_a,0,0,0.28,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,0,0,0.25,_p.hull_dark,false);
    sc_visual_circle(_x,_y,_r,_a,0,0,0.2,_p.recess,false);
    sc_visual_circle(_x,_y,_r,_a,0,0,0.25,_p.trim,true);

    // Nose targeting point.
    sc_visual_triangle(
        _x,_y,_r,_a,
        1.62,0,
        1.31,-0.11,
        1.31,0.11,
        _p.hull_light,false
    );

    sc_corp_visual_sensor_node(_x,_y,_r,_a,1.48,0,0.035,_p);

    // Twin rear engines.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a,
            -1.02,0.1*_side,
            -1.42,0.11*_side,
            -1.42,0.29*_side,
            -1.03,0.25*_side,
            _p.recess
        );

        sc_visual_quad(_x,_y,_r,_a,
            -1.06,0.12*_side,
            -1.38,0.13*_side,
            -1.38,0.26*_side,
            -1.06,0.23*_side,
            _p.armour_dark
        );

        sc_corp_visual_energy_strip(
            _x,_y,_r,_a,
            -1.1,0.19*_side,
            -1.39,0.195*_side,
            4,_p
        );
    }

    if (_stage >= 1)
        sc_visual_line(_x,_y,_r,_a,0.7,-0.27,0.36,-0.38,4,_p.void);

    if (_stage >= 2)
    {
        sc_visual_circle(_x,_y,_r,_a,-0.42,0.3,0.13,_p.void,false);
        sc_visual_line(_x,_y,_r,_a,-0.18,0.18,-0.7,0.34,4,_p.recess);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x,_y,_r,_a,0.48,-0.22,0.16,_p.void,false);
        sc_visual_circle(_x,_y,_r,_a,-1.08,-0.2,0.12,_p.void,false);
    }
}

/// @description Draws the Artillery Cruiser's removable elite armour.
function sc_enemy_corporation_artillery_cruiser_armour_draw(_x,_y,_r,_a,_v,_stage)
{
    var _p = _v.palette;

    // Permanent centre armour.
 armour.
    sc_visual_quad(_x,_y,_r,_a,
        1.28,-0.1,
        0.56,-0.18,
        0.1,-0.16,
        0.1,-0.08,
        _p.armour_light
    );

    sc_visual_quad(_x,_y,_r,_a,
        1.28,0.1,
        0.56,0.18,
        0.1,0.16,
        0.1,0.08,
        _p.armour_mid
    );

    for (var _side = -1; _side <= 1; _side += 2)
    {
        if (_stage <= 2)
        {
            sc_corp_visual_armour_plate(
                _x,_y,_r,_a,
                1.12,0.14*_side,
                0.78,0.28*_side,
                0.35,0.34*_side,
                0.48,0.2*_side,
                _p.armour_light,_p
            );

            sc_corp_visual_elite_panel(
                _x,_y,_r,_a,
                0.54,0.27*_side,
                0.38,0.14,_p
            );
        }

        if (_stage <= 1)
        {
            sc_corp_visual_armour_plate(
                _x,_y,_r,_a,
                0.04,0.2*_side,
                -0.28,0.37*_side,
                -0.72,0.38*_side,
                -0.55,0.2*_side,
                _p.metal,_p
            );

            sc_corp_visual_elite_panel(
                _x,_y,_r,_a,
                -0.43,0.3*_side,
                0.42,0.13,_p
            );
        }

        if (_stage == 0)
        {
            sc_corp_visual_armour_plate(
                _x,_y,_r,_a,
                -0.78,0.2*_side,
                -0.94,0.36*_side,
                -1.28,0.27*_side,
                -1.17,0.14*_side,
                _p.armour_light,_p
            );

            sc_corp_visual_ident_bar(
                _x,_y,_r,_a,
                -0.87,0.3*_side,
                -1.13,0.25*_side,
                _p
            );
        }
    }

    if (_stage == 0)
    {
        sc_visual_circle(_x,_y,_r,_a,0,0,0.27,_p.armour_light,true);
        sc_visual_circle(_x,_y,_r,_a,0,0,0.22,_p.trim,true);
    }
}

/// @description Draws one half of the rotating twin artillery assembly.
function sc_enemy_corporation_artillery_barrel_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    // Overlapping mounts make both hardpoints appear as one turret.
    sc_visual_circle(_x,_y,_r,_a,0,-0.075,0.19,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,0,-0.075,0.16,_p.armour_light,false);
    sc_visual_circle(_x,_y,_r,_a,0,-0.075,0.11,_p.armour_dark,false);

    // Long recoil housing.
    sc_visual_quad(_x,_y,_r,_a,
        -0.16,-0.125,
        0.48,-0.095,
        0.48,-0.025,
        -0.16,-0.025,
        _p.recess
    );

    sc_visual_quad(_x,_y,_r,_a,
        -0.11,-0.105,
        0.52,-0.078,
        0.52,-0.038,
        -0.11,-0.045,
        _p.metal
    );

    // Super-long reinforced barrel.
    sc_visual_line(_x,_y,_r,_a,0.35,-0.067,1.72,-0.067,18,_p.void);
    sc_visual_line(_x,_y,_r,_a,0.38,-0.067,1.68,-0.067,12,_p.armour_dark);
    sc_visual_line(_x,_y,_r,_a,0.42,-0.067,1.66,-0.067,5,_p.hull_light);
    sc_visual_line(_x,_y,_r,_a,0.5,-0.067,1.63,-0.067,2,_p.trim);

    // Barrel braces.
    for (var _forward = 0.56; _forward <= 1.46; _forward += 0.3)
    {
        sc_visual_line(
            _x,_y,_r,_a,
            _forward,-0.112,
            _forward,-0.022,
            5,_p.recess
        );

        sc_visual_line(
            _x,_y,_r,_a,
            _forward,-0.1,
            _forward,-0.034,
            2,_p.armour_light
        );
    }

    sc_corp_visual_energy_strip(
        _x,_y,_r,_a,
        0.08,-0.067,
        0.43,-0.067,
        3,_p
    );

    // Hot launcher mouth.
    sc_visual_circle(_x,_y,_r,_a,1.68,-0.067,0.075,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,1.68,-0.067,0.044,_p.energy,false);
    sc_visual_circle(_x,_y,_r,_a,1.68,-0.067,0.02,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the Artillery Cruiser's rear elite reactor.
function sc_enemy_corporation_artillery_cruiser_core_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p = _v.palette;
    var _pulse = 0.88+sin(GAME_TICK*0.075)*0.12;

    draw_set_alpha(_alpha*0.22);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_r*0.23*_pulse,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_r*0.16,false);
    draw_set_colour(_p.armour_light);
    draw_circle(_x,_y,_r*0.16,true);
    draw_set_colour(_p.accent);
    draw_circle(_x,_y,_r*0.105,false);
    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_r*0.065*_pulse,false);
    draw_set_colour(_p.core);
    draw_circle(_x,_y,_r*0.025,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Artillery Cruiser's destruction fragments.
function sc_enemy_corporation_artillery_cruiser_death(_enemy)
{
    var _data = _enemy.enemy;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _r = _data.visual.radius;
    var _a = _enemy.draw_angle;
    var _fragments = [];

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[0],
        _enemy.x+lengthdir_x(_r*0.74,_a),
        _enemy.y+lengthdir_y(_r*0.74,_a),
        _a+random_range(-8,8),
        random_range(2,3),
        _a,choose(-6,6),1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[1],
        _enemy.x+lengthdir_x(-_r*0.25,_a)+lengthdir_x(-_r*0.25,_a+90),
        _enemy.y+lengthdir_y(-_r*0.25,_a)+lengthdir_y(-_r*0.25,_a+90),
        _a-22,
        random_range(1.8,2.8),
        _a,-7,1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[2],
        _enemy.x+lengthdir_x(-_r*0.25,_a)+lengthdir_x(_r*0.25,_a+90),
        _enemy.y+lengthdir_y(-_r*0.25,_a)+lengthdir_y(_r*0.25,_a+90),
        _a+22,
        random_range(1.8,2.8),
        _a,7,1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.core,
        _enemy.x+lengthdir_x(-_r*0.92,_a),
        _enemy.y+lengthdir_y(-_r*0.92,_a),
        random(360),
        random_range(1.4,2.2),
        _a,choose(-8,8),0.9
    ));

    sc_death_fragment_create(
        _enemy.x,_enemy.y,_fragments,
        _data.visual.palette.core,
        _data.visual.palette.glow,
        _r,82
    );

    return true;
}

/// @description Draws the Artillery Cruiser's separated front wreckage.
function sc_enemy_corporation_artillery_fragment_front_draw(_x,_y,_r,_a,_v)
{
    var _p = _v.palette;

    sc_visual_triangle(_x,_y,_r,_a,1.62,0,0.2,-0.29,0.2,0.29,_p.hull_mid,false);
    sc_visual_triangle(_x,_y,_r,_a,1.5,0,0.28,-0.19,0.28,0.19,_p.armour_light,false);
    sc_corp_visual_energy_strip(_x,_y,_r,_a,1.35,0,0.45,0,3,_p);
}

/// @description Draws the Artillery Cruiser's separated left wreckage.
function sc_enemy_corporation_artillery_fragment_left_draw(_x,_y,_r,_a,_v)
{
    var _p = _v.palette;

    sc_visual_quad(_x,_y,_r,_a,0.16,-0.13,-0.7,-0.17,-1.3,-0.27,-0.18,-0.43,_p.hull_dark);
    sc_visual_triangle(_x,_y,_r,_a,-0.3,-0.37,-1.12,-0.56,-1.31,-0.24,_p.armour_mid,false);
    sc_corp_visual_energy_strip(_x,_y,_r,_a,-0.38,-0.31,-1,-0.28,3,_p);
}

/// @description Draws the Artillery Cruiser's separated right wreckage.
function sc_enemy_corporation_artillery_fragment_right_draw(_x,_y,_r,_a,_v)
{
    var _p = _v.palette;

    sc_visual_quad(_x,_y,_r,_a,0.16,0.13,-0.7,0.17,-1.3,0.27,-0.18,0.43,_p.hull_dark);
    sc_visual_triangle(_x,_y,_r,_a,-0.3,0.37,-1.12,0.56,-1.31,0.24,_p.armour_mid,false);
    sc_corp_visual_energy_strip(_x,_y,_r,_a,-0.38,0.31,-1,0.28,3,_p);
}