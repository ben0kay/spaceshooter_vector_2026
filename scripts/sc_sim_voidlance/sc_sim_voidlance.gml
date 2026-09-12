/*
SIMULANT VOIDLANCE

Slow SUPERHEAVY Simulant siege vessel facing east at draw_angle 0.

HARDPOINTS
super_beam: Fixed forward weapon. The complete ship must rotate to aim it.
core_weapon: Independently timed seeker-core attack.

Both weapons use separate attack channels and may operate simultaneously.
*/

/// @description Registers the SUPERHEAVY Simulant Voidlance.
function sc_enemy_register_sim_voidlance()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_voidlance",
            name: "Simulant Voidlance",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.SUPERHEAVY,
            rank: EnemyRank.ELITE,
            threat_value: 40
        },

        reward: {
            credits: 380
        },

        stats_base: {
            shield_max: 250,
            armour_max: 700,
            hull_max: 275,
            mass: 4,

            handling: {
                speed_max: 1.45,
                acceleration: 0.045,
                friction_coeff: 0.988,
                turn_speed: 0.42,
                directional: true,
                directional_speed_min: 0.22,
                directional_thrust_min: 0.32
            },

            range: {
                detection: 1750,
                combat: 2250,
                backaway: 700,
                forget: 2700,
                wander: 0,
                alert_share: 2200
            },

            damage_multiplier: 1.35,
            fire_rate_multiplier: 0.82
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.BOMBARD,

            idle_script: sc_enemy_movement_hold,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_hold_line_of_sight,

            // The entire vessel slowly turns toward its target.
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
            duration: 720,
            arrival_radius: 150,
            search_duration: 240,
            speed_scale: 0.5
        },

        visual: sc_enemy_sim_voidlance_visual_data(),

        collision: {
            radius_forward_scale: 1.18,
            radius_side_scale: 0.82,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "super_beam",
                group: "super_beam",

                // The muzzle sits at the tip of the long forward lance.
                forward: 1.02,
                side: 0,
                angle: 0,
                muzzle_forward: 0.26,

                // Absolutely no independent hardpoint rotation.
                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_voidlance_beam_emitter_draw
            },

            {
                key: "core_weapon",
                group: "core_weapon",
                forward: -0.34,
                side: 0,
                angle: 0,
                muzzle_forward: 0,

                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: true
                },

                draw_script: sc_enemy_sim_voidlance_core_emitter_draw
            }
        ],

        thrusters: [
            { key: "thruster_outer_left", forward: -0.83, side: -0.53, angle: 180, scale: 1.05 },
            { key: "thruster_inner_left", forward: -0.94, side: -0.2, angle: 180, scale: 1.28 },
            { key: "thruster_inner_right", forward: -0.94, side: 0.2, angle: 180, scale: 1.28 },
            { key: "thruster_outer_right", forward: -0.83, side: 0.53, angle: 180, scale: 1.05 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                {
                    key: "beam",
                    selection: AttackSelection.WEIGHTED
                },
                {
                    key: "core",
                    selection: AttackSelection.WEIGHTED
                }
            ],

            attacks: [
                {
                    key: "voidlance_super_beam",
                    channel: "beam",
                    weight: 100,
                    hardpoint_group: "super_beam",
                    weapon_key: "weapon_simulant_super_beam",

                    conditions: {
                        line_of_sight: true,
                        range_min: 350,
                        range_max: 2250
                    },

                    // MOUNT means the beam always follows the fixed cannon.
                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 4
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 110,

                        // Zero means the hull keeps turning for the entire charge.
                        aim_lock_remaining: 0,

                        // The hull and attached beam keep tracking while firing.
                        track_during_active: true,

                        scale: 0.16,
                        particle_interval: 1,
                        draw_script: sc_enemy_sim_voidlance_beam_telegraph_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        duration: 150,
                        cooldown: 380
                    }
                },

                {
                    key: "voidlance_core_launch",
                    channel: "core",
                    weight: 100,
                    hardpoint_group: "core_weapon",
                    weapon_key: "weapon_simulant_seeker_core",

                    conditions: {
                        line_of_sight: true,
                        range_min: 280,
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

                    // Reuses the Dreadwing's collapsing core telegraph.
                    telegraph: {
                        duration: 72,
                        aim_lock_remaining: 0,
                        track_during_active: true,
                        scale: 0.42,
                        particle_interval: 1,
                        draw_script: sc_enemy_sim_dreadwing_seeker_telegraph_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 310
                    }
                }
            ]
        }
    });
}

