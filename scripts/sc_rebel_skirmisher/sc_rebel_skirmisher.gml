/*
REBEL SCRAP SKIRMISHER

A narrow lightly armoured Rebel fighter with thin salvaged wings,
one oversized engine and paired forward kinetic slug cannons.
*/

/// @description Registers the Rebel Scrap Skirmisher.
function sc_enemy_register_rebel_skirmisher()
{
    return sc_enemy_register({
        identity: {
            key: "e_rebel_skirmisher",
            name: "Rebel Scrap Skirmisher",
            faction: Faction.REBEL,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.LIGHT,
            rank: EnemyRank.COMMON,
            threat_value: 2
        },

        reward: { credits: 12 },

        stats_base: {
            shield_max: 0,
            armour_max: 60,
            hull_max: 42,
            mass: 0.7,

            handling: {
                speed_max: 5.6,
                acceleration: 0.26,
                friction_coeff: 0.982,
                turn_speed: 4,
                directional: true,
                directional_speed_min: 0.5,
                directional_thrust_min: 0.58
            },

            range: {
                detection: 1100,
                combat: 760,
                backaway: 160,
                forget: 1550,
                wander: 340,
                alert_share: 900
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_movement_erratic_skirmish,
            combat_script: sc_enemy_movement_erratic_skirmish,

            runtime: {
                erratic: {
                    angle_offset: 0,
                    speed_scale: 1,
                    next_change_tick: 0
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

            erratic: {
                angle_min: 10,
                angle_max: 32,
                speed_min: 0.62,
                speed_max: 0.92,
                change_min: 24,
                change_max: 55
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 480,
            arrival_radius: 75,
            search_duration: 150,
            speed_scale: 0.72
        },

        visual: sc_enemy_rebel_skirmisher_visual_data(),

        collision: {
            radius_forward_scale: 1.08,
            radius_side_scale: 0.72,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "slug_left",
                group: "slug_cannons",
                forward: 0.48,
                side: -0.24,
                angle: 0,
                muzzle_forward: 0.58,
                draw_script: sc_enemy_rebel_skirmisher_cannon_draw
            },
            {
                key: "slug_right",
                group: "slug_cannons",
                forward: 0.48,
                side: 0.24,
                angle: 0,
                muzzle_forward: 0.58,
                draw_script: sc_enemy_rebel_skirmisher_cannon_draw
            }
        ],

        thrusters: [
            {
                key: "engine_centre",
                forward: -1.03,
                side: 0,
                angle: 180,
                scale: 0.94
            }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "twin_scrap_cannons",
                    weight: 100,
                    hardpoint_group: "slug_cannons",
                    weapon_key: "weapon_rebel_slug_cannon",

                    conditions: {
                        line_of_sight: true,
                        range_min: 140,
                        range_max: 760
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 5,
                        fire_tolerance: 11
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.SEQUENTIAL,
                        interval: 8,
                        volley_max: 6,
                        cooldown: 75
                    }
                }
            ]
        }
    });
}

/// @description Returns the Rebel Scrap Skirmisher visual definition.
function sc_enemy_rebel_skirmisher_visual_data()
{
    return {
        radius: 48,
        motion_strength: 2.7,
        palette: sc_faction_palette_get(Faction.REBEL),
        core: { forward: -0.72, side: 0 },

        draw: {
            body: sc_enemy_rebel_skirmisher_body_draw,
            core: sc_enemy_rebel_skirmisher_core_draw
        },

        death: {
            script: sc_enemy_rebel_skirmisher_death,

            draw_scripts: [
                sc_enemy_rebel_skirmisher_fragment_front_draw,
                sc_enemy_rebel_skirmisher_fragment_left_draw,
                sc_enemy_rebel_skirmisher_fragment_right_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_rebel_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 192,
            core_canvas_size: 96,
            hardpoint_canvas_size: 96,
            thrust_canvas_size: 96,
            fragment_canvas_size: 128
        }
    };
}

/// @description Draws the detailed patchwork Rebel Scrap Skirmisher.
function sc_enemy_rebel_skirmisher_body_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    // ==================================================
    // EXPOSED CENTRAL FRAME
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        0.98,-0.13,
        -0.94,-0.16,
        -1.06,0.16,
        0.98,0.13,
        _p.void
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.87,-0.085,
        -0.91,-0.1,
        -0.91,0.1,
        0.87,0.085,
        _p.steel_dark
    );

    // Structural rails.
    sc_rebel_visual_brace(_x,_y,_r,_a,-0.76,-0.13,0.58,-0.11,_p);
    sc_rebel_visual_brace(_x,_y,_r,_a,-0.76,0.13,0.58,0.11,_p);

    // ==================================================
    // SHORT AIRCRAFT-LIKE WINGS
    // ==================================================

    for (var _side=-1; _side<=1; _side+=2)
    {
        // Dark wing frame.
        sc_visual_quad(_x,_y,_r,_a,
            0.34,0.14*_side,
            0.03,0.25*_side,
            -0.3,0.48*_side,
            -0.62,0.4*_side,
            _p.void
        );

        sc_rebel_visual_brace(_x,_y,_r,_a,0.27,0.15*_side,-0.49,0.38*_side,_p);

        // Main salvaged wing plate.
        sc_rebel_visual_patch_plate(_x,_y,_r,_a,
            0.3,0.16*_side,
            0.02,0.27*_side,
            -0.28,0.44*_side,
            -0.55,0.37*_side,
            _side<0?_p.hull_light:_p.paint,
            _p
        );

        // Outer cap plate.
        sc_rebel_visual_patch_plate(_x,_y,_r,_a,
            -0.24,0.43*_side,
            -0.42,0.51*_side,
            -0.64,0.43*_side,
            -0.53,0.34*_side,
            _p.hull_dark,_p
        );

        // Small middle patch.
        sc_rebel_visual_patch_plate(_x,_y,_r,_a,
            0.02,0.26*_side,
            -0.17,0.36*_side,
            -0.31,0.32*_side,
            -0.11,0.22*_side,
            _p.steel_mid,_p
        );

        // Vent in outer wing.
        sc_rebel_visual_vent(_x,_y,_r,_a,-0.36,0.4*_side,0.15,0.026,3,_p);

        if (_side<0)
            sc_rebel_visual_hazard_panel(_x,_y,_r,_a,-0.39,-0.39,0.18,0.055,_p);
        else
            sc_rebel_visual_patch_x(_x,_y,_r,_a,-0.22,0.31,0.025,_p);
    }

    // ==================================================
    // CENTRAL FUSELAGE PLATES
    // ==================================================

    // Lower dark shape.
    sc_visual_triangle(_x,_y,_r,_a,
        1.24,0,
        0.38,-0.19,
        0.38,0.19,
        _p.void,false
    );

    // Left forward armour.
    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        1.2,0,
        0.46,-0.16,
        -0.26,-0.17,
        0.17,-0.04,
        _p.hull_light,_p
    );

    // Right forward armour.
    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        1.2,0,
        0.17,0.04,
        -0.26,0.17,
        0.46,0.16,
        _p.paint,_p
    );

    // Middle mismatched panels.
    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        0.37,-0.05,
        -0.08,-0.16,
        -0.36,-0.14,
        0.05,-0.02,
        _p.hull_mid,_p
    );

    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        0.05,0.02,
        -0.36,0.14,
        -0.08,0.16,
        0.37,0.05,
        _p.steel_mid,_p
    );

    // ==================================================
    // COCKPIT
    // ==================================================

    sc_visual_quad(_x,_y,_r,_a,
        0.83,-0.085,
        0.61,-0.13,
        0.48,-0.075,
        0.71,-0.025,
        _p.void
    );

    sc_visual_quad(_x,_y,_r,_a,
        0.71,0.025,
        0.48,0.075,
        0.61,0.13,
        0.83,0.085,
        _p.void
    );

    sc_visual_line(_x,_y,_r,_a,0.64,-0.11,0.58,-0.04,1,_p.steel_light);
    sc_visual_line(_x,_y,_r,_a,0.58,0.04,0.64,0.11,1,_p.steel_light);

    sc_rebel_visual_slit_light(_x,_y,_r,_a,0.75,-0.043,0.86,-0.018,_p);
    sc_rebel_visual_slit_light(_x,_y,_r,_a,0.86,0.018,0.75,0.043,_p);

    // ==================================================
    // REAR ENGINE BLOCK
    // ==================================================

    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        -0.5,-0.21,
        -1.05,-0.18,
        -1.09,0,
        -0.58,0,
        _p.steel_mid,_p
    );

    sc_rebel_visual_patch_plate(_x,_y,_r,_a,
        -0.58,0,
        -1.09,0,
        -1.05,0.18,
        -0.5,0.21,
        _p.steel_dark,_p
    );

    sc_rebel_visual_vent(_x,_y,_r,_a,-0.79,-0.1,0.25,0.032,3,_p);
    sc_rebel_visual_vent(_x,_y,_r,_a,-0.79,0.1,0.25,0.032,3,_p);

    // Engine frame braces.
    sc_rebel_visual_brace(_x,_y,_r,_a,-0.57,-0.18,-0.94,-0.15,_p);
    sc_rebel_visual_brace(_x,_y,_r,_a,-0.57,0.18,-0.94,0.15,_p);

    // ==================================================
    // EXPOSED PIPEWORK
    // ==================================================

    sc_rebel_visual_pipe(_x,_y,_r,_a,-0.61,-0.2,0.25,-0.18,3,_p);
    sc_rebel_visual_pipe_hot(_x,_y,_r,_a,-0.55,0.2,0.08,0.18,3,_p);

    // Small crossover hose.
    sc_rebel_visual_pipe(_x,_y,_r,_a,-0.36,-0.12,-0.22,0.12,2,_p);

    // ==================================================
    // PANEL DETAIL
    // ==================================================

    sc_rebel_visual_panel_seam(_x,_y,_r,_a,0.28,-0.15,0.16,-0.03,_p);
    sc_rebel_visual_panel_seam(_x,_y,_r,_a,0.16,0.03,0.29,0.15,_p);

    sc_rebel_visual_panel_seam(_x,_y,_r,_a,-0.13,-0.15,-0.11,-0.02,_p);
    sc_rebel_visual_panel_seam(_x,_y,_r,_a,-0.11,0.02,-0.18,0.15,_p);

    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,0.14,-0.16,-0.08,-0.16,4,_p);
    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,-0.08,0.16,0.14,0.16,4,_p);

    sc_rebel_visual_patch_x(_x,_y,_r,_a,-0.19,-0.07,0.022,_p);

    sc_rebel_visual_chevrons(_x,_y,_r,_a,0.18,0.13,0.028,1,_p);

    // ==================================================
    // HARDPOINT BED DETAIL
    // ==================================================

    for (var _side=-1; _side<=1; _side+=2)
    {
        sc_visual_circle(_x,_y,_r,_a,0.48,0.24*_side,0.12,_p.void,false);
        sc_visual_circle(_x,_y,_r,_a,0.48,0.24*_side,0.095,_p.steel_dark,false);
        sc_visual_circle(_x,_y,_r,_a,0.48,0.24*_side,0.095,_p.steel_light,true);

        sc_rebel_visual_rivet_strip(
            _x,_y,_r,_a,
            0.36,0.19*_side,
            0.58,0.19*_side,
            3,_p
        );
    }

    // ==================================================
    // NOSE DETAILS
    // ==================================================

    sc_rebel_visual_slit_light(_x,_y,_r,_a,0.93,-0.045,1.07,-0.015,_p);
    sc_rebel_visual_slit_light(_x,_y,_r,_a,1.07,0.015,0.93,0.045,_p);

    sc_rebel_visual_rivet_strip(_x,_y,_r,_a,0.5,-0.145,0.82,-0.085,4,_p);
}

