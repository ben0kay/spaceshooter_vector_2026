/// @description Creates centralized game-wide tuning values.
function sc_config_init()
{
    global.config = {
        visual: {
            ship_motion: {
                side_amount: 0.6, side_speed: 0.018,
                forward_amount: 1.2, forward_speed: 0.012
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
                visual_mass_min: 0.5, visual_mass_max: 3,
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
            }
        }
    };

    return true;
}