/// @description Returns the Voidlance's complete visual definition.
function sc_enemy_sim_voidlance_visual_data()
{
    return {
        radius: 176,
        motion_strength: 1.25,
        rocket_launcher_scale: 0.85,
        palette: sc_faction_palette_get(Faction.SIMULANT),

        core: {
            forward: -0.34,
            side: 0
        },

        draw: {
            body: sc_enemy_sim_voidlance_body_draw,
            core: sc_enemy_sim_voidlance_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_sim_voidlance_hull_draw,
            armour_draw_script: sc_enemy_sim_voidlance_armour_draw
        },

        death: {
            script: sc_enemy_sim_voidlance_death,

            draw_scripts: [
                sc_enemy_sim_voidlance_fragment_centre_draw,
                sc_enemy_sim_voidlance_fragment_left_draw,
                sc_enemy_sim_voidlance_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 640,
            core_canvas_size: 256,
            hardpoint_canvas_size: 256,
            thrust_canvas_size: 192,
            fragment_canvas_size: 384
        }
    };
}

/// @description Draws the complete intact Voidlance fallback body.
function sc_enemy_sim_voidlance_body_draw(_x, _y, _radius, _angle, _visual)
{
    sc_enemy_sim_voidlance_hull_draw(
        _x, _y, _radius, _angle,
        _visual,
        0
    );

    sc_enemy_sim_voidlance_armour_draw(
        _x, _y, _radius, _angle,
        _visual,
        0
    );
}

/// @description Draws the permanent Voidlance hull and extended beam conduit.
function sc_enemy_sim_voidlance_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Compact upper rear hull.
    sc_visual_quad(
        _x, _y, _radius, _angle,
        -1.04, 0,
        -0.79, -0.39,
        -0.13, -0.31,
        0.03, 0,
        _p.hull_dark
    );

    // Compact lower rear hull.
    sc_visual_quad(
        _x, _y, _radius, _angle,
        -1.04, 0,
        0.03, 0,
        -0.13, 0.31,
        -0.79, 0.39,
        _p.hull_dark
    );

    // Raised central mechanical deck.
    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.88, -0.25,
        -0.17, -0.22,
        0.04, 0,
        -0.88, 0,
        _p.hull_mid
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.88, 0,
        0.04, 0,
        -0.17, 0.22,
        -0.88, 0.25,
        _p.hull_mid
    );

    // Dark rear reactor bed.
    sc_visual_circle(
        _x, _y, _radius, _angle,
        -0.34, 0,
        0.31,
        _p.void,
        false
    );

    // Three separated blades on each side.
    // Every blade begins against the hull; only its outer reach changes.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        // Forward blade.
        sc_sim_visual_swept_blade(
            _x, _y, _radius, _angle,
            -0.09,
            0.27 * _side,
            0.22,
            0.19,
            0.08,
            _p.hull_mid,
            _p,
            true
        );

        // Middle blade.
        sc_sim_visual_swept_blade(
            _x, _y, _radius, _angle,
            -0.43,
            0.29 * _side,
            0.25,
            0.26,
            0.1,
            _p.hull_dark,
            _p,
            true
        );

        // Rear blade.
        sc_sim_visual_swept_blade(
            _x, _y, _radius, _angle,
            -0.81,
            0.31 * _side,
            0.29,
            0.34,
            0.12,
            _p.hull_mid,
            _p,
            true
        );
    }

    // Long upper triangular cannon rail.
    sc_sim_visual_blade_panel(
        _x, _y, _radius, _angle,
        -0.24, -0.22,
        0.14, -0.2,
        1.09, -0.045,
        0.73, -0.09,
        _p.hull_dark,
        _p
    );

    // Long lower triangular cannon rail.
    sc_sim_visual_blade_panel(
        _x, _y, _radius, _angle,
        0.73, 0.09,
        1.09, 0.045,
        0.14, 0.2,
        -0.24, 0.22,
        _p.hull_dark,
        _p
    );

    // Inner structural rails surrounding the conduit.
    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.17, -0.15,
        0.2, -0.135,
        0.94, -0.036,
        0.63, -0.07,
        _p.hull_mid
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.63, 0.07,
        0.94, 0.036,
        0.2, 0.135,
        -0.17, 0.15,
        _p.hull_mid
    );

    // Long central energy conduit.
    sc_sim_visual_beam_spine(
        _x, _y, _radius, _angle,
        -0.22,
        1.08,
        0.082,
        _p
    );

    // Mechanical bands segmenting the conduit.
    var _brace_forward = [0.04, 0.31, 0.58, 0.82, 1.01];

    for (var _i = 0; _i < array_length(_brace_forward); _i++)
    {
        var _forward = _brace_forward[_i];
        var _progress = (_forward + 0.22) / 1.3;
        var _half_width = lerp(0.105, 0.038, _progress);

        sc_visual_line(
            _x, _y, _radius, _angle,
            _forward, -_half_width,
            _forward, _half_width,
            5,
            _p.void
        );

        sc_visual_line(
            _x, _y, _radius, _angle,
            _forward, -_half_width * 0.72,
            _forward, _half_width * 0.72,
            1,
            _p.outline
        );
    }

    // Permanent rear reactor housing.
    sc_sim_visual_energy_socket(
        _x, _y, _radius, _angle,
        -0.34, 0,
        0.25,
        _p
    );
}

