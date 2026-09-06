/*
REBEL NAPALM GUNSHIP

A slow close-range pressure ship carrying one large exposed napalm
canister, thin scrap wings and a limited-arc flame projector.
*/

/// @description Registers the Rebel Napalm Gunship.
function sc_enemy_register_rebel_napalm_gunship()
{
    return sc_enemy_register({
        identity: {
            key: "e_rebel_napalm_gunship",
            name: "Rebel Napalm Gunship",
            faction: Faction.REBEL,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.STANDARD,
            rank: EnemyRank.COMMON,
            threat_value: 3
        },

        reward: { credits: 48 },

        stats_base: {
            shield_max: 0,
            armour_max: 230,
            hull_max: 120,
            mass: 1.2,

            handling: {
                speed_max: 4.3,
                acceleration: 0.19,
                friction_coeff: 0.978,
                turn_speed: 2.7,
                directional: true,
                directional_speed_min: 0.38,
                directional_thrust_min: 0.48
            },

            range: {
                detection: 1050,
                combat: 470,
                backaway: 145,
                forget: 1500,
                wander: 360,
                alert_share: 950
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_movement_stalk_range,
            combat_script: sc_enemy_movement_stalk_range,

            runtime: {
                stalker: {
                    side: choose(-1,1),
                    next_switch_tick: 0
                }
            },

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
            },

            stalker: {
                hold_range: 330,
                approach_speed: 0.85,
                circle_speed: 0.38,
                firing_speed: 0.24,
                side_angle: 78,
                switch_min: 90,
                switch_max: 180
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 540,
            arrival_radius: 85,
            search_duration: 170,
            speed_scale: 0.65
        },

        visual: sc_enemy_rebel_napalm_gunship_visual_data(),

        collision: {
            radius_forward_scale: 1.08,
            radius_side_scale: 0.72,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "napalm_projector",
                group: "flamethrower",
                forward: 0.4,
                side: 0,
                angle: 0,
                muzzle_forward: 0.57,

                rotation: {
                    mode: HardpointRotation.TARGET,
                    turn_speed: 2.8,
                    arc: 140,
                    return_to_rest: true
                },

                draw_script: sc_enemy_rebel_napalm_projector_draw
            }
        ],

        thrusters: [
            {
                key: "engine_centre",
                forward: -0.94,
                side: 0,
                angle: 180,
                scale: 0.95
            }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "napalm_burst",
                    weight: 100,
                    hardpoint_group: "flamethrower",
                    weapon_key: "weapon_rebel_flamethrower",

                    conditions: {
                        line_of_sight: true,
                        range_min: 90,
                        range_max: 430
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 1.5,
                        fire_tolerance: 10
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 28,
                        aim_lock_remaining: 0,
                        track_during_active: true,
                        scale: 0.17,
                        particle_interval: 3,
                        draw_script: sc_attack_telegraph_energy_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        duration: 105,
                        cooldown: 145
                    }
                }
            ]
        }
    });
}

