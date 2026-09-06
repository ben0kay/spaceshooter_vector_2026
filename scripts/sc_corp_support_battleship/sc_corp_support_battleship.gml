/*
CORPORATION SUPPORT BATTLESHIP

Huge slow 3:1 repair vessel with six defensive plasma turrets,
two centreline rocket pods and one independent repair-beam turret.
*/

/// @description Registers the Corporation Support Battleship.
function sc_enemy_register_corporation_support_battleship()
{
    return sc_enemy_register({
        identity: {
            key: "e_corp_support_battleship",
            name: "Corp Support Battleship",
            faction: Faction.CORPORATION,
            role: EnemyRole.SUPPORT,
            ship_class: EnemyClass.HEAVY,
            rank: EnemyRank.ELITE,
            threat_value: 35
        },

        reward: { credits: 450 },

        stats_base: {
            shield_max: 800,
            armour_max: 2500,
            hull_max: 1100,
            mass: 8,

            handling: {
                speed_max: 1.35,
                acceleration: 0.035,
                friction_coeff: 0.996,
                turn_speed: 0.22,
                directional: true,
                directional_speed_min: 0.18,
                directional_thrust_min: 0.3
            },

            range: {
                detection: 1800,
                combat: 1450,
                backaway: 384,
                forget: 2300,
                wander: 0,
                alert_share: 2200
            },

            damage_multiplier: 1.25,
            fire_rate_multiplier: 0.75
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_hold,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_hold_line_of_sight,

            facing: {
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.TARGET,
                angle_offset: 0,
                turn_speed_scale: 0.5,
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
            duration: 900,
            arrival_radius: 160,
            search_duration: 240,
            speed_scale: 0.45
        },

        visual: sc_enemy_corporation_support_battleship_visual_data(),

        collision: {
            radius_forward_scale: 1.5,
            radius_side_scale: 0.5,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "plasma_front_left", group: "plasma_turrets",
                forward: 0.85, side: -0.43, angle: 0, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.2, arc: 300, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "plasma_front_right", group: "plasma_turrets",
                forward: 0.85, side: 0.43, angle: 0, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.2, arc: 300, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "plasma_mid_left", group: "plasma_turrets",
                forward: 0.05, side: -0.48, angle: 0, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2, arc: 300, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "plasma_mid_right", group: "plasma_turrets",
                forward: 0.05, side: 0.48, angle: 0, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2, arc: 300, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "plasma_rear_left", group: "plasma_turrets",
                forward: -0.72, side: -0.42, angle: 180, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.8, arc: 300, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "plasma_rear_right", group: "plasma_turrets",
                forward: -0.72, side: 0.42, angle: 180, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.8, arc: 300, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_plasma_turret_draw
            },
            {
                key: "rocket_front", group: "rocket_launchers",
                forward: 0.62, side: 0, angle: 0, muzzle_forward: 0,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_rocket_pod_draw
            },
            {
                key: "repair_centre", group: "repair_beam",
                forward: 0, side: 0, angle: 0, muzzle_forward: 0.42,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.5, arc: 360, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_repair_turret_draw
            },
            {
                key: "rocket_rear", group: "rocket_launchers",
                forward: -0.62, side: 0, angle: 180, muzzle_forward: 0,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_corporation_battleship_rocket_pod_draw
            }
        ],

        thrusters: [
            { key: "engine_left", forward: -1.43, side: -0.32, angle: 180, scale: 0.62 },
            { key: "engine_centre", forward: -1.5, side: 0, angle: 180, scale: 0.74 },
            { key: "engine_right", forward: -1.43, side: 0.32, angle: 180, scale: 0.62 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                { key: "plasma", selection: AttackSelection.WEIGHTED },
                { key: "rockets", selection: AttackSelection.WEIGHTED }
            ],

            attacks: [
                {
                    key: "defensive_plasma",
                    channel: "plasma",
                    weight: 100,
                    hardpoint_group: "plasma_turrets",
                    weapon_key: "weapon_corporation_plasma",

                    conditions: {
                        line_of_sight: true,
                        range_min: 150,
                        range_max: 1450
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
                        order: HardpointFireOrder.RANDOM,
                        interval: 7,
                        volley_max: 20,
                        cooldown: 85
                    }
                },
                {
                    key: "rocket_salvo",
                    channel: "rockets",
                    weight: 100,
                    hardpoint_group: "rocket_launchers",
                    weapon_key: "weapon_corporation_rocket",

                    conditions: {
                        line_of_sight: true,
                        range_min: 300,
                        range_max: 1700
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 3,
                        fire_tolerance: 360
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 12,
                        volley_max: 3,
                        cooldown: 210
                    }
                }
            ]
        },

        utility_controller: {
            channels: [
                {
                    key: "repair",
                    hardpoint_group: "repair_beam",

                    target_script: sc_enemy_utility_target_damaged_ally,
                    valid_script: sc_enemy_utility_target_repair_valid,
                    action_script: sc_enemy_utility_action_repair,
                    draw_script: sc_enemy_utility_repair_beam_draw,

                    acquire_range: 640,
                    release_range: 768,
                    retarget_interval: 30,
                    action_interval: 6,
                    aim_tolerance: 5,

                    repair: {
                        armour: 4,
                        hull: 2
                    },

                    visual: {
                        width: 5,
                        glow_width: 18
                    }
                }
            ]
        }
    });
}

