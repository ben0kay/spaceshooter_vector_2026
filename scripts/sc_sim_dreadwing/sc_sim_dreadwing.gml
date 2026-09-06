/*
SIMULANT DREADWING
Large elite crescent warship facing east at draw_angle 0.
The body, core, four rotating cannons, thrust and death fragments are baked separately.
Each cannon independently tracks its target inside a registered 65-degree firing arc.
Reuses the existing Simulant pulse weapon and generic enemy combat systems.
*/

/// @description Registers the large elite Simulant Dreadwing.
function sc_enemy_register_sim_dreadwing()
{
    return sc_enemy_register({
        identity: {
            key: "enemy_sim_dreadwing",
            name: "Simulant Dreadwing",
            faction: Faction.SIMULANT,
			role: EnemyRole.FIGHTER,
			ship_class: EnemyClass.HEAVY,
			rank: EnemyRank.ELITE,
			threat_value: 15
        },
			
		reward: { credits: 125 },	

        stats_base: {
            shield_max: 180,
            armour_max: 600,
            hull_max: 250,
			mass: 2,
			
            handling: {
                speed_max: 3,
                acceleration: 0.12,
                friction_coeff: 0.992,
                turn_speed: 1,
                directional: true,
                directional_speed_min: 0.3,
                directional_thrust_min: 0.42
            },

            // Simulant Dreadwing
			range: {
			    detection: 1340,
			    combat: 1080,
			    backaway: 420,
			    forget: 1560,
			    wander: 0,
			    alert_share: 1600
			},

            damage_multiplier: 1.2,
            fire_rate_multiplier: 0.85
        },

		movement_controller: {
			
			asteroid_response: AsteroidResponse.AVOID,
		    idle_script: sc_enemy_movement_hold,
		    chase_script: sc_enemy_movement_chase,
		    combat_script: sc_enemy_movement_hold_line_of_sight,

		    facing: {
		        default_mode: EnemyFacingMode.TARGET,
		        backaway_mode: EnemyFacingMode.TARGET,
		        angle_offset: 0,
		        turn_speed_scale: 0.65,
		        spin_speed: 0
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

		awareness_controller: {
		    unseen_damage_script: sc_enemy_awareness_investigate,
		    alert_receive_script: sc_enemy_awareness_investigate,
		    duration: 600,
		    arrival_radius: 90,
		    search_duration: 180,
		    speed_scale: 0.65
		},

        visual: sc_enemy_sim_dreadwing_visual_data(),

        collision: {
            radius_forward_scale: 0.95,
            radius_side_scale: 1.52,
            blocks_player: true
        },

        hardpoints: [
		    {
		        key: "cannon_outer_left", group: "cannons",
		        forward: 0.34, side: -1.08, angle: 0, muzzle_forward: 0.44,
		        rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.4, arc: 65, return_to_rest: true },
		        draw_script: sc_enemy_sim_dreadwing_cannon_draw
		    },
		    {
		        key: "cannon_inner_left", group: "cannons",
		        forward: 0.57, side: -0.37, angle: 0, muzzle_forward: 0.44,
		        rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.4, arc: 65, return_to_rest: true },
		        draw_script: sc_enemy_sim_dreadwing_cannon_draw
		    },
		    {
		        key: "beam_centre", group: "beam",
		        forward: 0.69, side: 0, angle: 0, muzzle_forward: 0.25,
		        rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
		        draw_script: sc_enemy_simulant_thin_beam_emitter_draw
		    },
		    {
		        key: "cannon_inner_right", group: "cannons",
		        forward: 0.57, side: 0.37, angle: 0, muzzle_forward: 0.44,
		        rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.4, arc: 65, return_to_rest: true },
		        draw_script: sc_enemy_sim_dreadwing_cannon_draw
		    },
		    {
		        key: "cannon_outer_right", group: "cannons",
		        forward: 0.34, side: 1.08, angle: 0, muzzle_forward: 0.44,
		        rotation: { mode: HardpointRotation.TARGET, turn_speed: 2.4, arc: 65, return_to_rest: true },
		        draw_script: sc_enemy_sim_dreadwing_cannon_draw
		    },
		    {
		        key: "seeker_core", group: "core_weapon",
		        forward: -0.19, side: 0, angle: 0, muzzle_forward: 0,
		        rotation: { mode: HardpointRotation.FIXED, turn_speed: 0, arc: 0, return_to_rest: true },
		        draw_script: sc_enemy_sim_dreadwing_core_emitter_draw
		    }
		],

        thrusters: [
            { key: "thruster_outer_left", forward: -0.58, side: -1.05, angle: 180, scale: 0.72 },
            { key: "thruster_inner_left", forward: -0.72, side: -0.32, angle: 180, scale: 0.9 },
            { key: "thruster_inner_right", forward: -0.72, side: 0.32, angle: 180, scale: 0.9 },
            { key: "thruster_outer_right", forward: -0.58, side: 1.05, angle: 180, scale: 0.72 }
        ],

        attack_controller: {
		    selection: AttackSelection.WEIGHTED,
			max_active_channels: 2,

			channels: [
			    {
			        key: "cannons",
			        selection: AttackSelection.WEIGHTED
			    },
			    {
			        key: "heavy",
			        selection: AttackSelection.WEIGHTED
			    }
			],

		    attacks: [
		        {
		            key: "four_cannon_salvo",
					channel: "cannons",
		            weight: 40,
		            hardpoint_group: "cannons",
		            weapon_key: "weapon_simulant_pulse",

		            conditions: {
		                line_of_sight: true,
		                range_min: 120,
		                range_max: 940
		            },

		            aim: {
		                mode: AimMode.TARGET,
		                angle_offset: 0,
		                inaccuracy: 2,
		                fire_tolerance: 10
		            },

		            shot: {
		                pattern: ShotPattern.SINGLE,
		                amount: 1
		            },

		            firing: {
		                order: HardpointFireOrder.RANDOM,
		                interval: 8,
		                volley_max: 16,
		                cooldown: 150
		            }
		        },
		        {
		            key: "centre_beam",
					channel: "heavy",
		            weight: 40,
		            hardpoint_group: "beam",
		            weapon_key: "weapon_simulant_thin_beam",

		            conditions: {
		                line_of_sight: true,
		                range_min: 250,
		                range_max: 900
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
		                duration: 48,
		                aim_lock_remaining: 15,
		                track_during_active: false,
		                scale: 0.18,
		                particle_interval: 2,
		                draw_script: sc_attack_telegraph_energy_draw,
		                particle_script: sc_particles_attack_telegraph_emit
		            },

		            firing: {
		                order: HardpointFireOrder.ALL,
		                duration: 80,
		                cooldown: 200
		            }
		        },
		        {
		            key: "seeker_core_launch",
					channel: "heavy",
		            weight: 20,
		            hardpoint_group: "core_weapon",
		            weapon_key: "weapon_simulant_seeker_core",

		            conditions: {
		                line_of_sight: true,
		                range_min: 220,
		                range_max: 1050
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
		                duration: 72,
		                aim_lock_remaining: 0,
		                track_during_active: true,
		                scale: 0.34,
		                particle_interval: 1,
		                draw_script: sc_enemy_sim_dreadwing_seeker_telegraph_draw,
		                particle_script: sc_particles_attack_telegraph_emit
		            },

		            firing: {
		                order: HardpointFireOrder.ALL,
		                interval: 30,
		                volley_max: 2,
		                cooldown: 290
		            }
		        }
		    ]
		}
    });
}

