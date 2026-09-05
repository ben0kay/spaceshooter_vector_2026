/*
REBEL FLYBY GUNSHIP

A fast battered gunship with four fully rotating deck miniguns,
two fixed forward guns and repeated attack runs past the player.
*/

/// @description Registers the Rebel Flyby Gunship.
function sc_enemy_register_rebel_gunship()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_rebel_gunship",
            name: "Rebel Flyby Gunship",
            faction: Faction.REBEL
        },

        reward: { credits: 55 },

        stats_base: {
            shield_max: 0,
            armour_max: 280,
            hull_max: 130,

            handling: {
                speed_max: 7.2,
                acceleration: 0.24,
                friction_coeff: 0.987,
                turn_speed: 3.2,
                directional: true,
                directional_speed_min: 0.32,
                directional_thrust_min: 0.44
            },

            range: {
                detection: 1400,
                combat: 1050,
                retreat: 0,
                forget: 2100,
                wander: 480,
                alert_share: 1200
            },

            damage_multiplier: 1,
            fire_rate_multiplier: 1
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.AVOID,
            idle_script: sc_enemy_movement_wander,
            chase_script: sc_enemy_movement_flyby,
            combat_script: sc_enemy_movement_flyby,
			
			runtime: {
		        flyby: {
		            active: false,
		            destination_x: 0,
		            destination_y: 0,
		            side: 0,
		            next_run_tick: 0
		        }
			},

            facing: {
                default_mode: EnemyFacingMode.MOVEMENT,
                retreat_mode: EnemyFacingMode.MOVEMENT,
                angle_offset: 0,
                turn_speed_scale: 1,
                spin_speed: 0
            },

            orbit: {
                range: 0,
                direction: 0,
                radial_strength: 0,
                direction_change_chance: 0
            },

            strafe: {
                amount: 0,
                speed: 0
            },

            flyby: {
                offset_min: 190,
                offset_max: 330,
                exit_distance: 760,
                arrival_radius: 90,
                turnaround_delay: 25,
                speed_scale: 1,
                alternate_side: true
            }
        },

        visual: sc_enemy_rebel_gunship_visual_data(),

        collision: {
            radius_forward_scale: 1.05,
            radius_side_scale: 0.78,
            blocks_player: true
        },

        hardpoints: [
            {
                key: "turret_front_left", group: "turrets",
                forward: 0.35, side: -0.47, angle: 0, muzzle_forward: 0.47,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.2, arc: 360, return_to_rest: true },
                draw_script: sc_enemy_rebel_gunship_minigun_draw
            },
            {
                key: "turret_front_right", group: "turrets",
                forward: 0.35, side: 0.47, angle: 0, muzzle_forward: 0.47,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4.2, arc: 360, return_to_rest: true },
                draw_script: sc_enemy_rebel_gunship_minigun_draw
            },
            {
                key: "turret_rear_left", group: "turrets",
                forward: -0.33, side: -0.43, angle: 0, muzzle_forward: 0.47,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4, arc: 360, return_to_rest: true },
                draw_script: sc_enemy_rebel_gunship_minigun_draw
            },
            {
                key: "turret_rear_right", group: "turrets",
                forward: -0.33, side: 0.43, angle: 0, muzzle_forward: 0.47,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 4, arc: 360, return_to_rest: true },
                draw_script: sc_enemy_rebel_gunship_minigun_draw
            },
            {
                key: "fixed_left", group: "forward_guns",
                forward: 0.75, side: -0.18, angle: 0, muzzle_forward: 0.48,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_rebel_gunship_forward_gun_draw
            },
            {
                key: "fixed_right", group: "forward_guns",
                forward: 0.75, side: 0.18, angle: 0, muzzle_forward: 0.48,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_rebel_gunship_forward_gun_draw
            }
        ],

        thrusters: [
            { key: "engine_left", forward: -0.94, side: -0.35, angle: 180, scale: 0.92 },
            { key: "engine_centre", forward: -1.02, side: 0, angle: 180, scale: 1.08 },
            { key: "engine_right", forward: -0.94, side: 0.35, angle: 180, scale: 0.92 }
        ],

        attack_controller: {
            selection: AttackSelection.WEIGHTED,

            attacks: [
                {
                    key: "deck_miniguns",
                    weight: 76,
                    hardpoint_group: "turrets",
                    weapon_key: "weapon_rebel_minigun",

                    conditions: {
                        line_of_sight: true,
                        range_min: 120,
                        range_max: 1050
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 4,
                        fire_tolerance: 10
                    },

                    shot: {
                        pattern: ShotPattern.RANDOM_CONE,
                        amount: 1,
                        angle_total: 5
                    },

                    firing: {
                        order: HardpointFireOrder.RANDOM,
                        interval: 3,
                        volley_max: 24,
                        cooldown: 65
                    }
                },
                {
                    key: "forward_strafe",
                    weight: 24,
                    hardpoint_group: "forward_guns",
                    weapon_key: "weapon_rebel_minigun",

                    conditions: {
                        line_of_sight: true,
                        range_min: 160,
                        range_max: 900
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 2,
                        fire_tolerance: 8
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 4,
                        volley_max: 8,
                        cooldown: 90
                    }
                }
            ]
        }
    });
}