/// @description Returns the Support Battleship's layered visual definition.
function sc_enemy_corporation_support_battleship_visual_data()
{
    return {
        radius: 260,
        motion_strength: 0.45,
        palette: sc_faction_palette_get(Faction.CORPORATION),
        core: { forward: -1.05, side: 0 },

        draw: {
            body: sc_enemy_corporation_support_battleship_body_draw,
            core: sc_enemy_corporation_support_battleship_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_corporation_support_battleship_hull_draw,
            armour_draw_script: sc_enemy_corporation_support_battleship_armour_draw
        },

        death: {
            script: sc_enemy_corporation_support_battleship_death,
            draw_scripts: [
                sc_enemy_corporation_support_fragment_front_draw,
                sc_enemy_corporation_support_fragment_left_draw,
                sc_enemy_corporation_support_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_corporation_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 1024,
            core_canvas_size: 512,
            hardpoint_canvas_size: 384,
            thrust_canvas_size: 512,
            fragment_canvas_size: 512
        }
    };
}

/// @description Draws the intact Support Battleship fallback.
function sc_enemy_corporation_support_battleship_body_draw(_x, _y, _radius, _angle, _visual)
{
    sc_enemy_corporation_support_battleship_hull_draw(_x,_y,_radius,_angle,_visual,0);
    sc_enemy_corporation_support_battleship_armour_draw(_x,_y,_radius,_angle,_visual,0);
}

/// @description Draws the permanent industrial battleship hull and progressive damage.
function sc_enemy_corporation_support_battleship_hull_draw(_x, _y, _r, _a, _v, _stage)
{
    var _p = _v.palette;

    // Three-section 3:1 permanent silhouette.
    sc_visual_quad(_x,_y,_r,_a, 1.1,-0.3, 1.5,0, 1.1,0.3, 0.45,0.42,_p.hull_dark);
    sc_visual_quad(_x,_y,_r,_a, 1.1,-0.3, 0.45,0.42, -0.65,0.46, -1.2,0.34,_p.hull_dark);
    sc_visual_quad(_x,_y,_r,_a, 1.1,-0.3, -1.2,-0.34, -0.65,-0.46, 0.45,-0.42,_p.hull_dark);
    sc_visual_quad(_x,_y,_r,_a, -0.65,-0.46, -1.2,-0.34, -1.48,-0.2, -1.48,0.2,_p.hull_dark);
    sc_visual_quad(_x,_y,_r,_a, -0.65,0.46, -1.48,-0.2, -1.48,0.2, -1.2,0.34,_p.hull_dark);

    // Central structural spine.
    sc_visual_quad(_x,_y,_r,_a, 1.34,-0.13, 1.48,0, 1.34,0.13, -1.34,0.18,_p.hull_mid);
    sc_visual_quad(_x,_y,_r,_a, 1.34,-0.13, -1.34,-0.18, -1.34,0.18, 1.34,0.13,_p.hull_mid);

    // Symmetrical machinery and power conduits.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a, 0.92,0.18*_side, 0.45,0.38*_side, -0.28,0.4*_side, -0.15,0.2*_side,_p.hull_mid);
        sc_visual_quad(_x,_y,_r,_a, -0.36,0.21*_side, -0.64,0.42*_side, -1.17,0.31*_side, -1.05,0.17*_side,_p.hull_mid);

        sc_visual_line(_x,_y,_r,_a, 1.14,0.2*_side, 0.55,0.28*_side, 10,_p.void);
        sc_visual_line(_x,_y,_r,_a, 1.12,0.2*_side, 0.57,0.28*_side, 3,_p.energy);
        sc_visual_line(_x,_y,_r,_a, -0.24,0.29*_side, -1.08,0.25*_side, 11,_p.void);
        sc_visual_line(_x,_y,_r,_a, -0.26,0.29*_side, -1.06,0.25*_side, 3,_p.accent);

        for (var _i = 0; _i < 4; _i++)
        {
            var _f = 0.43 - _i*0.21;
            sc_visual_quad(_x,_y,_r,_a, _f,0.27*_side, _f-0.15,0.32*_side, _f-0.15,0.4*_side, _f,0.36*_side,_p.void);
            sc_visual_line(_x,_y,_r,_a, _f-0.03,0.32*_side, _f-0.13,0.35*_side, 3,_p.outline);
        }
    }

    // Nose targeting assembly.
    sc_visual_triangle(_x,_y,_r,_a, 1.5,0, 1.12,-0.16, 1.12,0.16,_p.hull_mid,false);
    sc_visual_line(_x,_y,_r,_a, 1.47,0, 1.16,-0.1, 3,_p.energy);
    sc_visual_line(_x,_y,_r,_a, 1.47,0, 1.16,0.1, 3,_p.energy);

    // Central and rocket hardpoint collars.
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.22,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.22,_p.metal,true);
    sc_visual_circle(_x,_y,_r,_a, 0.62,0,0.13,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a, -0.62,0,0.13,_p.void,false);

    // Rear engine blocks.
    for (var _side = -1; _side <= 1; _side++)
    {
        sc_visual_quad(_x,_y,_r,_a, -1.08,-0.11+_side*0.3, -1.48,-0.12+_side*0.32, -1.48,0.12+_side*0.32, -1.08,0.11+_side*0.3,_p.hull_mid);
        sc_visual_line(_x,_y,_r,_a, -1.16,_side*0.31, -1.47,_side*0.32, 9,_p.energy);
    }

    if (_stage >= 1)
    {
        sc_visual_line(_x,_y,_r,_a, 0.85,-0.28, 0.6,-0.39, 7,_p.void);
        sc_visual_line(_x,_y,_r,_a, 0.86,-0.27, 0.65,-0.36, 2,_p.energy);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x,_y,_r,_a, -0.48,0.34,0.14,_p.void,false);
        sc_visual_line(_x,_y,_r,_a, -0.46,0.34, -0.72,0.42, 3,_p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x,_y,_r,_a, 0.34,-0.34,0.16,_p.void,false);
        sc_visual_circle(_x,_y,_r,_a, -1.08,-0.2,0.13,_p.void,false);
        sc_visual_line(_x,_y,_r,_a, -0.95,-0.17, -1.28,-0.27, 3,_p.energy);
    }
}

