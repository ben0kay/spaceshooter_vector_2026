/// @description Creates centralized game-wide tuning values.
function sc_config_init()
{
    global.config = {
		
		debug: {
		    structure_collision: true,
			player_full_loadout: true,
			asteroid_clearance: true,
			show_fps: true,
			room_restart: true,
		},
		
        visual: {
            ship_motion: {
                side_amount: 0.6, side_speed: 0.018,
                forward_amount: 1.2, forward_speed: 0.012
            },
			
			projectile_motion: {
		    rocket: {
		        reference_speed: 16,
		        reference_radius: 8,
		        amount: 1.6,
		        frequency: 0.16,
		        angle: 1.4,
		        influence_min: 0.3,
		        influence_max: 1.35
		    }
		},
			
			enemy_death: {
		    shake_base: 3.5, shake_per_mass: 1.5,
		    shake_min: 3.5, shake_max: 8,
		    time_base: 7, time_per_mass: 2, time_max: 12,
		    falloff_start: 640, falloff_end: 1600, falloff_min: 0
		},

            enemy_thrust: {
                active_power_min: 0.05, emit_power_min: 0.15, emit_interval: 3,
                radius_reference: 52, radius_factor_min: 0.65, radius_factor_max: 2.5,
                mass_min: 0.5, mass_max: 3,
                width_base: 0.8, width_radius_mix: 0.72,

                ignition: {
                    length_base: 0.7, mass_weight: 0.45,
                    power_min: 0.8, power_max: 1.3,
                    ring_size_min: 0.22, ring_size_max: 0.34, ring_growth: 0.065,
                    life_min_base: 10, life_min_mass: 2,
                    life_max_base: 14, life_max_mass: 3,
                    trail_spread: 20, trail_size_min: 0.14, trail_size_max: 0.3,
                    trail_shrink: -0.005, trail_growth: 0.035,
                    trail_speed_min: 1.2, trail_speed_max: 3.2, trail_speed_reduce: -0.04,
                    trail_life_min_base: 10, trail_life_min_length: 4,
                    trail_life_max_base: 16, trail_life_max_length: 7,
                    trail_count_scale: 4, trail_count_min: 3, trail_count_max: 8
                },

                trail: {
                    length_base: 0.65, mass_weight: 0.42,
                    power_min: 0.55, power_max: 1.75,
                    direction_spread: 7, side_spread: 2.5,
                    size_min: 0.1, size_max_base: 0.15, size_max_power: 0.1,
                    shrink: -0.004, growth: 0.018,
                    speed_min: 0.8, speed_max: 2.3, speed_reduce: -0.025,
                    life_min_base: 11, life_min_length: 4,
                    life_max_base: 17, life_max_length: 7,
                    wide_threshold: 1.25, count_normal: 1, count_wide: 2
                }
            },

			enemy_damage: {
			    hull_threshold: 0.5,
			    footprint_scale: 0.68,
			    interval_max: 18,
			    interval_min: 3,
			    puff_count_min: 1,
			    puff_count_max: 3,

			    radius_reference: 58,
			    scale_min: 0.7,
			    scale_max: 3.5,
			    mass_scale: 0.12,

			    size_min: 0.28,
			    size_max: 0.62,
			    growth: 0.018,
			    size_wiggle: 0.045,

			    speed_min: 0.15,
			    speed_max: 0.7,
			    speed_reduce: -0.012,

			    life_min: 26,
			    life_max: 38,
			    life_min_severe: 38,
			    life_max_severe: 58
			},

            shield: {
                radius_scale: 1.28,
                field_centre_mix: 0.72, field_edge_mix: 0.28, field_alpha: 0.62,
                inner_scale: 0.93, inner_alpha: 0.18,
                glow_layers: 3, glow_spacing: 1, glow_alpha: 0.16, glow_alpha_falloff: 0.035,
                outline_alpha: 0.88, inner_outline_offset: 2, inner_outline_alpha: 0.5,
                runtime_alpha_base: 0.28, runtime_alpha_charge: 0.5, runtime_alpha_max: 0.82,
                idle_pulse_base: 0.88, idle_pulse_amount: 0.12, idle_pulse_speed: 0.08,
                idle_scale_amount: 0.008, idle_scale_speed: 0.06,
                hit_scale_amount: 0.11, hit_flash_alpha: 0.48
            }
        },
		
		optimization: {
		    enemy_screen_padding: 128,
		    enemy_visual_radius_scale: 1.75,

		    enemy_updates: {
		        perception_idle_interval: 4,
		        perception_active_interval: 2,
		        hardpoint_idle_interval: 4,

		        lazy_visible: 1,
		        lazy_offscreen: 2,
		        lazy_distant: 4,
		        lazy_very_distant: 8,

		        distant_range: 1800,
		        very_distant_range: 3600
		    }
		},

		sector: {
            world_seed: 8122026,
            edge_spawn_padding: 640,

            asteroid_fields: {
			    amount_min: 4,
			    amount_max: 6,
			    centre_padding: 2800,
			    centre_separation: 4400,
			    spawn_clear_radius: 2200,
				budget_min: 360,
				budget_max: 420,
				population_multiplier: 1.5,
				structure_clearance: 1200,
				density_depletion_power: 0.65,

			    materials: [
    {
        key: "asteroid_rock",
        weight: 33,
        rich_weight: 0,
        min_sector_east: 0,
        rich_min_sector_east: 0
    },
    {
        key: "asteroid_carbon",
        weight: 13,
        rich_weight: 13,
        min_sector_east: 0,
        rich_min_sector_east: 0
    },
    {
        key: "asteroid_iron",
        weight: 11,
        rich_weight: 11,
        min_sector_east: 0,
        rich_min_sector_east: 0
    },
    {
        key: "asteroid_copper",
        weight: 8,
        rich_weight: 8,
        min_sector_east: 0,
        rich_min_sector_east: 1
    },
    {
        key: "asteroid_silicon",
        weight: 7,
        rich_weight: 7,
        min_sector_east: 0,
        rich_min_sector_east: 1
    },
    {
        key: "asteroid_ice",
        weight: 10,
        rich_weight: 8,
        min_sector_east: 0,
        rich_min_sector_east: 2
    },
    {
        key: "asteroid_sulfur",
        weight: 8,
        rich_weight: 6,
        min_sector_east: 1,
        rich_min_sector_east: 3
    },
    {
        key: "asteroid_quartz",
        weight: 4,
        rich_weight: 3,
        min_sector_east: 2,
        rich_min_sector_east: 4
    },
    {
        key: "asteroid_titanium",
        weight: 3,
        rich_weight: 1.5,
        min_sector_east: 3,
        rich_min_sector_east: 6
    },
    {
        key: "asteroid_crystal",
        weight: 2,
        rich_weight: 0.75,
        min_sector_east: 5,
        rich_min_sector_east: 9
    },
    {
        key: "asteroid_uranium",
        weight: 1,
        rich_weight: 0.2,
        min_sector_east: 6,
        rich_min_sector_east: 12
    }
],

			    sizes: [
			        { size: AsteroidSize.SMALL, weight: 12 },
			        { size: AsteroidSize.MEDIUM, weight: 46 },
			        { size: AsteroidSize.LARGE, weight: 34 },
			        { size: AsteroidSize.HUGE, weight: 8 }
			    ]
			}
        },

        projectile: {
            classes: [
                {
                    name: "Light",
                    camera_shake: 0.65, shake_time: 3,
                    shield_deflect: 1, deflect_chance: 0.5,
                    deflect_speed: 4.5, deflect_life: 24,
                    deflect_shrink: 0.97, deflect_scale: 0.9,
                    deflect_spread: 3, deflect_strength: 0.3
                },
                {
                    name: "Regular",
                    camera_shake: 1.25, shake_time: 5,
                    shield_deflect: 0, deflect_chance: 0,
                    deflect_speed: 3, deflect_life: 18,
                    deflect_shrink: 0.965, deflect_scale: 1,
                    deflect_spread: 5, deflect_strength: 0.3
                },
                {
                    name: "Heavy",
                    camera_shake: 2.5, shake_time: 9,
                    shield_deflect: 0, deflect_chance: 0,
                    deflect_speed: 2, deflect_life: 14,
                    deflect_shrink: 0.96, deflect_scale: 1.15,
                    deflect_spread: 3, deflect_strength: 0.3
                }
            ]
        },

        damage: {
            types: [
                { name: "Kinetic", shield_multiplier: 0.65, armour_multiplier: 1.35, hull_multiplier: 1, default_effect: DamageEffect.NONE },
                { name: "Energy", shield_multiplier: 1.5, armour_multiplier: 0.75, hull_multiplier: 1, default_effect: DamageEffect.NONE },
                { name: "Explosive", shield_multiplier: 0.75, armour_multiplier: 1, hull_multiplier: 1.4, default_effect: DamageEffect.NONE },
                { name: "Electric", shield_multiplier: 1.15, armour_multiplier: 0.55, hull_multiplier: 0.75, default_effect: DamageEffect.DISRUPTION },
                { name: "Thermal", shield_multiplier: 0.4, armour_multiplier: 1.1, hull_multiplier: 1.25, default_effect: DamageEffect.BURN },
                { name: "Corrosive", shield_multiplier: 0.55, armour_multiplier: 1.3, hull_multiplier: 1.2, default_effect: DamageEffect.CORROSION }
            ],

            effects: [
                { name: "None", chance: 0, duration: 0, strength: 0, tick_interval: 0 },
                { name: "Disruption", chance: 0.25, duration: 180, strength: 0.25, tick_interval: 0 },
                { name: "Burn", chance: 0.2, duration: 180, strength: 0.15, tick_interval: 30 },
                { name: "Corrosion", chance: 0.25, duration: 240, strength: 0.2, tick_interval: 30 },
                { name: "Stagger", chance: 1, duration: 12, strength: 0.45, tick_interval: 0 }
            ]
        },

        enemy: {
			
			perception: {
			    line_of_sight: {
			        enabled: true,
			        solids: true,
			        asteroids: true
			    },

			    asteroid_concealment: {
			        enabled: true,
			        nearby_radius: 256,
			        sample_radius: 190,
			        sample_amount: 7,
			        blocked_required: 4
			    }
			},
			
			rear_damage: {
			    arc: 40,
			    multiplier: 1.25
			},
			
			critical_response: {
			    class_chance_multiplier: [1, 0.6, 0.25, 0.1, 0.02, 0],
			    field_repair_armour_min: 0.1,
			    field_repair_armour_max: 0.25,
			    return_arrival_margin: 32
			},
			
            separation: {
                strength: 0.14,
                maximum_push: 0.8,
                position_correction: 0.18
            },

            wander: {
                speed_scale: 0.45,
                arrival_radius: 32,
                wait_min: 60,
                wait_max: 150,
                candidate_attempts: 4,
                edge_margin: 24
            },
				
			asteroid: {
			    check_interval: 4,
				destroy_visibility_interval: 30,
				bombard_field_check_interval: 60,
				bombard_field_clearance: 180,
				bombard_arrival_radius: 80,
				bombard_speed_scale: 0.7,
				destroy_damage_multiplier: 3,
			    clearance_margin: 10,
			    look_ahead_base: 70,
			    look_ahead_speed: 14,
			    sample_spacing_scale: 0.65,
			    candidate_angles: [25, -25, 50, -50, 75, -75, 105, -105],
			    side_switch_penalty: 30,
			    line_of_sight_width_scale: 0.45
			},
				
			engagement: {
                limit_to_player_range: true,
                activation_range: 4000
            },
			
			field_navigation: {
			    check_interval: 30,

			    class_penalty: [
			        0.05,
			        0.08,
			        0.11,
			        0.14,
			        0.17,
			        0.2,
			        0.23
			    ]
			},
        },
			
		asteroid: {
			
			composition: {
		        rock_item_key: "item_rock",
		        ore_chance: 0.5
		    },
			
		    extraction: {
		        weapon_efficiency: 0.45,
		        destruction_efficiency: 0.15
		    },
				
			

		    pickup: {
			    launch_speed_min: 1.8,
			    launch_speed_max: 3.6,
			    mining_launch_multiplier: 1.65,
			    spawn_clearance: 14,

			    movement_decay: 0.965,
			    attraction_delay: 20,
			    attraction_range: 420,
			    attraction_strength_min: 0.18,
			    attraction_strength_max: 0.75,
			    attraction_speed_max: 11,
			    collect_range: 72,

			    lifetime: 5400,
			    fade_duration: 300,

			    trail_interval: 2,
			    trail_speed_min: 0.35,

			    merge_interval: 16,
			    merge_range: 70,
			    merge_amount_max: 999,

			    scale_base: 0.92,
			    scale_per_decade: 0.1,
			    scale_max: 1.25,
				player_drop_lifetime_multiplier: 3
			},
				
			death: {
		        visibility_padding: 192,

		        smoke: {
		            amount_min: 4,
		            amount_max: 10,
		            radius_scale: 0.65,
		            size_reference: 58,
		            size_min: 0.8,
		            size_max: 3
		        },

		        shockwave: {
		            radius_scale: 1.1,
		            expansion_response: 0.18,
		            fade_speed: 0.045,
		            thickness: 4,
		            colour: make_colour_rgb(170,190,200),

		            particles_enabled: true,
		            particle_interval: 2,
		            particle_min_radius: 8,

		            smoke_enabled: true,
		            smoke_amount_max: 4,
		            smoke_colour: make_colour_rgb(80,90,95),

		            fragments_enabled: true,
		            fragment_chance: 0.3,
		            fragment_colour: make_colour_rgb(190,210,220),

		            shape: {
		                forward_min: 1.05,
		                forward_max: 1.35,
		                side_min: 0.6,
		                side_max: 0.9
		            }
		        }
    }
		},
		
			
		crafting: {
		    grades: [
		        { chance: 0, multiplier: 1 },
		        { chance: 0.01, multiplier: 1.05 },
		        { chance: 0.002, multiplier: 1.15 },
		        { chance: 0.0004, multiplier: 1.25 },
		        { chance: 0.0001, multiplier: 1.4 }
		    ]
		},
			
		player: {
		    heat_signature: {
		        maximum_range: 4000,

		        mining: {
		            interval: 45,
		            strength: 1
		        }
		    },

		    critical_hit: {
		        projectile: {
		            kinetic: {
		                chance: 0.05,
		                multiplier: 5,
		                armour_enabled: false
		            }
		        }
		    }
		},
			
		player_collision: {
		    asteroid_bounce: 0.38,
		    asteroid_bounce_min: 1.2,
		    dash_substep_threshold: 12,
		    movement_step_max: 6
		},
    };

    return true;
}

