/*
REBEL WARWING

A wide, scrappy Veteran Superheavy Rebel missile-fighter.
- 2 nose miniguns
- 2 wing missile launcher hardpoints
- each launcher fires a 6-rocket salvo
- total 12 rockets per missile attack
- 1 huge rear thruster
*/

/// @description Registers the guided Rebel Salvo Rocket weapon.
function sc_weapon_register_rebel_salvo_rocket()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_rebel_salvo_rocket",
            name: "Rebel Salvo Rocket"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_rebel_salvo_rocket",

            projectile: {
                scale: 1,
                speed: 14,
                life: 135
            },

            damage: {
                amount: 4,
                type: DamageType.EXPLOSIVE,
                effect: DamageEffect.NONE
            },

            guidance: {
                acquire_range: 760,
                turn_speed: 1,
                reacquire_interval: 12,
                lead_strength: 0.15,
                guidance_delay: 10,
                lock_angle: 180,
                retain_assigned_target: true,

                avoidance: {
                    strength: 0.65,
                    asteroids: 1,
                    structures: 1,
                    clearance_scale: 0.8
                }
            },

            detonation: {
                scale: 1,

                damage: {
                    amount: 5,
                    type: DamageType.EXPLOSIVE,
                    effect: DamageEffect.NONE,
                    knockback_force: 1
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.6,
            pitch_range: 0.05
        }
    });
}

