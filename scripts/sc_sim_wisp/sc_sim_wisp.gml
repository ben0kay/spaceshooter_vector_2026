/*
SIMULANT WISP

Tiny autonomous Simulant combat drone that inhabits dense asteroid regions.

CURRENT DEBUG BEHAVIOUR

The F1 debug spawner bypasses future sector spawn conditions. A debug-spawned
Wisp therefore searches for and binds itself to the nearest surviving asteroid
zone with navigation density at or above 0.8.

FUTURE SECTOR SPAWN RULE

Wisps should only enter the eligible sector enemy pool after asteroid generation
has confirmed that at least one dense asteroid field or dense subregion exists.
The sector spawner should eventually place and pre-bind them directly inside the
selected zone rather than relying on their runtime search.

TERRITORY FAILURE

If its assigned region is depleted, the Wisp searches for another dense region.
Without another region, it anchors to the largest nearby friendly HEAVY-or-larger
ship. Without any valid shelter, it flees the sector.
*/

/// @description Registers the Wisp's small low-damage pulse weapon.
function sc_weapon_register_simulant_wisp_pulse()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_simulant_wisp_pulse",
            name: "Wisp Pulse Emitter"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_pulse",

            projectile: {
                scale: 0.55,
                speed: 15,
                life: 110
            },

            damage: {
                amount: 1,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: 0
        },

        audio: {
            sound: noone,
            volume: 0.16,
            pitch_range: 0.14
        }
    });
}

/// @description Registers the tiny territory-bound Simulant Wisp.
function sc_enemy_register_sim_wisp()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_wisp",
            name: "Simulant Wisp",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.TINY,
            rank: EnemyRank.COMMON,
            threat_value: 1
        },

        reward: {
            credits: 2
        },

        stats_base: {
            shield_max: 8,
            armour_max: 6,
            hull_max: 8,
            mass: 0.18,

            handling: {
                speed_max: 5.8,
                acceleration: 0.34,
                friction_coeff: 0.975,
                turn_speed: 0,
                directional: false,
                directional_speed_min: 1,
                directional_thrust_min: 1
            },

            range: {
                detection: 760,
                combat: 500,
                backaway: 0,
                forget: 920,
                wander: 420,
                alert_share: 900
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_pursue,

            facing: {
                default_mode: EnemyFacingMode.SPIN,
                backaway_mode: EnemyFacingMode.SPIN,
                angle_offset: 0,
                turn_speed_scale: 1,
                spin_speed: 5
            },

            strafe: {
                amount: 0.16,
                speed: 0.055
            }
        },

        /*
        This is the first enemy using territory. Existing enemies omit this
        controller and therefore perform no territory searches or checks.
        */
        territory_controller: {
            type: EnemyTerritoryType.ASTEROID_REGION,

            // Dense generation uses 0.85; standard uses 0.55.
            required_density_min: 0.8,

            // The Wisp may briefly pursue outside its region before returning.
            boundary_padding: 140,
            return_padding: 35,

            check_interval: 15,
            search_interval: 90,
            return_speed_scale: 0.85,

            fallback: {
                ally_anchor_enabled: true,
                ally_class_minimum: EnemyClass.HEAVY,
                ally_search_range: 5000,
                ally_orbit_radius: 260,
                ally_orbit_speed_scale: 0.55,
                flee_when_unavailable: true
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 420,
            arrival_radius: 50,
            search_duration: 120,
            speed_scale: 0.75
        },

        visual: sc_enemy_sim_wisp_visual_data(),

        collision: {
            radius_forward_scale: 0.82,
            radius_side_scale: 0.82,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "pulse_centre",
                group: "pulse",
                forward: 0,
                side: 0,
                angle: 0,
                muzzle_forward: 0.9,

                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: false
                },

                draw_script:
                    sc_enemy_sim_wisp_emitter_draw
            }
        ],

        // The Wisp floats through tight spaces without conventional engines.
        thrusters: [],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "rotating_pulse",
                    weight: 100,
                    hardpoint_group: "pulse",
                    weapon_key: "weapon_simulant_wisp_pulse",

                    conditions: {
                        line_of_sight: true,
                        range_min: 0,
                        range_max: 520
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 5,
                        fire_tolerance: 12
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 55
                    }
                }
            ]
        }
    });
}

/// @description Returns the Wisp's compact rotating visual definition.
function sc_enemy_sim_wisp_visual_data()
{
    return {
        radius: 17,
        motion_strength: 1.4,
        palette: sc_faction_palette_get(Faction.SIMULANT),
        core: { forward: 0, side: 0 },

        draw: {
            body: sc_enemy_sim_wisp_body_draw,
            core: sc_enemy_sim_wisp_core_draw
        },

        death: {
            script: sc_enemy_sim_wisp_death,
            draw_scripts: []
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 96,
            core_canvas_size: 64,
            hardpoint_canvas_size: 64,
            thrust_canvas_size: 64,
            fragment_canvas_size: 64
        }
    };
}

