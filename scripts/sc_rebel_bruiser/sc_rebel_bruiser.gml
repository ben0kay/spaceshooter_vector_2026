/// @description Registers the Rebel Incendiary Cannon.
function sc_weapon_register_rebel_incendiary_cannon_bruiser()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_incendiary_cannon_bruiser",
            name: "Rebel Incendiary Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_incendiary_canister",

            projectile: {
                scale: 1.5,
                speed: 16,
                life: 55
            },

            damage: {
                amount: 2,
                type: DamageType.KINETIC,
                effect: DamageEffect.NONE
            },

            guidance: 0,

            detonation: {
                scale: 1.5,

                damage: {
                    amount: 3,
                    type: DamageType.THERMAL,
                    effect: DamageEffect.BURN,
                    effect_chance: 0.2
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.48,
            pitch_range: 0.1
        }
    });
}

/// @description Registers the slow Veteran Superheavy Rebel Bruiser.
function sc_enemy_register_rebel_bruiser()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_rebel_bruiser",
            name: "Rebel Bruiser",
            faction: Faction.REBEL,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.SUPERHEAVY,
            rank: EnemyRank.VETERAN,
            threat_value: 19
        },

        reward: {
            credits: 165
        },

        stats_base: {
            shield_max: 0,
            armour_max: 2100,
            hull_max: 900,
            mass: 3.5,

            handling: {
                speed_max: 2.7,
                acceleration: 0.095,
                friction_coeff: 0.994,
                turn_speed: 0.9,
                directional: true,
                directional_speed_min: 0.25,
                directional_thrust_min: 0.4
            },

            range: {
                detection: 1700,
                combat: 1200,
                backaway: 0,
                forget: 2050,
                wander: 0,
                alert_share: 1600
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_hold,
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
                offset_min: 175,
                offset_max: 290,
                exit_distance: 850,
                arrival_radius: 125,
                turnaround_delay: 45,
                speed_scale: 1,
                alternate_side: true
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 650,
            arrival_radius: 130,
            search_duration: 190,
            speed_scale: 0.6
        },

        visual: sc_enemy_rebel_bruiser_visual_data(),

        collision: {
            radius_forward_scale: 1.15,
            radius_side_scale: 1.08,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "upper_rear_minigun",
                group: "upper_miniguns",
                forward: -0.05,
                side: -0.94,
                angle: -90,
                muzzle_forward: 0.24,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 2,
                    arc: 20,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_bruiser_minigun_draw
            },
            {
                key: "upper_front_minigun",
                group: "upper_miniguns",
                forward: 0.65,
                side: -0.88,
                angle: -90,
                muzzle_forward: 0.24,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 2,
                    arc: 20,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_bruiser_minigun_draw
            },
            {
                key: "lower_rear_minigun",
                group: "lower_miniguns",
                forward: -0.05,
                side: 0.94,
                angle: 90,
                muzzle_forward: 0.24,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 2,
                    arc: 20,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_bruiser_minigun_draw
            },
            {
                key: "lower_front_minigun",
                group: "lower_miniguns",
                forward: 0.65,
                side: 0.88,
                angle: 90,
                muzzle_forward: 0.24,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 2,
                    arc: 20,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_bruiser_minigun_draw
            },
            {
                key: "nose_incendiary_cannon_bruiser",
                group: "incendiary_cannon_bruiser",
                forward: 0.91,
                side: 0,
                angle: 0,
                muzzle_forward: 0.52,

                authored: {
                    sprite: s_rebel_projectile_cannon,
                    scale: 0.07
                },

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 1.7,
                    arc: 45,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_bruiser_cannon_draw
            }
        ],

        thrusters: [
            {
                key: "main_thruster",
                forward: -0.89,
                side: 0,
                angle: 180,
                scale: 1.5
            }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 3,

            channels: [
                { key: "upper_guns", selection: AttackSelection.WEIGHTED },
                { key: "lower_guns", selection: AttackSelection.WEIGHTED },
                { key: "nose_cannon", selection: AttackSelection.WEIGHTED }
            ],

            attacks: [
                {
                    key: "upper_side_miniguns",
                    channel: "upper_guns",
                    weight: 100,
                    hardpoint_group: "upper_miniguns",
                    weapon_key: "weapon_rebel_minigun",

                    conditions: {
                        line_of_sight: true,
                        range_min: 0,
                        range_max: 1400
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 2,
                        fire_tolerance: 9
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 6,
                        volley_max: 18,
                        cooldown: 30
                    }
                },
                {
                    key: "lower_side_miniguns",
                    channel: "lower_guns",
                    weight: 100,
                    hardpoint_group: "lower_miniguns",
                    weapon_key: "weapon_rebel_minigun",

                    conditions: {
                        line_of_sight: true,
                        range_min: 0,
                        range_max: 1400
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 2,
                        fire_tolerance: 9
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 6,
                        volley_max: 18,
                        cooldown: 30
                    }
                },
                {
                    key: "nose_incendiary_burst",
                    channel: "nose_cannon",
                    weight: 100,
                    hardpoint_group: "incendiary_cannon_bruiser",
                    weapon_key: "weapon_rebel_incendiary_cannon_bruiser",

                    conditions: {
                        line_of_sight: true,
                        range_min: 180,
                        range_max: 1500
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 2.5,
                        fire_tolerance: 10
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 180
                    }
                }
            ]
        }
    });
}