/// @description Registers the Rebel Warwing.
function sc_enemy_register_rebel_warwing()
{
    return sc_enemy_register({
        identity:{
            key:"enemy_rebel_warwing",
            name:"Rebel Warwing",
            faction:Faction.REBEL,
            role:EnemyRole.FIGHTER,
            ship_class:EnemyClass.SUPERHEAVY,
            rank:EnemyRank.VETERAN,
            threat_value:18
        },

        reward:{
            credits:150
        },

        stats_base:{
            shield_max:0,
            armour_max:1950,
            hull_max:820,
            mass:3.25,

            handling:{
                speed_max:2.25,
                acceleration:0.085,
                friction_coeff:0.994,
                turn_speed:0.82,
                directional:true,
                directional_speed_min:0.22,
                directional_thrust_min:0.38
            },

            range:{
                detection:1650,
                combat:1150,
                backaway:320,
                forget:1850,
                wander:0,
                alert_share:1600
            },

            damage_multiplier:1.05,
            fire_rate_multiplier:1
        },

        movement_controller:{
            asteroid_response:AsteroidResponse.AVOID,

            idle_script:sc_enemy_movement_hold,
            chase_script:sc_enemy_movement_chase,
            combat_script:sc_enemy_movement_hold_line_of_sight,

            facing:{
                default_mode:EnemyFacingMode.TARGET,
                backaway_mode:EnemyFacingMode.TARGET,
                angle_offset:0,
                turn_speed_scale:0.72,
                spin_speed:0
            },

            strafe:{
                amount:0,
                speed:0
            }
        },

        awareness_controller:{
            unseen_damage_script:sc_enemy_awareness_investigate,
            alert_receive_script:sc_enemy_awareness_investigate,
            duration:620,
            arrival_radius:110,
            search_duration:180,
            speed_scale:0.7
        },

        visual:sc_enemy_rebel_warwing_visual_data(),

        collision:{
            radius_forward_scale:1.08,
            radius_side_scale:1.62,
            blocks_player:true
        },

        hardpoints:[
            // ==================================================
            // NOSE MINIGUNS
            // ==================================================
            {
                key:"minigun_upper",
                group:"nose_miniguns",
                forward:0.88,
                side:0.19,
                angle:0,
                muzzle_forward:0.22,

                rotation:{
                    mode:HardpointRotation.TARGET,
                    turn_speed:3.6,
                    arc:60,
                    return_to_rest:true
                },

                draw_script:sc_enemy_rebel_warwing_minigun_draw
            },

            {
                key:"minigun_lower",
                group:"nose_miniguns",
                forward:0.88,
                side:-0.19,
                angle:0,
                muzzle_forward:0.22,

                rotation:{
                    mode:HardpointRotation.TARGET,
                    turn_speed:3.6,
                    arc:60,
                    return_to_rest:true
                },

                draw_script:sc_enemy_rebel_warwing_minigun_draw
            },

            // ==================================================
            // WING SALVO LAUNCHERS
            // ==================================================
            {
                key:"launcher_upper",
                group:"wing_launchers",
                forward:0.24,
                side:1.08,
                angle:0,
                muzzle_forward:0.18,

                rotation:{
                    mode:HardpointRotation.FIXED,
                    turn_speed:0,
                    arc:0,
                    return_to_rest:true
                },

                draw_script:sc_enemy_rebel_warwing_launcher_draw
            },

            {
                key:"launcher_lower",
                group:"wing_launchers",
                forward:0.24,
                side:-1.08,
                angle:0,
                muzzle_forward:0.18,

                rotation:{
                    mode:HardpointRotation.FIXED,
                    turn_speed:0,
                    arc:0,
                    return_to_rest:true
                },

                draw_script:sc_enemy_rebel_warwing_launcher_draw
            }
        ],

        thrusters:[
            {
                key:"main_thruster",
                forward:-0.96,
                side:0,
                angle:180,
                scale:1.42
            }
        ],

        attack_controller:{
            selection:AttackSelection.WEIGHTED,
            max_active_channels:2,

            channels:[
                { key:"guns", selection:AttackSelection.WEIGHTED },
                { key:"missiles", selection:AttackSelection.WEIGHTED }
            ],

            attacks:[
                {
                    key:"nose_minigun_burst",
                    channel:"guns",
                    weight: 100,
                    hardpoint_group:"nose_miniguns",
                    weapon_key:"weapon_rebel_minigun",

                    conditions:{
                        line_of_sight:true,
                        range_min:90,
                        range_max:900
                    },

                    aim:{
                        mode:AimMode.TARGET_LEAD,
                        prediction_strength:0.62,
                        angle_offset:0,
                        inaccuracy:4,
                        fire_tolerance:10
                    },

                    shot:{
                        pattern:ShotPattern.SINGLE,
                        amount:1
                    },

                    firing:{
                        order:HardpointFireOrder.SEQUENTIAL,
                        interval:3,
                        volley_max:18,
                        cooldown:65
                    }
                },

                {
                    key:"wing_salvo_barrage",
                    channel:"missiles",
                    weight:100,
                    hardpoint_group:"wing_launchers",
                    weapon_key:"weapon_rebel_salvo_rocket",

                    conditions:{
                        line_of_sight:true,
                        range_min:240,
                        range_max:1250
                    },

                    aim:{
                        mode:AimMode.TARGET,
                        prediction_strength:0.2,
                        angle_offset:0,
                        inaccuracy:8,
                        fire_tolerance:20
                    },

                    shot: {
					    pattern: ShotPattern.RANDOM_CONE,
					    amount: 1,
					    angle_total: 30,
					    projectile_interval: 0
					},

					firing: {
					    order: HardpointFireOrder.SEQUENTIAL,
					    interval: 4,
					    volley_max: 12,
					    cooldown: 190
					}
                }
            ]
        }
    });
}

/// @description Returns the Rebel Warwing visual definition.
function sc_enemy_rebel_warwing_visual_data()
{
    var _authored_enabled = true;

    return {
        radius:132,
        motion_strength:1.7,
        palette:sc_faction_palette_get(Faction.REBEL),

        authored:{
            enabled:_authored_enabled,

            body:{
                sprite:s_rebel_warwing_hull,
                scale:0.5,
                fallback_script:sc_enemy_rebel_warwing_body_draw
            }
        },

        core:{
            forward:0,
            side:0
        },

        draw:{
            body:sc_enemy_body_dispatch,
            core:sc_enemy_rebel_warwing_core_draw
        },

        damage_layers:{
            enabled:!_authored_enabled,
            damage_stages:4,
            hull_draw_script:sc_enemy_rebel_warwing_hull_draw,
            armour_draw_script:sc_enemy_rebel_warwing_armour_draw
        },

        death:{
            script:sc_enemy_rebel_warwing_death,

            draw_scripts:[
                sc_enemy_rebel_warwing_fragment_body_draw,
                sc_enemy_rebel_warwing_fragment_wing_draw
            ]
        },

        thrust:{
            draw_script:sc_enemy_rebel_warwing_thruster_draw,
            ignition_script:sc_particles_enemy_thrust_ignition,
            particle_script:sc_particles_enemy_thrust_emit
        },

        bake:{
            body_canvas_size:768,
            core_canvas_size:64,
            hardpoint_canvas_size:160,
            thrust_canvas_size:160,
            fragment_canvas_size:320
        }
    };
}