/// @description Draws one fixed Rebel scrap cannon.
function sc_enemy_rebel_skirmisher_cannon_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p = _visual.palette;
    draw_set_alpha(_alpha);

    sc_visual_quad(_x,_y,_radius,_angle,-0.22,-0.13,0.26,-0.1,0.26,0.1,-0.22,0.13,_p.hull_dark);
    sc_visual_quad(_x,_y,_radius,_angle,-0.16,-0.09,0.18,-0.07,0.18,0.07,-0.16,0.09,_p.hull_mid);
    sc_visual_line(_x,_y,_radius,_angle,0.08,0,0.56,0,6,_p.void);
    sc_visual_line(_x,_y,_radius,_angle,0.12,0,0.55,0,3,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle,-0.12,-0.1,-0.02,0.1,2,_p.energy);

    draw_set_alpha(1);
}

/// @description Draws the Skirmisher's exposed rear engine core.
function sc_enemy_rebel_skirmisher_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha*0.25);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_radius*0.34,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_radius*0.24,false);

    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_radius*0.24,true);

    for (var _i=0; _i<4; ++_i)
    {
        var _direction=_angle+_i*90;
        draw_line_width(
            _x+lengthdir_x(_radius*0.1,_direction),
            _y+lengthdir_y(_radius*0.1,_direction),
            _x+lengthdir_x(_radius*0.21,_direction),
            _y+lengthdir_y(_radius*0.21,_direction),
            2
        );
    }

    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_radius*0.1,false);
    draw_set_colour(_p.core);
    draw_circle(_x,_y,_radius*0.04,false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Rebel Scrap Skirmisher destruction visual.
function sc_enemy_rebel_skirmisher_death(_enemy)
{
    var _data=_enemy.enemy;
    var _visual=_data.visual;
    var _cache=sc_enemy_visual_cache_get(_data.key);
    var _x=_enemy.x;
    var _y=_enemy.y;
    var _angle=_enemy.draw_angle;
    var _radius=_visual.radius;
    var _fragments=[];

    array_push(_fragments,sc_death_fragment_data(_cache.fragments[0],_x+lengthdir_x(_radius*0.48,_angle),_y+lengthdir_y(_radius*0.48,_angle),_angle+random_range(-10,10),random_range(2.5,4),_angle,choose(-8,8),1));
    array_push(_fragments,sc_death_fragment_data(_cache.fragments[1],_x+lengthdir_x(-_radius*0.12,_angle)+lengthdir_x(-_radius*0.34,_angle+90),_y+lengthdir_y(-_radius*0.12,_angle)+lengthdir_y(-_radius*0.34,_angle+90),_angle-48,random_range(3,4.5),_angle,-10,1));
    array_push(_fragments,sc_death_fragment_data(_cache.fragments[2],_x+lengthdir_x(-_radius*0.12,_angle)+lengthdir_x(_radius*0.34,_angle+90),_y+lengthdir_y(-_radius*0.12,_angle)+lengthdir_y(_radius*0.34,_angle+90),_angle+48,random_range(3,4.5),_angle,10,1));
    array_push(_fragments,sc_death_fragment_data(_cache.core,_x+lengthdir_x(-_radius*0.72,_angle),_y+lengthdir_y(-_radius*0.72,_angle),random(360),random_range(2,3),_angle,choose(-12,12),0.9));

    for (var _i=0; _i<array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint=_data.hardpoints[_i];
        var _hx=_x+lengthdir_x(_hardpoint.forward*_radius,_angle)+lengthdir_x(_hardpoint.side*_radius,_angle+90);
        var _hy=_y+lengthdir_y(_hardpoint.forward*_radius,_angle)+lengthdir_y(_hardpoint.side*_radius,_angle+90);

        array_push(_fragments,sc_death_fragment_data(
            _cache.hardpoints[_i],_hx,_hy,random(360),
            random_range(3,5),_angle,random_range(-12,12),0.9
        ));
    }

    sc_death_fragment_create(_x,_y,_fragments,_visual.palette.core,_visual.palette.glow,_radius,34);
    return true;
}

function sc_enemy_rebel_skirmisher_fragment_front_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,1.3,0,0.05,-0.16,0.05,0.16,_v.palette.hull_light,false);
    sc_visual_line(_x,_y,_r,_a,1.3,0,0.05,-0.16,2,_v.palette.outline);
    sc_visual_line(_x,_y,_r,_a,1.3,0,0.05,0.16,2,_v.palette.outline);
}

function sc_enemy_rebel_skirmisher_fragment_left_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,0.34,-0.16,-0.18,-0.55,-0.72,-0.48,_v.palette.hull_mid,false);
    sc_visual_line(_x,_y,_r,_a,0.34,-0.16,-0.18,-0.55,2,_v.palette.outline);
}

function sc_enemy_rebel_skirmisher_fragment_right_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,0.34,0.16,-0.72,0.48,-0.18,0.55,_v.palette.metal,false);
    sc_visual_line(_x,_y,_r,_a,0.34,0.16,-0.18,0.55,2,_v.palette.outline);
}