/// @description Draws the Voidlance's removable layered armour.
function sc_enemy_sim_voidlance_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Rear hull armour surrounding the reactor.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_sim_visual_blade_panel(
            _x, _y, _radius, _angle,
            -0.05, 0.1 * _side,
            -0.24, 0.27 * _side,
            -0.61, 0.3 * _side,
            -0.48, 0.13 * _side,
            _p.hull_mid,
            _p
        );

        if (_stage <= 2)
        {
            sc_sim_visual_blade_panel(
                _x, _y, _radius, _angle,
                -0.22, 0.27 * _side,
                -0.49, 0.38 * _side,
                -0.86, 0.36 * _side,
                -0.65, 0.25 * _side,
                _p.hull_light,
                _p
            );
        }
    }

    // Narrow armour overlays follow the attached permanent blades.
    if (_stage <= 2)
    {
        for (var _side = -1; _side <= 1; _side += 2)
        {
            // Forward blade armour.
            sc_sim_visual_swept_blade(
                _x, _y, _radius, _angle,
                -0.09,
                0.285 * _side,
                0.18,
                0.13,
                0.07,
                _p.hull_light,
                _p,
                false
            );

            // Middle blade armour.
            if (_stage <= 1)
            {
                sc_sim_visual_swept_blade(
                    _x, _y, _radius, _angle,
                    -0.43,
                    0.305 * _side,
                    0.21,
                    0.19,
                    0.085,
                    _p.hull_mid,
                    _p,
                    false
                );
            }

            // Rear blade armour.
            if (_stage == 0)
            {
                sc_sim_visual_swept_blade(
                    _x, _y, _radius, _angle,
                    -0.81,
                    0.325 * _side,
                    0.25,
                    0.26,
                    0.1,
                    _p.hull_light,
                    _p,
                    false
                );
            }
        }
    }

    // Long forward armour strips emphasize the tapered pyramid.
    if (_stage <= 2)
    {
        for (var _side = -1; _side <= 1; _side += 2)
        {
            sc_sim_visual_blade_panel(
                _x, _y, _radius, _angle,
                -0.14, 0.18 * _side,
                0.22, 0.16 * _side,
                0.92, 0.05 * _side,
                0.62, 0.085 * _side,
                _p.hull_light,
                _p
            );

            sc_visual_line(
                _x, _y, _radius, _angle,
                -0.06, 0.145 * _side,
                0.88, 0.045 * _side,
                1,
                _p.core
            );
        }
    }
}