/// @description Returns the Rebel Napalm Gunship visual definition.
function sc_enemy_rebel_napalm_gunship_visual_data()
{
    return {
        radius: 66,
        motion_strength: 2,
        palette: sc_faction_palette_get(Faction.REBEL),
        core: { forward: -0.38, side: 0 },

        draw: {
            body: sc_enemy_rebel_napalm_gunship_body_draw,
            core: sc_enemy_rebel_napalm_gunship_core_draw
        },

        death: {
            script: sc_enemy_rebel_napalm_gunship_death,

            draw_scripts: [
                sc_enemy_rebel_napalm_fragment_front_draw,
                sc_enemy_rebel_napalm_fragment_left_draw,
                sc_enemy_rebel_napalm_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_rebel_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 256,
            core_canvas_size: 128,
            hardpoint_canvas_size: 128,
            thrust_canvas_size: 128,
            fragment_canvas_size: 192
        }
    };
}

/// @description Draws the bulky tank-fed Rebel Napalm Gunship hull.
function sc_enemy_rebel_napalm_gunship_body_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    // ==================================================
    // DARK ENGINEERING UNDERFRAME
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        0.5,-0.3,
        -0.78,-0.47,
        -1.02,-0.26,
        0.34,-0.18,
        _p.hull_dark
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.5,0.3,
        0.34,0.18,
        -1.02,0.26,
        -0.78,0.47,
        _p.hull_dark
    );

    // Heavy central backbone.
    sc_visual_quad(_x,_y,_r,_a,
        0.9,-0.13,
        -1,-0.15,
        -1,0.15,
        0.9,0.13,
        _p.void
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.82,-0.09,
        -0.91,-0.1,
        -0.91,0.1,
        0.82,0.09,
        _p.hull_mid
    );

    // ==================================================
    // LARGE REAR NAPALM CANISTERS
    // ==================================================

    for (var _side=-1; _side<=1; _side+=2)
    {
        var _sy=0.38*_side;

        // Main tank body.
        sc_visual_quad(_x,_y,_r,_a,
            -0.18,_sy-0.15,
            -0.83,_sy-0.15,
            -0.83,_sy+0.15,
            -0.18,_sy+0.15,
            _p.metal
        );

        // Rounded tank ends.
        sc_visual_circle(_x,_y,_r,_a,-0.18,_sy,0.15,_p.hull_light,false);
        sc_visual_circle(_x,_y,_r,_a,-0.83,_sy,0.15,_p.hull_mid,false);

        // Dark lower grime strip.
        sc_visual_line(_x,_y,_r,_a,-0.2,_sy+0.09,-0.8,_sy+0.09,5,_p.hull_dark);

        // Tank securing bands.
        sc_visual_line(_x,_y,_r,_a,-0.31,_sy-0.16,-0.31,_sy+0.16,5,_p.void);
        sc_visual_line(_x,_y,_r,_a,-0.31,_sy-0.15,-0.31,_sy+0.15,2,_p.outline);

        sc_visual_line(_x,_y,_r,_a,-0.51,_sy-0.16,-0.51,_sy+0.16,5,_p.void);
        sc_visual_line(_x,_y,_r,_a,-0.51,_sy-0.15,-0.51,_sy+0.15,2,_p.outline);

        sc_visual_line(_x,_y,_r,_a,-0.7,_sy-0.16,-0.7,_sy+0.16,5,_p.void);
        sc_visual_line(_x,_y,_r,_a,-0.7,_sy-0.15,-0.7,_sy+0.15,2,_p.outline);

        // Rough hazard stripe plate.
        sc_visual_quad(_x,_y,_r,_a,
            -0.38,_sy-0.11,
            -0.61,_sy-0.11,
            -0.61,_sy-0.04,
            -0.38,_sy-0.04,
            _p.accent
        );

        sc_visual_line(_x,_y,_r,_a,-0.39,_sy-0.1,-0.45,_sy-0.04,2,_p.void);
        sc_visual_line(_x,_y,_r,_a,-0.47,_sy-0.1,-0.53,_sy-0.04,2,_p.void);
        sc_visual_line(_x,_y,_r,_a,-0.55,_sy-0.1,-0.61,_sy-0.04,2,_p.void);

        // Heavy pipe from tank toward central manifold.
        sc_visual_line(_x,_y,_r,_a,-0.69,_sy-0.17,-0.48,0.17*_side,8,_p.void);
        sc_visual_line(_x,_y,_r,_a,-0.69,_sy-0.17,-0.48,0.17*_side,4,_p.metal);

        sc_visual_circle(_x,_y,_r,_a,-0.49,0.17*_side,0.055,_p.hull_dark,false);
        sc_visual_circle(_x,_y,_r,_a,-0.49,0.17*_side,0.035,_p.energy,false);
    }

    // ==================================================
    // CENTRAL PRESSURE MANIFOLD / PIPE
    // ==================================================

    // Thick black backing makes the pipe obvious.
    sc_visual_line(_x,_y,_r,_a,-0.88,0,0.5,0,15,_p.void);

    // Main rusty metal pipe.
    sc_visual_line(_x,_y,_r,_a,-0.86,0,0.5,0,10,_p.metal);

    // Inner heated/feed pipe.
    sc_visual_line(_x,_y,_r,_a,-0.82,0,0.48,0,4,_p.energy);

    // Pipe coupling rings.
    for (var _i=0; _i<5; ++_i)
    {
        var _f=-0.68+_i*0.25;

        sc_visual_line(_x,_y,_r,_a,_f,-0.1,_f,0.1,5,_p.void);
        sc_visual_line(_x,_y,_r,_a,_f,-0.08,_f,0.08,2,_p.outline);
    }

    // Large rear manifold.
    sc_visual_circle(_x,_y,_r,_a,-0.78,0,0.18,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,-0.78,0,0.14,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_r,_a,-0.78,0,0.14,_p.metal,true);

    // ==================================================
    // CENTRAL SINGLE ENGINE BLOCK
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        -0.7,-0.2,
        -1.05,-0.19,
        -1.09,0.19,
        -0.7,0.2,
        _p.hull_dark
    );

    sc_visual_quad(_x,_y,_r,_a,
        -0.74,-0.14,
        -1,-0.13,
        -1,0.13,
        -0.74,0.14,
        _p.hull_mid
    );

    sc_visual_line(_x,_y,_r,_a,-0.78,-0.15,-0.78,0.15,3,_p.outline);
    sc_visual_line(_x,_y,_r,_a,-0.94,-0.13,-0.94,0.13,3,_p.metal);

    // ==================================================
    // WIDE SCRAP ARMOUR SHOULDERS
    // ==================================================

    for (var _side=-1; _side<=1; _side+=2)
    {
        // Main shoulder.
        sc_visual_quad(_x,_y,_r,_a,
            0.36,0.18*_side,
            0.02,0.4*_side,
            -0.46,0.52*_side,
            -0.38,0.27*_side,
            _side<0?_p.hull_light:_p.hull_mid
        );

        // Rear scrap plate.
        sc_visual_quad(_x,_y,_r,_a,
            -0.08,0.4*_side,
            -0.32,0.59*_side,
            -0.62,0.58*_side,
            -0.46,0.48*_side,
            _p.hull_dark
        );

        // Small mismatched patch.
        sc_visual_quad(_x,_y,_r,_a,
            0.11,0.28*_side,
            -0.08,0.41*_side,
            -0.26,0.39*_side,
            -0.1,0.29*_side,
            _p.metal
        );

        // Exposed brace.
        sc_visual_line(_x,_y,_r,_a,0.21,0.22*_side,-0.34,0.47*_side,5,_p.void);
        sc_visual_line(_x,_y,_r,_a,0.21,0.22*_side,-0.34,0.47*_side,2,_p.outline);

        // Hazard mark on one battered shoulder.
        if (_side>0)
        {
            sc_visual_line(_x,_y,_r,_a,-0.15,0.42,-0.23,0.51,4,_p.accent);
            sc_visual_line(_x,_y,_r,_a,-0.23,0.42,-0.31,0.51,4,_p.accent);
        }
    }

    // ==================================================
    // BROAD WEDGE FORWARD HULL
    // ==================================================

    sc_visual_triangle(_x,_y,_r,_a,
        1.12,0,
        0.02,-0.39,
        0.02,0.39,
        _p.hull_dark,
        false
    );

    // Patchwork left half.
    sc_visual_triangle(_x,_y,_r,_a,
        1.08,0,
        0.08,-0.34,
        0.63,-0.19,
        _p.hull_light,
        false
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.63,-0.19,
        0.08,-0.34,
        -0.04,-0.19,
        0.46,-0.1,
        _p.metal
    );

    // Patchwork right half.
    sc_visual_triangle(_x,_y,_r,_a,
        1.08,0,
        0.63,0.19,
        0.08,0.34,
        _p.hull_mid,
        false
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.63,0.19,
        0.46,0.1,
        -0.04,0.19,
        0.08,0.34,
        _p.metal
    );

    // Angular side armour rails.
    for (var _side=-1; _side<=1; _side+=2)
    {
        sc_visual_line(_x,_y,_r,_a,1.05,0.05*_side,0.08,0.32*_side,4,_p.void);
        sc_visual_line(_x,_y,_r,_a,1.03,0.05*_side,0.1,0.31*_side,2,_p.outline);
    }

    // ==================================================
    // DARK COCKPIT WINDOWS
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        0.67,-0.18,
        0.4,-0.24,
        0.29,-0.15,
        0.61,-0.09,
        _p.void
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.67,0.18,
        0.61,0.09,
        0.29,0.15,
        0.4,0.24,
        _p.void
    );

    sc_visual_line(_x,_y,_r,_a,0.62,-0.13,0.37,-0.18,2,_p.energy);
    sc_visual_line(_x,_y,_r,_a,0.62,0.13,0.37,0.18,2,_p.energy);

    // ==================================================
    // FRONT PIPE / PROJECTOR FEED
    // ==================================================

    sc_visual_line(_x,_y,_r,_a,0.1,0,0.67,0,12,_p.void);
    sc_visual_line(_x,_y,_r,_a,0.12,0,0.67,0,7,_p.metal);
    sc_visual_line(_x,_y,_r,_a,0.14,0,0.65,0,3,_p.energy);

    // Projector mounting plate.
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.22,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.18,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.18,_p.metal,true);

    // Mount braces.
    sc_visual_line(_x,_y,_r,_a,0.27,-0.17,0.5,-0.17,3,_p.outline);
    sc_visual_line(_x,_y,_r,_a,0.27,0.17,0.5,0.17,3,_p.outline);
}