/// @description Draws intact Warwing.
function sc_enemy_rebel_warwing_body_draw(_x,_y,_radius,_angle,_visual)
{
    sc_enemy_rebel_warwing_hull_draw(_x,_y,_radius,_angle,_visual,0);
    sc_enemy_rebel_warwing_armour_draw(_x,_y,_radius,_angle,_visual,0);
}

/// @description Draws the layered industrial Rebel Warwing hull.
function sc_enemy_rebel_warwing_hull_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p=_visual.palette;

    // Dark underframe gives every section visible separation.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        1.08,-0.2,
        1.08,0.2,
        -1.1,0.24,
        -1.1,-0.24,
        _p.void
    );

    // Main mismatched fuselage plating.
    sc_rebel_visual_patch_plate(
        _x,_y,_radius,_angle,
        0.98,-0.18,
        0.98,0.18,
        0.18,0.22,
        0.12,-0.22,
        _p.paint,_p
    );

    sc_rebel_visual_patch_plate(
        _x,_y,_radius,_angle,
        0.12,-0.22,
        0.18,0.22,
        -0.56,0.2,
        -0.62,-0.2,
        _p.hull_mid,_p
    );

    sc_rebel_visual_patch_plate(
        _x,_y,_radius,_angle,
        -0.62,-0.2,
        -0.56,0.2,
        -1.08,0.15,
        -1.08,-0.15,
        _p.steel_dark,_p
    );

    // Armoured nose and segmented cockpit.
    sc_visual_triangle(
        _x,_y,_radius,_angle,
        1.15,0,
        0.82,-0.22,
        0.82,0.22,
        _p.hull_light,false
    );

    sc_rebel_visual_patch_plate(
        _x,_y,_radius,_angle,
        0.89,-0.13,
        0.89,0.13,
        0.57,0.105,
        0.57,-0.105,
        _p.steel_dark,_p
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.84,-0.09,
        0.84,0.09,
        0.63,0.075,
        0.63,-0.075,
        _p.void
    );

    sc_rebel_visual_panel_seam(
        _x,_y,_radius,_angle,
        0.74,-0.085,
        0.74,0.085,_p
    );

    sc_rebel_visual_slit_light(
        _x,_y,_radius,_angle,
        0.68,-0.055,
        0.8,-0.055,_p
    );

    sc_rebel_visual_slit_light(
        _x,_y,_radius,_angle,
        0.68,0.055,
        0.8,0.055,_p
    );

    // Central machinery and exposed spine.
    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.02,0,0.215,
        _p.void,false
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.02,0,0.165,
        _p.steel_mid,false
    );

    sc_visual_circle(
        _x,_y,_radius,_angle,
        -0.02,0,0.105,
        _p.hull_dark,false
    );

    sc_rebel_visual_pipe(
        _x,_y,_radius,_angle,
        -0.5,-0.11,
        0.42,-0.11,
        5,_p
    );

    sc_rebel_visual_pipe(
        _x,_y,_radius,_angle,
        -0.5,0.11,
        0.42,0.11,
        5,_p
    );

    // Wide armoured wings.
    for (var _side=-1;_side<=1;_side+=2)
    {
        sc_rebel_visual_patch_plate(
            _x,_y,_radius,_angle,
            0.39,0.2*_side,
            0.3,0.93*_side,
            -0.04,1.29*_side,
            -0.24,0.27*_side,
            _p.steel_dark,_p
        );

        sc_rebel_visual_patch_plate(
            _x,_y,_radius,_angle,
            0.3,0.9*_side,
            0.05,1.62*_side,
            -0.3,1.76*_side,
            -0.18,1.0*_side,
            _p.paint,_p
        );

        // Dark replacement plate across each wing.
        sc_rebel_visual_patch_plate(
            _x,_y,_radius,_angle,
            0.17,1.05*_side,
            0.01,1.48*_side,
            -0.13,1.52*_side,
            -0.02,1.08*_side,
            _p.hull_dark,_p
        );

        // Structural brace and fuel conduit.
        sc_rebel_visual_brace(
            _x,_y,_radius,_angle,
            0.28,0.43*_side,
            -0.07,1.38*_side,_p
        );

        sc_rebel_visual_pipe(
            _x,_y,_radius,_angle,
            0.12,0.49*_side,
            0.05,0.88*_side,
            5,_p
        );

        // External cylindrical machinery.
        sc_visual_quad(
            _x,_y,_radius,_angle,
            -0.14,0.5*_side,
            0.14,0.5*_side,
            0.17,0.76*_side,
            -0.17,0.76*_side,
            _p.steel_dark
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            -0.15,0.63*_side,
            0.13,_p.void,false
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            -0.15,0.63*_side,
            0.095,_p.rust,true
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            0.15,0.63*_side,
            0.13,_p.void,false
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            0.15,0.63*_side,
            0.095,_p.steel_mid,true
        );

        // Hazard block, vents and identification marks.
        sc_rebel_visual_hazard_panel(
            _x,_y,_radius,_angle,
            -0.11,1.24*_side,
            0.32,0.13,_p
        );

        sc_rebel_visual_vent(
            _x,_y,_radius,_angle,
            -0.12,1.59*_side,
            0.19,0.045,4,_p
        );

        sc_rebel_visual_chevrons(
            _x,_y,_radius,_angle,
            0.13,1.39*_side,
            0.055,1,_p
        );

        sc_rebel_visual_rivet_strip(
            _x,_y,_radius,_angle,
            0.2,0.97*_side,
            -0.2,1.68*_side,
            7,_p
        );

        // Jagged reinforced wingtip.
        sc_visual_triangle(
            _x,_y,_radius,_angle,
            -0.03,1.58*_side,
            -0.23,1.9*_side,
            -0.38,1.68*_side,
            _p.hull_light,false
        );
    }

    // Tail structure and asymmetric repair plates.
    for (var _side=-1;_side<=1;_side+=2)
    {
        sc_rebel_visual_patch_plate(
            _x,_y,_radius,_angle,
            -0.83,0.13*_side,
            -0.7,0.58*_side,
            -1.08,0.42*_side,
            -1.15,0.18*_side,
            _side<0?_p.paint:_p.hull_mid,_p
        );

        sc_rebel_visual_rivet_strip(
            _x,_y,_radius,_angle,
            -0.83,0.18*_side,
            -0.82,0.48*_side,
            4,_p
        );
    }

    sc_rebel_visual_patch_x(
        _x,_y,_radius,_angle,
        -0.42,-0.04,
        0.065,_p
    );

    sc_rebel_visual_panel_seam(
        _x,_y,_radius,_angle,
        0.42,-0.18,
        0.42,0.18,_p
    );

    sc_rebel_visual_panel_seam(
        _x,_y,_radius,_angle,
        -0.54,-0.18,
        -0.54,0.18,_p
    );

    // Damage stages remove detail and expose burnt sections.
    if (_stage>=1)
    {
        sc_visual_circle(_x,_y,_radius,_angle,-0.08,0.7,0.13,_p.void,false);
        sc_visual_circle(_x,_y,_radius,_angle,-0.12,-1.29,0.16,_p.void,false);
    }

    if (_stage>=2)
    {
        sc_visual_line(_x,_y,_radius,_angle,0.18,0.93,-0.17,1.59,7,_p.void);
        sc_visual_line(_x,_y,_radius,_angle,0.2,-0.92,-0.08,-1.48,7,_p.void);
    }

    if (_stage>=3)
    {
        sc_visual_circle(_x,_y,_radius,_angle,-0.88,0,0.16,_p.void,false);
        sc_visual_circle(_x,_y,_radius,_angle,0.5,-0.12,0.12,_p.void,false);
    }
}

