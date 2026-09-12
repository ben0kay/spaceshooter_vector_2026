/*
SIMULANT NEXUS

Massive rotating Simulant champion capital ship.

WEAPONS
- 4 fixed diagonal Super Beam emitters.
- 8 fixed dividing-orb emitters, two per cardinal module.
- 1 central Seeker Core emitter.

ATTACK CHANNELS
- main_weapons:
    diagonal beams OR dividing orbs.
- core:
    independent Seeker Core attack.

The entire vessel slowly rotates constantly.
No conventional rear thrusters.
*/

/// @description Registers the Nexus's expanding purple fire shockwave.
function sc_weapon_register_sim_nexus_shockwave()
{
    var _p = sc_faction_palette_get(Faction.SIMULANT);

    return sc_weapon_register({
        identity: {
            key: "weapon_sim_nexus_shockwave",
            name: "Nexus Fire Shockwave"
        },

        delivery: {
            type: AttackDelivery.AREA,
            scale: 1,

            damage: {
                amount: 42,
                type: DamageType.ENERGY,
                effect: DamageEffect.STAGGER,
                knockback_force: 13
            },

            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 950
                },

                behaviour: {
                    duration: 72,
                    tick_interval: 1,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 1,
                    falloff_exponent: 1,

                    expanding_ring: {
                        enabled: true,
                        start_radius: 285,
                        thickness: 105
                    },

                    occlusion: {
                        asteroids: false
                    }
                },

                visual: {
                    palette: _p,
                    draw_script: sc_attack_area_sim_nexus_shockwave_draw,
                    particles_register_script: sc_particles_sim_nexus_shockwave_register,
                    particle_script: sc_particles_sim_nexus_shockwave_emit,

                    // Broad secondary glow beneath the true damaging fire ring.
                    shockwave: {
                        radius_scale: 1,
                        expansion_response: 0.055,
                        fade_speed: 0.014,
                        thickness: 8,
                        colour: _p.energy,

                        particles_enabled: true,
                        particle_interval: 2,
                        particle_min_radius: 285,

                        smoke_enabled: true,
                        smoke_amount_max: 12,
                        smoke_colour: merge_colour(_p.glow,c_black,0.55),

                        fragments_enabled: true,
                        fragment_chance: 0.65,
                        fragment_colour: _p.core
                    }
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.9,
            pitch_range: 0.04
        }
    });
}

function sc_weapon_register_sim_nexus_seeker_core()
{
    return sc_weapon_register({
        identity: {
            key: "weapon_sim_nexus_seeker_core",
            name: "Simulant Nexus Seeker Core"
        },

        delivery: {
            type: AttackDelivery.PROJECTILE,
            projectile_key: "projectile_simulant_seeker_core",

            projectile: {
                scale: 1.6,
                speed: 11,
                life: 250
            },

            damage: {
                amount: 20,
                type: DamageType.ENERGY,
                effect: DamageEffect.NONE
            },

            guidance: {
			    acquire_range: 1500,
			    turn_speed: 1.65,
			    reacquire_interval: 8,
			    lead_strength: 0,
			    guidance_delay: 0,
			    lock_angle: 360,
			    avoidance: 0
			},

            detonation: {
                scale: 1.15,

                damage: {
                    amount: 28,
                    type: DamageType.ENERGY,
                    effect: DamageEffect.STAGGER,
                    effect_chance: 1,
                    effect_duration: 18,
                    effect_strength: 0.55,
                    knockback_force: 4
                }
            }
        },

        audio: {
            sound: noone,
            volume: 0.8,
            pitch_range: 0.04
        }
    });
}

/// @description Registers the original Nexus ring particles plus larger interior fire-smoke.
function sc_particles_sim_nexus_shockwave_register()
{
    var _p = sc_faction_palette_get(Faction.SIMULANT);
    var _flame = sc_particles_type_create();
    var _wisp = sc_particles_type_create();
    var _interior = sc_particles_type_create();

    if (!part_type_exists(_flame)
    || !part_type_exists(_wisp)
    || !part_type_exists(_interior))
        return false;

    // Original smaller flames travelling around the damage edge.
    part_type_sprite(_flame,s_broad_flame_body_white,false,false,false);
    part_type_size(_flame,0.1,0.2,-0.004,0.015);
    part_type_colour3(_flame,_p.core,_p.energy,_p.glow);
    part_type_alpha3(_flame,0.85,0.55,0);
    part_type_blend(_flame,true);
    part_type_speed(_flame,1.5,4,-0.05,0);
    part_type_direction(_flame,0,359,0,0);
    part_type_orientation(_flame,-10,10,0,3,true);
    part_type_life(_flame,14,25);

    // Much larger, denser purple smoke filling the expanding area.
    part_type_sprite(_wisp,s_particle_smokey_wisp_001,false,false,true);
    part_type_size(_wisp,0.21,0.42,0.008,0.026);
    part_type_colour3(_wisp,_p.core,_p.energy,_p.glow);
    part_type_alpha3(_wisp,0.4,0.24,0);
    part_type_blend(_wisp,true);
    part_type_speed(_wisp,0.6,1.8,-0.03,0);
    part_type_direction(_wisp,0,359,0,0);
    part_type_orientation(_wisp,0,359,0,2,false);
    part_type_life(_wisp,20,36);

    // Broad flames filling the area behind the damage edge.
    part_type_sprite(_interior,s_broad_flame_body_white,false,false,false);
    part_type_size(_interior,0.15,0.3,0.006,0.022);
    part_type_scale(_interior,1.1,0.85);
    part_type_colour3(_interior,_p.core,_p.energy,_p.glow);
    part_type_alpha3(_interior,0.48,0.28,0);
    part_type_blend(_interior,true);
    part_type_speed(_interior,2.5,6,-0.06,0);
    part_type_direction(_interior,0,359,0,0);
    part_type_orientation(_interior,-14,14,0,3,true);
    part_type_life(_interior,22,38);

    return sc_particles_group_register("sim_nexus_shockwave",{
        flame: _flame,
        wisp: _wisp,
        interior: _interior
    });
}

