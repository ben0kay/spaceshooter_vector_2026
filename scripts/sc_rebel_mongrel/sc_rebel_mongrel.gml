/// @description Registers the common Rebel Mongrel shotgun fighter.
function sc_enemy_register_rebel_mongrel()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_rebel_mongrel",
            name: "Rebel Mongrel",
            faction: Faction.REBEL,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.STANDARD,
            rank: EnemyRank.COMMON,
            threat_value: 3
        },

        reward: { credits: 45 },

        stats_base: {
            shield_max: 0,
            armour_max: 270,
            hull_max: 140,
            mass: 1.3,

            handling: {
                speed_max: 5.5,
                acceleration: 0.23,
                friction_coeff: 0.986,
                turn_speed: 3.4,
                directional: true,
                directional_speed_min: 0.42,
                directional_thrust_min: 0.52
            },

            range: {
                detection: 1250,
                combat: 900,
                backaway: 330,
                forget: 1700,
                wander: 480,
                alert_share: 1200
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
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.TARGET,
                angle_offset: 0,
                turn_speed_scale: 1,
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
            duration: 600,
            arrival_radius: 90,
            search_duration: 180,
            speed_scale: 0.65
        },

        visual: sc_enemy_rebel_mongrel_visual_data(),

        collision: {
            radius_forward_scale: 1.05,
            radius_side_scale: 0.85,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "nose_shotgun",
                group: "shotgun",
                forward: 0.85,
                side: 0,
                angle: 0,
                muzzle_forward: 0.82,

                rotation: {
                    mode: HardpointRotation.FIXED,
                    turn_speed: 0,
                    arc: 0,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_mongrel_shotgun_draw
            }
        ],

        thrusters: [
            { key: "engine_upper", forward: -0.8, side: -0.33, angle: 180, scale: 0.9 },
            { key: "engine_lower", forward: -0.8, side: 0.33, angle: 180, scale: 0.9 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "shrapnel_carrier",
                    weight: 100,
                    hardpoint_group: "shotgun",
                    weapon_key: "weapon_rebel_mongrel_carrier",

                    conditions: {
                        line_of_sight: true,
                        range_min: 300,
                        range_max: 900
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
                        order: HardpointFireOrder.ALL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 105
                    }
                }
            ]
        }
    });
}

/// @description Returns the Mongrel's authored hull and shotgun visual.
function sc_enemy_rebel_mongrel_visual_data()
{
    return {
        radius: 76,
        motion_strength: 2.2,
        palette: sc_faction_palette_get(Faction.REBEL),

        authored: {
            enabled: true,

            body: {
                sprite: s_rebel_mongrel_hull,
                scale: 0.12,
                fallback_script: sc_enemy_rebel_gunship_body_draw
            }
        },

        core: {
            forward: -0.35,
            side: 0
        },

        draw: {
            body: sc_enemy_body_dispatch,
            core: sc_enemy_rebel_mongrel_core_draw
        },

        death: {
            script: sc_enemy_rebel_mongrel_death,
            draw_scripts: [
                sc_enemy_rebel_mongrel_fragment_front_draw,
                sc_enemy_rebel_mongrel_fragment_upper_draw,
                sc_enemy_rebel_mongrel_fragment_lower_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_rebel_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 256,
            core_canvas_size: 64,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 192
        }
    };
}

/// @description Draws the Mongrel's fixed, long scrap-metal shotgun barrel.
function sc_enemy_rebel_mongrel_shotgun_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.43, -0.29,
        0.3, -0.29,
        0.3, 0.29,
        -0.43, 0.29,
        _p.hull_dark
    );

    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.31, -0.2,
        0.12, -0.2,
        0.12, 0.2,
        -0.31, 0.2,
        _p.metal
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.02, 0, 0.92, 0, 14, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.05, 0, 0.89, 0, 9, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.22, 0, 0.92, 0, 5, _p.hull_dark);

    sc_visual_line(_x, _y, _radius, _angle, 0.22, -0.27, 0.22, 0.27, 3, _p.paint);
    sc_visual_line(_x, _y, _radius, _angle, 0.61, -0.22, 0.61, 0.22, 3, _p.hull_light);

    sc_visual_circle(_x, _y, _radius, _angle, 0.92, 0, 0.17, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.92, 0, 0.17, _p.metal, true);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Leaves the imported Mongrel hull free of an extra core overlay.
function sc_enemy_rebel_mongrel_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    return;
}

/// @description Creates Mongrel hull, wing and shotgun fragments.
function sc_enemy_rebel_mongrel_death(_enemy)
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
        _x + lengthdir_x(_radius * 0.38, _angle),
        _y + lengthdir_y(_radius * 0.38, _angle),
        _angle + random_range(-12, 12),
        random_range(2.5, 4),
        _angle,
        choose(-8, 8),
        1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[1],
        _x + lengthdir_x(-_radius * 0.2, _angle) + lengthdir_x(-_radius * 0.46, _angle + 90),
        _y + lengthdir_y(-_radius * 0.2, _angle) + lengthdir_y(-_radius * 0.46, _angle + 90),
        _angle - 55,
        random_range(3, 4.5),
        _angle,
        -10,
        1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[2],
        _x + lengthdir_x(-_radius * 0.2, _angle) + lengthdir_x(_radius * 0.46, _angle + 90),
        _y + lengthdir_y(-_radius * 0.2, _angle) + lengthdir_y(_radius * 0.46, _angle + 90),
        _angle + 55,
        random_range(3, 4.5),
        _angle,
        10,
        1
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _x
            + lengthdir_x(_hardpoint.forward * _radius, _angle)
            + lengthdir_x(_hardpoint.side * _radius, _angle + 90);

        var _hardpoint_y = _y
            + lengthdir_y(_hardpoint.forward * _radius, _angle)
            + lengthdir_y(_hardpoint.side * _radius, _angle + 90);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x,
            _hardpoint_y,
            _angle + random_range(-15, 15),
            random_range(3, 5),
            _angle,
            choose(-12, 12),
            0.95
        ));
    }

    sc_death_fragment_create(
        _x, _y, _fragments,
        _visual.palette.core,
        _visual.palette.glow,
        _radius,
        42
    );

    return true;
}

/// @description Draws the Mongrel's broken nose and front chassis.
function sc_enemy_rebel_mongrel_fragment_front_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(
        _x, _y, _radius, _angle,
        1.04, 0,
        -0.22, -0.29,
        -0.16, 0.28,
        _p.hull_mid,
        false
    );

    sc_visual_line(_x, _y, _radius, _angle, 1.04, 0, -0.22, -0.29, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 1.04, 0, -0.16, 0.28, 2, _p.outline);
}

/// @description Draws the Mongrel's broken upper wing.
function sc_enemy_rebel_mongrel_fragment_upper_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.28, -0.2,
        -0.16, -0.78,
        -0.84, -0.92,
        -0.58, -0.25,
        _p.hull_light
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.28, -0.2, -0.16, -0.78, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.16, -0.78, -0.84, -0.92, 2, _p.outline);
}

/// @description Draws the Mongrel's broken lower wing.
function sc_enemy_rebel_mongrel_fragment_lower_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        0.2, 0.19,
        -0.55, 0.29,
        -0.76, 0.84,
        -0.06, 0.71,
        _p.metal
    );

    sc_visual_line(_x, _y, _radius, _angle, 0.2, 0.19, -0.06, 0.71, 2, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, -0.06, 0.71, -0.76, 0.84, 2, _p.outline);
}