/// @description Draws the Warwing armour layer.
function sc_enemy_rebel_warwing_armour_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _plate=make_colour_rgb(142,124,96);
    var _patch=make_colour_rgb(166,150,128);
    var _dark=make_colour_rgb(76,67,57);

    // Nose and central plates.
    if (_stage<=2)
    {
        sc_visual_quad(_x,_y,_radius,_angle,0.82,-0.17,0.82,0.17,0.46,0.12,0.46,-0.12,_plate);
        sc_visual_quad(_x,_y,_radius,_angle,0.38,-0.14,0.38,0.14,0.04,0.16,0.04,-0.16,_patch);
    }

    for (var _s=-1;_s<=1;_s+=2)
    {
        if (_stage<=2)
        {
            sc_visual_quad(_x,_y,_radius,_angle,0.26,0.34*_s,0.18,1.02*_s,-0.02,1.1*_s,-0.08,0.38*_s,_plate);
        }

        if (_stage<=1)
        {
            sc_visual_quad(_x,_y,_radius,_angle,0.16,1.02*_s,-0.02,1.56*_s,-0.18,1.6*_s,-0.04,1.04*_s,_patch);
        }

        if (_stage==0)
        {
            sc_visual_triangle(_x,_y,_radius,_angle,-0.04,1.54*_s,-0.22,1.82*_s,-0.3,1.64*_s,_dark,false);
        }
    }
}