/// @description Returns the complete Rebel Flyby Gunship visual definition.
function sc_enemy_rebel_gunship_visual_data()
{
    return {
        radius: 70,
        visual_mass: 1.25,
        motion_strength: 2.2,
        palette: sc_faction_palette_get(Faction.REBEL),
        core: { forward: -0.48, side: 0 },

        draw: {
            body: sc_enemy_rebel_gunship_body_draw,
            core: sc_enemy_rebel_gunship_core_draw
        },

        death: {
            script: sc_enemy_rebel_gunship_death,
            draw_scripts: [
                sc_enemy_rebel_gunship_fragment_front_draw,
                sc_enemy_rebel_gunship_fragment_left_draw,
                sc_enemy_rebel_gunship_fragment_right_draw
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

/// @description Draws the battered modular Rebel gunship hull.
function sc_enemy_rebel_gunship_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    // Uneven industrial silhouette.
    sc_visual_quad(_x,_y,_radius,_angle, 1.03,-0.22, 0.66,-0.58, -0.62,-0.68, -0.94,-0.28, _p.hull_dark);
    sc_visual_quad(_x,_y,_radius,_angle, 1.03,0.22, 0.56,0.62, -0.69,0.57, -1.02,0.24, _p.hull_dark);
    sc_visual_quad(_x,_y,_radius,_angle, 0.82,-0.31, 0.82,0.31, -0.91,0.31, -0.91,-0.31, _p.hull_mid);

    // Central raised armour and cockpit.
    sc_visual_quad(_x,_y,_radius,_angle, 0.68,-0.24, 0.87,0, 0.68,0.24, -0.18,0.27, _p.hull_light);
    sc_visual_quad(_x,_y,_radius,_angle, 0.55,-0.16, 0.76,0, 0.55,0.16, 0.08,0.18, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, 0.56,-0.12, 0.72,0, 2, _p.energy);
    sc_visual_line(_x,_y,_radius,_angle, 0.72,0, 0.56,0.12, 2, _p.energy);

    // Asymmetric patchwork plates.
    sc_visual_quad(_x,_y,_radius,_angle, 0.42,-0.51, -0.05,-0.58, -0.18,-0.28, 0.29,-0.25, _p.metal);
    sc_visual_quad(_x,_y,_radius,_angle, 0.27,0.29, -0.28,0.27, -0.47,0.52, 0.15,0.55, _p.hull_light);
    sc_visual_quad(_x,_y,_radius,_angle, -0.28,-0.27, -0.75,-0.31, -0.68,-0.57, -0.17,-0.59, _p.hull_mid);
    sc_visual_quad(_x,_y,_radius,_angle, -0.46,0.25, -0.87,0.22, -0.76,0.48, -0.37,0.5, _p.metal);

    // Plate seams and exposed framework.
    sc_visual_line(_x,_y,_radius,_angle, 0.45,-0.56, 0.22,-0.27, 2, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, -0.09,-0.57, -0.19,-0.28, 2, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, 0.13,0.54, -0.01,0.27, 2, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, -0.48,0.49, -0.39,0.26, 2, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, -0.83,-0.17, 0.5,-0.17, 3, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, -0.83,0.17, 0.5,0.17, 3, _p.void);

    // Orange conduits.
    sc_visual_line(_x,_y,_radius,_angle, -0.72,-0.38, -0.09,-0.38, 5, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, -0.7,-0.38, -0.1,-0.38, 2, _p.accent);
    sc_visual_line(_x,_y,_radius,_angle, -0.61,0.37, 0.18,0.37, 5, _p.void);
    sc_visual_line(_x,_y,_radius,_angle, -0.59,0.37, 0.16,0.37, 2, _p.energy);

    // Hazard bars.
    for (var _i = 0; _i < 4; _i++)
    {
        var _f = -0.18 + _i * 0.12;
        sc_visual_line(_x,_y,_radius,_angle, _f,-0.6, _f + 0.1,-0.46, 3, _p.energy);
    }

    // Engine blocks.
    for (var _side = -1; _side <= 1; _side++)
    {
        sc_visual_quad(_x,_y,_radius,_angle, -0.66,-0.12 + _side*0.27, -1.03,-0.11 + _side*0.31, -1.03,0.11 + _side*0.31, -0.66,0.12 + _side*0.27, _p.hull_dark);
        sc_visual_line(_x,_y,_radius,_angle, -0.72,_side*0.3, -1.02,_side*0.31, 4, _p.energy);
    }

    // Outer silhouette.
    sc_visual_line(_x,_y,_radius,_angle, 1.03,-0.22, 0.66,-0.58, 2, _p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 0.66,-0.58, -0.62,-0.68, 2, _p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 1.03,0.22, 0.56,0.62, 2, _p.outline);
    sc_visual_line(_x,_y,_radius,_angle, 0.56,0.62, -0.69,0.57, 2, _p.outline);
}

/// @description Draws one fully rotating deck-mounted Rebel minigun.
function sc_enemy_rebel_gunship_minigun_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_radius,_angle, -0.08,0,0.2,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle, -0.08,0,0.2,_p.metal,true);
    sc_visual_quad(_x,_y,_radius,_angle, -0.06,-0.14, 0.28,-0.11, 0.28,0.11, -0.06,0.14,_p.hull_mid);

    for (var _side = -1; _side <= 1; _side += 2)
        sc_visual_line(_x,_y,_radius,_angle, 0.12,0.055*_side, 0.48,0.055*_side, 3,_p.metal);

    sc_visual_line(_x,_y,_radius,_angle, 0.05,0,0.51,0,2,_p.void);
    sc_visual_circle(_x,_y,_radius,_angle, -0.08,0,0.07,_p.energy,false);

    draw_set_alpha(1);
}

/// @description Draws one fixed forward Rebel gun.
function sc_enemy_rebel_gunship_forward_gun_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    draw_set_alpha(_alpha);

    sc_visual_quad(_x,_y,_radius,_angle, -0.22,-0.1, 0.39,-0.07, 0.39,0.07, -0.22,0.1,_p.hull_dark);
    sc_visual_line(_x,_y,_radius,_angle, -0.1,0,0.51,0,4,_p.metal);
    sc_visual_line(_x,_y,_radius,_angle, 0.12,0,0.52,0,2,_p.energy);

    draw_set_alpha(1);
}