/// @description Draws strictly subtractive Corporation battleship armour.
function sc_enemy_corporation_support_battleship_armour_draw(_x, _y, _r, _a, _v, _stage)
{
    var _p = _v.palette;

    // Inner armour survives every stage.
    sc_visual_quad(_x,_y,_r,_a, 0.75,-0.15, 1.24,0, 0.75,0.15, 0.2,0.16,_p.metal);
    sc_visual_quad(_x,_y,_r,_a, 0.2,-0.16, 0.2,0.16, -0.42,0.18, -0.42,-0.18,_p.hull_light);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x,_y,_r,_a, 0.75,0.19*_side, 0.43,0.32*_side, 0.05,0.34*_side, 0.16,0.2*_side,_p.metal);

        if (_stage <= 2)
            sc_visual_quad(_x,_y,_r,_a, -0.18,0.21*_side, -0.45,0.35*_side, -0.83,0.36*_side, -0.68,0.2*_side,_p.hull_light);

        if (_stage <= 1)
        {
            sc_visual_quad(_x,_y,_r,_a, 1.06,0.19*_side, 0.78,0.31*_side, 0.47,0.38*_side, 0.58,0.2*_side,_p.hull_light);
            sc_visual_quad(_x,_y,_r,_a, -0.75,0.2*_side, -0.93,0.34*_side, -1.25,0.27*_side, -1.12,0.15*_side,_p.metal);
        }

        if (_stage == 0)
        {
            sc_visual_quad(_x,_y,_r,_a, 0.36,0.34*_side, 0.05,0.43*_side, -0.38,0.43*_side, -0.25,0.34*_side,_p.metal);
            sc_visual_quad(_x,_y,_r,_a, -0.48,0.36*_side, -0.72,0.44*_side, -1.05,0.34*_side, -0.86,0.29*_side,_p.hull_light);
        }
    }

    if (_stage <= 2)
        sc_visual_triangle(_x,_y,_r,_a, 1.46,0, 1.03,-0.17, 1.03,0.17,_p.hull_light,false);

    if (_stage <= 1)
        sc_visual_quad(_x,_y,_r,_a, -0.46,-0.15, -0.46,0.15, -1.16,0.13, -1.16,-0.13,_p.metal);

    if (_stage == 0)
    {
        sc_visual_circle(_x,_y,_r,_a, 0,0,0.245,_p.metal,true);
        sc_visual_circle(_x,_y,_r,_a, 0.62,0,0.15,_p.hull_light,true);
        sc_visual_circle(_x,_y,_r,_a, -0.62,0,0.15,_p.hull_light,true);
    }
}

