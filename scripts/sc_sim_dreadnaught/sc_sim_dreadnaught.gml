/*
SIMULANT DREADNAUGHT

Mega-boss facing east at draw_angle 0.
The boss encounter rotates it to draw_angle 90 before entry.

HARDPOINT GROUPS
main_beams:    2 fixed major beam cannons
edge_lasers:  14 independently rotating turrets
plasma_core:  1 central heavy-plasma aperture
rockets_upper: 3 upper rocket tubes
rockets_lower: 3 lower rocket tubes

The edge lasers temporarily use the existing Simulant pulse weapon.
The main beams temporarily use the existing Simulant thin beam.
Plasma and rocket mounts remain inactive until their weapons are registered.
*/

/// @description Registers the Simulant Dreadnaught mega-boss.
function sc_enemy_register_sim_dreadnaught()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_dreadnaught",
            name: "Simulant Dreadnaught",
            faction: Faction.SIMULANT,
			role: EnemyRole.FIGHTER,
			ship_class: EnemyClass.CAPITAL,
			rank: EnemyRank.BOSS,
			threat_value: 500
        },
		
		awareness_controller: {
		    unseen_damage_script: sc_enemy_awareness_ignore,
		    alert_receive_script: sc_enemy_awareness_ignore,
		    duration: 0,
		    arrival_radius: 0,
		    search_duration: 0,
		    speed_scale: 0
		},

        reward: { credits: 2500 },

        stats_base: {
            shield_max: 1800,
            armour_max: 4200,
            hull_max: 2200,
			mass: 5.5,

            handling: {
                speed_max: 0.8,
                acceleration: 0.025,
                friction_coeff: 0.985,
                turn_speed: 0,
                directional: false,
                directional_speed_min: 1,
                directional_thrust_min: 1
            },

            range: {
                detection: 2000,
                combat: 1650,
                backaway: 0,
                forget: 2400,
                wander: 0,
                alert_share: 2000
            },

            damage_multiplier: 1.5,
            fire_rate_multiplier: 1
        },

        movement_controller: {
			asteroid_response: AsteroidResponse.IGNORE,
		    idle_script: sc_enemy_movement_swing,
		    chase_script: sc_enemy_movement_swing,
		    combat_script: sc_enemy_movement_swing,

    facing: {
        default_mode: EnemyFacingMode.FIXED,
        backaway_mode: EnemyFacingMode.FIXED,
        angle_offset: 0,
        turn_speed_scale: 0,
        spin_speed: 0
    },

    swing: {
        width: 150,
        arc_depth: 18,
        speed: 0.004,
        speed_scale: 0.85,
        response_distance: 55
    },

    orbit: {
        range: 0,
        direction: 1,
        radial_strength: 0,
        direction_change_chance: 0
    },

    strafe: {
        amount: 0,
        speed: 0
    }
},

        visual: sc_enemy_sim_dreadnaught_visual_data(),

        collision: {
            radius_forward_scale: 1.18,
            radius_side_scale: 1.82,
            blocks_player: true
        },

        hardpoints: [
            // ==================================================
            // TWO FIXED MAIN BEAMS
            // ==================================================
            {
                key: "main_beam_upper", group: "main_beams",
                forward: 0.82, side: -0.22, angle: 0, muzzle_forward: 0.5,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_main_beam_draw
            },
            {
                key: "main_beam_lower", group: "main_beams",
                forward: 0.82, side: 0.22, angle: 0, muzzle_forward: 0.5,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_main_beam_draw
            },

            // ==================================================
            // SEVEN UPPER EDGE LASERS
            // ==================================================
            {
                key: "edge_upper_01", group: "edge_lasers",
                forward: 0.58, side: -0.57, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.2, arc: 105, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_upper_02", group: "edge_lasers",
                forward: 0.47, side: -0.82, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.2, arc: 105, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_upper_03", group: "edge_lasers",
                forward: 0.33, side: -1.06, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.1, arc: 110, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_upper_04", group: "edge_lasers",
                forward: 0.16, side: -1.29, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2, arc: 115, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_upper_05", group: "edge_lasers",
                forward: -0.04, side: -1.5, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.9, arc: 120, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_upper_06", group: "edge_lasers",
                forward: -0.28, side: -1.67, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.8, arc: 125, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_upper_07", group: "edge_lasers",
                forward: -0.54, side: -1.76, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.7, arc: 130, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },

            // ==================================================
            // SEVEN LOWER EDGE LASERS
            // ==================================================
            {
                key: "edge_lower_01", group: "edge_lasers",
                forward: 0.58, side: 0.57, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.2, arc: 105, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_lower_02", group: "edge_lasers",
                forward: 0.47, side: 0.82, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.2, arc: 105, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_lower_03", group: "edge_lasers",
                forward: 0.33, side: 1.06, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.1, arc: 110, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_lower_04", group: "edge_lasers",
                forward: 0.16, side: 1.29, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 2, arc: 115, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_lower_05", group: "edge_lasers",
                forward: -0.04, side: 1.5, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.9, arc: 120, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_lower_06", group: "edge_lasers",
                forward: -0.28, side: 1.67, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.8, arc: 125, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },
            {
                key: "edge_lower_07", group: "edge_lasers",
                forward: -0.54, side: 1.76, angle: 0, muzzle_forward: 0.27,
                rotation: { mode: HardpointRotation.TARGET, turn_speed: 1.7, arc: 130, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_edge_turret_draw
            },

            // ==================================================
            // CENTRAL PLASMA CORE
            // ==================================================
            {
                key: "plasma_core", group: "plasma_core",
                forward: 0, side: 0, angle: 0, muzzle_forward: 0.17,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_core_mount_draw
            },

            // ==================================================
            // THREE UPPER ROCKET TUBES
            // ==================================================
            {
                key: "rocket_upper_01", group: "rockets",
                forward: -0.2, side: -0.68, angle: 0, muzzle_forward: 0.26,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_rocket_tube_draw
            },
            {
                key: "rocket_upper_02", group: "rockets",
                forward: 0, side: -0.68, angle: 0, muzzle_forward: 0.26,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_rocket_tube_draw
            },
            {
                key: "rocket_upper_03", group: "rockets",
                forward: 0.2, side: -0.68, angle: 0, muzzle_forward: 0.26,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_rocket_tube_draw
            },

            // ==================================================
            // THREE LOWER ROCKET TUBES
            // ==================================================
            {
                key: "rocket_lower_01", group: "rocket",
                forward: -0.2, side: 0.68, angle: 0, muzzle_forward: 0.26,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_rocket_tube_draw
            },
            {
                key: "rocket_lower_02", group: "rockets",
                forward: 0, side: 0.68, angle: 0, muzzle_forward: 0.26,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_rocket_tube_draw
            },
            {
                key: "rocket_lower_03", group: "rockets",
                forward: 0.2, side: 0.68, angle: 0, muzzle_forward: 0.26,
                rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
                draw_script: sc_enemy_sim_dreadnaught_rocket_tube_draw
            }
        ],

        thrusters: [
            { key: "thruster_01", forward: -0.93, side: -1.28, angle: 180, scale: 1.05 },
            { key: "thruster_02", forward: -1.02, side: -0.84, angle: 180, scale: 1.2 },
            { key: "thruster_03", forward: -1.08, side: -0.42, angle: 180, scale: 1.35 },
            { key: "thruster_04", forward: -1.12, side: 0, angle: 180, scale: 1.5 },
            { key: "thruster_05", forward: -1.08, side: 0.42, angle: 180, scale: 1.35 },
            { key: "thruster_06", forward: -1.02, side: 0.84, angle: 180, scale: 1.2 },
            { key: "thruster_07", forward: -0.93, side: 1.28, angle: 180, scale: 1.05 }
        ],

        attack_controller: {
		    selection: AttackSelection.WEIGHTED,

		    attacks: [
		        {
		            key: "edge_laser_spray",
		            weight: 55,
		            hardpoint_group: "edge_lasers",
		            weapon_key: "weapon_simulant_pulse",

		            conditions: {
		                range_min: 160,
		                range_max: 1500
		            },

		            aim: {
		                mode: AimMode.TARGET,
		                angle_offset: 0,
		                inaccuracy: 4,
						fire_tolerance: 10
		            },

		            shot: {
		                pattern: ShotPattern.SINGLE,
		                amount: 1
		            },

		            firing: {
		                order: HardpointFireOrder.RANDOM,
		                interval: 3,
		                volley_max: 38,
		                cooldown: 100
		            }
		        },
		        {
		            key: "twin_main_beams",
		            weight: 20,
		            hardpoint_group: "main_beams",
		            weapon_key: "weapon_simulant_thin_beam",

		            conditions: {
		                range_min: 260,
		                range_max: 1450,
		                hull_ratio_max: 0.95
		            },

		            aim: {
		                mode: AimMode.MOUNT,
		                angle_offset: 0,
		                inaccuracy: 0,
						fire_tolerance: 10
		            },

		            shot: {
		                pattern: ShotPattern.SINGLE,
		                amount: 1
		            },

		            telegraph: {
		                duration: 90,
		                aim_lock_remaining: 90,
		                track_during_active: false,
		                scale: 0.24,
		                particle_interval: 2,
		                draw_script: sc_attack_telegraph_energy_draw,
		                particle_script: sc_particles_attack_telegraph_emit
		            },

		            firing: {
		                order: HardpointFireOrder.ALL,
		                duration: 110,
		                cooldown: 300
		            }
		        },
		        {
		            key: "six_rocket_salvo",
		            weight: 25,
		            hardpoint_group: "rockets",
		            weapon_key: "weapon_simulant_dreadnaught_rocket",

		            conditions: {
		                range_min: 280,
		                range_max: 1550
		            },

		            aim: {
		                mode: AimMode.TARGET,
		                angle_offset: 0,
		                inaccuracy: 3,
						fire_tolerance: 10
		            },

		            shot: {
		                pattern: ShotPattern.SINGLE,
		                amount: 1
		            },

		            telegraph: {
		                duration: 42,
		                aim_lock_remaining: 10,
		                track_during_active: true,
		                scale: 0.11,
		                particle_interval: 3,
		                draw_script: sc_attack_telegraph_energy_draw,
		                particle_script: sc_particles_attack_telegraph_emit
		            },

		            firing: {
		                order: HardpointFireOrder.SEQUENTIAL,
		                interval: 6,
		                volley_max: 6,
		                cooldown: 220
		            }
		        }

		        // Future plasma_core attack goes here.
		    ]
		}
    });
}

