/*
SIMULANT HARROWER

Extremely wide elite Simulant heavy assault ship.

WEAPONS
- 2 upper rapid-fire Shard Cannons.
- 2 lower rapid-fire Shard Cannons.
- 1 central fixed Simulant beam.

Unlike the Dreadwing, the Harrower is built around a huge lateral
armoured frame with weapon mounts spread across the front edge.
*/

/// @description Registers the Simulant Harrower.
function sc_enemy_register_sim_harrower()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_harrower",
            name: "Simulant Harrower",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.HEAVY,
            rank: EnemyRank.ELITE,
            threat_value: 20
        },

        reward: {
            credits: 165
        },

        stats_base: {
            shield_max: 190,
            armour_max: 720,
            hull_max: 330,
            mass: 2.5,

            handling: {
                speed_max: 3.35,
                acceleration: 0.14,
                friction_coeff: 0.991,
                turn_speed: 1.15,
                directional: true,
                directional_speed_min: 0.35,
                directional_thrust_min: 0.42
            },

            range: {
                detection: 1500,
                combat: 1140,
                backaway: 400,
                forget: 1720,
                wander: 0,
                alert_share: 1700
            },

            damage_multiplier: 1.15,
            fire_rate_multiplier: 0.9
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
                turn_speed_scale: 0.72,
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
            duration: 620,
            arrival_radius: 100,
            search_duration: 180,
            speed_scale: 0.68
        },

        visual: sc_enemy_sim_harrower_visual_data(),

        collision: {
            radius_forward_scale: 0.96,
            radius_side_scale: 1.82,
            blocks_player: true
        },

        hardpoints: [
            // ==================================================
            // UPPER OUTER SHARD MINIGUN
            // ==================================================
            {
                key: "shard_upper_outer",
                group: "shard_miniguns",
                forward: 0.43,
                side: 1.52,
                angle: 0,
                muzzle_forward: 0.28,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 3.2,
                    arc: 60,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_harrower_shard_emitter_draw
            },

            // ==================================================
            // UPPER INNER SHARD MINIGUN
            // ==================================================
            {
                key: "shard_upper_inner",
                group: "shard_miniguns",
                forward: 0.62,
                side: 0.76,
                angle: 0,
                muzzle_forward: 0.28,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 3.2,
                    arc: 60,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_harrower_shard_emitter_draw
            },

            // ==================================================
            // CENTRAL BEAM
            // ==================================================
            {
                key: "beam_centre",
                group: "beam",
                forward: 0.84,
                side: 0,
                angle: 0,
                muzzle_forward: 0.24,

                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: true
                },

                draw_script: sc_enemy_simulant_thin_beam_emitter_draw
            },

            // ==================================================
            // LOWER INNER SHARD MINIGUN
            // ==================================================
            {
                key: "shard_lower_inner",
                group: "shard_miniguns",
                forward: 0.62,
                side: -0.76,
                angle: 0,
                muzzle_forward: 0.28,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 3.2,
                    arc: 60,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_harrower_shard_emitter_draw
            },

            // ==================================================
            // LOWER OUTER SHARD MINIGUN
            // ==================================================
            {
                key: "shard_lower_outer",
                group: "shard_miniguns",
                forward: 0.43,
                side: -1.52,
                angle: 0,
                muzzle_forward: 0.28,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 3.2,
                    arc: 60,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_harrower_shard_emitter_draw
            }
        ],

        thrusters: [
            { key: "thruster_upper_outer", forward: -0.48, side: 1.48, angle: 180, scale: 0.68 },
            { key: "thruster_upper_inner", forward: -0.68, side: 0.58, angle: 180, scale: 0.92 },
            { key: "thruster_lower_inner", forward: -0.68, side: -0.58, angle: 180, scale: 0.92 },
            { key: "thruster_lower_outer", forward: -0.48, side: -1.48, angle: 180, scale: 0.68 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                {
                    key: "shards",
                    selection: AttackSelection.WEIGHTED
                },
                {
                    key: "beam",
                    selection: AttackSelection.WEIGHTED
                }
            ],

            attacks: [
                {
                    key: "shard_minigun_stream",
                    channel: "shards",
                    weight: 100,
                    hardpoint_group: "shard_miniguns",
                    weapon_key: "weapon_simulant_shard",

                    conditions: {
                        line_of_sight: true,
                        range_min: 100,
                        range_max: 1080
                    },

                    aim: {
                        mode: AimMode.TARGET_LEAD,
                        prediction_strength: 0.65,
                        angle_offset: 0,
                        inaccuracy: 2.5,
                        fire_tolerance: 10
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.RANDOM,
                        interval: 2,
                        volley_max: 30,
                        cooldown: 95
                    }
                },

                {
                    key: "centre_beam",
                    channel: "beam",
                    weight: 100,
                    hardpoint_group: "beam",
                    weapon_key: "weapon_simulant_thin_beam",

                    conditions: {
                        line_of_sight: true,
                        range_min: 260,
                        range_max: 1140
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 18
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 38,
                        aim_lock_remaining: 10,
                        track_during_active: true,
                        scale: 0.2,
                        particle_interval: 1,
                        draw_script: sc_attack_telegraph_energy_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        duration: 72,
                        cooldown: 210
                    }
                }
            ]
        }
    });
}

