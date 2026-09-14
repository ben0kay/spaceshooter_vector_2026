/*
SIMULANT SKYVOID

Fast Heavy Elite flyby ship built around s_sim_skyvoid_hull.
Faces its target while travelling sideways through repeated attack runs.

Attack channels:
- Six independently rotating rapid-orb cannons.
- Nose beam or core seeker.
*/

/// @description Registers the Skyvoid's faster reusable orb cannon.
function sc_weapon_register_simulant_rapid_orb()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_rapid_orb",
            name: "Simulant Rapid Orb Cannon"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_orb",

            projectile: {
                scale: 0.82,
                speed: 17,
                life: 150
            },

            damage: {
                amount: 7,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0.42,
            pitch_range: 0.09
        }
    });
}

/// @description Registers the Heavy Elite Simulant Skyvoid.
function sc_enemy_register_sim_skyvoid()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_skyvoid",
            name: "Simulant Skyvoid",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.HEAVY,
            rank: EnemyRank.ELITE,
            threat_value: 22
        },

        reward: { credits: 190 },

        stats_base: {
            shield_max: 280,
            armour_max: 720,
            hull_max: 340,
            mass: 2.5,

            handling: {
                speed_max: 6.2,
                acceleration: 0.24,
                friction_coeff: 0.992,
                turn_speed: 2.7,
                directional: true,
                directional_speed_min: 0.45,
                directional_thrust_min: 0.58
            },

            range: {
                detection: 1750,
                combat: 1450,
                backaway: 0,
                forget: 2300,
                wander: 650,
                alert_share: 1900
            },

            damage_multiplier: 1.2,
            fire_rate_multiplier: 1.08
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_sim_skyvoid_flyby,
            combat_script: sc_enemy_sim_skyvoid_flyby,

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
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.TARGET,
                angle_offset: 0,
                turn_speed_scale: 0.82,
                spin_speed: 0
            },

            strafe: { amount: 0, speed: 0 },

            flyby: {
                offset_min: 290,
                offset_max: 520,
                exit_distance: 1050,
                arrival_radius: 120,
                turnaround_delay: 28,
                speed_scale: 1.08,
                alternate_side: true
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 720,
            arrival_radius: 120,
            search_duration: 210,
            speed_scale: 0.82
        },

        visual: sc_enemy_sim_skyvoid_visual_data(),

        collision: {
            radius_forward_scale: 1.02,
            radius_side_scale: 0.68,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "orb_rear_upper", group: "orb_battery",
                forward: -0.308, side: 0.417, angle: 0, muzzle_forward: 0.37,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.2, arc: 210, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_orb_turret_draw
            },
            {
                key: "orb_inner_upper", group: "orb_battery",
                forward: -0.096, side: 0.379, angle: 0, muzzle_forward: 0.37,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.4, arc: 210, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_orb_turret_draw
            },
            {
                key: "orb_front_upper", group: "orb_battery",
                forward: 0.528, side: 0.120, angle: 0, muzzle_forward: 0.37,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.7, arc: 190, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_orb_turret_draw
            },
            {
                key: "orb_front_lower", group: "orb_battery",
                forward: 0.531, side: -0.107, angle: 0, muzzle_forward: 0.37,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.7, arc: 190, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_orb_turret_draw
            },
            {
                key: "orb_inner_lower", group: "orb_battery",
                forward: -0.098, side: -0.355, angle: 0, muzzle_forward: 0.37,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.4, arc: 210, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_orb_turret_draw
            },
            {
                key: "orb_rear_lower", group: "orb_battery",
                forward: -0.310, side: -0.383, angle: 0, muzzle_forward: 0.37,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.2, arc: 210, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_orb_turret_draw
            },
            {
                key: "nose_beam", group: "nose_beam",
                forward: 0.82, side: 0, angle: 0, muzzle_forward: 0.24,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_simulant_thin_beam_emitter_draw
            },
            {
                key: "core_seeker", group: "core_weapon",
                forward: 0, side: 0, angle: 0, muzzle_forward: 0,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_skyvoid_core_emitter_draw
            }
        ],

        thrusters: [
            { key: "thruster_outer_upper", forward: -0.77, side: 0.40, angle: 180, scale: 0.7 },
            { key: "thruster_inner_upper", forward: -0.87, side: 0.26, angle: 180, scale: 1.05 },
            { key: "thruster_centre", forward: -0.87, side: 0, angle: 180, scale: 1.12 },
            { key: "thruster_inner_lower", forward: -0.87, side: -0.26, angle: 180, scale: 1.05 },
            { key: "thruster_outer_lower", forward: -0.77, side: -0.40, angle: 180, scale: 0.7 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                { key: "orb_battery", selection: AttackSelection.WEIGHTED },
                { key: "heavy_systems", selection: AttackSelection.WEIGHTED }
            ],

            attacks: [
                {
                    key: "rapid_orb_barrage",
                    channel: "orb_battery",
                    weight: 100,
                    hardpoint_group: "orb_battery",
                    weapon_key: "weapon_simulant_rapid_orb",

                    conditions: {
                        line_of_sight: true,
                        range_min: 140,
                        range_max: 1250
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 4,
                        fire_tolerance: 18
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.RANDOM,
                        interval: 4,
                        volley_max: 18,
                        cooldown: 95
                    }
                },
                {
                    key: "skyvoid_nose_beam",
                    channel: "heavy_systems",
                    weight: 65,
                    hardpoint_group: "nose_beam",
                    weapon_key: "weapon_simulant_thin_beam",

                    conditions: {
                        line_of_sight: true,
                        range_min: 260,
                        range_max: 1200
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 22
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 32,
                        aim_lock_remaining: 9,
                        track_during_active: true,
                        scale: 0.18,
                        particle_interval: 1,
                        draw_script: sc_attack_telegraph_energy_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        duration: 64,
                        cooldown: 190
                    }
                },
                {
                    key: "skyvoid_core_seeker",
                    channel: "heavy_systems",
                    weight: 35,
                    hardpoint_group: "core_weapon",
                    weapon_key: "weapon_simulant_seeker_core",

                    conditions: {
                        line_of_sight: true,
                        range_min: 260,
                        range_max: 1650
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 360
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 52,
                        aim_lock_remaining: 0,
                        track_during_active: true,
                        scale: 0.32,
                        particle_interval: 1,
                        draw_script: sc_enemy_sim_dreadwing_seeker_telegraph_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 24,
                        volley_max: 2,
                        cooldown: 275
                    }
                }
            ]
        }
    });
}