/// @description Returns the Dreadnaught's complete visual definition.
function sc_enemy_sim_dreadnaught_visual_data()
{
    return {
        radius: 250,
        motion_strength: 1,
        palette: sc_faction_palette_get(Faction.SIMULANT),
        core: { forward: 0, side: 0 },

        draw: {
            body: sc_enemy_sim_dreadnaught_body_draw,
            core: sc_enemy_sim_dreadnaught_core_energy_draw
        },

        death: {
            script: sc_enemy_sim_dreadnaught_death,
            draw_scripts: [
                sc_enemy_sim_dreadnaught_fragment_centre_draw,
                sc_enemy_sim_dreadnaught_fragment_upper_inner_draw,
                sc_enemy_sim_dreadnaught_fragment_upper_outer_draw,
                sc_enemy_sim_dreadnaught_fragment_lower_inner_draw,
                sc_enemy_sim_dreadnaught_fragment_lower_outer_draw
            ]
        },

        thrust: {
            draw_script: sc_enemy_simulant_thrust_draw,
            ignition_script: sc_particles_enemy_thrust_ignition,
            particle_script: sc_particles_enemy_thrust_emit
        },

        bake: {
            body_canvas_size: 1280,
            core_canvas_size: 512,
            hardpoint_canvas_size: 384,
            thrust_canvas_size: 256,
            fragment_canvas_size: 768
        }
    };
}

