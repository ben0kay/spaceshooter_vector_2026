/*
CORPORATION RAZORWING CHAMPION

Fast elite Standard-class fighter with:
- Four twin plasma turrets
- Two narrow-arc micro-missile turrets
- One fast-tracking close-defence laser
- Two independent attack channels
*/

/// @description Registers the Corporation Razorwing Champion.
function sc_enemy_register_corporation_razorwing_champion()
{
    return sc_enemy_register({
        identity: {
            key: "e_corp_razorwing_champion",
            name: "Corp Razorwing Champion",
            faction: Faction.CORPORATION,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.STANDARD,
            rank: EnemyRank.CHAMPION,
            threat_value: 18
        },

        reward: {
            credits: 180
        },

        stats_base: {
            shield_max: 320,
            armour_max: 560,
            hull_max: 260,
            mass: 2.2,

            handling: {
                speed_max: 7.6,
                acceleration: 0.27,
                friction_coeff: 0.991,
                turn_speed: 3.4,
                directional: true,
                directional_speed_min: 0.5,
                directional_thrust_min: 0.62
            },

            range: {
                detection: 1750,
                combat: 1450,
                backaway: 0,
                forget: 2400,
                wander: 600,
                alert_share: 1900
            },

            damage_multiplier: 1.2,
            fire_rate_multiplier: 1.12
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
                offset_min: 220,
                offset_max: 390,
                exit_distance: 920,
                arrival_radius: 100,
                turnaround_delay: 24,
                speed_scale: 1.06,
                alternate_side: true
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 720,
            arrival_radius: 110,
            search_duration: 210,
            speed_scale: 0.82
        },

        visual: sc_enemy_corporation_razorwing_visual_data(),

                collision: {
            radius_forward_scale: 1.65,
            radius_side_scale: 0.58,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "plasma_front_left",
                group: "plasma_pairs",
                forward: 0.22,
                side: -0.31,
                angle: 0,
                muzzle_forward: 0.29,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 7,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_twin_plasma_draw
            },
            {
                key: "plasma_front_right",
                group: "plasma_pairs",
                forward: 0.22,
                side: 0.31,
                angle: 0,
                muzzle_forward: 0.29,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 7,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_twin_plasma_draw
            },
            {
                key: "plasma_rear_left",
                group: "plasma_pairs",
                forward: -0.48,
                side: -0.33,
                angle: 180,
                muzzle_forward: 0.29,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 6.5,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_twin_plasma_draw
            },
            {
                key: "plasma_rear_right",
                group: "plasma_pairs",
                forward: -0.48,
                side: 0.33,
                angle: 180,
                muzzle_forward: 0.29,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 6.5,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_twin_plasma_draw
            },
            {
                key: "rocket_front_left",
                group: "micro_missiles",
                forward: 0.73,
                side: -0.25,
                angle: 0,
                muzzle_forward: 0.19,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 4.5,
                    arc: 50,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_rocket_turret_draw
            },
            {
                key: "rocket_front_right",
                group: "micro_missiles",
                forward: 0.73,
                side: 0.25,
                angle: 0,
                muzzle_forward: 0.19,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 4.5,
                    arc: 50,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_rocket_turret_draw
            },
            {
                key: "laser_centre",
                group: "precision_laser",
                forward: 0.02,
                side: 0,
                angle: 0,
                muzzle_forward: 0.34,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 14,
                    arc: 360,
                    return_to_rest: true
                },

                draw_script: sc_enemy_corporation_razorwing_laser_turret_draw
            }
        ],

        thrusters: [
            { key: "engine_left", forward: -1.08, side: -0.2, angle: 180, scale: 0.86 },
            { key: "engine_right", forward: -1.08, side: 0.2, angle: 180, scale: 0.86 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                { key: "plasma", selection: AttackSelection.WEIGHTED },
                { key: "heavy", selection: AttackSelection.WEIGHTED }
            ],

            attacks: [
                {
                    key: "twin_plasma_barrage",
                    channel: "plasma",
                    weight: 100,
                    hardpoint_group: "plasma_pairs",
                    weapon_key: "weapon_corporation_plasma",

                    conditions: {
                        line_of_sight: true,
                        range_min: 90,
                        range_max: 1250
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 2.2,
                        fire_tolerance: 7
                    },

                    shot: {
                        pattern: ShotPattern.SPREAD,
                        amount: 2,
                        angle_total: 4
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 11,
                        volley_max: 4,
                        cooldown: 72
                    }
                },
                {
                    key: "micro_missile_salvo",
                    channel: "heavy",
                    weight: 100,
                    hardpoint_group: "micro_missiles",
                    weapon_key: "weapon_corporation_pursuit_micro_missile",

                    conditions: {
                        line_of_sight: true,
                        range_min: 640,
                        range_max: 1500
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 1,
                        fire_tolerance: 45
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 12,
                        volley_max: 2,
                        cooldown: 145
                    }
                },
                {
                    key: "close_defence_laser",
                    channel: "heavy",
                    weight: 100,
                    hardpoint_group: "precision_laser",
                    weapon_key: "weapon_corporation_combat_beam",

                    conditions: {
                        line_of_sight: true,
                        range_min: 0,
                        range_max: 640
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 2
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        duration: 54,
                        cooldown: 70
                    }
                }
            ]
        }
    });
}