/// @description Returns the complete visual definition for the Simulant Dreadwing.
function sc_enemy_sim_dreadwing_visual_data()
{
    return {
        radius: 88,
		motion_strength: 2,
        palette: sc_faction_palette_get(Faction.SIMULANT),
		core: { forward: -0.19, side: 0 },

        draw: {
		    body: sc_enemy_sim_dreadwing_body_draw,
		    core: sc_enemy_sim_dreadwing_core_draw
		},

		damage_layers: {
		    enabled: true,
		    damage_stages: 4,
		    hull_draw_script: sc_enemy_sim_dreadwing_hull_draw,
		    armour_draw_script: sc_enemy_sim_dreadwing_armour_draw
		},

        death: {
            script: sc_enemy_sim_dreadwing_death,
            draw_scripts: [
                sc_enemy_sim_dreadwing_fragment_centre_draw,
                sc_enemy_sim_dreadwing_fragment_left_draw,
                sc_enemy_sim_dreadwing_fragment_right_draw
            ]
        },

        thrust: {
	    draw_script: sc_enemy_simulant_thrust_draw,
	    ignition_script: sc_particles_enemy_thrust_ignition,
	    particle_script: sc_particles_enemy_thrust_emit
	},

        bake: {
            body_canvas_size: 384,
            core_canvas_size: 160,
            hardpoint_canvas_size: 160,
            thrust_canvas_size: 128,
            fragment_canvas_size: 256
        }
    };
}