/// @description Draws a small battleship plasma turret.
function sc_enemy_corporation_battleship_plasma_turret_draw(_x, _y, _r, _a, _v, _alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_r,_a, 0,0,0.065,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.055,_p.metal,false);
    sc_visual_quad(_x,_y,_r,_a, -0.01,-0.035, 0.145,-0.025, 0.145,0.025, -0.01,0.035,_p.hull_dark);
    sc_visual_line(_x,_y,_r,_a, 0.02,0,0.17,0,3,_p.energy);
    sc_visual_circle(_x,_y,_r,_a, 0.165,0,0.024,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws one centreline armoured rocket pod.
function sc_enemy_corporation_battleship_rocket_pod_draw(_x, _y, _r, _a, _v, _alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    sc_visual_quad(_x,_y,_r,_a, -0.1,-0.085, 0.1,-0.085, 0.1,0.085, -0.1,0.085,_p.hull_dark);

    for (var _forward = -1; _forward <= 1; _forward += 2)
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_circle(_x,_y,_r,_a, 0.045*_forward,0.04*_side,0.026,_p.void,false);
        sc_visual_circle(_x,_y,_r,_a, 0.045*_forward,0.04*_side,0.015,_p.energy,false);
    }

    sc_visual_line(_x,_y,_r,_a, -0.1,-0.085, 0.1,-0.085,2,_p.metal);
    sc_visual_line(_x,_y,_r,_a, -0.1,0.085, 0.1,0.085,2,_p.outline);

    draw_set_alpha(1);
}