/// @description Warwing has no special core.
function sc_enemy_rebel_warwing_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    return;
}

/// @description Draws one Rebel Warwing six-tube salvo launcher.
function sc_enemy_rebel_warwing_launcher_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    sc_rebel_visual_salvo_launcher(
        _x,_y,_radius,_angle,
        3,2,
        _visual.palette,
        _alpha
    );
}

/// @description Draws one Rebel nose minigun.
function sc_enemy_rebel_warwing_minigun_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _body=make_colour_rgb(92,78,62);
    var _dark=make_colour_rgb(46,40,36);
    var _metal=make_colour_rgb(126,112,92);

    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_radius,_angle,-0.05,0,0.08,_dark,false);
    sc_visual_circle(_x,_y,_radius,_angle,-0.05,0,0.06,_body,true);

    sc_visual_quad(_x,_y,_radius,_angle,-0.02,-0.045,0.18,-0.04,0.18,0.04,-0.02,0.045,_body);

    // Twin barrels.
    sc_visual_line(_x,_y,_radius,_angle,0.04,-0.02,0.22,-0.02,5,_dark);
    sc_visual_line(_x,_y,_radius,_angle,0.04,0.02,0.22,0.02,5,_dark);
    sc_visual_line(_x,_y,_radius,_angle,0.04,-0.02,0.22,-0.02,2,_metal);
    sc_visual_line(_x,_y,_radius,_angle,0.04,0.02,0.22,0.02,2,_metal);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the Warwing's large rear thruster.
function sc_enemy_rebel_warwing_thruster_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _pulse=0.9+sin(current_time*0.02)*0.1;
    var _metal=make_colour_rgb(88,76,62);

    draw_set_alpha(_alpha);

    // Engine housing.
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.19,_metal,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.14,make_colour_rgb(52,48,44),false);

    // Flame.
    gpu_set_blendmode(bm_add);
    sc_visual_triangle(
        _x,_y,_radius,_angle,
        -0.72*_pulse,0,
        -0.12,0.14*_pulse,
        -0.12,-0.14*_pulse,
        make_colour_rgb(255,170,60),
        false
    );
    sc_visual_triangle(
        _x,_y,_radius,_angle,
        -0.5*_pulse,0,
        -0.06,0.08*_pulse,
        -0.06,-0.08*_pulse,
        make_colour_rgb(255,235,180),
        false
    );
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Rebel Warwing death hook.
function sc_enemy_rebel_warwing_death(_enemy)
{
    return true;
}

/// @description Draws the Warwing central body fragment.
function sc_enemy_rebel_warwing_fragment_body_draw(_x,_y,_radius,_angle,_visual)
{
    var _body=make_colour_rgb(98,84,66);
    sc_visual_quad(_x,_y,_radius,_angle,0.56,-0.18,0.56,0.18,-0.52,0.22,-0.58,-0.22,_body);
    sc_visual_triangle(_x,_y,_radius,_angle,0.74,0,0.48,0.16,0.48,-0.16,make_colour_rgb(62,56,50),false);
}

/// @description Draws one Warwing wing fragment.
function sc_enemy_rebel_warwing_fragment_wing_draw(_x,_y,_radius,_angle,_visual)
{
    var _body=make_colour_rgb(120,104,82);
    sc_visual_quad(_x,_y,_radius,_angle,0.24,-0.22,0.02,-0.9,-0.28,-1.0,-0.08,-0.26,_body);
}