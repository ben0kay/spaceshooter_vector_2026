/*
REBEL SALVO HAWK

A Veteran Heavy Rebel rocket fighter.

- Authored hull and reusable rocket hardpoints.
- Two fixed wing-mounted launchers.
- Fires four straight rockets, alternating launchers.
- Chases directly until it enters rocket range.
- Weaves laterally while maintaining its preferred firing distance.
*/

/// @description Registers the Salvo Hawk's unguided rocket weapon.
function sc_weapon_register_rebel_salvohawk_rocket()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_salvohawk_rocket",
            name: "Salvo Hawk Rocket"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_salvo_rocket",

            projectile: {
                scale: 1,
                speed: 18,
                life: 105
            },

            damage: {
                amount: 5,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: 0,

            detonation: {
                scale: 1,

                damage: {
                    amount: 7,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.NONE,
                    knockback_force: 1
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.6,
            pitch_range: 0.06
        }
    });
}

/// @description Registers the Veteran Heavy Rebel Salvo Hawk.
function sc_enemy_register_rebel_salvohawk()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_rebel_salvohawk",
            name: "Rebel Salvo Hawk",
            faction: Faction.REBEL,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.HEAVY,
            rank: EnemyRank.VETERAN,
            threat_value: 10
        },

        reward: {
            credits: 95
        },

        stats_base: {
            shield_max: 0,
            armour_max: 720,
            hull_max: 310,
            mass: 2.1,

            handling: {
                speed_max: 4.4,
                acceleration: 0.19,
                friction_coeff: 0.988,
                turn_speed: 3.1,
                directional: true,
                directional_speed_min: 0.48,
                directional_thrust_min: 0.58
            },

            range: {
                detection: 1650,
                combat: 1200,
                backaway: 400,
                forget: 2050,
                wander: 520,
                alert_share: 1450
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_combat_weave,

            facing: {
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.TARGET,
                angle_offset: 0,
                turn_speed_scale: 1,
                spin_speed: 0
            },

            weave: {
                range: 950,
                range_tolerance: 80,
                response_distance: 260,
                lateral_strength: 1,
                radial_strength: 0.85,
                speed: 0.055,
                speed_scale: 0.92
            },

            // The combat callback supplies the Salvo Hawk's complete weave.
            strafe: {
                amount: 0,
                speed: 0
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 620,
            arrival_radius: 105,
            search_duration: 180,
            speed_scale: 0.72
        },

        visual: sc_enemy_rebel_salvohawk_visual_data(),

        collision: {
            radius_forward_scale: 1,
            radius_side_scale: 0.98,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "launcher_upper",
                group: "rocket_launchers",
                forward: 0.29,
                side: -0.36,
                angle: 0,
                muzzle_forward: 0.27,

                authored: {
                    sprite: s_rebel_rocket_turret_regular,
                    scale: 0.045
                },

                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_salvohawk_launcher_draw
            },
            {
                key: "launcher_lower",
                group: "rocket_launchers",
                forward: 0.29,
                side: 0.36,
                angle: 0,
                muzzle_forward: 0.27,

                authored: {
                    sprite: s_rebel_rocket_turret_regular,
                    scale: 0.045
                },

                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_salvohawk_launcher_draw
            }
        ],

        thrusters: [
            {
                key: "thruster_upper",
                forward: -0.25,
                side: -0.32,
                angle: 180,
                scale: 1
            },
            {
                key: "thruster_lower",
                forward: -0.25,
                side: 0.32,
                angle: 180,
                scale: 1
            }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "alternating_rocket_salvo",
                    weight: 100,
                    hardpoint_group: "rocket_launchers",
                    weapon_key: "weapon_rebel_salvohawk_rocket",

                    conditions: {
                        line_of_sight: true,
                        range_min: 400,
                        range_max: 1200
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 2,
                        fire_tolerance: 11
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 9,
                        volley_max: 4,
                        cooldown: 135
                    }
                }
            ]
        }
    });
}

/// @description Returns the authored Salvo Hawk visual definition.
function sc_enemy_rebel_salvohawk_visual_data()
{
    var _authored_enabled = true;

    return {
        radius: 116,
        motion_strength: 2.1,
        palette: sc_faction_palette_get(Faction.REBEL),

        authored: {
            enabled: _authored_enabled,

            body: {
                sprite: s_rebel_salvohawk_hull,
                scale: 0.18,
                fallback_script: sc_enemy_rebel_salvohawk_body_draw
            }
        },

        core: {
            forward: 0,
            side: 0
        },

        draw: {
            body: sc_enemy_body_dispatch,
            core: sc_enemy_rebel_salvohawk_core_draw
        },

        damage_layers: {
            enabled: !_authored_enabled,
            damage_stages: 4,
            hull_draw_script: sc_enemy_rebel_salvohawk_hull_draw,
            armour_draw_script: sc_enemy_rebel_salvohawk_armour_draw
        },

        death: {
            script: sc_enemy_rebel_salvohawk_death,

            draw_scripts: [
                sc_enemy_rebel_salvohawk_fragment_front_draw,
                sc_enemy_rebel_salvohawk_fragment_upper_draw,
                sc_enemy_rebel_salvohawk_fragment_lower_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_rebel_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 512,
            core_canvas_size: 64,
            hardpoint_canvas_size: 192,
            thrust_canvas_size: 128,
            fragment_canvas_size: 256
        }
    };
}

/// @description Draws the complete primitive Salvo Hawk fallback.
function sc_enemy_rebel_salvohawk_body_draw(_x,_y,_radius,_angle,_visual)
{
    sc_enemy_rebel_salvohawk_hull_draw(_x,_y,_radius,_angle,_visual,0);
    sc_enemy_rebel_salvohawk_armour_draw(_x,_y,_radius,_angle,_visual,0);
}

/// @description Draws the Salvo Hawk fallback hull.
function sc_enemy_rebel_salvohawk_hull_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x,_y,_radius,_angle,
        1.05,-0.18,
        -0.92,-0.2,
        -1.05,0.2,
        1.05,0.18,
        _p.void
    );

    sc_visual_triangle(
        _x,_y,_radius,_angle,
        1.08,0,
        0.46,-0.29,
        0.46,0.29,
        _p.hull_mid,
        false
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.46,-0.29,
        -0.42,-0.28,
        -0.82,-0.18,
        0.46,-0.12,
        _p.hull_dark
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.46,0.12,
        -0.82,0.18,
        -0.42,0.28,
        0.46,0.29,
        _p.hull_dark
    );

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.38,0.2*_side,
            0.05,0.93*_side,
            -0.42,0.98*_side,
            -0.18,0.23*_side,
            _p.hull_mid
        );

        sc_visual_triangle(
            _x,_y,_radius,_angle,
            0.05,0.93*_side,
            -0.04,1.08*_side,
            -0.42,0.98*_side,
            _p.hull_dark,
            false
        );
    }

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.3,-0.18,
        -1.06,-0.13,
        -1.06,0.13,
        -0.3,0.18,
        _p.hull_light
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        -0.9,0,
        0.92,0,
        3,
        _p.metal
    );
}