/*
CENTRAL INPUT

All physical keyboard and mouse bindings live here.
Gameplay systems consume named actions rather than checking keys directly.
The bindings struct can later be changed and saved by an Options menu.
*/

/// @description Creates all default player bindings and input runtime.
function sc_input_init()
{
    global.input = {
        binding: {
            move_left: vk_left,
            move_right: vk_right,
            move_up: vk_up,
            move_down: vk_down,

            fire_primary: mb_left,
			fire_secondary: mb_middle,
			shield_focus: mb_right,
			equipment: ord("Q"),
            inventory: ord("E"),
			interact: ord("F"),
			map: ord("M"),
            dash: vk_shift,
			
			debug_enemy_spawn: vk_f1,
			debug_weapon_test: vk_f2,

            fullscreen: vk_f11
        },

        action: {
            move_left: false,
            move_right: false,
            move_up: false,
            move_down: false,

            fire_primary: false,
			fire_secondary: false,
			shield_focus: false,
			equipment_pressed: false,

			primary_cycle: 0,
			secondary_cycle: 0,

            ui_select_held: false,
            ui_select_pressed: false,
            ui_select_released: false,

            fullscreen_pressed: false,
            inventory_pressed: false,
			interact_pressed: false,
            dash_held: false,
            dash_pressed: false,
			
			debug_enemy_spawn_pressed: false,
			debug_weapon_test_pressed: false,
			
			map_pressed: false,
        }
    };

    return true;
}