/// @description Returns the Bruiser's authored hull, turrets and debris visuals.
function sc_enemy_rebel_bruiser_visual_data()
{
    return {
        radius: 215,
        motion_strength: 1.2,
        palette: sc_faction_palette_get(Faction.REBEL),

        authored: {
            enabled: true,

            body: {
                sprite: s_rebel_bruiser_hull,
                scale: 0.35,
                fallback_script: sc_enemy_rebel_bruiser_body_draw
            }
        },

        core: {
            forward: -0.45,
            side: 0
        },

        draw: {
            body: sc_enemy_body_dispatch,
            core: sc_enemy_rebel_bruiser_core_draw
        },

        death: {
            script: sc_enemy_rebel_bruiser_death,

            draw_scripts: [
                sc_enemy_rebel_bruiser_fragment_front_draw,
                sc_enemy_rebel_bruiser_fragment_upper_draw,
                sc_enemy_rebel_bruiser_fragment_lower_draw,
                sc_enemy_rebel_bruiser_fragment_engine_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_rebel_bruiser_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 512,
            core_canvas_size: 64,
            hardpoint_canvas_size: 256,
            thrust_canvas_size: 160,
            fragment_canvas_size: 320
        }
    };
}

/// @description Draws a primitive hull if the imported Bruiser sprite is unavailable.
function sc_enemy_rebel_bruiser_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.83, -0.23,
        0.83, 0.23,
        -0.96, 0.3,
        -0.96, -0.3,
        _p.hull_dark
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.4, -0.2,
        0.08, -0.96,
        -0.64, -0.97,
        -0.47, -0.23,
        _p.hull_light
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.4, 0.2,
        -0.47, 0.23,
        -0.64, 0.97,
        0.08, 0.96,
        _p.hull_mid
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        1.14, -0.13,
        1.14, 0.13,
        0.62, 0.19,
        0.62, -0.19,
        _p.metal
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.46, -0.18,
        0.46, 0.18,
        -0.56, 0.22,
        -0.56, -0.22,
        _p.paint
    );

    sc_visual_line(_x, _y, _radius, _angle, -0.35, -0.2, 0.3, -0.2, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.35, 0.2, 0.3, 0.2, 3, _p.metal);
}

/// @description Draws a broad outward-facing Bruiser side minigun.
function sc_enemy_rebel_bruiser_minigun_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _r = 42;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _r, _angle, -0.2, 0, 0.39, _p.void, false);
    sc_visual_circle(_x, _y, _r, _angle, -0.2, 0, 0.31, _p.metal, false);

    sc_visual_quad(
        _x, _y, _r, _angle,
        -0.31, -0.32,
        0.38, -0.27,
        0.38, 0.27,
        -0.31, 0.32,
        _p.hull_dark
    );

    sc_visual_quad(
        _x, _y, _r, _angle,
        -0.16, -0.24,
        0.46, -0.19,
        0.46, 0.19,
        -0.16, 0.24,
        _p.hull_light
    );

    sc_visual_line(_x, _y, _r, _angle, 0.29, -0.13, 0.96, -0.13, 7, _p.metal);
    sc_visual_line(_x, _y, _r, _angle, 0.29, 0.13, 0.96, 0.13, 7, _p.metal);
    sc_visual_line(_x, _y, _r, _angle, 0.43, -0.13, 0.98, -0.13, 2, _p.void);
    sc_visual_line(_x, _y, _r, _angle, 0.43, 0.13, 0.98, 0.13, 2, _p.void);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws a primitive incendiary cannon if its sprite is unavailable.
function sc_enemy_rebel_bruiser_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);
    sc_visual_quad(
        _x, _y, 75, _angle,
        -0.3, -0.37,
        0.5, -0.37,
        0.5, 0.37,
        -0.3, 0.37,
        _p.hull_dark
    );
    sc_visual_line(_x, _y, 75, _angle, 0.16, 0, 1.33, 0, 16, _p.metal);
    sc_visual_circle(_x, _y, 75, _angle, 1.33, 0, 0.18, _p.void, false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Leaves the imported Bruiser hull free of an extra core overlay.
function sc_enemy_rebel_bruiser_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    return;
}