/// @description Returns the Razorwing Champion's long elite strike-cruiser visual definition.
function sc_enemy_corporation_razorwing_visual_data()
{
    return {
        radius: 96,
        motion_strength: 2.2,
        palette: sc_faction_palette_elite_get(Faction.CORPORATION),
        core: { forward: -0.12, side: 0 },

        draw: {
            body: sc_enemy_corporation_razorwing_body_draw,
            core: sc_enemy_corporation_razorwing_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_corporation_razorwing_hull_draw,
            armour_draw_script: sc_enemy_corporation_razorwing_armour_draw
        },

        death: {
            script: sc_enemy_corporation_razorwing_death,

            draw_scripts: [
                sc_enemy_corporation_razorwing_fragment_front_draw,
                sc_enemy_corporation_razorwing_fragment_left_draw,
                sc_enemy_corporation_razorwing_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_corporation_thrust_draw,
            ignition_script: sc_particles_corporation_thrust_ignition,
            particle_script: sc_particles_corporation_thrust_emit
        },

        bake: {
            body_canvas_size: 448,
            core_canvas_size: 160,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 352
        }
    };
}
/// @description Draws the complete intact Razorwing.
function sc_enemy_corporation_razorwing_body_draw(_x,_y,_r,_a,_v)
{
    sc_enemy_corporation_razorwing_hull_draw(_x,_y,_r,_a,_v,0);
    sc_enemy_corporation_razorwing_armour_draw(_x,_y,_r,_a,_v,0);
}

/// @description Draws the Razorwing's long narrow elite strike-cruiser chassis.
function sc_enemy_corporation_razorwing_hull_draw(_x,_y,_r,_a,_v,_stage)
{
    var _p = _v.palette;

    // Long central mechanical keel.
    sc_visual_quad(_x,_y,_r,_a,
        1.68,-0.07,
        -1.08,-0.13,
        -1.18,0,
        1.68,0.07,
        _p.recess
    );

    sc_visual_quad(_x,_y,_r,_a,
        1.52,-0.045,
        -0.96,-0.085,
        -1.08,0,
        1.52,0.045,
        _p.hull_dark
    );

    // Forward split prow understructure.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a,
            1.7,0.025*_side,
            0.85,0.13*_side,
            0.48,0.2*_side,
            1.24,0.105*_side,
            _p.armour_dark
        );

        sc_visual_line(_x,_y,_r,_a,
            1.67,0.035*_side,
            0.8,0.14*_side,
            2,_p.trim
        );
    }

    // Long internal flanking chassis rails.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a,
            0.7,0.12*_side,
            0.18,0.26*_side,
            -0.82,0.3*_side,
            -0.66,0.17*_side,
            _p.hull_dark
        );

        sc_corp_visual_armour_rib(
            _x,_y,_r,_a,
            0.56,0.16*_side,
            -0.76,0.24*_side,
            2,_p
        );
    }

    // Rear engine frame.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a,
            -0.58,0.12*_side,
            -0.92,0.15*_side,
            -1.18,0.29*_side,
            -0.65,0.27*_side,
            _p.recess
        );

        sc_visual_quad(_x,_y,_r,_a,
            -0.64,0.16*_side,
            -0.94,0.18*_side,
            -1.1,0.245*_side,
            -0.7,0.24*_side,
            _p.armour_dark
        );

        sc_corp_visual_energy_strip(
            _x,_y,_r,_a,
            -0.79,0.21*_side,
            -1.11,0.21*_side,
            2,_p
        );
    }

    // Central power channel.
    sc_corp_visual_energy_strip(
        _x,_y,_r,_a,
        0.9,0,
        -0.62,0,
        3,_p
    );

    // Rear reactor trench.
    sc_visual_quad(_x,_y,_r,_a,
        -0.24,-0.11,
        -0.67,-0.1,
        -0.78,0,
        -0.67,0.1,
        -0.24,0.11,
        _p.recess
    );

    sc_corp_visual_sensor_node(_x,_y,_r,_a,-0.13,0,0.035,_p);

    // Rear centre structural spine.
    sc_visual_triangle(
        _x,_y,_r,_a,
        -0.7,-0.07,
        -1.2,0,
        -0.7,0.07,
        _p.hull_dark,false
    );

    sc_corp_visual_ident_bar(
        _x,_y,_r,_a,
        -0.7,0,
        -1.06,0,
        _p
    );

    if (_stage >= 3)
        sc_visual_line(_x,_y,_r,_a,0.7,0,-0.64,0,3,_p.recess);
}