/// @description Draws the complete intact Dreadwing for non-layered fallback.
function sc_enemy_sim_dreadwing_body_draw(_x, _y, _radius, _angle, _visual)
{
    sc_enemy_sim_dreadwing_hull_draw(_x, _y, _radius, _angle, _visual, 0);
    sc_enemy_sim_dreadwing_armour_draw(_x, _y, _radius, _angle, _visual, 0);
}

/// @description Draws the permanent purple mechanical Dreadwing hull.
function sc_enemy_sim_dreadwing_hull_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // ==================================================
    // PERMANENT CRESCENT SILHOUETTE
    // ==================================================
    sc_visual_triangle(_x, _y, _radius, _angle, 1.02, 0, 0.08, -0.54, -0.73, 0, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.02, 0, -0.73, 0, 0.08, 0.54, _p.hull_dark, false);

    for (var _side = -1; _side <= 1; _side += 2)
    {
        // Broad crescent wing.
        sc_visual_quad(_x, _y, _radius, _angle,
            0.57, 0.2 * _side,
            0.32, 0.91 * _side,
            -0.12, 1.55 * _side,
            -0.66, 0.53 * _side,
            _p.hull_dark
        );

        // Internal mechanical wing bed.
        sc_visual_quad(_x, _y, _radius, _angle,
            0.45, 0.28 * _side,
            0.19, 0.79 * _side,
            -0.14, 1.32 * _side,
            -0.51, 0.5 * _side,
            _p.hull_mid
        );

        // Outer crescent blade structure.
        sc_visual_triangle(_x, _y, _radius, _angle,
            0.32, 0.91 * _side,
            -0.12, 1.55 * _side,
            -0.31, 1.25 * _side,
            _p.hull_dark, false
        );

        sc_visual_triangle(_x, _y, _radius, _angle,
            -0.12, 1.55 * _side,
            -0.66, 0.53 * _side,
            -0.48, 1.05 * _side,
            _p.hull_dark, false
        );

        // Structural ribs.
        sc_visual_line(_x, _y, _radius, _angle, 0.38, 0.35 * _side, -0.48, 0.56 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.36, 0.35 * _side, -0.46, 0.56 * _side, 2, _p.metal);

        sc_visual_line(_x, _y, _radius, _angle, 0.17, 0.62 * _side, -0.37, 1.11 * _side, 6, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.17, 0.62 * _side, -0.36, 1.1 * _side, 2, _p.outline);

        sc_visual_line(_x, _y, _radius, _angle, -0.19, 0.5 * _side, -0.55, 0.78 * _side, 5, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.19, 0.5 * _side, -0.53, 0.77 * _side, 2, _p.metal);

        // Permanent purple energy channels.
        sc_visual_line(_x, _y, _radius, _angle, 0.26, 0.46 * _side, -0.08, 0.72 * _side, 7, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.25, 0.46 * _side, -0.08, 0.72 * _side, 3, _p.accent);

        sc_visual_line(_x, _y, _radius, _angle, -0.07, 0.93 * _side, -0.29, 1.14 * _side, 6, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.07, 0.93 * _side, -0.29, 1.14 * _side, 2, _p.energy);

        // Outer powered node.
        sc_visual_circle(_x, _y, _radius, _angle, -0.1, 1.21 * _side, 0.16, _p.void, false);
        sc_visual_circle(_x, _y, _radius, _angle, -0.1, 1.21 * _side, 0.16, _p.metal, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.1, 1.21 * _side, 0.09, _p.accent, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.1, 1.21 * _side, 0.04, _p.core, false);

        // Inner powered node.
        sc_visual_circle(_x, _y, _radius, _angle, -0.09, 0.63 * _side, 0.105, _p.void, false);
        sc_visual_circle(_x, _y, _radius, _angle, -0.09, 0.63 * _side, 0.105, _p.metal, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.09, 0.63 * _side, 0.045, _p.energy, false);

        // Crescent silhouette highlights.
        sc_visual_line(_x, _y, _radius, _angle, 0.57, 0.2 * _side, 0.32, 0.91 * _side, 2, _p.outline);
        sc_visual_line(_x, _y, _radius, _angle, 0.32, 0.91 * _side, -0.12, 1.55 * _side, 2, _p.energy);
        sc_visual_line(_x, _y, _radius, _angle, -0.12, 1.55 * _side, -0.66, 0.53 * _side, 2, _p.outline);
    }

    // ==================================================
    // CENTRAL HULL
    // ==================================================
    sc_visual_triangle(_x, _y, _radius, _angle, 1.02, 0, 0.28, -0.23, -0.69, 0, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.02, 0, -0.69, 0, 0.28, 0.23, _p.hull_dark, false);

    sc_visual_triangle(_x, _y, _radius, _angle, 0.92, 0, 0.21, -0.13, -0.5, 0, _p.hull_mid, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.92, 0, -0.5, 0, 0.21, 0.13, _p.hull_mid, false);

    // Permanent pointed purple nose.
    sc_visual_triangle(_x, _y, _radius, _angle, 1.02, 0, 0.63, -0.09, 0.77, 0, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 1.02, 0, 0.77, 0, 0.63, 0.09, _p.hull_dark, false);

    sc_visual_line(_x, _y, _radius, _angle, 1.02, 0, 0.63, -0.09, 2, _p.energy);
    sc_visual_line(_x, _y, _radius, _angle, 1.02, 0, 0.63, 0.09, 2, _p.energy);

    // Reactor socket remains part of the hull.
    sc_visual_circle(_x, _y, _radius, _angle, -0.19, 0, 0.28, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, -0.19, 0, 0.28, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, -0.19, 0, 0.21, _p.hull_light, true);

    // Permanent central energy trench.
    sc_visual_line(_x, _y, _radius, _angle, -0.71, 0, 0.88, 0, 8, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, -0.62, 0, 0.82, 0, 3, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.09, 0, 0.61, 0, 5, _p.accent);
    sc_visual_line(_x, _y, _radius, _angle, 0.18, 0, 0.59, 0, 2, _p.energy);

    // ==================================================
    // HARDPOINT COLLARS
    // ==================================================
    var _mount_forward = [0.34, 0.57, 0.57, 0.34];
    var _mount_side = [-1.08, -0.37, 0.37, 1.08];

    for (var _i = 0; _i < 4; _i++)
    {
        sc_visual_circle(_x, _y, _radius, _angle, _mount_forward[_i], _mount_side[_i], 0.135, _p.void, false);
        sc_visual_circle(_x, _y, _radius, _angle, _mount_forward[_i], _mount_side[_i], 0.135, _p.metal, true);
        sc_visual_circle(_x, _y, _radius, _angle, _mount_forward[_i], _mount_side[_i], 0.065, _p.accent, true);
    }

    // ==================================================
    // ENGINE HOUSINGS
    // ==================================================
    var _engine_side = [-1.05, -0.32, 0.32, 1.05];

    for (var _i = 0; _i < 4; _i++)
    {
        var _engine_scale = abs(_engine_side[_i]) > 0.8 ? 0.8 : 1;

        sc_visual_quad(_x, _y, _radius, _angle,
            -0.39, _engine_side[_i] - 0.09 * _engine_scale,
            -0.73, _engine_side[_i] - 0.08 * _engine_scale,
            -0.73, _engine_side[_i] + 0.08 * _engine_scale,
            -0.39, _engine_side[_i] + 0.09 * _engine_scale,
            _p.hull_mid
        );

        sc_visual_line(_x, _y, _radius, _angle, -0.46, _engine_side[_i], -0.73, _engine_side[_i], 8 * _engine_scale, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, -0.49, _engine_side[_i], -0.72, _engine_side[_i], 3 * _engine_scale, _p.energy);
        sc_visual_circle(_x, _y, _radius, _angle, -0.72, _engine_side[_i], 0.04 * _engine_scale, _p.core, false);
    }

    // ==================================================
    // ACTUAL HULL DAMAGE
    // ==================================================
    if (_stage >= 1)
    {
        sc_visual_line(_x, _y, _radius, _angle, 0.21, -0.41, -0.04, -0.66, 4, _p.void);
        sc_visual_line(_x, _y, _radius, _angle, 0.21, -0.41, 0.03, -0.58, 2, _p.accent);
    }

    if (_stage >= 2)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.31, 0.85, 0.16, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.31, 0.85, -0.5, 1.02, 2, _p.energy);
        sc_visual_line(_x, _y, _radius, _angle, 0.35, 0.28, 0.1, 0.5, 4, _p.void);
    }

    if (_stage >= 3)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.45, -0.74, 0.22, _p.void, false);
        sc_visual_line(_x, _y, _radius, _angle, -0.45, -0.74, -0.64, -0.91, 3, _p.accent);
        sc_visual_circle(_x, _y, _radius, _angle, 0.33, 0.48, 0.14, _p.void, false);
    }
}