/// @description Samples every centralized player action once per Step.
function sc_input_update()
{
    var _binding = global.input.binding;
    var _action = global.input.action;

    _action.fullscreen_pressed = keyboard_check_pressed(_binding.fullscreen);

    _action.move_left = keyboard_check(_binding.move_left);
    _action.move_right = keyboard_check(_binding.move_right);
    _action.move_up = keyboard_check(_binding.move_up);
    _action.move_down = keyboard_check(_binding.move_down);

    _action.fire_primary = mouse_check_button(_binding.fire_primary);
    _action.fire_secondary = mouse_check_button(_binding.fire_secondary);
    _action.shield_focus = mouse_check_button(_binding.shield_focus);
    _action.equipment_pressed = keyboard_check_pressed(_binding.equipment);
	_action.map_pressed = keyboard_check_pressed(_binding.map);

    _action.primary_cycle = 0;
    _action.secondary_cycle = 0;

    var _wheel = mouse_wheel_down() - mouse_wheel_up();

    if (_wheel != 0 && !keyboard_check(vk_control))
    {
        if (keyboard_check(vk_shift))
            _action.secondary_cycle = _wheel;
        else
            _action.primary_cycle = _wheel;
    }

    _action.ui_select_held = mouse_check_button(mb_left);
    _action.ui_select_pressed = mouse_check_button_pressed(mb_left);
    _action.ui_select_released = mouse_check_button_released(mb_left);

    _action.inventory_pressed = keyboard_check_pressed(_binding.inventory);
    _action.interact_pressed = keyboard_check_pressed(_binding.interact);
    _action.dash_held = keyboard_check(_binding.dash);
    _action.dash_pressed = keyboard_check_pressed(_binding.dash);

    _action.debug_enemy_spawn_pressed = keyboard_check_pressed(_binding.debug_enemy_spawn);
    _action.debug_weapon_test_pressed = keyboard_check_pressed(_binding.debug_weapon_test);
}