/// @description Draws the long limited-arc Rebel Napalm Projector.
function sc_enemy_rebel_napalm_projector_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p=_v.palette;
    draw_set_alpha(_alpha);

    // Heavy improvised swivel base.
    sc_visual_circle(_x,_y,_r,_a,-0.1,0,0.21,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,-0.1,0,0.175,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_r,_a,-0.1,0,0.175,_p.metal,true);

    // Crude welded projector housing.
    sc_visual_quad(_x,_y,_r,_a,
        -0.08,-0.15,
        0.31,-0.13,
        0.42,-0.09,
        0.42,0.09,
        _p.hull_dark
    );

    sc_visual_quad(_x,_y,_r,_a,
        -0.08,-0.15,
        0.42,0.09,
        -0.08,0.15,
        -0.2,0,
        _p.hull_mid
    );

    // Long feed/barrel assembly.
    sc_visual_line(_x,_y,_r,_a,0.03,0,0.58,0,13,_p.void);
    sc_visual_line(_x,_y,_r,_a,0.07,0,0.57,0,8,_p.metal);
    sc_visual_line(_x,_y,_r,_a,0.12,0,0.55,0,3,_p.energy);

    // Barrel braces.
    sc_visual_line(_x,_y,_r,_a,0.16,-0.1,0.16,0.1,3,_p.outline);
    sc_visual_line(_x,_y,_r,_a,0.32,-0.09,0.32,0.09,3,_p.outline);

    // Wide ugly flamethrower nozzle.
    sc_visual_quad(_x,_y,_r,_a,
        0.48,-0.12,
        0.62,-0.09,
        0.62,0.09,
        0.48,0.12,
        _p.hull_dark
    );

    sc_visual_circle(_x,_y,_r,_a,0.61,0,0.1,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,0.61,0,0.1,_p.metal,true);
    sc_visual_circle(_x,_y,_r,_a,0.585,0,0.052,_p.energy,false);

    draw_set_alpha(1);
}

