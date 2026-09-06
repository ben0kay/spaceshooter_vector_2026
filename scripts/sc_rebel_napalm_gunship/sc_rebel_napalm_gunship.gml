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

/// @description Draws the detailed tank-fed Rebel Napalm Gunship hull.
function sc_enemy_rebel_napalm_gunship_body_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    // ==================================================
    // EXPOSED CENTRAL CHASSIS
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        0.96,-0.17,
        -0.96,-0.2,
        -1.05,0.2,
        0.96,0.17,
        _p.void
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.86,-0.11,
        -0.91,-0.13,
        -0.91,0.13,
        0.86,0.11,
        _p.steel_dark
    );

    // Long structural rails.
    sc_rebel_visual_brace(_x,_y,_r,_a,-0.82,-0.15,0.67,-0.13,_p);
    sc_rebel_visual_brace(_x,_y,_r,_a,-0.82,0.15,0.67,0.13,_p);

    // ==================================================
    // LARGE REAR NAPALM TANKS
    // ==================================================

    for (var _side=-1; _side<=1; _side+=2)
    {
        var _sy=0.39*_side;

        // Dark tank cradle.
        sc_visual_quad(_x,_y,_r,_a,
            -0.12,_sy-0.18,
            -0.82,_sy-0.18,
            -0.9,_sy+0.18,
            -0.13,_sy+0.18,
            _p.void
        );

        sc_rebel_visual_brace(_x,_y,_r,_a,-0.18,_sy-0.18,-0.73,_sy-0.18,_p);
        sc_rebel_visual_brace(_x,_y,_r,_a,-0.18,_sy+0.18,-0.73,_sy+0.18,_p);

        // Main cylindrical tank.
        sc_visual_quad(_x,_y,_r,_a,
            -0.17,_sy-0.14,
            -0.78,_sy-0.14,
            -0.78,_sy+0.14,
            -0.17,_sy+0.14,
            _p.steel_mid
        );

        sc_visual_circle(_x,_y,_r,_a,-0.17,_sy,0.14,_p.steel_light,false);
        sc_visual_circle(_x,_y,_r,_a,-0.78,_sy,0.14,_p.steel_dark,false);

        // Dirty lower tank plate.
        sc_visual_quad(_x,_y,_r,_a,
            -0.23,_sy+0.03,
            -0.7,_sy+0.03,
            -0.7,_sy+0.12,
            -0.23,_sy+0.12,
            _p.hull_mid
        );

        // Tank straps.
        for (var _i=0; _i<3; ++_i)
        {
            var _f=-0.31-_i*0.19;
            sc_visual_line(_x,_y,_r,_a,_f,_sy-0.155,_f,_sy+0.155,5,_p.void);
            sc_visual_line(_x,_y,_r,_a,_f,_sy-0.14,_f,_sy+0.14,2,_p.steel_dark);
        }

        // Tank warning panel.
        sc_rebel_visual_hazard_panel(_x,_y,_r,_a,-0.48,_sy-0.07*_side,0.25,0.07,_p);

        // Feed pipe into manifold.
        sc_rebel_visual_pipe(_x,_y,_r,_a,-0.7,_sy-0.17*_side,-0.47,0.18*_side,5,_p);

        // Small valve.
        sc_visual_circle(_x,_y,_r,_a,-0.47,0.18*_side,0.055,_p.void,false);
        sc_visual_circle(_x,_y,_r,_a,-0.47,0.18*_side,0.032,_p.rust,false);

        // A couple visible tank rivets.
        sc_rebel_visual_rivet_strip(_x,_y,_r,_a,-0.27,_sy-0.12,-0.67,_sy-0.12,5,_p);
    }

    // ==================================================
    // CENTRAL PRESSURE LINE
    // ==================================================

    sc_rebel_visual_pipe_hot(_x,_y,_r,_a,-0.9,0,0.61,0,9,_p);

    // Heavy pipe couplings.
    for (var _i=0; _i<5; ++_i)
    {
        var _f=-0.67+_i*0.27;
        sc_visual_line(_x,_y,_r,_a,_f,-0.1,_f,0.1,6,_p.void);
        sc_visual_line(_x,_y,_r,_a,_f,-0.085,_f,0.085,2,_p.steel_light);
    }

    // Rear pressure manifold.
    sc_visual_circle(_x,_y,_r,_a,-0.75,0,0.17,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,-0.75,0,0.135,_p.steel_mid,false);
    sc_visual_circle(_x,_y,_r,_a,-0.75,0,0.135,_p.steel_light,true);

    // ==================================================
    // CENTRAL ENGINE CASING
    // ==================================================

    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        -0.69,-0.2,
        -1.05,-0.18,
        -1.09,0,
        -0.7,0,
        _p.steel_mid,_p
    );

    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        -0.7,0,
        -1.09,0,
        -1.05,0.18,
        -0.69,0.2,
        _p.steel_dark,_p
    );

    sc_rebel_visual_vent(_x,_y,_r,_a,-0.9,-0.1,0.23,0.035,3,_p);
    sc_rebel_visual_vent(_x,_y,_r,_a,-0.9,0.1,0.23,0.035,3,_p);

    // ==================================================
    // BROAD SCRAP SHOULDERS
    // ==================================================

    for (var _side=-1; _side<=1; _side+=2)
    {
        // Structural shoulder frame.
        sc_visual_quad(_x,_y,_r,_a,
            0.34,0.17*_side,
            0.05,0.34*_side,
            -0.41,0.55*_side,
            -0.62,0.49*_side,
            _p.void
        );

        sc_rebel_visual_brace(_x,_y,_r,_a,0.25,0.2*_side,-0.5,0.49*_side,_p);
        sc_rebel_visual_brace(_x,_y,_r,_a,-0.06,0.31*_side,-0.3,0.48*_side,_p);

        // Main shoulder plate.
        sc_rebel_visual_patch_plate(_x,_y,_r,_a,
            0.31,0.2*_side,
            0.04,0.34*_side,
            -0.35,0.51*_side,
            -0.54,0.45*_side,
            _side<0?_p.hull_light:_p.paint,
            _p
        );

        // Outer dark patch.
        sc_rebel_visual_patch_plate(_x,_y,_r,_a,
            -0.2,0.43*_side,
            -0.38,0.56*_side,
            -0.62,0.53*_side,
            -0.48,0.41*_side,
            _p.hull_dark,_p
        );

        // Small repair panel.
        sc_rebel_visual_patch_plate(_x,_y,_r,_a,
            0.11,0.26*_side,
            -0.08,0.36*_side,
            -0.22,0.33*_side,
            -0.03,0.23*_side,
            _p.steel_mid,_p
        );

        // Outer vent.
        sc_rebel_visual_vent(_x,_y,_r,_a,-0.32,0.47*_side,0.18,0.03,3,_p);

        // One battered hazard panel.
        if (_side>0)
            sc_rebel_visual_hazard_panel(_x,_y,_r,_a,-0.23,0.43,0.22,0.07,_p);
        else
            sc_rebel_visual_patch_x(_x,_y,_r,_a,-0.18,-0.42,0.035,_p);
    }

    // ==================================================
    // FORWARD COCKPIT / ARMOUR BODY
    // ==================================================

    // Dark broad base shape.
    sc_visual_triangle(_x,_y,_r,_a,
        1.13,0,
        0.02,-0.36,
        0.02,0.36,
        _p.void,false
    );

    // Left forward armour.
    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        1.08,0,
        0.61,-0.2,
        0.08,-0.31,
        0.37,-0.09,
        _p.hull_light,_p
    );

    // Right forward armour.
    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        1.08,0,
        0.37,0.09,
        0.08,0.31,
        0.61,0.2,
        _p.paint,_p
    );

    // Mid hull patchwork.
    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        0.43,-0.1,
        0.06,-0.27,
        -0.09,-0.16,
        0.27,-0.04,
        _p.hull_mid,_p
    );

    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        0.27,0.04,
        -0.09,0.16,
        0.06,0.27,
        0.43,0.1,
        _p.steel_mid,_p
    );

    // ==================================================
    // MULTI-PANE COCKPIT
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        0.79,-0.11,
        0.52,-0.17,
        0.38,-0.1,
        0.67,-0.035,
        _p.void
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.67,0.035,
        0.38,0.1,
        0.52,0.17,
        0.79,0.11,
        _p.void
    );

    sc_visual_line(_x,_y,_r,_a,0.57,-0.15,0.51,-0.05,2,_p.steel_light);
    sc_visual_line(_x,_y,_r,_a,0.51,0.05,0.57,0.15,2,_p.steel_light);

    sc_rebel_visual_slit_light(_x,_y,_r,_a,0.73,-0.055,0.83,-0.025,_p);
    sc_rebel_visual_slit_light(_x,_y,_r,_a,0.83,0.025,0.73,0.055,_p);

    // ==================================================
    // SURFACE DETAIL
    // ==================================================

    sc_rebel_visual_panel_seam(_x,_y,_r,_a,0.19,-0.25,0.12,-0.08,_p);
    sc_rebel_visual_panel_seam(_x,_y,_r,_a,0.12,0.08,0.19,0.25,_p);

    sc_rebel_visual_panel_seam(_x,_y,_r,_a,-0.15,-0.3,-0.08,-0.13,_p);
    sc_rebel_visual_panel_seam(_x,_y,_r,_a,-0.08,0.13,-0.15,0.3,_p);

    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,0.05,-0.31,0.37,-0.21,5,_p);
    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,0.37,0.21,0.05,0.31,5,_p);

    sc_rebel_visual_patch_x(_x,_y,_r,_a,0.06,-0.16,0.025,_p);

    sc_rebel_visual_chevrons(_x,_y,_r,_a,0.17,0.27,0.035,1,_p);

    // ==================================================
    // FRONT PROJECTOR FEED
    // ==================================================

    sc_rebel_visual_pipe_hot(_x,_y,_r,_a,0.08,0,0.66,0,7,_p);

    // Projector mounting socket.
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.22,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.18,_p.steel_dark,false);
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.18,_p.steel_light,true);

    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,0.28,-0.17,0.51,-0.17,4,_p);
    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,0.51,0.17,0.28,0.17,4,_p);
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