/// @description Keeps the original ring particles and densely fills its interior with fire-smoke.
function sc_particles_sim_nexus_shockwave_emit(_area,_data)
{
    if ((GAME_TICK mod 2) != 0) return true;

    var _types = sc_particles_group_get("sim_nexus_shockwave");
    var _radius = _data.runtime.ring_radius;
    var _thickness = _data.behaviour.expanding_ring.thickness;
    var _edge_amount = clamp(ceil(_radius/115),4,10);
    var _fill_amount = clamp(ceil(_radius/100),4,11);
    var _fill_radius = max(1,_radius-_thickness*0.3);

    // Original flame particles and larger smoke around the damage edge.
    for (var _i = 0; _i < _edge_amount; _i++)
    {
        var _angle = random(360);
        var _spread = random_range(-_thickness*0.35,_thickness*0.35);
        var _x = _area.x+lengthdir_x(_radius+_spread,_angle);
        var _y = _area.y+lengthdir_y(_radius+_spread,_angle);

        part_type_direction(_types.flame,_angle-16,_angle+16,0,0);
        part_particles_create(
            global.particles.impact_system,
            _x,_y,_types.flame,1
        );

        if (irandom(1) == 0)
        {
            part_type_direction(_types.wisp,_angle-45,_angle+45,0,0);
            part_particles_create(
                global.particles.impact_system,
                _x,_y,_types.wisp,3
            );
        }
    }

    // Additional flames and much denser smoke throughout the interior.
    for (var _i = 0; _i < _fill_amount; _i++)
    {
        var _angle = random(360);
        var _distance = sqrt(random(1))*_fill_radius;
        var _x = _area.x+lengthdir_x(_distance,_angle);
        var _y = _area.y+lengthdir_y(_distance,_angle);

        part_type_direction(_types.interior,_angle-30,_angle+30,0,0);
        part_particles_create(
            global.particles.impact_system,
            _x,_y,_types.interior,1
        );

        if (irandom(1) == 0)
        {
            part_type_direction(_types.wisp,_angle-65,_angle+65,0,0);
            part_particles_create(
                global.particles.impact_system,
                _x,_y,_types.wisp,3
            );
        }
    }

    return true;
}