/// @description Draws the Wisp's rotating mechanical drone body.
function sc_enemy_sim_wisp_body_draw(
    _x,
    _y,
    _radius,
    _angle,
    _visual
)
{
    var _p = _visual.palette;

    // Six narrow sensor blades create a rotating mechanical silhouette.
    for (var _i = 0; _i < 6; _i++)
    {
        var _blade_angle =
            _angle + _i * 60;

        var _tip_x = _x
            + lengthdir_x(
                _radius * 1.08,
                _blade_angle
            );

        var _tip_y = _y
            + lengthdir_y(
                _radius * 1.08,
                _blade_angle
            );

        var _left_x = _x
            + lengthdir_x(
                _radius * 0.43,
                _blade_angle - 24
            );

        var _left_y = _y
            + lengthdir_y(
                _radius * 0.43,
                _blade_angle - 24
            );

        var _right_x = _x
            + lengthdir_x(
                _radius * 0.43,
                _blade_angle + 24
            );

        var _right_y = _y
            + lengthdir_y(
                _radius * 0.43,
                _blade_angle + 24
            );

        draw_set_colour(_p.hull_dark);

        draw_triangle(
            _tip_x,
            _tip_y,
            _left_x,
            _left_y,
            _right_x,
            _right_y,
            false
        );

        draw_set_colour(_p.hull_light);
        draw_set_alpha(0.8);

        draw_line(
            _tip_x,
            _tip_y,
            _left_x,
            _left_y
        );

        draw_set_colour(_p.accent);
        draw_set_alpha(0.65);

        draw_line_width(
            _x
                + lengthdir_x(
                    _radius * 0.48,
                    _blade_angle
                ),
            _y
                + lengthdir_y(
                    _radius * 0.48,
                    _blade_angle
                ),
            _tip_x,
            _tip_y,
            1
        );
    }

    draw_set_alpha(1);

    // Dark circular chassis.
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _radius * 0.67, false);

    draw_set_colour(_p.hull_dark);
    draw_circle(_x, _y, _radius * 0.58, false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x, _y, _radius * 0.58, true);

    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _radius * 0.42, true);

    // Repeating sentient sensor nodes around the centre.
    for (var _i = 0; _i < 3; _i++)
    {
        var _node_angle =
            _angle + 30 + _i * 120;

        var _node_x = _x
            + lengthdir_x(
                _radius * 0.45,
                _node_angle
            );

        var _node_y = _y
            + lengthdir_y(
                _radius * 0.45,
                _node_angle
            );

        draw_set_colour(_p.glow);
        draw_circle(
            _node_x,
            _node_y,
            max(1, _radius * 0.095),
            false
        );

        draw_set_colour(_p.energy);
        draw_circle(
            _node_x,
            _node_y,
            max(1, _radius * 0.045),
            false
        );
    }

    draw_set_colour(c_white);
    draw_set_alpha(1);
}

/// @description Draws the Wisp's fixed central directional emitter.
function sc_enemy_sim_wisp_emitter_draw(
    _x,
    _y,
    _radius,
    _angle,
    _visual,
    _alpha
)
{
    var _p = _visual.palette;
    var _muzzle_x =
        _x + lengthdir_x(
            _radius * 0.88,
            _angle
        );

    var _muzzle_y =
        _y + lengthdir_y(
            _radius * 0.88,
            _angle
        );

    draw_set_alpha(_alpha);

    draw_set_colour(_p.void);
    draw_line_width(
        _x,
        _y,
        _muzzle_x,
        _muzzle_y,
        max(2, _radius * 0.25)
    );

    draw_set_colour(_p.accent);
    draw_line_width(
        _x + lengthdir_x(_radius * 0.34, _angle),
        _y + lengthdir_y(_radius * 0.34, _angle),
        _muzzle_x,
        _muzzle_y,
        max(1, _radius * 0.1)
    );

    draw_set_colour(_p.core);
    draw_circle(
        _muzzle_x,
        _muzzle_y,
        max(1, _radius * 0.09),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the Wisp's sentient central eye.
function sc_enemy_sim_wisp_core_draw(
    _x,
    _y,
    _radius,
    _angle,
    _visual,
    _alpha
)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha * 0.2);
    draw_set_colour(_p.glow);
    draw_circle(
        _x,
        _y,
        _radius * 0.48,
        false
    );

    draw_set_alpha(_alpha * 0.72);
    draw_set_colour(_p.energy);
    draw_circle(
        _x,
        _y,
        _radius * 0.26,
        false
    );

    draw_set_alpha(_alpha);
    draw_set_colour(_p.core);
    draw_circle(
        _x,
        _y,
        max(1, _radius * 0.11),
        false
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Wisp's compact Simulant death effect.
function sc_enemy_sim_wisp_death(_enemy)
{
    var _data = _enemy.enemy;

    sc_particles_simulant_enemy_death(
        _enemy.x,
        _enemy.y,
        _data.visual.radius
    );

    return true;
}