/// @description Draws the Razorwing's layered elite cruiser armour.
function sc_enemy_corporation_razorwing_armour_draw(_x,_y,_r,_a,_v,_stage)
{
    var _p = _v.palette;

    // Long pointed prow.
    sc_visual_triangle(
        _x,_y,_r,_a,
        1.72,0,
        0.65,-0.13,
        0.65,0.13,
        _p.armour_light,false
    );

    sc_visual_triangle(
        _x,_y,_r,_a,
        1.62,0,
        0.82,-0.08,
        0.96,0,
        _p.metal,false
    );

    sc_visual_triangle(
        _x,_y,_r,_a,
        1.62,0,
        0.96,0,
        0.82,0.08,
        _p.armour_mid,false
    );

    // Forward shoulder plating.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_corp_visual_armour_plate(
            _x,_y,_r,_a,
            0.74,0.11*_side,
            0.38,0.28*_side,
            -0.02,0.31*_side,
            0.17,0.14*_side,
            _p.armour_light,_p
        );

        sc_corp_visual_panel_seam(
            _x,_y,_r,_a,
            0.62,0.145*_side,
            0.18,0.255*_side,
            _p
        );

        sc_corp_visual_light_slit(
            _x,_y,_r,_a,
            0.52,0.19*_side,
            0.34,0.235*_side,
            _p
        );
    }

    // Long midships armour strips.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        if (_stage < 3)
        {
            sc_corp_visual_armour_plate(
                _x,_y,_r,_a,
                0.08,0.15*_side,
                -0.28,0.32*_side,
                -0.75,0.34*_side,
                -0.55,0.17*_side,
                _p.armour_mid,_p
            );
        }

        sc_corp_visual_panel_seam(
            _x,_y,_r,_a,
            -0.03,0.18*_side,
            -0.58,0.29*_side,
            _p
        );
    }

    // Thin outer cruiser fins rather than giant wings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        if (_stage < 2)
        {
            sc_visual_quad(_x,_y,_r,_a,
                0.18,0.29*_side,
                -0.18,0.48*_side,
                -0.72,0.52*_side,
                -0.48,0.34*_side,
                _p.armour_dark
            );

            sc_visual_quad(_x,_y,_r,_a,
                0.12,0.31*_side,
                -0.2,0.43*_side,
                -0.6,0.46*_side,
                -0.43,0.35*_side,
                _p.armour_light
            );

            sc_corp_visual_energy_strip(
                _x,_y,_r,_a,
                -0.06,0.36*_side,
                -0.44,0.43*_side,
                2,_p
            );
        }
    }

    // Rear shoulder plating surrounding engines.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        if (_stage < 4)
        {
            sc_corp_visual_armour_plate(
                _x,_y,_r,_a,
                -0.5,0.15*_side,
                -0.76,0.18*_side,
                -1.03,0.3*_side,
                -0.58,0.29*_side,
                _p.armour_light,_p
            );

            sc_corp_visual_light_slit(
                _x,_y,_r,_a,
                -0.63,0.245*_side,
                -0.83,0.25*_side,
                _p
            );
        }
    }

    // Central laser mount armour cradle.
    sc_corp_visual_weapon_housing(
        _x,_y,_r,_a,
        0.02,0,
        0.3,0.24,
        _p
    );

    // Forward missile housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_corp_visual_weapon_housing(
            _x,_y,_r,_a,
            0.73,0.25*_side,
            0.26,0.18,
            _p
        );
    }

    // Front plasma housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_corp_visual_weapon_housing(
            _x,_y,_r,_a,
            0.22,0.31*_side,
            0.3,0.2,
            _p
        );
    }

    // Rear plasma housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_corp_visual_weapon_housing(
            _x,_y,_r,_a,
            -0.48,0.33*_side,
            0.3,0.2,
            _p
        );
    }

    // Fine longitudinal hull seams.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_corp_visual_panel_seam(
            _x,_y,_r,_a,
            0.98,0.075*_side,
            -0.58,0.12*_side,
            _p
        );
    }

    // Small elite lighting, kept deliberately restrained.
    sc_corp_visual_energy_strip(_x,_y,_r,_a,1.1,0,1.48,0,2,_p);

    if (_stage >= 1)
    {
        sc_visual_line(_x,_y,_r,_a,0.28,-0.29,-0.12,-0.39,2,_p.recess);
        sc_visual_line(_x,_y,_r,_a,-0.35,0.3,-0.68,0.4,2,_p.recess);
    }

    if (_stage >= 2)
    {
        sc_visual_line(_x,_y,_r,_a,-0.08,0.18,-0.58,0.29,3,_p.recess);
        sc_visual_line(_x,_y,_r,_a,0.16,-0.2,-0.3,-0.31,3,_p.recess);
    }

    if (_stage >= 3)
    {
        sc_visual_line(_x,_y,_r,_a,-0.15,-0.08,-0.6,-0.1,3,_p.recess);
        sc_visual_line(_x,_y,_r,_a,-0.26,0.09,-0.72,0.12,3,_p.recess);
    }
}