/// @description Draws the immense layered Dreadnaught hull facing east.
function sc_enemy_sim_dreadnaught_body_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    // Central armoured spine.
    sc_visual_quad(_x, _y, _radius, _angle, 1.04, -0.34, 1.22, 0, 1.04, 0.34, -1.02, 0.58, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -1.02, -0.58, 1.04, -0.34, 1.04, 0.34, -1.02, 0.58, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.82, -0.24, 1.11, 0, 0.82, 0.24, -0.85, 0.42, _p.hull_mid);
    sc_visual_quad(_x, _y, _radius, _angle, -0.85, -0.42, 0.82, -0.24, 0.82, 0.24, -0.85, 0.42, _p.hull_mid);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        // Massive inner wing.
        sc_visual_quad(_x, _y, _radius, _angle,
            0.86, 0.28 * _side,
            0.58, 0.92 * _side,
            -0.2, 1.47 * _side,
            -0.93, 0.55 * _side,
            _p.hull_dark
        );

        sc_visual_quad(_x, _y, _radius, _angle,
            0.71, 0.38 * _side,
            0.45, 0.88 * _side,
            -0.18, 1.3 * _side,
            -0.72, 0.54 * _side,
            _p.hull_mid
        );

        // Huge outer armour blade.
        sc_visual_quad(_x, _y, _radius, _angle,
            0.54, 0.9 * _side,
            0.3, 1.38 * _side,
            -0.53, 1.92 * _side,
            -0.91, 1.35 * _side,
            _p.hull_dark
        );

        sc_visual_quad(_x, _y, _radius, _angle,
            0.42, 1.01 * _side,
            0.17, 1.39 * _side,
            -0.49, 1.76 * _side,
            -0.75, 1.31 * _side,
            _p.hull_mid
        );

        // Rear stabilizer blade.
        sc_visual_triangle(_x, _y, _radius, _angle,
            -0.42, 1.48 * _side,
            -0.97, 1.7 * _side,
            -0.76, 1.15 * _side,
            _p.hull_light,
            false
        );

        // Layered mechanical plates.
        sc_visual_quad(_x, _y, _radius, _angle,
            0.52, 0.48 * _side,
            0.31, 0.86 * _side,
            -0.12, 1.06 * _side,
            -0.39, 0.65 * _side,
            _p.hull_light
        );

        sc_visual_quad(_x, _y, _radius, _angle,
            0.18, 1.04 * _side,
            -0.08, 1.42 * _side,
            -0.45, 1.58 * _side,
            -0.38, 1.14 * _side,
            _p.hull_light
        );

        sc_visual_quad(_x, _y, _radius, _angle,
            -0.43, 0.59 * _side,
            -0.57, 1.02 * _side,
            -0.84, 1.19 * _side,
            -0.79, 0.64 * _side,
            _p.hull_light
        );

        // Black armour divisions.
        sc_visual_line(_x, _y, _radius, _angle, 0.71, 0.38 * _side, 0.45, 0.88 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.42, 1.01 * _side, 0.17, 1.39 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.38, 1.14 * _side, -0.75, 1.31 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.43, 0.59 * _side, -0.79, 0.64 * _side, 6, _p.void);

        // Violet power conduits.
        sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.49 * _side, 0.19, 0.86 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.49 * _side, 0.19, 0.86 * _side, 3, _p.accent);

        sc_visual_line(_x, _y, _radius, _angle, 0.2, 1.12 * _side, -0.36, 1.47 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.2, 1.12 * _side, -0.36, 1.47 * _side, 3, _p.energy);

        sc_visual_line(_x, _y, _radius, _angle, -0.43, 0.77 * _side, -0.77, 0.84 * _side, 6, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.43, 0.77 * _side, -0.77, 0.84 * _side, 2, _p.accent);

        // Outer hull outline.
        sc_visual_line(_x, _y, _radius, _angle, 0.86, 0.28 * _side, 0.54, 0.9 * _side, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 0.54, 0.9 * _side, 0.3, 1.38 * _side, 2, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 0.3, 1.38 * _side, -0.53, 1.92 * _side, 2, _p.outline);
        sc_visual_line(_x, _y, _radius, _angle, -0.53, 1.92 * _side, -0.97, 1.7 * _side, 2, _p.outline);
        sc_visual_line(_x, _y, _radius, _angle, -0.97, 1.7 * _side, -0.93, 0.55 * _side, 2, _p.metal);
    }

    // Forward command spear between the main cannons.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.28, 0, 0.5, -0.24, -0.83, 0, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.28, 0, -0.83, 0, 0.5, 0.24, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.19, 0, 0.49, -0.11, 0.49, 0.11, _p.metal, false);

    // Central plasma-core socket.
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.38, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.38, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.31, _p.hull_mid, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.24, _p.accent, true);

    // Long central energy trench.
    sc_visual_line(_x, _y, _radius, _angle, -0.94, 0, 1.11, 0, 12, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, -0.84, 0, 1.05, 0, 5, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, 0.36, 0, 1.04, 0, 3, _p.energy);

    // Main beam attachment housings.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            0.55, (0.22 * _side) - 0.13,
            0.97, (0.22 * _side) - 0.12,
            0.97, (0.22 * _side) + 0.12,
            0.55, (0.22 * _side) + 0.13,
            _p.hull_dark
        );

        sc_visual_circle(_x, _y, _radius, _angle, 0.82, 0.22 * _side, 0.16, _p.void, false);
        sc_visual_circle(_x, _y, _radius, _angle, 0.82, 0.22 * _side, 0.16, _p.metal, true);
    }

    // Edge-turret attachment collars.
    var _edge_forward = [0.58, 0.47, 0.33, 0.16, -0.04, -0.28, -0.54];
    var _edge_side = [0.57, 0.82, 1.06, 1.29, 1.5, 1.67, 1.76];

    for (var _side = -1; _side <= 1; _side += 2)
    {
        for (var _i = 0; _i < 7; _i++)
        {
            sc_visual_circle(_x, _y, _radius, _angle, _edge_forward[_i], _edge_side[_i] * _side, 0.115, _p.void, false);
            sc_visual_circle(_x, _y, _radius, _angle, _edge_forward[_i], _edge_side[_i] * _side, 0.115, _p.metal, true);
            sc_visual_circle(_x, _y, _radius, _angle, _edge_forward[_i], _edge_side[_i] * _side, 0.052, _p.accent, true);
        }
    }

    // Upper and lower rocket-rack armour.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            -0.34, 0.55 * _side,
            0.34, 0.55 * _side,
            0.34, 0.81 * _side,
            -0.34, 0.81 * _side,
            _p.hull_dark
        );

        sc_visual_line(_x, _y, _radius, _angle, -0.34, 0.55 * _side, 0.34, 0.55 * _side, 3, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, -0.34, 0.81 * _side, 0.34, 0.81 * _side, 2, _p.outline);
    }

    // Seven engine housings.
    var _engine_side = [-1.28, -0.84, -0.42, 0, 0.42, 0.84, 1.28];

    for (var _i = 0; _i < 7; _i++)
    {
        sc_visual_quad(_x, _y, _radius, _angle,
            -0.72, _engine_side[_i] - 0.075,
            -1.1, _engine_side[_i] - 0.06,
            -1.1, _engine_side[_i] + 0.06,
            -0.72, _engine_side[_i] + 0.075,
            _p.hull_mid
        );

        sc_visual_line(_x, _y, _radius, _angle, -0.78, _engine_side[_i], -1.1, _engine_side[_i], 9, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.81, _engine_side[_i], -1.08, _engine_side[_i], 3, _p.energy);
    }
}