/// @description Draws the Voidlance reactor centred inside its positioned sprite.
function sc_enemy_sim_voidlance_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    // The runtime already positions this sprite at visual.core.forward/side.
    // The reactor therefore remains centred on its local x/y.
    sc_sim_visual_reactor(
        _x, _y, _radius, _angle,
        {
            outer_scale: 0.24,
            middle_scale: 0.16,
            inner_scale: 0.075,

            socket_enabled: true,
            middle_colour: _p.accent,
            middle_filled: false,

            glow_alpha: 0.28,
            glow_scale: 1.55,
            secondary_glow_alpha: 0,
            secondary_glow_scale: 1,

            vane_amount: 8,
            vane_start: 0,
            vane_twist: 12,
            vane_inner_scale: 0.72,
            vane_outer_scale: 0.9,
            vane_width: 4,
            vane_secondary_colour: _p.outline,

            accent_scale: 1.65,
            accent_filled: false,
            core_scale: 0.42,
            additive: false
        },
        _p,
        _alpha
    );
}

/// @description Draws the fixed super-beam muzzle at the nose.
function sc_enemy_sim_voidlance_beam_emitter_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    // Angular focusing claws around the muzzle.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _x, _y, _radius, _angle,
            -0.15, 0.12 * _side,
            0.18, 0.065 * _side,
            0.28, 0.025 * _side,
            _p.hull_light,
            false
        );

        sc_visual_line(
            _x, _y, _radius, _angle,
            -0.11, 0.085 * _side,
            0.25, 0.025 * _side,
            2, _p.energy
        );
    }

    sc_sim_visual_energy_socket(
        _x, _y, _radius, _angle,
        0.26, 0,
        0.07,
        _p,
        _alpha
    );

    draw_set_alpha(1);
}

/// @description Draws the containment hardware around the core weapon.
function sc_enemy_sim_voidlance_core_emitter_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.26;

    draw_set_alpha(_alpha * 0.85);
    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _outer, true);

    for (var _i = 0; _i < 6; _i++)
    {
        var _direction = _angle + _i * 60;

        draw_set_colour(_p.outline);
        draw_line_width(
            _x + lengthdir_x(_outer * 0.76, _direction),
            _y + lengthdir_y(_outer * 0.76, _direction),
            _x + lengthdir_x(_outer * 1.18, _direction + 7),
            _y + lengthdir_y(_outer * 1.18, _direction + 7),
            3
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the broken central Voidlance section.
function sc_enemy_sim_voidlance_fragment_centre_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.46, -0.28,
        0.42, -0.18,
        0.42, 0.18,
        -0.46, 0.28,
        _p.hull_dark
    );

    sc_sim_visual_beam_spine(_x, _y, _radius, _angle, -0.35, 0.4, 0.09, _p);
    sc_sim_visual_energy_socket(_x, _y, _radius, _angle, -0.32, 0, 0.18, _p);
}

/// @description Draws the broken upper/left Voidlance wing.
function sc_enemy_sim_voidlance_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_sim_visual_blade_panel(
        _x, _y, _radius, _angle,
        0.08, -0.16,
        -0.2, -0.7,
        -0.94, -0.94,
        -0.57, -0.27,
        _p.hull_mid, _p
    );

    sc_sim_visual_energy_conduit(_x, _y, _radius, _angle, -0.62, -0.35, -0.16, -0.5, 3, _p);
}

/// @description Draws the broken lower/right Voidlance wing.
function sc_enemy_sim_voidlance_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_sim_visual_blade_panel(
        _x, _y, _radius, _angle,
        0.08, 0.16,
        -0.2, 0.7,
        -0.94, 0.94,
        -0.57, 0.27,
        _p.hull_mid, _p
    );

    sc_sim_visual_energy_conduit(_x, _y, _radius, _angle, -0.62, 0.35, -0.16, 0.5, 3, _p);
}

/// @description Creates the Voidlance destruction fragments.
function sc_enemy_sim_voidlance_death(_enemy)
{
    // The Siegebreaker's death function is data-driven and already supports
    // three body fragments, any number of hardpoints and a detached core.
    return sc_enemy_sim_siegebreaker_death(_enemy);
}