/// @description Returns the Harrower's extra-wide visual definition.
function sc_enemy_sim_harrower_visual_data()
{
    return {
        radius: 112,
        motion_strength: 1.8,
        palette: sc_faction_palette_get(Faction.SIMULANT),

        core: {
            forward: -0.12,
            side: 0
        },

        draw: {
            body: sc_enemy_sim_harrower_body_draw,
            core: sc_enemy_sim_harrower_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_sim_harrower_hull_draw,
            armour_draw_script: sc_enemy_sim_harrower_armour_draw
        },

        death: {
            script: sc_enemy_sim_harrower_death,

            draw_scripts: [
                sc_enemy_sim_harrower_fragment_centre_draw,
                sc_enemy_sim_harrower_fragment_wing_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 640,
            core_canvas_size: 192,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 384
        }
    };
}

/// @description Draws the complete intact Harrower.
function sc_enemy_sim_harrower_body_draw(_x,_y,_radius,_angle,_visual)
{
    sc_enemy_sim_harrower_hull_draw(_x,_y,_radius,_angle,_visual,0);
    sc_enemy_sim_harrower_armour_draw(_x,_y,_radius,_angle,_visual,0);
}

/// @description Draws the permanent Harrower hull.
function sc_enemy_sim_harrower_hull_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p=_visual.palette;

    // ==================================================
    // CENTRAL BODY
    // Short and dense instead of crescent-shaped.
    // ==================================================
    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.92,-0.28,
        0.92,0.28,
        -0.68,0.48,
        -0.78,-0.48,
        _p.hull_dark
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.72,-0.2,
        0.74,0.2,
        -0.56,0.34,
        -0.64,-0.34,
        _p.hull_mid
    );

    // Heavy pointed nose around centre beam.
    sc_visual_triangle(
        _x,_y,_radius,_angle,
        1.1,0,
        0.42,0.3,
        0.42,-0.3,
        _p.hull_dark,
        false
    );

    // ==================================================
    // MASSIVE UPPER + LOWER LATERAL FRAME
    // ==================================================
    for (var _side=-1;_side<=1;_side+=2)
    {
        // Inner wing root.
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.55,0.24*_side,
            0.53,0.92*_side,
            -0.08,1.28*_side,
            -0.48,0.48*_side,
            _p.hull_dark
        );

        // Huge outer wing platform.
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.48,0.78*_side,
            0.4,1.62*_side,
            -0.18,1.96*_side,
            -0.55,1.02*_side,
            _p.hull_dark
        );

        // Internal wing bed.
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.4,0.82*_side,
            0.32,1.48*_side,
            -0.14,1.7*_side,
            -0.42,1.04*_side,
            _p.hull_mid
        );

        // Forward outer nose blade.
        sc_sim_visual_swept_blade(
            _x,_y,_radius,_angle,
            0.35,1.47*_side,
            0.62,
            0.15,
            0.18,
            _p.hull_light,
            _p,
            true
        );

        // Long outer claw.
        sc_sim_visual_swept_blade(
            _x,_y,_radius,_angle,
            -0.08,1.78*_side,
            0.7,
            0.16,
            0.19,
            _p.hull_dark,
            _p,
            true
        );

        // Rear stabiliser blade.
        sc_sim_visual_swept_blade(
            _x,_y,_radius,_angle,
            -0.46,1.45*_side,
            0.46,
            0.14,
            0.16,
            _p.hull_mid,
            _p,
            true
        );

        // Inner forward weapon support.
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.48,0.54*_side,
            0.71,0.65*_side,
            0.63,0.85*_side,
            0.34,0.73*_side,
            _p.metal
        );

        // Outer weapon support platform.
        sc_visual_quad(
            _x,_y,_radius,_angle,
            0.24,1.35*_side,
            0.53,1.43*_side,
            0.47,1.64*_side,
            0.14,1.58*_side,
            _p.metal
        );

        // Bright energy path from core to outer weapon assembly.
        sc_sim_visual_energy_conduit(
            _x,_y,_radius,_angle,
            -0.08,0.26*_side,
            0.42,1.48*_side,
            3,
            _p
        );

        // Secondary rear conduit.
        sc_sim_visual_energy_conduit(
            _x,_y,_radius,_angle,
            -0.35,0.52*_side,
            -0.34,1.45*_side,
            2,
            _p
        );

        // Outer energy node.
        sc_sim_visual_energy_socket(
            _x,_y,_radius,_angle,
            -0.02,1.64*_side,
            0.085,
            _p
        );

        // Mechanical support ribs.
        sc_visual_line(
            _x,_y,_radius,_angle,
            0.28,0.46*_side,
            -0.28,1.48*_side,
            8,
            _p.void
        );

        sc_visual_line(
            _x,_y,_radius,_angle,
            0.28,0.46*_side,
            -0.28,1.48*_side,
            2,
            _p.metal
        );

        sc_visual_line(
            _x,_y,_radius,_angle,
            -0.28,0.72*_side,
            -0.52,1.28*_side,
            6,
            _p.void
        );

        sc_visual_line(
            _x,_y,_radius,_angle,
            -0.28,0.72*_side,
            -0.52,1.28*_side,
            2,
            _p.outline
        );
    }

    // ==================================================
    // CENTRAL REACTOR HOUSING
    // ==================================================
    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.12,0,
        0.27,
        _p.void,
        false
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.12,0,
        0.22,
        _p.hull_mid,
        true
    );

    // Main central energy spine.
    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        -0.58,0,
        0.72,0,
        4,
        _p
    );

    if (_stage>=1)
    {
        sc_visual_line(
            _x,_y,_radius,_angle,
            0.02,0.72,
            -0.18,1.08,
            3,_p.void
        );
    }

    if (_stage>=2)
    {
        sc_visual_circle(
            _x,_y,_radius,_angle,
            -0.22,-1.18,
            0.13,
            _p.void,
            false
        );
    }

    if (_stage>=3)
    {
        sc_visual_circle(
            _x,_y,_radius,_angle,
            -0.36,0.82,
            0.15,
            _p.void,
            false
        );
    }
}

