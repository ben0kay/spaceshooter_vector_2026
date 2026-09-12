/*
SIMULANT SIEGEBREAKER

Bulky Simulant heavy assault ship facing east at draw_angle 0.
Carries two shoulder rocket launchers and one central pulse cannon.
Designed to stop and destroy obstructing asteroids rather than navigate around them.
*/

/// @description Registers the Simulant Siegebreaker.
function sc_enemy_register_sim_siegebreaker()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_siegebreaker",
            name: "Simulant Siegebreaker",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.STANDARD,
            rank: EnemyRank.VETERAN,
            threat_value: 14
        },

        reward: { credits: 110 },

        stats_base: {
            shield_max: 150,
            armour_max: 520,
            hull_max: 290,
            mass: 2.4,

            handling: {
                speed_max: 2.8,
                acceleration: 0.11,
                friction_coeff: 0.992,
                turn_speed: 1.5,
                directional: true,
                directional_speed_min: 0.3,
                directional_thrust_min: 0.42
            },

            range: {
                detection: 1320,
                combat: 980,
                backaway: 390,
                forget: 1540,
                wander: 0,
                alert_share: 1550
            },

            damage_multiplier: 1.15,
            fire_rate_multiplier: 0.9
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.DESTROY,
            idle_script: sc_enemy_movement_hold,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_hold_line_of_sight,

            facing: {
                default_mode: EnemyFacingMode.TARGET,
                backaway_mode: EnemyFacingMode.MOVEMENT,
                angle_offset: 0,
                turn_speed_scale: 0.7,
                spin_speed: 0
            },

            strafe: { amount: 0, speed: 0 }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 600,
            arrival_radius: 90,
            search_duration: 180,
            speed_scale: 0.6
        },

        visual: sc_enemy_sim_siegebreaker_visual_data(),

        collision: {
            radius_forward_scale: 1.08,
            radius_side_scale: 0.9,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "rocket_left", group: "rockets",
                forward: 0.18, side: -0.57, angle: 0, muzzle_forward: 0.56,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.7, arc: 50, return_to_rest: true },
                draw_script: sc_enemy_sim_siegebreaker_rocket_draw
            },
            {
                key: "pulse_centre", group: "pulse",
                forward: 0.69, side: 0, angle: 0, muzzle_forward: 0.42,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.1, arc: 55, return_to_rest: true },
                draw_script: sc_enemy_sim_siegebreaker_pulse_draw
            },
            {
                key: "rocket_right", group: "rockets",
                forward: 0.18, side: 0.57, angle: 0, muzzle_forward: 0.56,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.7, arc: 50, return_to_rest: true },
                draw_script: sc_enemy_sim_siegebreaker_rocket_draw
            }
        ],

        thrusters: [
    { key: "thruster_left", forward: -0.78, side: -0.45, angle: 180, scale: 0.95 },
    { key: "thruster_centre", forward: -0.90, side: 0, angle: 270, scale: 1.1 },
    { key: "thruster_right", forward: -0.78, side: 0.45, angle: 180, scale: 0.95 }
],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 2,

            channels: [
                {
                    key: "rockets",
                    selection: AttackSelection.WEIGHTED
                },
                {
                    key: "pulse",
                    selection: AttackSelection.WEIGHTED
                }
            ],

            attacks: [
                {
                    key: "twin_rocket_launch",
                    channel: "rockets",
                    weight: 42,
                    hardpoint_group: "rockets",
                    weapon_key: "weapon_simulant_rocket",

                    conditions: {
                        line_of_sight: true,
                        range_min: 300,
                        range_max: 940
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 3,
                        fire_tolerance: 9
                    },

                    shot: { pattern: ShotPattern.SINGLE, amount: 1 },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 190
                    }
                },
                {
                    key: "centre_pulse_burst",
                    channel: "pulse",
                    weight: 58,
                    hardpoint_group: "pulse",
                    weapon_key: "weapon_simulant_pulse",

                    conditions: {
                        line_of_sight: true,
                        range_min: 140,
                        range_max: 900
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 2,
                        fire_tolerance: 8
                    },

                    shot: { pattern: ShotPattern.SINGLE, amount: 1 },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 8,
                        volley_max: 6,
                        cooldown: 120
                    }
                }
            ]
        }
    });
}