/// @description Draws one articulated edge-mounted laser turret.
function sc_enemy_sim_dreadnaught_edge_turret_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.115, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.115, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.074, _p.hull_mid, false);

    sc_visual_quad(_x, _y, _radius, _angle, -0.025, -0.055, 0.19, -0.042, 0.19, 0.042, -0.025, 0.055, _p.hull_light);
    sc_visual_line(_x, _y, _radius, _angle, 0.01, 0, 0.265, 0, 6, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.04, 0, 0.25, 0, 2, _p.energy);

    sc_visual_circle(_x, _y, _radius, _angle, 0.265, 0, 0.05, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.265, 0, 0.05, _p.accent, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.265, 0, 0.018, _p.core, false);

    draw_set_alpha(1);
}

/// @description Draws one enormous fixed Dreadnaught beam cannon.
function sc_enemy_sim_dreadnaught_main_beam_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.165, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.165, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.11, _p.hull_mid, false);

    sc_visual_quad(_x, _y, _radius, _angle, -0.08, -0.12, 0.35, -0.1, 0.35, 0.1, -0.08, 0.12, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.02, -0.075, 0.46, -0.062, 0.46, 0.062, 0.02, 0.075, _p.hull_light);

    sc_visual_line(_x, _y, _radius, _angle, 0.04, 0, 0.51, 0, 13, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.08, 0, 0.5, 0, 7, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.12, 0, 0.5, 0, 3, _p.energy);

    sc_visual_line(_x, _y, _radius, _angle, 0.17, -0.105, 0.17, 0.105, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.33, -0.09, 0.33, 0.09, 3, _p.outline);

    sc_visual_circle(_x, _y, _radius, _angle, 0.5, 0, 0.095, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.5, 0, 0.095, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.5, 0, 0.055, _p.energy, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.5, 0, 0.022, _p.core, false);

    draw_set_alpha(1);
}

