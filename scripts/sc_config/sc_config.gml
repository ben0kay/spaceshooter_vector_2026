/// @description Creates centralized game-wide tuning values.
function sc_config_init()
{
    global.config = {
        visual: {
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
                    deflect_spread: 5
                },
                {
                    name: "Heavy",
                    camera_shake: 2.5, shake_time: 9,
                    shield_deflect: 0, deflect_chance: 0,
                    deflect_speed: 2, deflect_life: 14,
                    deflect_shrink: 0.96, deflect_scale: 1.15,
                    deflect_spread: 3
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
                { name: "Corrosion", chance: 0.25, duration: 240, strength: 0.2, tick_interval: 30 }
            ]
        }
    };

    return true;
}