/*
CORPORATION ARTILLERY ROCKET

Heavy unguided long-range rocket used by Corporation artillery vessels.
*/

/// @description Registers the Corporation heavy artillery rocket.
function sc_projectile_register_corporation_artillery_rocket()
{
    var _palette = sc_faction_palette_elite_get(Faction.CORPORATION);

    return sc_projectile_register({
        identity: {
            key: "projectile_corporation_artillery_rocket",
            name: "Corporation Artillery Rocket"
        },

        projectile_motion: ProjectileMotion.ROCKET,
        projectile_class: ProjectileClass.HEAVY,

        collision: {
            radius: 13
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 145
                },

                behaviour: {
                    duration: 24,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.2,
                    falloff_exponent: 1.35
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_corporation_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.45,
                        expansion_response: 0.14,
                        fade_speed: 0.036,
                        thickness: 6,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 10,

                        smoke_enabled: true,
                        smoke_amount_max: 7,
                        smoke_colour: _palette.hull_dark,

                        fragments_enabled: true,
                        fragment_chance: 0.7,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        visual: {
            radius: 14,
            length: 54,
            palette: _palette,
            draw_script: sc_projectile_corporation_rocket_draw,
            impact_script: sc_projectile_corporation_rocket_impact,
            trail_script: sc_projectile_particle_trail_emit,

            particle_trail: {
                group: "trail_corporation_rocket",
                interval: 1,
                amount: 2,
                rear_scale: 0.52,
                spread: 8,
                size_min: 0.15,
                size_max: 0.24,
                size_growth: 0.006,
                size_wiggle: 0.018
            },

            trail: {
                enabled: true,
                length: 105,
                width: 4,
                glow_width: 13,
                alpha: 0.88,
                glow_alpha: 0.28
            },

            bake: {
                canvas_size: 192,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}