/// @description Draws the Napalm Gunship's pressure manifold core.
function sc_enemy_rebel_napalm_gunship_core_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p=_v.palette;

    draw_set_alpha(_alpha*0.22);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_r*0.31,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_r*0.22,false);

    draw_set_colour(_p.hull_mid);
    draw_circle(_x,_y,_r*0.18,false);

    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_r*0.22,true);

    // Pressure-valve spokes.
    for (var _i=0; _i<4; ++_i)
    {
        var _sa=_a+_i*90;

        draw_line(
            _x+lengthdir_x(_r*0.06,_sa),
            _y+lengthdir_y(_r*0.06,_sa),
            _x+lengthdir_x(_r*0.17,_sa),
            _y+lengthdir_y(_r*0.17,_sa)
        );
    }

    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_r*0.09,false);

    draw_set_colour(_p.core);
    draw_circle(_x,_y,_r*0.035,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Rebel Napalm Gunship destruction visual.
function sc_enemy_rebel_napalm_gunship_death(_enemy)
{
    var _data=_enemy.enemy;
    var _visual=_data.visual;
    var _cache=sc_enemy_visual_cache_get(_data.key);
    var _x=_enemy.x;
    var _y=_enemy.y;
    var _a=_enemy.draw_angle;
    var _r=_visual.radius;
    var _fragments=[];

    // Forward hull.
    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[0],
        _x+lengthdir_x(_r*0.48,_a),
        _y+lengthdir_y(_r*0.48,_a),
        _a+random_range(-10,10),
        random_range(2.5,4),
        _a,
        choose(-7,7),
        1
    ));

    // Left tank / shoulder.
    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[1],
        _x+lengthdir_x(-_r*0.38,_a)+lengthdir_x(-_r*0.38,_a+90),
        _y+lengthdir_y(-_r*0.38,_a)+lengthdir_y(-_r*0.38,_a+90),
        _a-35,
        random_range(3,4.5),
        _a,
        -9,
        1
    ));

    // Right tank / shoulder.
    array_push(_fragments,sc_death_fragment_data(
        _cache.fragments[2],
        _x+lengthdir_x(-_r*0.38,_a)+lengthdir_x(_r*0.38,_a+90),
        _y+lengthdir_y(-_r*0.38,_a)+lengthdir_y(_r*0.38,_a+90),
        _a+35,
        random_range(3,4.5),
        _a,
        9,
        1
    ));

    // Pressure core.
    array_push(_fragments,sc_death_fragment_data(
        _cache.core,
        _x+lengthdir_x(-_r*0.38,_a),
        _y+lengthdir_y(-_r*0.38,_a),
        random(360),
        random_range(2,3),
        _a,
        choose(-11,11),
        0.9
    ));

    // Hardpoint.
    for (var _i=0; _i<array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint=_data.hardpoints[_i];
        var _hx=_x+lengthdir_x(_hardpoint.forward*_r,_a)+lengthdir_x(_hardpoint.side*_r,_a+90);
        var _hy=_y+lengthdir_y(_hardpoint.forward*_r,_a)+lengthdir_y(_hardpoint.side*_r,_a+90);

        array_push(_fragments,sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hx,
            _hy,
            random(360),
            random_range(3,5),
            _a,
            random_range(-12,12),
            0.9
        ));
    }

    sc_death_fragment_create(
        _x,
        _y,
        _fragments,
        _visual.palette.core,
        _visual.palette.glow,
        _r,
        44
    );

    return true;
}