/// @description Returns the complete Siegebreaker visual definition.
function sc_enemy_sim_siegebreaker_visual_data()
{
    return {
        radius: 90,
        motion_strength: 2,
        palette: sc_faction_palette_get(Faction.SIMULANT),
        core: { forward: -0.12, side: 0 },

        draw: {
            body: sc_enemy_sim_siegebreaker_body_draw,
            core: sc_enemy_sim_siegebreaker_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_sim_siegebreaker_hull_draw,
            armour_draw_script: sc_enemy_sim_siegebreaker_armour_draw
        },

        death: {
            script: sc_enemy_sim_siegebreaker_death,
            draw_scripts: [
                sc_enemy_sim_siegebreaker_fragment_centre_draw,
                sc_enemy_sim_siegebreaker_fragment_left_draw,
                sc_enemy_sim_siegebreaker_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 256,
            core_canvas_size: 160,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 256
        }
    };
}

/// @description Draws the intact Siegebreaker fallback body.
function sc_enemy_sim_siegebreaker_body_draw(_x, _y, _radius, _angle, _visual)
{
    sc_enemy_sim_siegebreaker_hull_draw(_x, _y, _radius, _angle, _visual, 0);
    sc_enemy_sim_siegebreaker_armour_draw(_x, _y, _radius, _angle, _visual, 0);
}

/// @description Draws the permanent bulky mechanical hull.
function sc_enemy_sim_siegebreaker_hull_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p=_visual.palette;

    // Heavy central wedge.
    sc_visual_triangle(_x,_y,_radius,_angle,1.1,0,0.44,-0.52,-0.96,-0.45,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_radius,_angle,1.1,0,-0.96,-0.45,-0.96,0.45,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_radius,_angle,1.1,0,-0.96,0.45,0.44,0.52,_p.hull_dark,false);

    // Thick inner mechanical body.
    sc_visual_quad(_x,_y,_radius,_angle,0.78,-0.29,0.25,-0.44,-0.75,-0.35,-0.75,0.35,_p.hull_mid);
    sc_visual_quad(_x,_y,_radius,_angle,0.78,-0.29,-0.75,0.35,0.25,0.44,0.78,0.29,_p.hull_mid);

    // Heavy launcher shoulders.
    for (var _side=-1;_side<=1;_side+=2)
    {
        sc_visual_quad(_x,_y,_radius,_angle,
            0.5,0.31*_side,
            0.33,0.79*_side,
            -0.55,0.76*_side,
            -0.81,0.38*_side,
            _p.hull_dark);

        sc_visual_quad(_x,_y,_radius,_angle,
            0.37,0.39*_side,
            0.24,0.7*_side,
            -0.46,0.67*_side,
            -0.65,0.42*_side,
            _p.hull_mid);

        // Recessed rocket-launcher bed.
        sc_visual_quad(_x,_y,_radius,_angle,
            0.41,0.47*_side,
            0.34,0.69*_side,
            -0.07,0.69*_side,
            -0.16,0.47*_side,
            _p.void);

        sc_visual_quad(_x,_y,_radius,_angle,
            0.35,0.5*_side,
            0.29,0.65*_side,
            -0.03,0.65*_side,
            -0.1,0.5*_side,
            _p.hull_light);

        // Launcher bearing.
        sc_visual_circle(_x,_y,_radius,_angle,0.18,0.57*_side,0.195,_p.void,false);
        sc_visual_circle(_x,_y,_radius,_angle,0.18,0.57*_side,0.195,_p.metal,true);
        sc_visual_circle(_x,_y,_radius,_angle,0.18,0.57*_side,0.13,_p.hull_mid,false);
        sc_visual_circle(_x,_y,_radius,_angle,0.18,0.57*_side,0.06,_p.accent,true);

        // Heavy shoulder power feed.
        sc_sim_visual_energy_conduit(
            _x,_y,_radius,_angle,
            0.03,0.44*_side,
            -0.51,0.5*_side,
            2,_p
        );

        sc_sim_visual_energy_socket(
            _x,_y,_radius,_angle,
            -0.4,0.54*_side,
            0.07,_p
        );

        // Structural shoulder edges.
        sc_visual_line(_x,_y,_radius,_angle,0.5,0.31*_side,0.33,0.79*_side,2,_p.outline);
        sc_visual_line(_x,_y,_radius,_angle,0.33,0.79*_side,-0.55,0.76*_side,2,_p.metal);
    }

    // Heavy central energy trench.
    sc_visual_line(_x,_y,_radius,_angle,-0.86,0,0.9,0,12,_p.void);

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        -0.76,0,
        0.86,0,
        3,_p
    );

    // Reactor socket.
    sc_visual_circle(_x,_y,_radius,_angle,-0.12,0,0.285,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,-0.12,0,0.285,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,-0.12,0,0.21,_p.hull_light,true);

    // Centre pulse hardpoint socket.
    sc_visual_circle(_x,_y,_radius,_angle,0.69,0,0.155,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.69,0,0.155,_p.metal,true);

    // Three heavy engine housings.
    var _engine_side=[-0.45,0,0.45];

    for (var _i=0;_i<3;_i++)
    {
        sc_visual_quad(_x,_y,_radius,_angle,
            -0.6,_engine_side[_i]-0.085,
            -0.93,_engine_side[_i]-0.075,
            -0.93,_engine_side[_i]+0.075,
            -0.6,_engine_side[_i]+0.085,
            _p.hull_mid);

        sc_visual_line(_x,_y,_radius,_angle,-0.65,_engine_side[_i],-0.94,_engine_side[_i],8,_p.void);
        sc_visual_line(_x,_y,_radius,_angle,-0.67,_engine_side[_i],-0.92,_engine_side[_i],3,_p.energy);
    }

    // Progressive hull damage.
    if (_stage>=1)
    {
        sc_visual_line(_x,_y,_radius,_angle,0.22,-0.23,-0.08,-0.39,4,_p.void);
        sc_visual_line(_x,_y,_radius,_angle,0.2,-0.23,-0.04,-0.35,2,_p.accent);
    }

    if (_stage>=2)
    {
        sc_visual_circle(_x,_y,_radius,_angle,-0.42,0.28,0.16,_p.void,false);
        sc_visual_line(_x,_y,_radius,_angle,-0.42,0.28,-0.61,0.41,2,_p.energy);
    }

    if (_stage>=3)
    {
        sc_visual_circle(_x,_y,_radius,_angle,0.16,0.42,0.14,_p.void,false);
        sc_visual_circle(_x,_y,_radius,_angle,-0.58,-0.34,0.18,_p.void,false);
        sc_visual_line(_x,_y,_radius,_angle,-0.58,-0.34,-0.78,-0.44,3,_p.accent);
    }
}