/// @description Draws strictly subtractive silver armour over the Dreadwing hull.
function sc_enemy_sim_dreadwing_armour_draw(_x, _y, _radius, _angle, _visual, _stage)
{
    var _p = _visual.palette;

    // Every later stage is a strict subset.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        // ==================================================
        // FINAL INNER PLATES - STAGES 0, 1, 2, 3
        // ==================================================
        sc_visual_quad(_x, _y, _radius, _angle,
            0.38, 0.3 * _side,
            0.23, 0.43 * _side,
            -0.04, 0.5 * _side,
            -0.16, 0.37 * _side,
            _p.metal
        );

        sc_visual_line(_x, _y, _radius, _angle,
            0.38, 0.3 * _side,
            0.23, 0.43 * _side,
            1, _p.core
        );

        // ==================================================
        // INNER WING AND SPEAR PLATES - STAGES 0, 1, 2
        // ==================================================
        if (_stage <= 2)
        {
            sc_visual_quad(_x, _y, _radius, _angle,
                0.37, 0.52 * _side,
                0.17, 0.75 * _side,
                -0.09, 0.87 * _side,
                -0.25, 0.64 * _side,
                _p.hull_light
            );

            sc_visual_line(_x, _y, _radius, _angle,
                0.37, 0.52 * _side,
                0.17, 0.75 * _side,
                1, _p.metal
            );

            sc_visual_triangle(_x, _y, _radius, _angle,
                0.85, 0.05 * _side,
                0.34, 0.12 * _side,
                0.14, 0.21 * _side,
                _p.metal, false
            );

            sc_visual_line(_x, _y, _radius, _angle,
                0.85, 0.05 * _side,
                0.34, 0.12 * _side,
                1, _p.core
            );
        }

        // ==================================================
        // OUTER-MIDDLE PLATES - STAGES 0, 1
        // ==================================================
        if (_stage <= 1)
        {
            sc_visual_quad(_x, _y, _radius, _angle,
                0.13, 0.82 * _side,
                -0.08, 1.19 * _side,
                -0.34, 1.01 * _side,
                -0.25, 0.74 * _side,
                _p.metal
            );

            sc_visual_line(_x, _y, _radius, _angle,
                0.13, 0.82 * _side,
                -0.08, 1.19 * _side,
                1, _p.core
            );

            sc_visual_quad(_x, _y, _radius, _angle,
                -0.24, 0.53 * _side,
                -0.36, 0.88 * _side,
                -0.53, 0.73 * _side,
                -0.49, 0.46 * _side,
                _p.hull_light
            );

            sc_visual_line(_x, _y, _radius, _angle,
                -0.36, 0.88 * _side,
                -0.53, 0.73 * _side,
                1, _p.metal
            );
        }

        // ==================================================
        // OUTER BLADE ARMOUR - STAGE 0 ONLY
        // ==================================================
        if (_stage == 0)
        {
            sc_visual_triangle(_x, _y, _radius, _angle,
                0.3, 0.94 * _side,
                -0.11, 1.48 * _side,
                -0.28, 1.25 * _side,
                _p.hull_light, false
            );

            sc_visual_line(_x, _y, _radius, _angle,
                0.3, 0.94 * _side,
                -0.11, 1.48 * _side,
                2, _p.metal
            );

            sc_visual_quad(_x, _y, _radius, _angle,
                -0.12, 1.2 * _side,
                -0.27, 1.38 * _side,
                -0.45, 1.02 * _side,
                -0.34, 0.92 * _side,
                _p.metal
            );
        }
    }

    // ==================================================
    // CENTRAL NOSE ARMOUR
    // ==================================================

    // Small nose cap survives through every armour stage.
    sc_visual_triangle(_x, _y, _radius, _angle,
        1, 0,
        0.73, -0.07,
        0.81, 0,
        _p.metal, false
    );

    sc_visual_triangle(_x, _y, _radius, _angle,
        1, 0,
        0.81, 0,
        0.73, 0.07,
        _p.metal, false
    );

    sc_visual_line(_x, _y, _radius, _angle, 1, 0, 0.73, -0.07, 1, _p.core);
    sc_visual_line(_x, _y, _radius, _angle, 1, 0, 0.73, 0.07, 1, _p.core);

    // Main central armour survives through stage 2.
    if (_stage <= 2)
    {
        sc_visual_triangle(_x, _y, _radius, _angle,
            0.76, -0.08,
            0.25, -0.2,
            -0.45, -0.04,
            _p.hull_light, false
        );

        sc_visual_triangle(_x, _y, _radius, _angle,
            0.76, 0.08,
            -0.45, 0.04,
            0.25, 0.2,
            _p.hull_light, false
        );

        sc_visual_line(_x, _y, _radius, _angle, 0.76, -0.08, 0.25, -0.2, 1, _p.metal);
        sc_visual_line(_x, _y, _radius, _angle, 0.76, 0.08, 0.25, 0.2, 1, _p.metal);
    }

    // Rear central armour exists through stage 1.
    if (_stage <= 1)
    {
        sc_visual_triangle(_x, _y, _radius, _angle,
            0.17, -0.19,
            -0.14, -0.25,
            -0.57, -0.07,
            _p.metal, false
        );

        sc_visual_triangle(_x, _y, _radius, _angle,
            0.17, 0.19,
            -0.57, 0.07,
            -0.14, 0.25,
            _p.metal, false
        );
    }

    // Reactor armour collar exists only at full armour.
    if (_stage == 0)
    {
        sc_visual_circle(_x, _y, _radius, _angle, -0.19, 0, 0.31, _p.void, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.19, 0, 0.31, _p.metal, true);
        sc_visual_circle(_x, _y, _radius, _angle, -0.19, 0, 0.255, _p.hull_light, true);
    }
}

