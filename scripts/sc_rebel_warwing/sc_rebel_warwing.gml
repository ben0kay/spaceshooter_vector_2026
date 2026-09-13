/*
REBEL WARWING

A wide, scrappy Veteran Superheavy Rebel missile-fighter.
- 2 nose miniguns
- 2 wing missile launcher hardpoints
- each launcher fires a 6-rocket salvo
- total 12 rockets per missile attack
- 1 huge rear thruster
*/

/// @description Registers the Rebel Salvo Rocket weapon.
function sc_weapon_register_rebel_salvo_rocket()
{
    return sc_weapon_register({
        identity:{
            key:"weapon_rebel_salvo_rocket",
            name:"Rebel Salvo Rocket"
        },

        delivery:{
            type:AttackDelivery.PROJECTILE,
            projectile_key:"projectile_rebel_salvo_rocket",

            projectile:{
                scale:1,
                speed:14,
                life:135
            },

            damage:{
                amount:4,
                type:DamageType.EXPLOSIVE,
                effect:DamageEffect.NONE
            },

            guidance:{
                enabled:true,
                strength:0.5,
                turn_speed:1.7,
                acquire_range:760,
                forget_range:1100,
                avoid_asteroids:true,
                avoid_structures:true
            },

            detonation:{
                enabled:true,
                radius:52,
                damage:5,
                type:DamageType.EXPLOSIVE,
                falloff:0.45
            }
        },

        audio:{
            sound:noone,
            volume:0.6,
            pitch_range:0.05
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
                    weight:100,
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

                    shot:{
                        pattern:ShotPattern.RANDOM_CONE,
                        amount:6,
                        angle_total:30,
                        projectile_interval:4
                    },

                    firing:{
                        order:HardpointFireOrder.ALL,
                        volley_max:1,
                        cooldown:190
                    }
                }
            ]
        }
    });
}

