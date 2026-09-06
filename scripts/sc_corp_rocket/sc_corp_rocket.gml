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
            radius: 10,
            length: 36,
            palette: _palette,
            draw_script: sc_projectile_simulant_rocket_draw,
            impact_script: sc_projectile_corporation_rocket_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_corporation_rocket_particles_register,

            particle_trail: {
                group: "trail_corporation_rocket",
                interval: 2,
                amount: 1,
                rear_scale: 0.48,
                spread: 6,
                size_min: 0.1,
                size_max: 0.17,
                size_growth: 0.004,
                size_wiggle: 0.015
            },

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

/// @description Registers Corporation rocket impact and energized trail particles.
function sc_projectile_corporation_rocket_particles_register()
{
    var _palette = sc_faction_palette_get(
        Faction.CORPORATION
    );

    if (!sc_particles_projectile_impact_register(
        "impact_corporation_rocket",
        _palette,
        {
            scale: 1.4,
            spark_amount: 18,
            fragment_amount: 10,
            spark_spread: 170,
            speed_min: 3,
            speed_max: 7
        }
    ))
        return false;

    return sc_particles_projectile_trail_register(
        "trail_corporation_rocket",
        {
            sprite: s_particle_firesmoke_trail_color,

            colour_start: _palette.core,
            colour_middle: _palette.energy,
            colour_end: _palette.glow,

            alpha_start: 0.62,
            alpha_middle: 0.3,

            speed_min: 0.4,
            speed_max: 1.1,
            speed_reduce: -0.02,

            life_min: 12,
            life_max: 19,

            rotation_speed: 1.5,
            blend_additive: true
        }
    );
}

/// @description Emits one Corporation rocket impact.
function sc_projectile_corporation_rocket_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_corporation_rocket",
        _x, _y, _direction, _scale
    );
}