/// @description Draws the Nexus's true travelling purple damage ring.
function sc_attack_area_sim_nexus_shockwave_draw(_area,_data)
{
    var _p = _data.visual.palette;
    var _radius = _data.runtime.ring_radius;
    var _thickness = _data.behaviour.expanding_ring.thickness;
    var _life_ratio = _data.runtime.life/_data.behaviour.duration;
    var _alpha = clamp(_life_ratio*2.5,0,1);
    var _pulse = 0.92+sin(GAME_TICK*0.65)*0.08;

    gpu_set_blendmode(bm_add);

    sc_visual_ellipse_outline(
        _area.x,_area.y,
        _radius+_thickness*0.55,
        _radius+_thickness*0.55,
        0,64,
        _thickness*0.55,
        _p.glow,
        _alpha*0.12
    );

    sc_visual_ellipse_outline(
        _area.x,_area.y,
        _radius,_radius,
        0,64,
        _thickness*0.28,
        _p.accent,
        _alpha*0.4
    );

    sc_visual_ellipse_outline(
        _area.x,_area.y,
        _radius,_radius,
        0,64,
        max(3,_thickness*0.09*_pulse),
        _p.energy,
        _alpha*0.95
    );

    sc_visual_ellipse_outline(
        _area.x,_area.y,
        _radius,_radius,
        0,64,
        2,
        _p.core,
        _alpha
    );

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates one fixed Nexus dividing-orb hardpoint.
function sc_enemy_sim_nexus_orb_hardpoint(_key,_forward,_side,_angle)
{
    return {
        key: _key,
        group: "orb_batteries",
        forward: _forward,
        side: _side,
        angle: _angle,
        muzzle_forward: 0.18,

        rotation: {
            mode: HardpointRotation.FIXED,
            turn_speed: 0,
            arc: 0,
            return_to_rest: true
        },

        draw_script: sc_enemy_sim_nexus_orb_emitter_draw
    };
}

/// @description Registers the Simulant Nexus champion capital ship.
function sc_enemy_register_sim_nexus()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_nexus",
            name: "Simulant Nexus",
            faction: Faction.SIMULANT,
            role: EnemyRole.FIGHTER,
            ship_class: EnemyClass.CAPITAL,
            rank: EnemyRank.CHAMPION,
            threat_value: 125
        },

        reward: {
            credits: 1100
        },

        stats_base: {
            shield_max: 350,
            armour_max: 2200,
            hull_max: 1500,
            mass: 10,

            handling: {
                speed_max: 0.58,
                acceleration: 0.018,
                friction_coeff: 0.994,
                turn_speed: 0.22,
                directional: false,
                directional_speed_min: 0.1,
                directional_thrust_min: 0.15
            },

            range: {
                detection: 2300,
                combat: 2200,
                backaway: 850,
                forget: 3200,
                wander: 0,
                alert_share: 2600
            },

            damage_multiplier: 1.15,
            fire_rate_multiplier: 0.82
        },

        movement_controller: {
            asteroid_response: AsteroidResponse.BOMBARD,

            idle_script: sc_enemy_movement_hold,
            chase_script: sc_enemy_movement_chase,
            combat_script: sc_enemy_movement_hold_line_of_sight,

            facing: {
                default_mode: EnemyFacingMode.SPIN,
                backaway_mode: EnemyFacingMode.SPIN,
                angle_offset: 0,
                turn_speed_scale: 1,
                spin_speed: 0.16
            },

            strafe: {
                amount: 0,
                speed: 0
            }
        },

        awareness_controller: {
            unseen_damage_script: sc_enemy_awareness_investigate,
            alert_receive_script: sc_enemy_awareness_investigate,
            duration: 900,
            arrival_radius: 220,
            search_duration: 300,
            speed_scale: 0.42
        },

        visual: sc_enemy_sim_nexus_visual_data(),

        collision: {
            radius_forward_scale: 0.94,
            radius_side_scale: 0.94,
            blocks_player: true
        },

        hardpoints: [
		    // ==================================================
		    // DIAGONAL SUPER BEAMS
		    // ==================================================
		{
		    key: "beam_ne",
		    group: "diagonal_beams",
		    forward: 0.62,
		    side: 0.62,
		    angle: 45,
		    muzzle_forward: 0.2,

		    rotation: {
		        mode: HardpointRotation.FIXED,
		        turn_speed: 0,
		        arc: 0,
		        return_to_rest: true
		    },

		    draw_script: sc_enemy_sim_nexus_beam_emitter_draw
		},

		{
		    key: "beam_nw",
		    group: "diagonal_beams",
		    forward: -0.62,
		    side: 0.62,
		    angle: 135,
		    muzzle_forward: 0.2,

		    rotation: {
		        mode: HardpointRotation.FIXED,
		        turn_speed: 0,
		        arc: 0,
		        return_to_rest: true
		    },

		    draw_script: sc_enemy_sim_nexus_beam_emitter_draw
		},

		{
		    key: "beam_sw",
		    group: "diagonal_beams",
		    forward: -0.62,
		    side: -0.62,
		    angle: 225,
		    muzzle_forward: 0.2,

		    rotation: {
		        mode: HardpointRotation.FIXED,
		        turn_speed: 0,
		        arc: 0,
		        return_to_rest: true
		    },

		    draw_script: sc_enemy_sim_nexus_beam_emitter_draw
		},

		{
		    key: "beam_se",
		    group: "diagonal_beams",
		    forward: 0.62,
		    side: -0.62,
		    angle: 315,
		    muzzle_forward: 0.2,

		    rotation: {
		        mode: HardpointRotation.FIXED,
		        turn_speed: 0,
		        arc: 0,
		        return_to_rest: true
		    },

		    draw_script: sc_enemy_sim_nexus_beam_emitter_draw
		},

            // ==================================================
            // THREE-WAY EAST ORB BATTERY
            // ==================================================
            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_east_lower",
                0.78,-0.14,
                330
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_east_centre",
                0.8,0,
                0
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_east_upper",
                0.78,0.14,
                30
            ),

            // ==================================================
            // THREE-WAY NORTH ORB BATTERY
            // ==================================================
            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_north_right",
                -0.14,-0.78,
                240
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_north_centre",
                0,-0.8,
                270
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_north_left",
                0.14,-0.78,
                300
            ),

            // ==================================================
            // THREE-WAY WEST ORB BATTERY
            // ==================================================
            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_west_lower",
                -0.78,-0.14,
                210
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_west_centre",
                -0.8,0,
                180
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_west_upper",
                -0.78,0.14,
                150
            ),

            // ==================================================
            // THREE-WAY SOUTH ORB BATTERY
            // ==================================================
            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_south_left",
                -0.14,0.78,
                120
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_south_centre",
                0,0.8,
                90
            ),

            sc_enemy_sim_nexus_orb_hardpoint(
                "orb_south_right",
                0.14,0.78,
                60
            ),

    // ==================================================
    // CENTRAL SEEKER CORE
    // ==================================================
    {
        key: "core_weapon",
        group: "core_weapon",
        forward: 0,
        side: 0,
        angle: 0,
        muzzle_forward: 0,

        rotation: {
            mode: HardpointRotation.FIXED,
            turn_speed: 0,
            arc: 0,
            return_to_rest: true
        },

        draw_script: sc_enemy_sim_nexus_core_emitter_draw
    }
],

        // Distributed/internal propulsion. No visible rear thruster bank.
        thrusters: [],

                attack_controller: {
            selection: AttackSelection.WEIGHTED,
            max_active_channels: 3,

            channels: [
                {
                    key: "beams",
                    selection: AttackSelection.WEIGHTED
                },
                {
                    key: "orbs",
                    selection: AttackSelection.WEIGHTED
                },
                {
                    key: "core",
                    selection: AttackSelection.WEIGHTED
                }
            ],

            attacks: [
                // ==================================================
                // FOUR-WAY DIAGONAL BEAM BARRAGE
                // ==================================================
                {
                    key: "nexus_diagonal_beams",
                    channel: "beams",
                    weight: 48,
                    hardpoint_group: "diagonal_beams",
                    weapon_key: "weapon_simulant_super_beam",

                    conditions: {
                        line_of_sight: true,
                        range_min: 350,
                        range_max: 2250
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 0,

                        // Fixed radial weapons intentionally do not aim at target.
                        fire_tolerance: 360
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 95,
                        aim_lock_remaining: 0,
                        track_during_active: true,
                        scale: 0.2,
                        particle_interval: 1,
                        draw_script: sc_enemy_sim_nexus_beam_telegraph_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        duration: 125,
                        cooldown: 400
                    }
                },

                // ==================================================
                // EIGHT-WAY DIVIDING ORB BARRAGE
                // ==================================================
                {
                    key: "nexus_dividing_orbs",
                    channel: "orbs",
                    weight: 52,
                    hardpoint_group: "orb_batteries",
                    weapon_key: "weapon_simulant_dividing_orb",

                    conditions: {
                        line_of_sight: true,
                        range_min: 250,
                        range_max: 1900
                    },

                    aim: {
                        mode: AimMode.MOUNT,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 360
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 46,
                        aim_lock_remaining: 0,
                        track_during_active: true,
                        scale: 0.18,
                        particle_interval: 2,
                        draw_script: sc_enemy_sim_nexus_orb_telegraph_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 30,
                        volley_max: 3,
                        cooldown: 260
                    }
                },

                // ==================================================
                // INDEPENDENT CENTRAL SEEKER CORE
                // ==================================================
                {
                    key: "nexus_core_launch",
                    channel: "core",
                    weight: 100,
                    hardpoint_group: "core_weapon",
                    weapon_key: "weapon_sim_nexus_seeker_core",

                    conditions: {
                        line_of_sight: true,
                        range_min: 720,
                        range_max: 2500
                    },

                    aim: {
                        mode: AimMode.TARGET,
                        angle_offset: 0,
                        inaccuracy: 0,
                        fire_tolerance: 360
                    },

                    shot: {
                        pattern: ShotPattern.SINGLE,
                        amount: 1
                    },

                    telegraph: {
                        duration: 88,
                        aim_lock_remaining: 0,
                        track_during_active: true,
                        scale: 0.7,
                        particle_interval: 1,

                        // Existing collapsing Simulant seeker-core telegraph.
                        draw_script: sc_enemy_sim_dreadwing_seeker_telegraph_draw,
                        particle_script: sc_particles_attack_telegraph_emit
                    },

                    firing: {
                        order: HardpointFireOrder.ALL,
                        interval: 0,
                        volley_max: 1,
                        cooldown: 360
                    }
                },
				
				{
				    key: "nexus_core_shockwave",
				    channel: "core",
				    weight: 160,
				    hardpoint_group: "core_weapon",
				    weapon_key: "weapon_sim_nexus_shockwave",

				    conditions: {
				        asteroid_target: false,
				        range_min: 0,
				        range_max: 720
				    },

				    aim: {
				        mode: AimMode.MOUNT,
				        angle_offset: 0,
				        inaccuracy: 0,
				        fire_tolerance: 360
				    },

				    shot: {
				        pattern: ShotPattern.SINGLE,
				        amount: 1
				    },

				    // Intentionally instantaneous: the travelling ring is the warning.
				    firing: {
				        order: HardpointFireOrder.ALL,
				        interval: 0,
				        volley_max: 1,
				        cooldown: 420
				    }
				}
            ]
        }
    });
}