/// @description Returns the Rebel Warwing visual definition.
function sc_enemy_rebel_warwing_visual_data()
{
    return {
        radius:132,
        motion_strength:1.7,
        palette:sc_faction_palette_get(Faction.REBEL),

        core:{
            forward:0,
            side:0
        },

        draw:{
            body:sc_enemy_rebel_warwing_body_draw,
            core:sc_enemy_rebel_warwing_core_draw
        },

        damage_layers:{
            enabled:true,
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
            body_canvas_size:640,
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

/// @description Draws the Warwing hull.
function sc_enemy_rebel_warwing_hull_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p=_visual.palette;
    var _hull_dark=make_colour_rgb(64,55,44);
    var _hull_mid=make_colour_rgb(104,90,70);
    var _hull_light=make_colour_rgb(154,135,104);
    var _metal=make_colour_rgb(86,78,70);
    var _hazard=make_colour_rgb(180,138,44);
    var _glass=make_colour_rgb(44,44,46);

    // ==================================================
    // CENTRAL FUSELAGE
    // ==================================================
    sc_visual_quad(_x,_y,_radius,_angle,0.92,-0.18,0.92,0.18,-0.78,0.22,-0.82,-0.22,_hull_mid);
    sc_visual_quad(_x,_y,_radius,_angle,0.72,-0.14,0.72,0.14,-0.56,0.17,-0.62,-0.17,_hull_dark);

    // Nose / cockpit shell.
    sc_visual_triangle(_x,_y,_radius,_angle,1.04,0,0.72,0.2,0.72,-0.2,_hull_mid,false);
    sc_visual_quad(_x,_y,_radius,_angle,0.86,-0.16,0.88,0.16,0.62,0.12,0.62,-0.12,_glass);

    // Tail body.
    sc_visual_quad(_x,_y,_radius,_angle,-0.78,-0.12,-0.78,0.12,-1.04,0.14,-1.04,-0.14,_hull_dark);

    // Tail fins.
    for (var _s=-1;_s<=1;_s+=2)
    {
        sc_visual_triangle(_x,_y,_radius,_angle,-0.88,0.14*_s,-0.72,0.56*_s,-1.08,0.4*_s,_hull_mid,false);
        sc_visual_triangle(_x,_y,_radius,_angle,-0.98,0.08*_s,-0.96,0.42*_s,-1.14,0.26*_s,_hull_light,false);
    }

    // ==================================================
    // BIPLANE WINGS
    // ==================================================
    for (var _s=-1;_s<=1;_s+=2)
    {
        // Wing root.
        sc_visual_quad(_x,_y,_radius,_angle,0.36,0.22*_s,0.26,0.98*_s,-0.04,1.28*_s,-0.18,0.28*_s,_hull_dark);

        // Main long outer wing.
        sc_visual_quad(_x,_y,_radius,_angle,0.3,0.9*_s,0.06,1.62*_s,-0.28,1.74*_s,-0.18,0.98*_s,_hull_mid);

        // Front bevel.
        sc_visual_triangle(_x,_y,_radius,_angle,0.36,0.88*_s,0.3,1.34*_s,-0.02,1.5*_s,_hull_light,false);

        // Outer tip cap.
        sc_visual_triangle(_x,_y,_radius,_angle,-0.04,1.58*_s,-0.22,1.84*_s,-0.34,1.66*_s,_hull_light,false);

        // Wing strut.
        sc_visual_line(_x,_y,_radius,_angle,0.22,0.44*_s,-0.1,1.42*_s,10,_metal);
        sc_visual_line(_x,_y,_radius,_angle,0.22,0.44*_s,-0.1,1.42*_s,3,make_colour_rgb(52,47,42));

        // External tank.
        sc_visual_quad(_x,_y,_radius,_angle,-0.06,0.54*_s,0.14,0.56*_s,0.16,0.82*_s,-0.1,0.8*_s,_metal);
        sc_visual_circle(_x,_y,_radius,_angle,-0.1,0.67*_s,0.11,_metal,false);
        sc_visual_circle(_x,_y,_radius,_angle,0.16,0.69*_s,0.11,_metal,false);

        // Pipe feed.
        sc_visual_line(_x,_y,_radius,_angle,0.1,0.52*_s,0.22,0.34*_s,5,make_colour_rgb(74,64,56));
        sc_visual_line(_x,_y,_radius,_angle,0.16,0.82*_s,0.2,1.0*_s,4,make_colour_rgb(74,64,56));

        // Missile pylon mount area.
        sc_visual_quad(_x,_y,_radius,_angle,0.08,0.94*_s,0.24,0.96*_s,0.22,1.14*_s,0.04,1.12*_s,_hull_dark);

        // Hazard stripe block.
        sc_visual_quad(_x,_y,_radius,_angle,0.02,1.1*_s,-0.08,1.38*_s,-0.18,1.4*_s,-0.08,1.12*_s,_hazard);
    }

    // Riveted spine / central module.
    sc_visual_circle(_x,_y,_radius,_angle,0.02,0,0.18,_metal,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.02,0,0.11,make_colour_rgb(60,54,48),true);

    if (_stage>=1)
    {
        sc_visual_circle(_x,_y,_radius,_angle,-0.1,0.72,0.1,make_colour_rgb(44,38,34),false);
        sc_visual_circle(_x,_y,_radius,_angle,-0.1,-0.72,0.1,make_colour_rgb(44,38,34),false);
    }

    if (_stage>=2)
    {
        sc_visual_line(_x,_y,_radius,_angle,0.22,0.96,-0.08,1.5,5,make_colour_rgb(42,38,34));
        sc_visual_line(_x,_y,_radius,_angle,0.22,-0.96,-0.08,-1.5,5,make_colour_rgb(42,38,34));
    }

    if (_stage>=3)
    {
        sc_visual_circle(_x,_y,_radius,_angle,-0.92,0,0.11,make_colour_rgb(42,36,32),false);
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

/// @description Draws one Rebel wing missile launcher.
function sc_enemy_rebel_warwing_launcher_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _body=make_colour_rgb(86,74,62);
    var _plate=make_colour_rgb(132,114,88);
    var _dark=make_colour_rgb(48,42,38);
    var _ring=make_colour_rgb(170,152,124);

    draw_set_alpha(_alpha);

    // Rear pivot.
    sc_visual_circle(_x,_y,_radius,_angle,-0.06,0,0.1,_dark,false);
    sc_visual_circle(_x,_y,_radius,_angle,-0.06,0,0.075,_body,true);

    // Main launcher pod.
    sc_visual_quad(_x,_y,_radius,_angle,-0.02,-0.18,0.22,-0.16,0.22,0.16,-0.02,0.18,_body);
    sc_visual_quad(_x,_y,_radius,_angle,0.0,-0.15,0.18,-0.135,0.18,0.135,0.0,0.15,_plate);

    // Six launch tubes (2 x 3).
    for (var _row=-1;_row<=1;_row+=2)
    for (var _col=0;_col<3;_col++)
    {
        var _fx=0.18;
        var _sy=-0.09+_col*0.09;
        var _oy=_row*0.045;

        sc_visual_circle(_x,_y,_radius,_angle,_fx,_sy+_oy,0.026,_dark,false);
        sc_visual_circle(_x,_y,_radius,_angle,_fx,_sy+_oy,0.015,make_colour_rgb(24,24,24),false);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
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