/// @description Draws a narrow Bruiser exhaust flame.
function sc_enemy_rebel_bruiser_thrust_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha * 0.25);
    sc_visual_triangle(_x, _y, _radius, _angle, 0, -0.11, 0.68, 0, 0, 0.11, _p.glow, false);

    draw_set_alpha(_alpha * 0.7);
    sc_visual_triangle(_x, _y, _radius, _angle, 0, -0.075, 0.51, 0, 0, 0.075, _p.energy, false);

    draw_set_alpha(_alpha);
    sc_visual_triangle(_x, _y, _radius, _angle, 0, -0.035, 0.32, 0, 0, 0.035, _p.core, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Breaks the Bruiser into four primitive hull sections and five turrets.
function sc_enemy_rebel_bruiser_death(_enemy)
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
        _x + lengthdir_x(_radius * 0.53, _angle),
        _y + lengthdir_y(_radius * 0.53, _angle),
        _angle + random_range(-10, 10),
        random_range(2.4, 3.6),
        _angle,
        choose(-6, 6),
        1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[1],
        _x + lengthdir_x(-_radius * 0.12, _angle) + lengthdir_x(-_radius * 0.57, _angle + 90),
        _y + lengthdir_y(-_radius * 0.12, _angle) + lengthdir_y(-_radius * 0.57, _angle + 90),
        _angle - 45,
        random_range(2.8, 4),
        _angle,
        -8,
        1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[2],
        _x + lengthdir_x(-_radius * 0.12, _angle) + lengthdir_x(_radius * 0.57, _angle + 90),
        _y + lengthdir_y(-_radius * 0.12, _angle) + lengthdir_y(_radius * 0.57, _angle + 90),
        _angle + 45,
        random_range(2.8, 4),
        _angle,
        8,
        1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[3],
        _x + lengthdir_x(-_radius * 0.65, _angle),
        _y + lengthdir_y(-_radius * 0.65, _angle),
        _angle + random_range(-15, 15),
        random_range(2, 3.4),
        _angle + 180,
        choose(-7, 7),
        1
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _mount_x = _x
            + lengthdir_x(_hardpoint.forward * _radius, _angle)
            + lengthdir_x(_hardpoint.side * _radius, _angle + 90);

        var _mount_y = _y
            + lengthdir_y(_hardpoint.forward * _radius, _angle)
            + lengthdir_y(_hardpoint.side * _radius, _angle + 90);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoints[_i],
            _mount_x,
            _mount_y,
            _angle + _hardpoint.angle + random_range(-20, 20),
            random_range(2.6, 4),
            _angle + _hardpoint.angle,
            choose(-10, 10),
            0.9
        ));
    }

    sc_death_fragment_create(
        _x, _y, _fragments,
        _visual.palette.core,
        _visual.palette.glow,
        _radius,
        52
    );

    return true;
}

/// @description Draws the Bruiser's broken nose and central plating.
function sc_enemy_rebel_bruiser_fragment_front_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        1.1, -0.13,
        1.1, 0.13,
        -0.15, 0.27,
        -0.15, -0.27,
        _p.hull_mid
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.41, -0.12,
        0.41, 0.11,
        -0.17, 0.15,
        -0.17, -0.16,
        _p.metal
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.31, -0.21, 0.3, 0.19, 3, _p.outline);
}

/// @description Draws the Bruiser's shattered upper gun deck.
function sc_enemy_rebel_bruiser_fragment_upper_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.39, -0.18,
        0.07, -0.99,
        -0.65, -0.96,
        -0.49, -0.21,
        _p.hull_light
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.18, -0.4, -0.49, -0.77, 3, _p.metal);
}

/// @description Draws the Bruiser's shattered lower gun deck.
function sc_enemy_rebel_bruiser_fragment_lower_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.39, 0.18,
        -0.49, 0.21,
        -0.65, 0.96,
        0.07, 0.99,
        _p.hull_mid
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.18, 0.4, -0.49, 0.77, 3, _p.metal);
}

/// @description Draws the Bruiser's severed engine block.
function sc_enemy_rebel_bruiser_fragment_engine_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.28, -0.32,
        -0.28, 0.32,
        -1.04, 0.29,
        -1.04, -0.29,
        _p.hull_dark
    );

    sc_visual_circle(_x, _y, _radius, _angle, -0.94, 0, 0.17, _p.metal, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.95, 0, 0.1, _p.void, false);
}