/// @description Draws one independently rotating Dreadwing pulse cannon.
function sc_enemy_sim_dreadwing_cannon_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha);

    // Circular rotating base.
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.135, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.135, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0, 0, 0.09, _p.hull_mid, false);

    // Armoured barrel body.
    sc_visual_quad(_x, _y, _radius, _angle, -0.04, -0.085, 0.31, -0.07, 0.31, 0.07, -0.04, 0.085, _p.hull_light);
    sc_visual_quad(_x, _y, _radius, _angle, 0.02, -0.045, 0.39, -0.04, 0.39, 0.04, 0.02, 0.045, _p.metal);

    // Dark barrel channel and violet energy rail.
    sc_visual_line(_x, _y, _radius, _angle, 0.03, 0, 0.43, 0, 7, _p.void);
    sc_visual_line(_x, _y, _radius, _angle, 0.08, 0, 0.4, 0, 2, _p.energy);

    // Mechanical barrel collars.
    sc_visual_line(_x, _y, _radius, _angle, 0.13, -0.08, 0.13, 0.08, 2, _p.outline);
    sc_visual_line(_x, _y, _radius, _angle, 0.28, -0.07, 0.28, 0.07, 2, _p.accent);

    // Muzzle housing.
    sc_visual_quad(_x, _y, _radius, _angle, 0.33, -0.095, 0.45, -0.08, 0.45, 0.08, 0.33, 0.095, _p.hull_dark);
    sc_visual_circle(_x, _y, _radius, _angle, 0.445, 0, 0.075, _p.void, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.445, 0, 0.075, _p.metal, true);
    sc_visual_circle(_x, _y, _radius, _angle, 0.445, 0, 0.037, _p.energy, false);
    sc_visual_circle(_x, _y, _radius, _angle, 0.445, 0, 0.015, _p.core, false);

    draw_set_alpha(1);
}

