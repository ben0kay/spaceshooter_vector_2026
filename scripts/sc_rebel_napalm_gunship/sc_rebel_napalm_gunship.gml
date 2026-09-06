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
                    side: choose(-1, 1),
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
            { key: "engine_left", forward: -0.82, side: -0.25, angle: 180, scale: 0.78 },
            { key: "engine_right", forward: -0.82, side: 0.25, angle: 180, scale: 0.78 }
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

/// @description Draws the armoured hull, thin wings and exposed napalm tank.
function sc_enemy_rebel_napalm_gunship_body_draw(_x,_y,_r,_a,_v)
{
    var _p=_v.palette;

    // Long central hull.
    sc_visual_triangle(_x,_y,_r,_a,1.15,0,0.42,-0.27,-0.9,-0.25,_p.hull_dark,false);
    sc_visual_triangle(_x,_y,_r,_a,1.15,0,-0.9,0.25,0.42,0.27,_p.hull_mid,false);

    // Genuinely thin wing spars.
    for (var _side=-1; _side<=1; _side+=2)
    {
        sc_visual_quad(_x,_y,_r,_a,
            0.2,0.2*_side,
            -0.18,0.58*_side,
            -0.72,0.63*_side,
            -0.48,0.52*_side,
            _p.hull_dark
        );

        sc_visual_quad(_x,_y,_r,_a,
            0.15,0.22*_side,
            -0.2,0.52*_side,
            -0.65,0.57*_side,
            -0.46,0.49*_side,
            _side<0?_p.hull_light:_p.hull_mid
        );

        sc_visual_line(_x,_y,_r,_a,0.15,0.22*_side,-0.2,0.52*_side,2,_p.outline);
        sc_visual_line(_x,_y,_r,_a,-0.2,0.52*_side,-0.65,0.57*_side,2,_p.energy);
    }

    // Raised forward armour.
    sc_visual_triangle(_x,_y,_r,_a,1.12,0,0.5,-0.19,-0.1,-0.18,_p.hull_light,false);
    sc_visual_triangle(_x,_y,_r,_a,1.12,0,-0.1,0.18,0.5,0.19,_p.metal,false);

    // Large exposed cylindrical napalm canister.
    sc_visual_quad(_x,_y,_r,_a,-0.03,-0.19,-0.76,-0.19,-0.76,0.19,-0.03,0.19,_p.accent);
    sc_visual_circle(_x,_y,_r,_a,-0.05,0,0.19,_p.energy,false);
    sc_visual_circle(_x,_y,_r,_a,-0.74,0,0.19,_p.glow,false);

    // Canister securing straps.
    for (var _i=0; _i<3; ++_i)
    {
        var _forward=-0.17-_i*0.23;
        sc_visual_line(_x,_y,_r,_a,_forward,-0.21,_forward,0.21,4,_p.void);
        sc_visual_line(_x,_y,_r,_a,_forward,-0.2,_forward,0.2,2,_p.metal);
    }

    // Hazard bands.
    for (var _i=0; _i<4; ++_i)
    {
        var _forward=-0.12-_i*0.13;
        sc_visual_line(_x,_y,_r,_a,_forward,-0.16,_forward-0.1,0.16,3,_p.void);
    }

    // Pipes leading toward the projector.
    sc_visual_line(_x,_y,_r,_a,-0.62,-0.23,0.38,-0.23,6,_p.void);
    sc_visual_line(_x,_y,_r,_a,-0.62,-0.23,0.38,-0.23,2,_p.metal);
    sc_visual_line(_x,_y,_r,_a,-0.58,0.23,0.3,0.23,5,_p.void);
    sc_visual_line(_x,_y,_r,_a,-0.58,0.23,0.3,0.23,2,_p.energy);

    // Rear engine blocks.
    sc_visual_quad(_x,_y,_r,_a,-0.62,-0.35,-1.02,-0.31,-1.02,-0.12,-0.62,-0.16,_p.hull_dark);
    sc_visual_quad(_x,_y,_r,_a,-0.62,0.16,-1.02,0.12,-1.02,0.31,-0.62,0.35,_p.hull_dark);

    // Cockpit and targeting slit.
    sc_visual_quad(_x,_y,_r,_a,0.58,-0.13,0.9,-0.06,1.02,0,0.58,0,_p.void);
    sc_visual_quad(_x,_y,_r,_a,0.58,0,1.02,0,0.9,0.06,0.58,0.13,_p.void);
    sc_visual_line(_x,_y,_r,_a,0.64,0,0.96,0,3,_p.energy);

    // Central projector mounting plate.
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.2,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,0.4,0,0.16,_p.metal,true);
}