/// @description Returns the Nexus's complete visual definition.
function sc_enemy_sim_nexus_visual_data()
{
    return {
        radius: 300,
        motion_strength: 0.65,
        palette: sc_faction_palette_get(Faction.SIMULANT),

        core: {
            forward: 0,
            side: 0
        },

        draw: {
            body: sc_enemy_sim_nexus_body_draw,
            core: sc_enemy_sim_nexus_core_draw
        },

        damage_layers: {
            enabled: true,
            damage_stages: 4,
            hull_draw_script: sc_enemy_sim_nexus_hull_draw,
            armour_draw_script: sc_enemy_sim_nexus_armour_draw
        },

        death: {
            script: sc_enemy_sim_nexus_death,

            draw_scripts: [
                sc_enemy_sim_nexus_fragment_centre_draw,
                sc_enemy_sim_nexus_fragment_arm_draw,
                sc_enemy_sim_nexus_fragment_module_draw
            ]
        },
			
		thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 768,
            core_canvas_size: 320,
            hardpoint_canvas_size: 256,
            thrust_canvas_size: 128,
            fragment_canvas_size: 512
        }
    };
}

/// @description Draws the complete intact Nexus fallback body.
function sc_enemy_sim_nexus_body_draw(_x,_y,_radius,_angle,_visual)
{
    sc_enemy_sim_nexus_hull_draw(_x,_y,_radius,_angle,_visual,0);
    sc_enemy_sim_nexus_armour_draw(_x,_y,_radius,_angle,_visual,0);
}