/// @description Draws the Dreadwing's rotating central reactor centred inside its baked sprite.
function sc_enemy_sim_dreadwing_core_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.235;
    var _middle = _radius * 0.16;
    var _inner = _radius * 0.075;

    draw_set_alpha(_alpha * 0.24);
    draw_set_colour(_p.glow);
    draw_circle(_x, _y, _outer * 1.5, false);

    draw_set_alpha(_alpha);
    draw_set_colour(_p.void);
    draw_circle(_x, _y, _outer, false);

    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _outer, true);

    draw_set_colour(_p.hull_light);
    draw_circle(_x, _y, _middle, true);

    for (var _i = 0; _i < 8; _i++)
    {
        var _direction = _angle + _i * 45;
        var _x1 = _x + lengthdir_x(_inner * 0.7, _direction);
        var _y1 = _y + lengthdir_y(_inner * 0.7, _direction);
        var _x2 = _x + lengthdir_x(_outer * 0.88, _direction + 13);
        var _y2 = _y + lengthdir_y(_outer * 0.88, _direction + 13);

        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.outline);
        draw_line_width(_x1, _y1, _x2, _y2, 3);
    }

    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _inner * 1.65, true);

    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _inner, false);

    draw_set_colour(_p.core);
    draw_circle(_x, _y, _inner * 0.42, false);

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Creates the complete Dreadwing destruction visual.
function sc_enemy_sim_dreadwing_death(_enemy)
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

    array_push(_fragments, sc_death_fragment_data(_cache.fragments[0], _enemy.x + lengthdir_x(_radius * 0.25, _angle), _enemy.y + lengthdir_y(_radius * 0.25, _angle), _angle + random_range(-10, 10), random_range(2, 3), _angle, choose(-6, 6), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[1], _enemy.x + lengthdir_x(-_radius * 0.05, _angle) + lengthdir_x(-_radius * 0.76, _angle + 90), _enemy.y + lengthdir_y(-_radius * 0.05, _angle) + lengthdir_y(-_radius * 0.76, _angle + 90), _angle - 75 + random_range(-10, 10), random_range(2.8, 4), _angle, random_range(-9, -5), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.fragments[2], _enemy.x + lengthdir_x(-_radius * 0.05, _angle) + lengthdir_x(_radius * 0.76, _angle + 90), _enemy.y + lengthdir_y(-_radius * 0.05, _angle) + lengthdir_y(_radius * 0.76, _angle + 90), _angle + 75 + random_range(-10, 10), random_range(2.8, 4), _angle, random_range(5, 9), 1));
    array_push(_fragments, sc_death_fragment_data(_cache.core, _enemy.x, _enemy.y, irandom(359), random_range(1.5, 2.4), _angle, choose(-10, 10), 0.95));

    for (var _i = 0; _i < array_length(_data.hardpoints); _i++)
    {
        var _hardpoint = _data.hardpoints[_i];
        var _hardpoint_x = _enemy.x + lengthdir_x(_hardpoint.forward * _radius, _angle) + lengthdir_x(_hardpoint.side * _radius, _angle + 90);
        var _hardpoint_y = _enemy.y + lengthdir_y(_hardpoint.forward * _radius, _angle) + lengthdir_y(_hardpoint.side * _radius, _angle + 90);
        var _direction = _angle + point_direction(0, 0, 0, _hardpoint.side);

        array_push(_fragments, sc_death_fragment_data(_cache.hardpoints[_i], _hardpoint_x, _hardpoint_y, _direction + random_range(-16, 16), random_range(3, 4.5), _angle, choose(-12, 12), 0.95));
    }

    for (var _i = 0; _i < array_length(_fragments); _i++)
    {
        _fragments[_i].velocity_x += _velocity_x * 0.3;
        _fragments[_i].velocity_y += _velocity_y * 0.3;
    }

    sc_death_fragment_create(_enemy.x, _enemy.y, _fragments, _palette.core, _palette.glow, _radius, 52);
    return true;
}