/// @description Draws the Salvo Hawk fallback armour plates.
function sc_enemy_rebel_salvohawk_armour_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p = _visual.palette;

    sc_rebel_visual_patch_plate(
        _x,_y,_radius,_angle,
        0.88,-0.14,
        0.88,0.14,
        0.18,0.2,
        0.18,-0.2,
        _p.paint,_p
    );

    sc_rebel_visual_patch_plate(
        _x,_y,_radius,_angle,
        0.14,-0.2,
        0.14,0.2,
        -0.58,0.18,
        -0.58,-0.18,
        _p.hull_light,_p
    );
}

/// @description Draws one primitive twin-rocket hardpoint fallback.
function sc_enemy_rebel_salvohawk_launcher_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.28,-0.23,
        0.38,-0.23,
        0.38,0.23,
        -0.28,0.23,
        _p.hull_dark
    );

    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_line(
            _x,_y,_radius,_angle,
            -0.05,0.11*_side,
            0.66,0.11*_side,
            5,
            _p.metal
        );

        sc_visual_triangle(
            _x,_y,_radius,_angle,
            0.79,0.11*_side,
            0.6,0.04*_side,
            0.6,0.18*_side,
            _p.energy,
            false
        );
    }

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.18,0,
        0.14,
        _p.metal,
        true
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Keeps the authored Salvo Hawk hull free of an additional core overlay.
function sc_enemy_rebel_salvohawk_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    return;
}

/// @description Creates Salvo Hawk hull and hardpoint fragments.
function sc_enemy_rebel_salvohawk_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _fragments = [];

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[0],
        _x+lengthdir_x(_radius*0.42,_angle),
        _y+lengthdir_y(_radius*0.42,_angle),
        _angle+random_range(-10,10),
        random_range(2.5,3.8),
        _angle,
        choose(-7,7),
        1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[1],
        _x+lengthdir_x(-_radius*0.08,_angle)+lengthdir_x(-_radius*0.58,_angle+90),
        _y+lengthdir_y(-_radius*0.08,_angle)+lengthdir_y(-_radius*0.58,_angle+90),
        _angle-48,
        random_range(3,4.6),
        _angle,
        -9,
        1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[2],
        _x+lengthdir_x(-_radius*0.08,_angle)+lengthdir_x(_radius*0.58,_angle+90),
        _y+lengthdir_y(-_radius*0.08,_angle)+lengthdir_y(_radius*0.58,_angle+90),
        _angle+48,
        random_range(3,4.6),
        _angle,
        9,
        1
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _x
            + lengthdir_x(_hardpoint.forward*_radius,_angle)
            + lengthdir_x(_hardpoint.side*_radius,_angle+90);

        var _hardpoint_y = _y
            + lengthdir_y(_hardpoint.forward*_radius,_angle)
            + lengthdir_y(_hardpoint.side*_radius,_angle+90);

        array_push(_fragments,sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x,
            _hardpoint_y,
            _angle+random_range(-20,20),
            random_range(3.2,5),
            _angle,
            _hardpoint.side<0 ? -12 : 12,
            0.95
        ));
    }

    sc_death_fragment_create(
        _x,
        _y,
        _fragments,
        _visual.palette.core,
        _visual.palette.glow,
        _radius,
        46
    );

    return true;
}

/// @description Draws the broken Salvo Hawk forward fuselage.
function sc_enemy_rebel_salvohawk_fragment_front_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(
        _x,_y,_radius,_angle,
        1.04,0,
        -0.14,-0.28,
        -0.14,0.28,
        _p.hull_mid,
        false
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        0.08,0,
        0.86,0,
        3,
        _p.metal
    );
}

/// @description Draws the broken Salvo Hawk upper wing.
function sc_enemy_rebel_salvohawk_fragment_upper_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.3,-0.16,
        0.02,-0.92,
        -0.42,-1,
        -0.16,-0.22,
        _p.hull_light
    );
}

/// @description Draws the broken Salvo Hawk lower wing.
function sc_enemy_rebel_salvohawk_fragment_lower_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.3,0.16,
        -0.16,0.22,
        -0.42,1,
        0.02,0.92,
        _p.hull_mid
    );
}