/// @description Draws the permanent eight-point radial Nexus hull.
function sc_enemy_sim_nexus_hull_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p = _visual.palette;

    // Large circular mechanical foundation.
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.39,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.365,_p.hull_dark,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.335,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.29,_p.hull_mid,true);

    // Eight separated structural necks establish the radial silhouette.
    for (var _i = 0; _i < 8; _i++)
    {
        var _a = _angle+_i*45;

        sc_visual_quad(
            _x,_y,_radius,_a,
            0.25,-0.065,
            0.52,-0.09,
            0.52,0.09,
            0.25,0.065,
            _p.hull_dark
        );

        sc_sim_visual_energy_conduit(
            _x,_y,_radius,_a,
            0.23,0,
            0.55,0,
            3,_p
        );

        // Mechanical collars around every spoke.
        sc_visual_line(
            _x,_y,_radius,_a,
            0.32,-0.075,
            0.32,0.075,
            3,_p.metal
        );

        sc_visual_line(
            _x,_y,_radius,_a,
            0.43,-0.085,
            0.43,0.085,
            2,_p.hull_light
        );
    }

    // Four heavy cardinal weapon blades.
    for (var _i = 0; _i < 4; _i++)
        sc_enemy_sim_nexus_cardinal_module_draw(
            _x,_y,_radius,_angle+_i*90,_visual,_stage
        );

    // Four longer diagonal beam blades.
    for (var _i = 0; _i < 4; _i++)
        sc_enemy_sim_nexus_diagonal_arm_draw(
            _x,_y,_radius,_angle+45+_i*90,_visual,_stage
        );

    // Layered reactor machinery remains visibly circular.
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.245,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.218,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.18,_p.hull_dark,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.15,_p.accent,true);

    // Sixteen small radial reactor details.
    for (var _i = 0; _i < 16; _i++)
    {
        var _a = _angle+_i*22.5;

        sc_visual_line(
            _x,_y,_radius,_a,
            0.19,0,
            0.235,0,
            2,
            (_i mod 2) == 0 ? _p.energy : _p.metal
        );
    }

    if (_stage >= 1)
    {
        sc_visual_line(_x,_y,_radius,_angle,-0.18,-0.09,-0.31,-0.2,5,_p.void);
        sc_visual_line(_x,_y,_radius,_angle,-0.18,-0.09,-0.29,-0.18,2,_p.energy);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x,_y,_radius,_angle,0.32,0.12,0.07,_p.void,false);
        sc_visual_line(_x,_y,_radius,_angle,0.3,0.11,0.47,0.19,3,_p.accent);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x,_y,_radius,_angle,-0.24,0.25,0.1,_p.void,false);
        sc_visual_circle(_x,_y,_radius,_angle,0.18,-0.3,0.08,_p.void,false);
    }
}