/// @description Performs a flyby while keeping the Skyvoid facing its target.
function sc_enemy_sim_skyvoid_flyby(_enemy)
{
    sc_enemy_movement_flyby(_enemy);

    var _data = _enemy.enemy;
    if (!_data.movement.command.active || !instance_exists(_data.target_id)) return;

    _data.movement.command.facing_mode = EnemyFacingMode.TARGET;
    _data.movement.command.face_direction = point_direction(
        _enemy.x, _enemy.y,
        _data.target_id.x, _data.target_id.y
    );
}

/// @description Returns the enlarged Skyvoid authored visual definition.
function sc_enemy_sim_skyvoid_visual_data()
{
    var _authored_enabled = true;

    return {
        radius: 153.4,
        motion_strength: 2.6,
        palette: sc_faction_palette_get(Faction.SIMULANT),

        authored: {
            enabled: _authored_enabled,

            body: {
                sprite: s_sim_skyvoid_hull,
                scale: 0.221,
                fallback_script: sc_enemy_sim_skyvoid_body_fallback_draw
            }
        },

        core: {
            forward: 0,
            side: 0
        },

        draw: {
            body: sc_enemy_body_dispatch,
            core: sc_enemy_sim_skyvoid_core_draw
        },

        damage_layers: {
            enabled: false,
            damage_stages: 4,
            hull_draw_script: sc_enemy_sim_skyvoid_body_fallback_draw,
            armour_draw_script: sc_enemy_sim_skyvoid_body_fallback_draw
        },

        death: {
            script: sc_enemy_sim_skyvoid_death,
            draw_scripts: [
                sc_enemy_sim_skyvoid_fragment_draw,
                sc_enemy_sim_skyvoid_fragment_draw,
                sc_enemy_sim_skyvoid_fragment_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 384,
            core_canvas_size: 192,
            hardpoint_canvas_size: 192,
            thrust_canvas_size: 192,
            fragment_canvas_size: 256
        }
    };
}

/// @description Draws one heavy rotating Skyvoid rapid-orb cannon.
function sc_enemy_sim_skyvoid_orb_turret_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p = _visual.palette;
    draw_set_alpha(_alpha);

    // Broad rotating socket seated inside the hull mount.
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.078,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.078,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.054,_p.hull_dark,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.028,_p.accent,false);

    // Thick armoured cannon housing.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.025,-0.064,
        0.25,-0.052,
        0.31,-0.037,
        -0.025,0.064,
        _p.hull_light
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.025,0.064,
        0.31,0.037,
        0.25,0.052,
        -0.025,-0.064,
        _p.hull_mid
    );

    // Large recessed orb-energy chamber.
    sc_visual_line(_x,_y,_radius,_angle,0.015,0,0.34,0,13,_p.void);
    sc_visual_line(_x,_y,_radius,_angle,0.045,0,0.32,0,6,_p.accent);
    sc_visual_line(_x,_y,_radius,_angle,0.08,0,0.34,0,2,_p.core);

    // Reinforced barrel collars.
    sc_visual_line(_x,_y,_radius,_angle,0.11,-0.065,0.11,0.065,3,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle,0.23,-0.054,0.23,0.054,3,_p.accent);

    // Heavy muzzle containing the orb before release.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.27,-0.07,
        0.37,-0.058,
        0.37,0.058,
        0.27,0.07,
        _p.hull_dark
    );

    sc_visual_circle(_x,_y,_radius,_angle,0.37,0,0.064,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.37,0,0.064,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0.37,0,0.043,_p.accent,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.37,0,0.024,_p.energy,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.37,0,0.01,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the containment hardware over the core seeker.
function sc_enemy_sim_skyvoid_core_emitter_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.19;

    draw_set_alpha(_alpha * 0.72);
    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_outer,true);

    for (var _i = 0; _i < 6; ++_i)
    {
        var _direction = _angle + _i * 60;

        draw_set_colour(_p.outline);
        draw_line_width(
            _x + lengthdir_x(_outer * 0.78,_direction),
            _y + lengthdir_y(_outer * 0.78,_direction),
            _x + lengthdir_x(_outer * 1.08,_direction + 8),
            _y + lengthdir_y(_outer * 1.08,_direction + 8),
            2
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the rotating reactor over the Skyvoid's central housing.
function sc_enemy_sim_skyvoid_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p = _visual.palette;

    sc_sim_visual_reactor(
        _x,_y,_radius,_angle,
        {
            outer_scale: 0.18,
            middle_scale: 0.125,
            inner_scale: 0.058,

            socket_enabled: false,
            middle_colour: _p.accent,
            middle_filled: false,

            glow_alpha: 0.22,
            glow_scale: 1.45,
            secondary_glow_alpha: 0.05,
            secondary_glow_scale: 1.16,

            vane_amount: 6,
            vane_start: 0,
            vane_twist: 18,
            vane_inner_scale: 0.72,
            vane_outer_scale: 0.9,
            vane_width: 3,
            vane_secondary_colour: _p.outline,

            accent_scale: 1.5,
            accent_filled: false,
            core_scale: 0.42,
            additive: false
        },
        _p,
        _alpha
    );
}

/// @description Draws a simple fallback Skyvoid hull.
function sc_enemy_sim_skyvoid_body_fallback_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -1,-0.42,
        0.95,-0.18,
        0.95,0.18,
        -1,0.42,
        _p.hull_dark
    );

    sc_visual_triangle(
        _x,_y,_radius,_angle,
        -0.45,-0.42,
        1,-0.18,
        0.26,-0.04,
        _p.hull_mid,
        false
    );

    sc_visual_triangle(
        _x,_y,_radius,_angle,
        0.26,0.04,
        1,0.18,
        -0.45,0.42,
        _p.hull_mid,
        false
    );

    sc_sim_visual_energy_socket(_x,_y,_radius,_angle,0,0,0.2,_p);
}

