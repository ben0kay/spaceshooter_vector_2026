/// @description Registers the Corporation battleship rocket.
function sc_projectile_register_corporation_rocket()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    return sc_projectile_register({
        identity: {
            key: "projectile_corporation_rocket",
            name: "Corporation Rocket"
        },

        projectile_motion: ProjectileMotion.ROCKET,
        projectile_class: ProjectileClass.HEAVY,

        collision: {
            radius: 9
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 80
                },

                behaviour: {
                    duration: 18,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.2,
                    falloff_exponent: 1.25
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_simulant_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.3,
                        expansion_response: 0.18,
                        fade_speed: 0.045,
                        thickness: 4,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 8,

                        smoke_enabled: true,
                        smoke_amount_max: 4,
                        smoke_colour: _palette.hull_dark,

                        fragments_enabled: true,
                        fragment_chance: 0.48,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        visual: {
            radius: 10,
            length: 36,
            palette: _palette,
            draw_script: sc_projectile_simulant_rocket_draw,
            impact_script: sc_projectile_corporation_rocket_impact,
            particles_register_script: sc_projectile_corporation_rocket_particles_register,

            trail: {
                enabled: true,
                length: 64,
                width: 2.5,
                glow_width: 8,
                alpha: 0.78,
                glow_alpha: 0.2
            },

            bake: {
                canvas_size: 128,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers Corporation rocket impact particles.
function sc_projectile_corporation_rocket_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    return sc_particles_projectile_impact_register("impact_corporation_rocket", _palette, {
        scale: 1.4,
        spark_amount: 18,
        fragment_amount: 10,
        spark_spread: 170,
        speed_min: 3,
        speed_max: 7
    });
}

/// @description Emits one Corporation rocket impact.
function sc_projectile_corporation_rocket_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_corporation_rocket",
        _x, _y, _direction, _scale
    );
}