/// @description Draws the Siegebreaker's layered armour around its heavy launcher beds.
function sc_enemy_sim_siegebreaker_armour_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p=_visual.palette;

    for (var _side=-1;_side<=1;_side+=2)
    {
        // Permanent inner armour.
        sc_visual_quad(_x,_y,_radius,_angle,
            0.45,0.19*_side,
            0.13,0.33*_side,
            -0.25,0.32*_side,
            -0.41,0.18*_side,
            _p.metal);

        sc_visual_line(_x,_y,_radius,_angle,
            0.45,0.19*_side,
            0.13,0.33*_side,
            2,_p.core);

        // Heavy launcher collar.
        if (_stage<=2)
        {
            sc_visual_quad(_x,_y,_radius,_angle,
                0.45,0.35*_side,
                0.31,0.5*_side,
                -0.16,0.51*_side,
                -0.39,0.37*_side,
                _p.hull_light);

            sc_visual_line(_x,_y,_radius,_angle,
                0.45,0.35*_side,
                0.31,0.5*_side,
                2,_p.metal);

            sc_visual_quad(_x,_y,_radius,_angle,
                0.29,0.69*_side,
                0.04,0.76*_side,
                -0.4,0.72*_side,
                -0.25,0.62*_side,
                _p.hull_light);

            sc_visual_line(_x,_y,_radius,_angle,
                0.29,0.69*_side,
                0.04,0.76*_side,
                2,_p.outline);
        }

        // Rear armour.
        if (_stage<=1)
        {
            sc_visual_quad(_x,_y,_radius,_angle,
                -0.33,0.39*_side,
                -0.49,0.61*_side,
                -0.72,0.52*_side,
                -0.67,0.29*_side,
                _p.metal);
        }

        // Heavy intact launcher guard.
        if (_stage==0)
        {
            sc_visual_triangle(_x,_y,_radius,_angle,
                0.24,0.75*_side,
                -0.5,0.76*_side,
                -0.7,0.55*_side,
                _p.hull_light,false);

            sc_visual_line(_x,_y,_radius,_angle,
                0.24,0.75*_side,
                -0.5,0.76*_side,
                3,_p.metal);

            sc_visual_line(_x,_y,_radius,_angle,
                0.21,0.72*_side,
                -0.44,0.72*_side,
                2,_p.accent);
        }
    }

    // Broad armoured forward prow.
    if (_stage<=2)
    {
        sc_visual_triangle(_x,_y,_radius,_angle,
            1.08,0,
            0.59,-0.2,
            0.59,0.2,
            _p.metal,false);

        sc_visual_line(_x,_y,_radius,_angle,1.08,0,0.59,-0.2,3,_p.core);
        sc_visual_line(_x,_y,_radius,_angle,1.08,0,0.59,0.2,3,_p.core);
    }
}