/// @description Draws one fixed armoured rocket-launch tube.
function sc_enemy_sim_dreadnaught_rocket_tube_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_quad(_x, _y, _radius, _angle, -0.15, -0.075, 0.19, -0.075, 0.25, -0.045, -0.15, -0.045, _p.hull_light);
    sc_visual_quad(_x, _y, _radius, _angle, -0.15, 0.045, 0.25, 0.045, 0.19, 0.075, -0.15, 0.075, _p.hull_light);
    sc_visual_quad(_x, _y, _radius, _angle, -0.1, -0.045, 0.25, -0.045, 0.25, 0.045, -0.1, 0.045, _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle, -0.07, 0, 0.25, 0, 7, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, -0.02, 0, 0.22, 0, 2, _p.accent);

    sc_visual_circle(_x, _y, _radius, _angle, 0.25, 0, 0.068, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.25, 0, 0.068, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.25, 0, 0.034, _p.energy, false);

    draw_set_alpha(1);
}

/// @description Draws the outer housing of the central plasma hardpoint.
function sc_enemy_sim_dreadnaught_core_mount_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.38, _p.void, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.34, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.28, _p.accent, true);

    for (var _i = 0; _i < 12; _i++)
    {
        var _direction = _angle + _i * 30;
        var _x1 = _x + lengthdir_x(_radius * 0.29, _direction);
        var _y1 = _y + lengthdir_y(_radius * 0.29, _direction);
        var _x2 = _x + lengthdir_x(_radius * 0.37, _direction + 5);
        var _y2 = _y + lengthdir_y(_radius * 0.37, _direction + 5);

        draw_set_colour((_i mod 2) == 0 ? _p.metal : _p.outline);
        draw_line_width(_x1, _y1, _x2, _y2, 4);
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws the rotating energy inside the central plasma hardpoint.
function sc_enemy_sim_dreadnaught_core_energy_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.27;
    var _middle = _radius * 0.18;
    var _inner = _radius * 0.09;

    gpu_set_blendmode(bm_add);

    draw_set_alpha(_alpha * 0.15);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _outer * 1.7, false);

    draw_set_alpha(_alpha * 0.35);
    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _outer * 1.25, false);

    draw_set_alpha(_alpha);

    for (var _i = 0; _i < 10; _i++)
    {
        var _direction = _angle + _i * 36;
        var _x1 = _x + lengthdir_x(_inner, _direction);
        var _y1 = _y + lengthdir_y(_inner, _direction);
        var _x2 = _x + lengthdir_x(_outer, _direction + 14);
        var _y2 = _y + lengthdir_y(_outer, _direction + 14);

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.accent);
        draw_line_width(_x1, _y1, _x2, _y2, 5);
    }

    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _middle, false);

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _inner, false);

    draw_set_colour(_p.core);
    draw_circle(_x, _y, _inner * 0.42, false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the complete Dreadnaught destruction visual.
function sc_enemy_sim_dreadnaught_death(_enemy)
{
    var _data = _enemy.enemy;
    var _visual = _data.visual;
    var _palette = _visual.palette;
    var _cache = sc_enemy_visual_cache_get(_data.key);
    var _angle = _enemy.draw_angle;
    var _radius = _visual.radius;
    var _velocity_x = _data.movement.velocity_x;
    var _velocity_y = _data.movement.velocity_y;
    var _fragments = [];

    sc_particles_simulant_enemy_death(_enemy.x, _enemy.y, _radius);

    array_push(_fragments, sc_death_fragment_data(_cache.fragments[0], _enemy.x, _enemy.y, _angle, 2.8, _angle, choose(-4, 4), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[1], _enemy.x + lengthdir_x(-_radius * 0.05, _angle) + lengthdir_x(-_radius * 0.85, _angle + 90), _enemy.y + lengthdir_y(-_radius * 0.05, _angle) + lengthdir_y(-_radius * 0.85, _angle + 90), _angle - 20, 3.4, _angle, -5, 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[2], _enemy.x + lengthdir_x(-_radius * 0.28, _angle) + lengthdir_x(-_radius * 1.52, _angle + 90), _enemy.y + lengthdir_y(-_radius * 0.28, _angle) + lengthdir_y(-_radius * 1.52, _angle + 90), _angle - 55, 4.2, _angle, -8, 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[3], _enemy.x + lengthdir_x(-_radius * 0.05, _angle) + lengthdir_x(_radius * 0.85, _angle + 90), _enemy.y + lengthdir_y(-_radius * 0.05, _angle) + lengthdir_y(_radius * 0.85, _angle + 90), _angle + 20, 3.4, _angle, 5, 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[4], _enemy.x + lengthdir_x(-_radius * 0.28, _angle) + lengthdir_x(_radius * 1.52, _angle + 90), _enemy.y + lengthdir_y(-_radius * 0.28, _angle) + lengthdir_y(_radius * 1.52, _angle + 90), _angle + 55, 4.2, _angle, 8, 1));
    array_push(_fragments, sc_death_fragment_data(_cache.core, _enemy.x, _enemy.y, irandom(359), 2.4, _angle, choose(-10, 10), 1));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _enemy.x + lengthdir_x(_hardpoint.forward * _radius, _angle) + lengthdir_x(_hardpoint.side * _radius, _angle + 90);
        var _hardpoint_y = _enemy.y + lengthdir_y(_hardpoint.forward * _radius, _angle) + lengthdir_y(_hardpoint.side * _radius, _angle + 90);
        var _direction = point_direction(_enemy.x, _enemy.y, _hardpoint_x, _hardpoint_y);

        array_push(_fragments, sc_death_fragment_data(
            _cache.hardpoints[_i],
            _hardpoint_x,
            _hardpoint_y,
            _direction + random_range(-12, 12),
            random_range(3.5, 6),
            _angle,
            choose(-12, 12),
            0.95
        ));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _velocity_x * 0.25;
        _fragments[_i].velocity_y += _velocity_y * 0.25;
    }

    sc_death_fragment_create(_enemy.x, _enemy.y, _fragments, _palette.core, _palette.glow, _radius, 75);
    return true;
}