/// @description Draws one thick pointed cardinal Nexus weapon blade.
function sc_enemy_sim_nexus_cardinal_module_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p = _visual.palette;

    // Narrow inner neck leaves obvious gaps between all eight arms.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.27,-0.09,
        0.48,-0.13,
        0.48,0.13,
        0.27,0.09,
        _p.hull_mid
    );

    // Split upper and lower hull plates form one thick pointed module.
    sc_sim_visual_blade_panel(
        _x,_y,_radius,_angle,
        0.38,-0.105,
        0.61,-0.22,
        1.04,-0.075,
        0.87,-0.025,
        _p.hull_dark,_p
    );

    sc_sim_visual_blade_panel(
        _x,_y,_radius,_angle,
        0.87,0.025,
        1.04,0.075,
        0.61,0.22,
        0.38,0.105,
        _p.hull_dark,_p
    );

    // Raised inner armour ridges.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.46,-0.075,
        0.7,-0.145,
        0.91,-0.065,
        0.62,-0.035,
        _p.hull_mid
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.62,0.035,
        0.91,0.065,
        0.7,0.145,
        0.46,0.075,
        _p.hull_mid
    );

    // Long central energy channel.
    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.3,0,
        0.96,0,
        5,_p
    );

    // Repeated armour seams and mechanical cross-braces.
    for (var _i = 0; _i < 3; _i++)
    {
        var _forward = 0.5+_i*0.15;
        var _width = 0.105-_i*0.017;

        sc_visual_line(
            _x,_y,_radius,_angle,
            _forward,-_width,
            _forward,_width,
            2,_p.metal
        );
    }

    // Side conduits leading toward the three orb mounts.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_sim_visual_energy_conduit(
            _x,_y,_radius,_angle,
            0.5,0.095*_side,
            0.8,0.13*_side,
            2,_p
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            0.72,0.115*_side,
            0.026,
            _p.energy,false
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            0.84,0.07*_side,
            0.018,
            _p.core,false
        );
    }

    // Jagged terminal cap rather than a broad square end.
    sc_visual_triangle(
        _x,_y,_radius,_angle,
        0.82,-0.055,
        1.075,0,
        0.82,0.055,
        _p.hull_light,false
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        0.84,0,
        1.035,0,
        3,_p.energy
    );

    if (_stage >= 2)
    {
        sc_visual_line(
            _x,_y,_radius,_angle,
            0.49,-0.14,
            0.66,-0.06,
            4,_p.void
        );
    }
}

/// @description Draws one long heavily layered diagonal Nexus beam blade.
function sc_enemy_sim_nexus_diagonal_arm_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p = _visual.palette;

    // Reinforced inner neck.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.27,-0.085,
        0.5,-0.125,
        0.56,0.125,
        0.27,0.085,
        _p.hull_mid
    );

    // Wide shoulders taper into a distinct long blade.
    sc_sim_visual_blade_panel(
        _x,_y,_radius,_angle,
        0.4,-0.09,
        0.63,-0.27,
        1.1,-0.045,
        0.69,-0.035,
        _p.hull_dark,_p
    );

    sc_sim_visual_blade_panel(
        _x,_y,_radius,_angle,
        0.69,0.035,
        1.1,0.045,
        0.63,0.27,
        0.4,0.09,
        _p.hull_dark,_p
    );

    // Layered swept armour makes the blade feel thick rather than flat.
    sc_sim_visual_swept_blade(
        _x,_y,_radius,_angle,
        0.57,-0.16,
        0.43,0.07,0.075,
        _p.hull_mid,_p,true
    );

    sc_sim_visual_swept_blade(
        _x,_y,_radius,_angle,
        0.57,0.16,
        0.43,0.07,0.075,
        _p.hull_mid,_p,true
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.51,-0.06,
        0.72,-0.105,
        0.94,-0.035,
        0.65,-0.025,
        _p.hull_light
    );

    sc_visual_quad(
        _x,_y,_radius,_angle,
        0.65,0.025,
        0.94,0.035,
        0.72,0.105,
        0.51,0.06,
        _p.hull_light
    );

    // Continuous beam-energy spine to the tip.
    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.28,0,
        1.055,0,
        5,_p
    );

    // Segmented plating and fine mechanical details.
    for (var _i = 0; _i < 4; _i++)
    {
        var _forward = 0.46+_i*0.135;
        var _width = 0.1-_i*0.013;

        sc_visual_line(
            _x,_y,_radius,_angle,
            _forward,-_width,
            _forward,_width,
            2,_p.metal
        );

        sc_visual_circle(
            _x,_y,_radius,_angle,
            _forward,0,
            0.012,
            _p.core,false
        );
    }

    // Beam emitter machinery around the existing hardpoint.
    sc_visual_circle(_x,_y,_radius,_angle,0.76,0,0.105,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.76,0,0.085,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0.76,0,0.045,_p.hull_mid,false);

    // Final needle-like tip.
    sc_visual_triangle(
        _x,_y,_radius,_angle,
        0.83,-0.045,
        1.12,0,
        0.83,0.045,
        _p.hull_light,false
    );

    sc_visual_line(
        _x,_y,_radius,_angle,
        0.85,0,
        1.085,0,
        3,_p.energy
    );

    if (_stage >= 1)
    {
        sc_visual_line(
            _x,_y,_radius,_angle,
            0.54,-0.12,
            0.72,-0.2,
            4,_p.void
        );
    }

    if (_stage >= 3)
    {
        sc_visual_circle(
            _x,_y,_radius,_angle,
            0.64,0.1,
            0.065,
            _p.void,false
        );
    }
}