/// @description Draws one standardized Simulant heavy rocket-launcher tube.
function sc_enemy_sim_siegebreaker_rocket_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    draw_set_alpha(_alpha);

    // Heavy rotating bearing.
    sc_visual_circle(_x,_y,_radius,_angle,-0.08,0,0.2,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,-0.08,0,0.2,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,-0.08,0,0.135,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_radius,_angle,-0.08,0,0.06,_p.accent,true);

    // Broad launcher cradle.
    sc_visual_quad(_x,_y,_radius,_angle,
        -0.05,-0.195,
        0.4,-0.18,
        0.52,-0.14,
        -0.05,-0.14,
        _p.hull_dark);

    sc_visual_quad(_x,_y,_radius,_angle,
        -0.05,0.14,
        0.52,0.14,
        0.4,0.18,
        -0.05,0.195,
        _p.hull_dark);

    sc_visual_quad(_x,_y,_radius,_angle,
        0,-0.145,
        0.49,-0.13,
        0.49,0.13,
        0,0.145,
        _p.hull_light);

    // Main launch tube.
    sc_visual_line(_x,_y,_radius,_angle,0.01,0,0.59,0,20,_p.void);
    sc_visual_line(_x,_y,_radius,_angle,0.03,0,0.56,0,14,_p.hull_mid);
    sc_visual_line(_x,_y,_radius,_angle,0.06,0,0.56,0,8,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle,0.07,0,0.54,0,4,_p.hull_dark);

    // Mechanical collars.
    sc_visual_line(_x,_y,_radius,_angle,0.1,-0.145,0.1,0.145,4,_p.outline);
    sc_visual_line(_x,_y,_radius,_angle,0.29,-0.155,0.29,0.155,4,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle,0.35,-0.145,0.35,0.145,2,_p.accent);

    // Powered tube feeds.
    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.04,-0.115,
        0.47,-0.105,
        2,_p,_alpha
    );

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.04,0.115,
        0.47,0.105,
        2,_p,_alpha
    );

    // Heavy muzzle block.
    sc_visual_quad(_x,_y,_radius,_angle,
        0.45,-0.195,
        0.62,-0.175,
        0.62,0.175,
        0.45,0.195,
        _p.hull_dark);

    sc_visual_line(_x,_y,_radius,_angle,0.47,-0.185,0.61,-0.165,3,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle,0.47,0.185,0.61,0.165,3,_p.metal);

    // Large hollow rocket aperture.
    sc_visual_circle(_x,_y,_radius,_angle,0.61,0,0.17,_p.metal,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.61,0,0.142,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.585,0,0.09,_p.hull_dark,false);

    sc_visual_circle(_x,_y,_radius,_angle,0.61,0,0.17,_p.hull_light,true);
    sc_visual_circle(_x,_y,_radius,_angle,0.61,0,0.125,_p.accent,true);

    // Ignition point.
    sc_visual_circle(_x,_y,_radius,_angle,0.57,0,0.03,_p.energy,false);

    draw_set_alpha(1);
}

/// @description Draws the Siegebreaker's central pulse cannon.
function sc_enemy_sim_siegebreaker_pulse_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    draw_set_alpha(_alpha);

    // Heavy rotating socket.
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.16,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.16,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.1,_p.accent,true);

    // Armoured cannon housing.
    sc_visual_quad(_x,_y,_radius,_angle,
        -0.04,-0.085,
        0.38,-0.065,
        0.38,0.065,
        -0.04,0.085,
        _p.hull_light);

    // Recessed powered barrel.
    sc_visual_line(_x,_y,_radius,_angle,0.02,0,0.48,0,10,_p.void);

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.07,0,
        0.48,0,
        2,_p,_alpha
    );

    // Heavy muzzle socket.
    sc_visual_circle(_x,_y,_radius,_angle,0.48,0,0.08,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0.48,0,0.045,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.48,0,0.028,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the Siegebreaker's rotating reactor.
function sc_enemy_sim_siegebreaker_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    sc_sim_visual_reactor(
        _x,_y,_radius,_angle,
        {
            outer_scale: 0.25,
            middle_scale: 0.17,
            inner_scale: 0.085,

            socket_enabled: true,
            middle_colour: _p.hull_light,
            middle_filled: false,

            glow_alpha: 0.3,
            glow_scale: 1.6,
            secondary_glow_alpha: 0.08,
            secondary_glow_scale: 1.2,

            vane_amount: 6,
            vane_start: 0,
            vane_twist: 20,
            vane_inner_scale: 1,
            vane_outer_scale: 0.86,
            vane_width: 3,
            vane_secondary_colour: _p.outline,

            accent_scale: 1.55,
            accent_filled: false,
            core_scale: 0.42,
            additive: false
        },
        _p,
        _alpha
    );
}