/// @description Draws one rotating paired elite plasma turret.
function sc_enemy_corporation_razorwing_twin_plasma_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    sc_corp_visual_weapon_housing(_x,_y,_r,_a,0,0,0.22,0.18,_p);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.072,_p.armour_mid,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.04,_p.sensor,false);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_line(_x,_y,_r,_a, 0.02,0.031 * _side, 0.29,0.025 * _side,5,_p.recess);
        sc_visual_line(_x,_y,_r,_a, 0.035,0.031 * _side, 0.31,0.025 * _side,2,_p.armour_light);
        sc_visual_circle(_x,_y,_r,_a, 0.31,0.025 * _side,0.016,_p.core,false);
    }

    sc_visual_line(_x,_y,_r,_a, 0.04,0, 0.25,0,2,_p.energy);
    draw_set_alpha(1);
}

/// @description Draws one compact narrow-arc micro-missile turret.
function sc_enemy_corporation_razorwing_rocket_turret_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    sc_corp_visual_weapon_housing(_x,_y,_r,_a,0.04,0,0.28,0.18,_p);
    sc_visual_circle(_x,_y,_r,_a, -0.02,0,0.08,_p.armour_mid,false);
    sc_visual_circle(_x,_y,_r,_a, -0.02,0,0.035,_p.sensor,false);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_line(_x,_y,_r,_a, 0.03,0.038 * _side, 0.21,0.032 * _side,6,_p.recess);
        sc_visual_circle(_x,_y,_r,_a, 0.21,0.032 * _side,0.026,_p.void,false);
        sc_visual_circle(_x,_y,_r,_a, 0.21,0.032 * _side,0.012,_p.energy,false);
    }

    sc_visual_line(_x,_y,_r,_a, -0.06,-0.075, 0.19,-0.06,2,_p.trim);
    draw_set_alpha(1);
}