/// @description Draws separated removable armour across all eight Nexus blades.
function sc_enemy_sim_nexus_armour_draw(_x,_y,_radius,_angle,_visual,_stage)
{
    var _p = _visual.palette;

    // Eight individual inner armour roots preserve the circular centre.
    if (_stage <= 2)
    {
        for (var _i = 0; _i < 8; _i++)
        {
            var _a = _angle+_i*45;

            sc_sim_visual_blade_panel(
                _x,_y,_radius,_a,
                0.16,-0.075,
                0.33,-0.135,
                0.45,-0.075,
                0.25,-0.035,
                _p.hull_light,_p
            );

            sc_sim_visual_blade_panel(
                _x,_y,_radius,_a,
                0.25,0.035,
                0.45,0.075,
                0.33,0.135,
                0.16,0.075,
                _p.hull_light,_p
            );
        }
    }

    // Cardinal outer armour stays narrow and pointed.
    if (_stage <= 1)
    {
        for (var _i = 0; _i < 4; _i++)
        {
            var _a = _angle+_i*90;

            sc_sim_visual_blade_panel(
                _x,_y,_radius,_a,
                0.48,-0.145,
                0.67,-0.19,
                0.98,-0.07,
                0.7,-0.055,
                _p.metal,_p
            );

            sc_sim_visual_blade_panel(
                _x,_y,_radius,_a,
                0.7,0.055,
                0.98,0.07,
                0.67,0.19,
                0.48,0.145,
                _p.metal,_p
            );
        }
    }

    // Diagonal armour caps create the four dominant corner blades.
    if (_stage == 0)
    {
        for (var _i = 0; _i < 4; _i++)
        {
            var _a = _angle+45+_i*90;

            sc_sim_visual_blade_panel(
                _x,_y,_radius,_a,
                0.56,-0.17,
                0.72,-0.235,
                1.075,-0.05,
                0.75,-0.075,
                _p.hull_light,_p
            );

            sc_sim_visual_blade_panel(
                _x,_y,_radius,_a,
                0.75,0.075,
                1.075,0.05,
                0.72,0.235,
                0.56,0.17,
                _p.hull_light,_p
            );
        }
    }
}

/// @description Draws the Nexus's massive central reactor.
function sc_enemy_sim_nexus_core_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    sc_sim_visual_reactor(
        _x,_y,_radius,_angle,
        {
            outer_scale: 0.19,
            middle_scale: 0.145,
            inner_scale: 0.072,

            socket_enabled: true,

            middle_colour: _p.hull_light,
            middle_filled: false,

            glow_alpha: 0.34,
            glow_scale: 1.85,

            secondary_glow_alpha: 0.13,
            secondary_glow_scale: 1.38,

            vane_amount: 8,
            vane_start: 0,
            vane_twist: 20,
            vane_inner_scale: 1,
            vane_outer_scale: 0.9,
            vane_width: 4,
            vane_secondary_colour: _p.accent,

            accent_scale: 1.6,
            accent_filled: false,

            core_scale: 0.46,
            additive: true
        },
        _p,
        _alpha
    );
}