/// @description Creates the complete Siegebreaker destruction visual.
function sc_enemy_sim_siegebreaker_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _palette = _visual.palette;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _fragments = [];

    sc_particles_simulant_enemy_death(_enemy.x, _enemy.y, _radius);

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[0],
        _enemy.x + lengthdir_x(_radius * 0.18, _angle),
        _enemy.y + lengthdir_y(_radius * 0.18, _angle),
        _angle + random_range(-8, 8),
        random_range(2, 3),
        _angle, choose(-7, 7), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[1],
        _enemy.x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(-_radius * 0.48, _angle + 90),
        _enemy.y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(-_radius * 0.48, _angle + 90),
        _angle - 65 + random_range(-10, 10),
        random_range(2.5, 3.8),
        _angle, random_range(-9, -5), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.fragments[2],
        _enemy.x + lengthdir_x(-_radius * 0.08, _angle) + lengthdir_x(_radius * 0.48, _angle + 90),
        _enemy.y + lengthdir_y(-_radius * 0.08, _angle) + lengthdir_y(_radius * 0.48, _angle + 90),
        _angle + 65 + random_range(-10, 10),
        random_range(2.5, 3.8),
        _angle, random_range(5, 9), 1
    ));

    array_push(_fragments, sc_death_fragment_data(
        _cache.core, _enemy.x, _enemy.y,
        irandom(359), random_range(1.5, 2.4),
        _angle, choose(-10, 10), 0.95
    ));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _enemy.x
            + lengthdir_x(_hardpoint.forward * _radius, _angle)
            + lengthdir_x(_hardpoint.side * _radius, _angle + 90);

        var _hardpoint_y = _enemy.y
            + lengthdir_y(_hardpoint.forward * _radius, _angle)
            + lengthdir_y(_hardpoint.side * _radius, _angle + 90);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x, _hardpoint_y,
            _angle + random_range(-20, 20),
            random_range(2.5, 4),
            _angle, choose(-11, 11), 0.95
        ));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _data.movement.velocity_x * 0.3;
        _fragments[_i].velocity_y += _data.movement.velocity_y * 0.3;
    }

    sc_death_fragment_create(
        _enemy.x, _enemy.y,
        _fragments,
        _palette.core,
        _palette.glow,
        _radius,
        50
    );

    return true;
}

/// @description Draws the broken central Siegebreaker fragment.
function sc_enemy_sim_siegebreaker_fragment_centre_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.98, 0, 0.3, -0.34, -0.74, 0,
        _p.hull_dark, false);

    sc_visual_triangle(_x, _y, _radius, _angle,
        0.98, 0, -0.74, 0, 0.3, 0.34,
        _p.hull_mid, false);

    sc_visual_line(_x, _y, _radius, _angle,
        -0.68, 0, 0.82, 0,
        3, _p.accent);
}

/// @description Draws the broken left Siegebreaker section.
function sc_enemy_sim_siegebreaker_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle,
        0.4, -0.25,
        0.13, -0.69,
        -0.55, -0.65,
        -0.76, -0.31,
        _p.hull_dark);

    sc_visual_quad(_x, _y, _radius, _angle,
        0.26, -0.35,
        0.07, -0.58,
        -0.46, -0.54,
        -0.61, -0.34,
        _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle,
        0.13, -0.68, -0.55, -0.64,
        2, _p.energy);
}

/// @description Draws the broken right Siegebreaker section.
function sc_enemy_sim_siegebreaker_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle,
        0.4, 0.25,
        -0.76, 0.31,
        -0.55, 0.65,
        0.13, 0.69,
        _p.hull_dark);

    sc_visual_quad(_x, _y, _radius, _angle,
        0.26, 0.35,
        -0.61, 0.34,
        -0.46, 0.54,
        0.07, 0.58,
        _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle,
        0.13, 0.68, -0.55, 0.64,
        2, _p.energy);
}