/// @description Draws the rear mechanical Rebel reactor.
function sc_enemy_rebel_gunship_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha * 0.25);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_radius*0.34,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_radius*0.24,false);

    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_radius*0.24,true);

    for (var _i = 0; _i < 6; _i++)
    {
        var _direction = _angle + _i*60;
        draw_line_width(
            _x + lengthdir_x(_radius*0.08,_direction),
            _y + lengthdir_y(_radius*0.08,_direction),
            _x + lengthdir_x(_radius*0.2,_direction+18),
            _y + lengthdir_y(_radius*0.2,_direction+18),
            2
        );
    }

    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_radius*0.09,false);
    draw_set_colour(_p.core);
    draw_circle(_x,_y,_radius*0.035,false);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one dirty orange Rebel engine flame.
function sc_enemy_rebel_thrust_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha*0.28);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.25, 0.9,0, 0,0.25,_p.glow,false);

    draw_set_alpha(_alpha*0.75);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.16, 0.68,0, 0,0.16,_p.energy,false);

    draw_set_alpha(_alpha);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.065, 0.43,0, 0,0.065,_p.core,false);

    draw_set_alpha(1);
}

/// @description Creates the Rebel Gunship destruction visual.
function sc_enemy_rebel_gunship_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _x = _enemy.x;
    var _y = _enemy.y;
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _fragments = [];

    array_push(_fragments, sc_death_fragment_data(_cache.fragments[0],_x+lengthdir_x(_radius*0.45,_angle),_y+lengthdir_y(_radius*0.45,_angle),_angle+random_range(-12,12),random_range(2.5,4),_angle,choose(-7,7),1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[1],_x+lengthdir_x(-_radius*0.15,_angle)+lengthdir_x(-_radius*0.4,_angle+90),_y+lengthdir_y(-_radius*0.15,_angle)+lengthdir_y(-_radius*0.4,_angle+90),_angle-55,random_range(3,4.5),_angle,-9,1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[2],_x+lengthdir_x(-_radius*0.15,_angle)+lengthdir_x(_radius*0.4,_angle+90),_y+lengthdir_y(-_radius*0.15,_angle)+lengthdir_y(_radius*0.4,_angle+90),_angle+55,random_range(3,4.5),_angle,9,1));
    array_push(_fragments, sc_death_fragment_data(_cache.core,_x,_y,random(360),random_range(1.5,2.5),_angle,choose(-10,10),0.9));

    for (var _i=0; _i<array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hx = _x+lengthdir_x(_hardpoint.forward*_radius,_angle)+lengthdir_x(_hardpoint.side*_radius,_angle+90);
        var _hy = _y+lengthdir_y(_hardpoint.forward*_radius,_angle)+lengthdir_y(_hardpoint.side*_radius,_angle+90);
        array_push(_fragments,sc_death_fragment_data(_cache.hardpoints[_i],_hx,_hy,random(360),random_range(3,5),_angle,random_range(-12,12),0.9));
    }

    sc_death_fragment_create(_x,_y,_fragments,_visual.palette.core,_visual.palette.glow,_radius,42);
    return true;
}

function sc_enemy_rebel_gunship_fragment_front_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,1.02,0,0.08,-0.34,0.08,0.34,_v.palette.hull_light,false);
    sc_visual_line(_x,_y,_r,_a,1.02,0,0.08,-0.34,2,_v.palette.outline);
    sc_visual_line(_x,_y,_r,_a,1.02,0,0.08,0.34,2,_v.palette.outline);
}

function sc_enemy_rebel_gunship_fragment_left_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,0.15,-0.2,-0.64,-0.68,-0.95,-0.27,_v.palette.hull_mid,false);
    sc_visual_line(_x,_y,_r,_a,0.15,-0.2,-0.64,-0.68,2,_v.palette.metal);
}

function sc_enemy_rebel_gunship_fragment_right_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,0.15,0.2,-0.95,0.24,-0.69,0.57,_v.palette.metal,false);
    sc_visual_line(_x,_y,_r,_a,0.15,0.2,-0.69,0.57,2,_v.palette.outline);
}