/// @description Draws the Harrower's layered armour.
function sc_enemy_sim_harrower_armour_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p=_visual.palette;

    // Central armour wedge.
    if (_stage<=2)
    {
        sc_sim_visual_blade_panel(
            _x,_y,_radius,_angle,
            0.3,-0.26,
            0.9,-0.22,
            1.04,-0.08,
            0.34,-0.1,
            _p.hull_light,_p
        );

        sc_sim_visual_blade_panel(
            _x,_y,_radius,_angle,
            0.34,0.1,
            1.04,0.08,
            0.9,0.22,
            0.3,0.26,
            _p.hull_light,_p
        );
    }

    for (var _side=-1;_side<=1;_side+=2)
    {
        // Inner weapon-arm armour.
        if (_stage<=2)
        {
            sc_sim_visual_blade_panel(
                _x,_y,_radius,_angle,
                0.28,0.38*_side,
                0.5,0.78*_side,
                0.31,1.12*_side,
                -0.04,0.75*_side,
                _p.hull_light,_p
            );
        }

        // Outer broad armour slab.
        if (_stage<=1)
        {
            sc_sim_visual_blade_panel(
                _x,_y,_radius,_angle,
                0.2,1.08*_side,
                0.34,1.55*_side,
                -0.13,1.82*_side,
                -0.34,1.25*_side,
                _p.metal,_p
            );
        }

        // Extreme outer blade cap.
        if (_stage==0)
        {
            sc_sim_visual_blade_panel(
                _x,_y,_radius,_angle,
                0.05,1.5*_side,
                0.17,1.88*_side,
                -0.22,2.02*_side,
                -0.31,1.58*_side,
                _p.hull_light,_p
            );
        }
    }
}