/// @description Draws the broken forward wedge of the Napalm Gunship.
function sc_enemy_rebel_napalm_fragment_front_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    sc_visual_triangle(_x,_y,_r,_a,1.1,0,0.05,-0.38,0.05,0.38,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_r,_a,1.03,0,0.1,-0.31,0.55,-0.16,_p.hull_light,false);
    sc_visual_triangle(_x,_y,_r,_a,1.03,0,0.55,0.16,0.1,0.31,_p.hull_mid,false);

    sc_visual_line(_x,_y,_r,_a,0.15,0,0.85,0,7,_p.void);
    sc_visual_line(_x,_y,_r,_a,0.18,0,0.83,0,3,_p.energy);

    sc_visual_line(_x,_y,_r,_a,1.1,0,0.05,-0.38,2,_p.outline);
    sc_visual_line(_x,_y,_r,_a,1.1,0,0.05,0.38,2,_p.outline);
}

/// @description Draws the broken left rear tank and shoulder.
function sc_enemy_rebel_napalm_fragment_left_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    sc_visual_quad(_x,_y,_r,_a,
        0.05,-0.25,
        -0.12,-0.53,
        -0.75,-0.54,
        -0.68,-0.26,
        _p.hull_dark
    );

    sc_visual_quad(_x,_y,_r,_a,
        -0.18,-0.31,
        -0.78,-0.31,
        -0.78,-0.57,
        -0.18,-0.57,
        _p.metal
    );

    sc_visual_circle(_x,_y,_r,_a,-0.2,-0.44,0.13,_p.hull_light,false);
    sc_visual_circle(_x,_y,_r,_a,-0.76,-0.44,0.13,_p.hull_mid,false);

    sc_visual_line(_x,_y,_r,_a,-0.35,-0.58,-0.35,-0.3,4,_p.void);
    sc_visual_line(_x,_y,_r,_a,-0.55,-0.58,-0.55,-0.3,2,_p.outline);

    sc_visual_line(_x,_y,_r,_a,-0.57,-0.28,-0.35,-0.08,6,_p.void);
    sc_visual_line(_x,_y,_r,_a,-0.57,-0.28,-0.35,-0.08,2,_p.metal);
}

/// @description Draws the broken right rear tank and shoulder.
function sc_enemy_rebel_napalm_fragment_right_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    sc_visual_quad(_x,_y,_r,_a,
        0.05,0.25,
        -0.68,0.26,
        -0.75,0.54,
        -0.12,0.53,
        _p.hull_mid
    );

    sc_visual_quad(_x,_y,_r,_a,
        -0.18,0.31,
        -0.18,0.57,
        -0.78,0.57,
        -0.78,0.31,
        _p.metal
    );

    sc_visual_circle(_x,_y,_r,_a,-0.2,0.44,0.13,_p.hull_light,false);
    sc_visual_circle(_x,_y,_r,_a,-0.76,0.44,0.13,_p.hull_dark,false);

    sc_visual_line(_x,_y,_r,_a,-0.35,0.58,-0.35,0.3,4,_p.void);
    sc_visual_line(_x,_y,_r,_a,-0.55,0.58,-0.55,0.3,2,_p.outline);

    sc_visual_line(_x,_y,_r,_a,-0.57,0.28,-0.35,0.08,6,_p.void);
    sc_visual_line(_x,_y,_r,_a,-0.57,0.28,-0.35,0.08,2,_p.energy);
}