/// @description Draws the limited-arc Rebel Napalm Projector.
function sc_enemy_rebel_napalm_projector_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p=_v.palette;
    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_r,_a,-0.1,0,0.2,_p.void,false);
    sc_visual_circle(_x,_y,_r,_a,-0.1,0,0.17,_p.hull_mid,false);
    sc_visual_circle(_x,_y,_r,_a,-0.1,0,0.17,_p.metal,true);

    sc_visual_quad(_x,_y,_r,_a,-0.05,-0.14,0.34,-0.12,0.46,-0.08,0.46,0.08,_p.hull_dark);
    sc_visual_quad(_x,_y,_r,_a,-0.05,-0.14,0.46,0.08,-0.05,0.14,-0.2,0,_p.hull_mid);

    sc_visual_line(_x,_y,_r,_a,0.08,0,0.55,0,9,_p.void);
    sc_visual_line(_x,_y,_r,_a,0.12,0,0.54,0,5,_p.metal);
    sc_visual_circle(_x,_y,_r,_a,0.54,0,0.1,_p.energy,false);

    draw_set_alpha(1);
}

/// @description Draws the Napalm Gunship's pressure valve core.
function sc_enemy_rebel_napalm_gunship_core_draw(_x,_y,_r,_a,_v,_alpha)
{
    var _p=_v.palette;

    draw_set_alpha(_alpha*0.25);
    draw_set_colour(_p.glow);
    draw_circle(_x,_y,_r*0.32,false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x,_y,_r*0.23,false);

    draw_set_colour(_p.metal);
    draw_circle(_x,_y,_r*0.23,true);
    draw_set_colour(_p.energy);
    draw_circle(_x,_y,_r*0.1,false);
    draw_set_colour(_p.core);
    draw_circle(_x,_y,_r*0.04,false);

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

    array_push(_fragments,sc_death_fragment_data(_cache.fragments[0],_x+lengthdir_x(_r*0.48,_a),_y+lengthdir_y(_r*0.48,_a),_a+random_range(-10,10),random_range(2.5,4),_a,choose(-7,7),1));
    array_push(_fragments,sc_death_fragment_data(_cache.fragments[1],_x+lengthdir_x(-_r*0.18,_a)+lengthdir_x(-_r*0.5,_a+90),_y+lengthdir_y(-_r*0.18,_a)+lengthdir_y(-_r*0.5,_a+90),_a-50,random_range(3,4.5),_a,-9,1));
    array_push(_fragments,sc_death_fragment_data(_cache.fragments[2],_x+lengthdir_x(-_r*0.18,_a)+lengthdir_x(_r*0.5,_a+90),_y+lengthdir_y(-_r*0.18,_a)+lengthdir_y(_r*0.5,_a+90),_a+50,random_range(3,4.5),_a,9,1));
    array_push(_fragments,sc_death_fragment_data(_cache.core,_x+lengthdir_x(-_r*0.38,_a),_y+lengthdir_y(-_r*0.38,_a),random(360),random_range(2,3),_a,choose(-11,11),0.9));

    for (var _i=0; _i<array_length(_data.hardpoints); ++_i)
    {
        var _hardpoint=_data.hardpoints[_i];
        var _hx=_x+lengthdir_x(_hardpoint.forward*_r,_a)+lengthdir_x(_hardpoint.side*_r,_a+90);
        var _hy=_y+lengthdir_y(_hardpoint.forward*_r,_a)+lengthdir_y(_hardpoint.side*_r,_a+90);

        array_push(_fragments,sc_death_fragment_data(
            _cache.hardpoints[_i],_hx,_hy,random(360),
            random_range(3,5),_a,random_range(-12,12),0.9
        ));
    }

    sc_death_fragment_create(_x,_y,_fragments,_visual.palette.core,_visual.palette.glow,_r,44);
    return true;
}

function sc_enemy_rebel_napalm_fragment_front_draw(_x,_y,_r,_a,_v)
{
    sc_visual_triangle(_x,_y,_r,_a,1.14,0,0.05,-0.25,0.05,0.25,_v.palette.hull_light,false);
    sc_visual_line(_x,_y,_r,_a,1.14,0,0.05,-0.25,2,_v.palette.outline);
    sc_visual_line(_x,_y,_r,_a,1.14,0,0.05,0.25,2,_v.palette.outline);
}

function sc_enemy_rebel_napalm_fragment_left_draw(_x,_y,_r,_a,_v)
{
    sc_visual_quad(_x,_y,_r,_a,0.2,-0.2,-0.18,-0.58,-0.72,-0.63,-0.48,-0.52,_v.palette.hull_mid);
}

function sc_enemy_rebel_napalm_fragment_right_draw(_x,_y,_r,_a,_v)
{
    sc_visual_quad(_x,_y,_r,_a,0.2,0.2,-0.48,0.52,-0.72,0.63,-0.18,0.58,_v.palette.metal);
}