/// @description Draws the Harrower's exposed central reactor.
function sc_enemy_sim_harrower_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    sc_sim_visual_reactor(
        _x,_y,_radius,_angle,
        {
            outer_scale: 0.18,
            middle_scale: 0.135,
            inner_scale: 0.068,

            socket_enabled: true,

            middle_colour: _p.hull_light,
            middle_filled: false,

            glow_alpha: 0.32,
            glow_scale: 1.75,

            secondary_glow_alpha: 0.12,
            secondary_glow_scale: 1.3,

            vane_amount: 6,
            vane_start: 0,
            vane_twist: 18,
            vane_inner_scale: 1,
            vane_outer_scale: 0.88,
            vane_width: 4,
            vane_secondary_colour: _p.accent,

            accent_scale: 1.55,
            accent_filled: false,

            core_scale: 0.45,
            additive: true
        },
        _p,
        _alpha
    );
}

/// @description Draws one Harrower shard minigun hardpoint.
function sc_enemy_sim_harrower_shard_emitter_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.05,0,
        0.115,
        _p.void,
        false
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.05,0,
        0.09,
        _p.metal,
        true
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.04,-0.058,
        0.24,-0.043,
        0.24,0.043,
        -0.04,0.058,
        _p.hull_mid
    );

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.01,0,
        0.23,0,
        2,
        _p,
        _alpha
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        0.28,0,
        0.048,
        _p.energy,
        false
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        0.28,0,
        0.02,
        _p.core,
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Harrower's death effect.
function sc_enemy_sim_harrower_death(_enemy)
{
    var _data=_enemy.enemy;

    sc_particles_simulant_enemy_death(
        _enemy.x,
        _enemy.y,
        _data.visual.radius
    );

    return true;
}

/// @description Draws the Harrower's centre death fragment.
function sc_enemy_sim_harrower_fragment_centre_draw(_x,_y,_radius,_angle,_visual)
{
    var _p=_visual.palette;

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.58,-0.32,
        0.58,0.32,
        -0.6,0.42,
        -0.66,-0.42,
        _p.hull_dark
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.12,0,
        0.18,
        _p.accent,
        true
    );

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        -0.45,0,
        0.46,0,
        3,
        _p
    );
}

/// @description Draws one detached Harrower wing fragment.
function sc_enemy_sim_harrower_fragment_wing_draw(_x,_y,_radius,_angle,_visual)
{
    var _p=_visual.palette;

    sc_sim_visual_blade_panel(
        _x,_y,_radius,_angle,
        0.32,-0.24,
        0.12,-0.96,
        -0.34,-1.42,
        -0.5,-0.46,
        _p.hull_dark,
        _p
    );

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.1,-0.38,
        -0.3,-1.06,
        3,
        _p
    );
}