/// @description Draws the fast-tracking elite central laser turret.
function sc_enemy_corporation_razorwing_laser_turret_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_r,_a, 0,0,0.18,_p.recess,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.15,_p.armour_light,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.115,_p.armour_dark,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.06,_p.sensor,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.025,_p.core,false);

    sc_corp_visual_weapon_housing(_x,_y,_r,_a,0.15,0,0.36,0.15,_p);
    sc_visual_line(_x,_y,_r,_a, 0.01,0, 0.36,0,8,_p.recess);
    sc_visual_line(_x,_y,_r,_a, 0.04,0, 0.37,0,4,_p.glow);
    sc_visual_line(_x,_y,_r,_a, 0.07,0, 0.38,0,2,_p.energy);
    sc_visual_circle(_x,_y,_r,_a, 0.38,0,0.038,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the Razorwing's central elite reactor.
function sc_enemy_corporation_razorwing_core_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p = _v.palette;
    var _pulse = 0.88 + sin(GAME_TICK * 0.11) * 0.12;

    draw_set_alpha(_alpha * 0.22);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_r * 0.25 * _pulse,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_r * 0.17,false);
    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_r * 0.17,true);
    draw_set_colour(_p.accent);
    draw_circle(_x,_y,_r * 0.11,false);
    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_r * 0.065 * _pulse,false);
    draw_set_colour(_p.core);
    draw_circle(_x,_y,_r * 0.025,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Razorwing Champion's destruction fragments.
function sc_enemy_corporation_razorwing_death(_enemy)
{
    var _data = _enemy.enemy;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _r = _data.visual.radius;
    var _a = _enemy.draw_angle;
    var _fragments = [];

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[0],
        _enemy.x + lengthdir_x(_r * 0.62,_a),
        _enemy.y + lengthdir_y(_r * 0.62,_a),
        _a + random_range(-10,10),
        random_range(2.8,4),
        _a,choose(-9,9),1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[1],
        _enemy.x + lengthdir_x(-_r * 0.1,_a) + lengthdir_x(-_r * 0.55,_a + 90),
        _enemy.y + lengthdir_y(-_r * 0.1,_a) + lengthdir_y(-_r * 0.55,_a + 90),
        _a - 35,
        random_range(3,4.5),
        _a,-11,1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[2],
        _enemy.x + lengthdir_x(-_r * 0.1,_a) + lengthdir_x(_r * 0.55,_a + 90),
        _enemy.y + lengthdir_y(-_r * 0.1,_a) + lengthdir_y(_r * 0.55,_a + 90),
        _a + 35,
        random_range(3,4.5),
        _a,11,1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.core,
        _enemy.x + lengthdir_x(-_r * 0.2,_a),
        _enemy.y + lengthdir_y(-_r * 0.2,_a),
        random(360),
        random_range(2,3),
        _a,choose(-12,12),0.9
    ));

    sc_death_fragment_create(
        _enemy.x,_enemy.y,
        _fragments,
        _data.visual.palette.core,
        _data.visual.palette.glow,
        _r,42
    );

    return true;
}

/// @description Draws the Razorwing's detached front section.
function sc_enemy_corporation_razorwing_fragment_front_draw(_x,_y,_r,_a,_v)
{
    var _p = _v.palette;
    sc_visual_triangle(_x,_y,_r,_a, 0.72,0, 0.04,-0.18, 0.04,0.18,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_r,_a, 0.68,0, 0.12,-0.11, 0.12,0.11,_p.metal,false);
    sc_visual_line(_x,_y,_r,_a, 0.58,0, 0.18,0,3,_p.energy);
}

/// @description Draws the Razorwing's detached left blade assembly.
function sc_enemy_corporation_razorwing_fragment_left_draw(_x,_y,_r,_a,_v)
{
    var _p = _v.palette;
    sc_visual_quad(_x,_y,_r,_a, 0.25,-0.12, -0.12,-0.72, -0.55,-0.94, -0.2,-0.2,_p.hull_mid);
    sc_visual_line(_x,_y,_r,_a, 0.18,-0.18, -0.46,-0.83,3,_p.energy);
}

/// @description Draws the Razorwing's detached right blade assembly.
function sc_enemy_corporation_razorwing_fragment_right_draw(_x,_y,_r,_a,_v)
{
    var _p = _v.palette;
    sc_visual_quad(_x,_y,_r,_a, 0.25,0.12, -0.2,0.2, -0.55,0.94, -0.12,0.72,_p.hull_dark);
    sc_visual_line(_x,_y,_r,_a, 0.18,0.18, -0.46,0.83,3,_p.accent);
}