/// @description Draws one Skyvoid destruction fragment.
function sc_enemy_sim_skyvoid_fragment_draw(_x,_y,_radius,_angle,_visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(
        _x,_y,_radius,_angle,
        -0.42,-0.24,
        0.5,0,
        -0.42,0.24,
        _p.hull_dark,
        false
    );

    sc_visual_line(_x,_y,_radius,_angle,-0.25,0,0.34,0,2,_p.energy);
}

/// @description Creates the Skyvoid's destruction fragments.
function sc_enemy_sim_skyvoid_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _fragments = [];

    sc_particles_simulant_enemy_death(_enemy.x,_enemy.y,_radius);

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[0],
        _enemy.x + lengthdir_x(_radius * 0.36,_angle),
        _enemy.y + lengthdir_y(_radius * 0.36,_angle),
        _angle + random_range(-14,14),
        random_range(2.5,3.6),
        _angle,choose(-8,8),1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[1],
        _enemy.x + lengthdir_x(-_radius * 0.2,_angle) + lengthdir_x(_radius * 0.38,_angle + 90),
        _enemy.y + lengthdir_y(-_radius * 0.2,_angle) + lengthdir_y(_radius * 0.38,_angle + 90),
        _angle - 65 + random_range(-12,12),
        random_range(2.8,4),
        _angle,random_range(-11,-6),1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[2],
        _enemy.x + lengthdir_x(-_radius * 0.2,_angle) + lengthdir_x(-_radius * 0.38,_angle + 90),
        _enemy.y + lengthdir_y(-_radius * 0.2,_angle) + lengthdir_y(-_radius * 0.38,_angle + 90),
        _angle + 65 + random_range(-12,12),
        random_range(2.8,4),
        _angle,random_range(6,11),1
    ));

    array_push(_fragments,sc_death_fragment_data(
        _cache.core,
        _enemy.x,_enemy.y,
        irandom(359),
        random_range(1.5,2.5),
        _angle,choose(-12,12),0.95
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _enemy.x
            + lengthdir_x(_hardpoint.forward * _radius,_angle)
            + lengthdir_x(_hardpoint.side * _radius,_angle + 90);

        var _hardpoint_y = _enemy.y
            + lengthdir_y(_hardpoint.forward * _radius,_angle)
            + lengthdir_y(_hardpoint.side * _radius,_angle + 90);

        array_push(_fragments,sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x,_hardpoint_y,
            _angle + random_range(-22,22),
            random_range(3,4.6),
            _angle,choose(-12,12),0.95
        ));
    }

    for (var _i = 0; _i < array_length(_fragments); ++_i)
    {
        _fragments[_i].velocity_x += _data.movement.velocity_x * 0.35;
        _fragments[_i].velocity_y += _data.movement.velocity_y * 0.35;
    }

    sc_death_fragment_create(
        _enemy.x,_enemy.y,
        _fragments,
        _visual.palette.core,
        _visual.palette.glow,
        _radius,
        48
    );

    return true;
}