/// @description Draws one fixed diagonal Nexus Super Beam emitter.
function sc_enemy_sim_nexus_beam_emitter_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.15,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.15,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.105,_p.hull_mid,false);

    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.02,-0.085,
        0.25,-0.055,
        0.25,0.055,
        -0.02,0.085,
        _p.hull_light
    );

    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.01,0,
        0.3,0,
        3,_p,_alpha
    );

    sc_visual_circle(_x,_y,_radius,_angle,0.3,0,0.075,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0.3,0,0.06,_p.accent,true);
    sc_visual_circle(_x,_y,_radius,_angle,0.3,0,0.027,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws one fixed Nexus dividing-orb emitter.
function sc_enemy_sim_nexus_orb_emitter_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    draw_set_alpha(_alpha);

    // Rear mounting socket.
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.12,_p.void,false);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.1,_p.metal,true);
    sc_visual_circle(_x,_y,_radius,_angle,0,0,0.067,_p.hull_mid,false);

    // Housing extends toward +forward / muzzle.
    sc_visual_quad(
        _x,_y,_radius,_angle,
        -0.04,-0.06,
        0.17,-0.048,
        0.17,0.048,
        -0.04,0.06,
        _p.hull_light
    );

    // Energy channel runs outward.
    sc_sim_visual_energy_conduit(
        _x,_y,_radius,_angle,
        0.01,0,
        0.19,0,
        2,_p,_alpha
    );

    // Muzzle at the forward end.
    sc_visual_circle(_x,_y,_radius,_angle,0.2,0,0.055,_p.accent,true);
    sc_visual_circle(_x,_y,_radius,_angle,0.2,0,0.025,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws the Nexus central Seeker Core emitter socket.
function sc_enemy_sim_nexus_core_emitter_draw(_x,_y,_radius,_angle,_visual,_alpha)
{
    var _p=_visual.palette;

    draw_set_alpha(_alpha);

    sc_sim_visual_energy_socket(
        _x,_y,_radius,_angle,
        0,0,
        0.16,
        _p,
        _alpha
    );

    draw_set_alpha(1);
}

/// @description Charges one Nexus diagonal beam muzzle.
function sc_enemy_sim_nexus_beam_telegraph_draw(_enemy,_attack,_transform,_progress,_palette,_config)
{
    var _charge=_progress*_progress*(3-2*_progress);
    var _pulse=0.88+sin(GAME_TICK*0.42)*0.12;
    var _r=lerp(5,26,_charge)*_pulse;
    var _direction=_transform.direction;

    gpu_set_blendmode(bm_add);

    draw_set_colour(_palette.glow);
    draw_set_alpha(0.12+0.28*_charge);
    draw_circle(_transform.x,_transform.y,_r*2.7,false);

    draw_set_colour(_palette.accent);
    draw_set_alpha(0.25+0.55*_charge);
    draw_circle(_transform.x,_transform.y,_r*1.45,false);

    draw_set_colour(_palette.energy);
    draw_set_alpha(0.45+0.5*_charge);
    draw_circle(_transform.x,_transform.y,_r,false);

    draw_set_colour(_palette.core);
    draw_set_alpha(_charge);
    draw_circle(_transform.x,_transform.y,max(2,_r*0.28),false);

    // Small energy packets collapse inward toward the muzzle.
    for (var _i=0;_i<4;_i++)
    {
        var _a=_direction+_i*90+GAME_TICK*2.5;
        var _distance=lerp(34,8,_charge);

        draw_set_colour(_palette.energy);
        draw_set_alpha(_charge*0.8);

        draw_circle(
            _transform.x+lengthdir_x(_distance,_a),
            _transform.y+lengthdir_y(_distance,_a),
            lerp(2,4,_charge),
            false
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Charges one Nexus dividing-orb emitter.
function sc_enemy_sim_nexus_orb_telegraph_draw(_enemy,_attack,_transform,_progress,_palette,_config)
{
    var _charge=_progress*_progress*(3-2*_progress);
    var _pulse=0.88+sin(GAME_TICK*0.5)*0.12;
    var _r=lerp(3,15,_charge)*_pulse;

    gpu_set_blendmode(bm_add);

    draw_set_colour(_palette.glow);
    draw_set_alpha(_charge*0.25);
    draw_circle(_transform.x,_transform.y,_r*2.4,false);

    draw_set_colour(_palette.energy);
    draw_set_alpha(_charge*0.75);
    draw_circle(_transform.x,_transform.y,_r,false);

    draw_set_colour(_palette.core);
    draw_set_alpha(_charge);
    draw_circle(_transform.x,_transform.y,max(2,_r*0.32),false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the Nexus capital-ship death effect.
function sc_enemy_sim_nexus_death(_enemy)
{
    var _data = _enemy.enemy;
    var _p = _data.visual.palette;
    var _r = _data.visual.radius;

    sc_shockwave_create(
        _enemy.x,_enemy.y,
        layer_get_id("Effects_Front"),
        {
            radius_scale: 1.4,
            expansion_response: 0.09,
            fade_speed: 0.018,
            thickness: 8,
            colour: _p.energy,

            particles_enabled: true,
            particle_interval: 1,
            particle_min_radius: 16,

            smoke_enabled: true,
            smoke_amount_max: 10,
            smoke_colour: _p.hull_dark,

            fragments_enabled: true,
            fragment_chance: 0.8,
            fragment_colour: _p.energy
        },
        _r*1.2
    );

    return true;
}

/// @description Draws the Nexus centre death fragment.
function sc_enemy_sim_nexus_fragment_centre_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.32, _p.hull_dark, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.25, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.12, _p.accent, true);
}

/// @description Draws one detached Nexus diagonal-arm fragment.
function sc_enemy_sim_nexus_fragment_arm_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_sim_visual_blade_panel(
        _x, _y, _radius, _angle,
        -0.28, -0.18,
        0.18, -0.27,
        0.55, 0,
        0.18, 0.27,
        _p.hull_dark, _p, 1
    );

    sc_sim_visual_energy_conduit(
        _x, _y, _radius, _angle,
        -0.18, 0,
        0.43, 0,
        3, _p, 1
    );
}

/// @description Draws one detached Nexus cardinal-module fragment.
function sc_enemy_sim_nexus_fragment_module_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(
        _x, _y, _radius, _angle,
        -0.32, -0.2,
        0.35, -0.18,
        0.4, 0.18,
        -0.32, 0.2,
        _p.hull_dark
    );

    sc_sim_visual_energy_conduit(
        _x, _y, _radius, _angle,
        -0.2, 0,
        0.3, 0,
        3, _p, 1
    );
}