/// @description Draws the broken central Dreadnaught section.
function sc_enemy_sim_dreadnaught_fragment_centre_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 1.1, -0.32, 1.22, 0, 1.1, 0.32, -1.02, 0.48, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, -1.02, -0.48, 1.1, -0.32, 1.1, 0.32, -1.02, 0.48, _p.hull_mid);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.38, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.38, _p.metal, true);
    sc_visual_line(_x, _y, _radius, _angle, -0.9, 0, 1.08, 0, 4, _p.accent);
}

/// @description Draws the broken upper inner Dreadnaught section.
function sc_enemy_sim_dreadnaught_fragment_upper_inner_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 0.82, -0.27, 0.5, -0.95, -0.3, -1.46, -0.88, -0.53, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.64, -0.38, 0.38, -0.87, -0.23, -1.25, -0.7, -0.54, _p.hull_mid);
    sc_visual_line(_x, _y, _radius, _angle, 0.57, -0.48, 0.03, -1.05, 4, _p.energy);
}

/// @description Draws the broken upper outer Dreadnaught section.
function sc_enemy_sim_dreadnaught_fragment_upper_outer_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 0.52, -0.92, 0.27, -1.39, -0.56, -1.91, -0.94, -1.34, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.38, -1.02, 0.13, -1.41, -0.49, -1.73, -0.73, -1.31, _p.hull_mid);
    sc_visual_line(_x, _y, _radius, _angle, 0.18, -1.17, -0.48, -1.62, 4, _p.accent);
}

/// @description Draws the broken lower inner Dreadnaught section.
function sc_enemy_sim_dreadnaught_fragment_lower_inner_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 0.82, 0.27, -0.88, 0.53, -0.3, 1.46, 0.5, 0.95, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.64, 0.38, -0.7, 0.54, -0.23, 1.25, 0.38, 0.87, _p.hull_mid);
    sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.48, 0.03, 1.05, 4, _p.energy);
}

/// @description Draws the broken lower outer Dreadnaught section.
function sc_enemy_sim_dreadnaught_fragment_lower_outer_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 0.52, 0.92, -0.94, 1.34, -0.56, 1.91, 0.27, 1.39, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.38, 1.02, -0.73, 1.31, -0.49, 1.73, 0.13, 1.41, _p.hull_mid);
    sc_visual_line(_x, _y, _radius, _angle, 0.18, 1.17, -0.48, 1.62, 4, _p.accent);
}