/// @description Draws the broken central Dreadwing fragment.
function sc_enemy_sim_dreadwing_fragment_centre_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_triangle(_x, _y, _radius, _angle, 0.88, 0, 0.15, -0.25, -0.62, 0, _p.hull_dark, false);
    sc_visual_triangle(_x, _y, _radius, _angle, 0.88, 0, -0.62, 0, 0.15, 0.25, _p.hull_mid, false);

    sc_visual_line(_x, _y, _radius, _angle, 0.88, 0, 0.15, -0.25, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.88, 0, 0.15, 0.25, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, -0.5, 0, 0.62, 0, 3, _p.accent);
}

/// @description Draws the broken upper/left Dreadwing wing fragment.
function sc_enemy_sim_dreadwing_fragment_left_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 0.42, -0.18, 0.18, -0.86, -0.13, -1.43, -0.6, -0.49, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.3, -0.29, 0.1, -0.78, -0.14, -1.22, -0.46, -0.5, _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle, 0.42, -0.18, 0.18, -0.86, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.18, -0.86, -0.13, -1.43, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.08, -0.72, -0.31, -0.62, 3, _p.energy);
}

/// @description Draws the broken lower/right Dreadwing wing fragment.
function sc_enemy_sim_dreadwing_fragment_right_draw(_x, _y, _radius, _angle, _visual)
{
    var _p = _visual.palette;

    sc_visual_quad(_x, _y, _radius, _angle, 0.42, 0.18, -0.6, 0.49, -0.13, 1.43, 0.18, 0.86, _p.hull_dark);
    sc_visual_quad(_x, _y, _radius, _angle, 0.3, 0.29, -0.46, 0.5, -0.14, 1.22, 0.1, 0.78, _p.hull_mid);

    sc_visual_line(_x, _y, _radius, _angle, 0.42, 0.18, 0.18, 0.86, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.18, 0.86, -0.13, 1.43, 2, _p.metal);
    sc_visual_line(_x, _y, _radius, _angle, 0.08, 0.72, -0.31, 0.62, 3, _p.energy);
}