/// @description Draws the battleship's dominant 360-degree repair turret.
function sc_enemy_corporation_battleship_repair_turret_draw(_x, _y, _r, _a, _v, _alpha)
{
    var _p = _v.palette;
    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_r,_a, 0,0,0.21,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.18,_p.metal,false);
    sc_visual_circle(_x,_y,_r,_a, 0,0,0.12,_p.hull_mid,false);

    sc_visual_quad(_x,_y,_r,_a, -0.03,-0.09, 0.37,-0.055, 0.37,0.055, -0.03,0.09,_p.hull_dark);
    sc_visual_line(_x,_y,_r,_a, 0.02,-0.065, 0.4,-0.035,3,_p.metal);
    sc_visual_line(_x,_y,_r,_a, 0.02,0.065, 0.4,0.035,3,_p.outline);
    sc_visual_line(_x,_y,_r,_a, 0.04,0,0.42,0,8,_p.void);
    sc_visual_line(_x,_y,_r,_a, 0.07,0,0.42,0,3,_p.energy);

    sc_visual_circle(_x,_y,_r,_a, 0.42,0,0.065,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a, 0.42,0,0.04,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the battleship's rear reactor.
function sc_enemy_corporation_support_battleship_core_draw(_x, _y, _r, _a, _v, _alpha)
{
    var _p = _v.palette;
    var _pulse = 0.9 + sin(GAME_TICK*0.06)*0.1;

    draw_set_alpha(_alpha*0.2);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_r*0.22*_pulse,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_r*0.15,false);
    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_r*0.15,true);
    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_r*0.07*_pulse,false);
    draw_set_colour(_p.core);
    draw_circle(_x,_y,_r*0.025,false);

    draw_set_alpha(1);
}

/// @description Creates the Support Battleship destruction fragments.
function sc_enemy_corporation_support_battleship_death(_enemy)
{
    var _data = _enemy.enemy;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _r = _data.visual.radius;
    var _a = _enemy.draw_angle;
    var _fragments = [];

    array_push(_fragments,sc_death_fragment_data(_cache.fragments[0],_enemy.x+lengthdir_x(_r*0.8,_a),_enemy.y+lengthdir_y(_r*0.8,_a),_a+random_range(-8,8),random_range(1.8,2.8),_a,choose(-5,5),1));
    array_push(_fragments,sc_death_fragment_data(_cache.fragments[1],_enemy.x+lengthdir_x(-_r*0.25,_a)+lengthdir_x(-_r*0.25,_a+90),_enemy.y+lengthdir_y(-_r*0.25,_a)+lengthdir_y(-_r*0.25,_a+90),_a-20,random_range(2,3),_a,-6,1));
    array_push(_fragments,sc_death_fragment_data(_cache.fragments[2],_enemy.x+lengthdir_x(-_r*0.25,_a)+lengthdir_x(_r*0.25,_a+90),_enemy.y+lengthdir_y(-_r*0.25,_a)+lengthdir_y(_r*0.25,_a+90),_a+20,random_range(2,3),_a,6,1));
    array_push(_fragments,sc_death_fragment_data(_cache.core,_enemy.x+lengthdir_x(-_r*1.05,_a),_enemy.y+lengthdir_y(-_r*1.05,_a),random(360),random_range(1.5,2.2),_a,choose(-8,8),0.9));

    sc_death_fragment_create(
        _enemy.x,_enemy.y,_fragments,
        _data.visual.palette.core,
        _data.visual.palette.glow,
        _r,72
    );

    return true;
}

function sc_enemy_corporation_support_fragment_front_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,1.5,0,0.35,-0.36,0.35,0.36,_v.palette.hull_light,false);
    sc_visual_line(_x,_y,_r,_a,1.5,0,0.35,-0.36,3,_v.palette.energy);
}

function sc_enemy_corporation_support_fragment_left_draw(_x,_y,_r,_a,_v)
{
    sc_visual_quad(_x,_y,_r,_a,0.35,-0.16,-1.28,-0.18,-1.2,-0.43,0.28,-0.42,_v.palette.hull_mid);
    sc_visual_line(_x,_y,_r,_a,0.2,-0.31,-1.08,-0.27,3,_v.palette.energy);
}

function sc_enemy_corporation_support_fragment_right_draw(_x,_y,_r,_a,_v)
{
    sc_visual_quad(_x,_y,_r,_a,0.35,0.16,0.28,0.42,-1.2,0.43,-1.28,0.18,_v.palette.hull_light);
    sc_visual_line(_x,_y,_r,_a,0.2,0.31,-1.08,0.27,3,_v.palette.accent);
}