/// @description Draws the containment ring over the Dreadwing's weaponized core.
function sc_enemy_sim_dreadwing_core_emitter_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;
    var _outer = _radius * 0.255;

    draw_set_alpha(_alpha * 0.75);
    draw_set_colour(_p.metal);
    draw_circle(_x, _y, _outer, true);

    for (var _i = 0; _i < 4; _i++)
    {
        var _direction = _angle + _i * 90;

        draw_set_colour(_p.outline);
        draw_line_width(
            _x + lengthdir_x(_outer * 0.82, _direction),
            _y + lengthdir_y(_outer * 0.82, _direction),
            _x + lengthdir_x(_outer * 1.16, _direction),
            _y + lengthdir_y(_outer * 1.16, _direction),
            3
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Intensifies the Dreadwing core before releasing its seeker orb.
function sc_enemy_sim_dreadwing_seeker_telegraph_draw(_enemy, _attack, _transform, _progress, _palette, _config)
{
    var _radius = _enemy.enemy.visual.radius;
    var _charge = _progress * _progress * (3 - 2 * _progress);
    var _pulse_speed = lerp(0.15, 0.75, _charge);
    var _pulse = 0.88 + sin(GAME_TICK * _pulse_speed) * lerp(0.08, 0.2, _charge);
    var _core_radius = lerp(_radius * 0.045, _radius * 0.19, _charge) * _pulse;
    var _orbit_radius = lerp(_radius * 0.55, _radius * 0.23, _charge);
    var _rotation = GAME_TICK * lerp(2, 11, _charge);
    var _alpha = lerp(0.28, 1, _charge);

    gpu_set_blendmode(bm_add);

    // Core glow becomes larger and considerably brighter.
    draw_set_colour(_palette.glow);
    draw_set_alpha(_alpha * lerp(0.12, 0.34, _charge));
    draw_circle(
        _transform.x,
        _transform.y,
        _core_radius * lerp(2.2, 3.8, _charge),
        false
    );

    draw_set_colour(_palette.accent);
    draw_set_alpha(_alpha * lerp(0.25, 0.65, _charge));
    draw_circle(
        _transform.x,
        _transform.y,
        _core_radius * 1.8,
        false
    );

    // Rotating energy arms collapse inward.
    for (var _i = 0; _i < 8; _i++)
    {
        var _direction = _rotation + _i * 45;
        var _inner = max(_core_radius, _radius * 0.09);
        var _outer = _orbit_radius;

        draw_set_colour((_i mod 2) == 0 ? _palette.energy : _palette.accent);
        draw_set_alpha(_alpha * 0.85);

        draw_line_width(
            _transform.x + lengthdir_x(_outer, _direction),
            _transform.y + lengthdir_y(_outer, _direction),
            _transform.x + lengthdir_x(_inner, _direction + 16),
            _transform.y + lengthdir_y(_inner, _direction + 16),
            lerp(1, 3, _charge)
        );

        draw_set_colour(_palette.core);
        draw_circle(
            _transform.x + lengthdir_x(_outer, _direction),
            _transform.y + lengthdir_y(_outer, _direction),
            lerp(1, 2.5, _charge),
            false
        );
    }

    draw_set_colour(_palette.energy);
    draw_set_alpha(_alpha);
    draw_circle(
        _transform.x,
        _transform.y,
        _core_radius,
        false
    );

    draw_set_colour(_palette.core);
    draw_set_alpha(lerp(0.7, 1, _charge));
    draw_circle(
        _transform.x,
        _transform.y,
        max(2, _core_radius * 0.32),
        false
    );

    // Final-frame white-hot flash.
    if (_progress > 0.88)
    {
        var _flash = (_progress - 0.88) / 0.12;

        draw_set_colour(c_white);
        draw_set_alpha(_flash * 0.8);
        draw_circle(
            _transform.x,
            _transform.y,
            _core_radius * (1 + _flash * 0.45),
            false
        );
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}