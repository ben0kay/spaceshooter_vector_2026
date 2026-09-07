/*
CORPORATION MICRO-MISSILE PROJECTILE

One compact manufactured missile shared by multiple Corporation weapons.
The projectile owns its shape, collision, trail and explosion appearance.
*/

/// @description Registers the reusable Corporation micro-missile projectile.
function sc_projectile_register_corporation_micro_missile()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    return sc_projectile_register({
        identity: {
            key: "projectile_corporation_micro_missile",
            name: "Corporation Micro-Missile"
        },

        projectile_motion: ProjectileMotion.ROCKET,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 5
        },

        detonation: {
            area: {
                shape: AttackAreaShape.CIRCLE,

                geometry: {
                    radius: 52
                },

                behaviour: {
                    duration: 14,
                    tick_interval: 0,
                    hit_once: true,
                    max_targets: 0,
                    falloff_minimum: 0.25,
                    falloff_exponent: 1.4
                },

                visual: {
                    palette: _palette,
                    draw_script: sc_attack_area_corporation_rocket_explosion_draw,

                    shockwave: {
                        radius_scale: 1.2,
                        expansion_response: 0.24,
                        fade_speed: 0.065,
                        thickness: 2.5,
                        colour: _palette.energy,

                        particles_enabled: true,
                        particle_interval: 1,
                        particle_min_radius: 5,

                        smoke_enabled: true,
                        smoke_amount_max: 2,
                        smoke_colour: _palette.hull_dark,

                        fragments_enabled: true,
                        fragment_chance: 0.32,
                        fragment_colour: _palette.energy
                    }
                }
            }
        },

        visual: {
            radius: 5,
            length: 22,
            palette: _palette,
            draw_script: sc_projectile_corporation_micro_missile_draw,
            impact_script: sc_projectile_corporation_micro_missile_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_corporation_micro_missile_particles_register,

            particle_trail: {
                group: "trail_corporation_micro_missile",
                interval: 2,
                amount: 1,
                rear_scale: 0.5,
                spread: 4,
                size_min: 0.055,
                size_max: 0.1,
                size_growth: 0.003,
                size_wiggle: 0.01
            },

            trail: {
                enabled: true,
                length: 34,
                width: 1.5,
                glow_width: 5,
                alpha: 0.72,
                glow_alpha: 0.18
            },

            bake: {
                canvas_size: 64,
                frames: 6,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the micro-missile trail and impact particles.
function sc_projectile_corporation_micro_missile_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

    if (!sc_particles_projectile_impact_register(
        "impact_corporation_micro_missile",
        _palette,
        {
            scale: 0.85,
            spark_amount: 10,
            fragment_amount: 5,
            spark_spread: 145,
            speed_min: 2.5,
            speed_max: 6
        }
    ))
        return false;

    return sc_particles_projectile_trail_register(
        "trail_corporation_micro_missile",
        {
            sprite: s_particle_firesmoke_trail_color,

            colour_start: _palette.core,
            colour_middle: _palette.energy,
            colour_end: _palette.glow,

            alpha_start: 0.58,
            alpha_middle: 0.25,

            speed_min: 0.25,
            speed_max: 0.75,
            speed_reduce: -0.02,

            life_min: 8,
            life_max: 14,

            rotation_speed: 2,
            blend_additive: true
        }
    );
}

/// @description Emits one Corporation micro-missile impact.
function sc_projectile_corporation_micro_missile_impact(_x,_y,_direction,_target,_scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_corporation_micro_missile",
        _x,_y,_direction,_scale
    );
}

/// @description Draws one compact Corporation guided missile.
function sc_projectile_corporation_micro_missile_draw(_x,_y,_angle,_visual,_frame,_frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.82 + sin(_phase) * 0.18;
    var _flame = 0.86 + sin(_phase + 0.7) * 0.14;

    var _engine_x = sc_visual_x(_x,_length,_angle,-0.44,0);
    var _engine_y = sc_visual_y(_y,_length,_angle,-0.44,0);
    var _flame_x = sc_visual_x(_x,_length,_angle,-0.8 - 0.08 * _flame,0);
    var _flame_y = sc_visual_y(_y,_length,_angle,-0.8 - 0.08 * _flame,0);

    gpu_set_blendmode(bm_add);

    draw_set_alpha(0.2);
    draw_set_colour(_p.glow);
    draw_line_width(_engine_x,_engine_y,_flame_x,_flame_y,_r * 1.05);

    draw_set_alpha(0.72);
    draw_set_colour(_p.energy);
    draw_line_width(_engine_x,_engine_y,_flame_x,_flame_y,_r * 0.42);

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(
        _engine_x,_engine_y,
        lerp(_engine_x,_flame_x,0.5),
        lerp(_engine_y,_flame_y,0.5),
        1
    );

    gpu_set_blendmode(bm_normal);

    // Rear guidance fins.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _x,_y,_length,_angle,
            -0.16,0.12 * _side,
            -0.44,0.13 * _side,
            -0.36,0.31 * _side,
            _p.outline,false
        );

        sc_visual_triangle(
            _x,_y,_length,_angle,
            -0.19,0.13 * _side,
            -0.4,0.14 * _side,
            -0.34,0.26 * _side,
            _p.hull_mid,false
        );
    }

    // Dark missile silhouette.
    sc_visual_quad(
        _x,_y,_length,_angle,
        -0.48,-0.17,
         0.25,-0.17,
         0.58,0,
        -0.48,0.17,
        _p.outline
    );

    // Silver manufactured casing.
    sc_visual_quad(
        _x,_y,_length,_angle,
        -0.42,-0.12,
         0.24,-0.12,
         0.51,0,
        -0.42,0.12,
        _p.hull_light
    );

    // Dark lower chassis.
    sc_visual_quad(
        _x,_y,_length,_angle,
        -0.38,0,
         0.48,0,
         0.23,0.11,
        -0.38,0.11,
        _p.hull_dark
    );

    // Bright armour ridge.
    sc_visual_triangle(
        _x,_y,_length,_angle,
        -0.04,-0.1,
         0.24,-0.1,
         0.49,0,
        _p.metal,false
    );

    // Blue guidance channel.
    gpu_set_blendmode(bm_add);

    draw_set_alpha(0.3);
    sc_visual_line(
        _x,_y,_length,_angle,
        -0.31,0,
         0.36,0,
        3,
        _p.glow
    );

    draw_set_alpha(0.88 * _pulse);
    sc_visual_line(
        _x,_y,_length,_angle,
        -0.28,0,
         0.39,0,
        1,
        _p.energy
    );

    draw_set_alpha(1);
    sc_visual_circle(
        _x,_y,_length,_angle,
        0.43,0,
        0.04 * _pulse,
        _p.core,false
    );

    gpu_set_blendmode(bm_normal);

    // Engine collar and Corporation identification bands.
    sc_visual_line(
        _x,_y,_length,_angle,
        -0.4,-0.13,
        -0.4,0.13,
        1.5,
        _p.metal
    );

    sc_visual_line(
        _x,_y,_length,_angle,
        -0.12,-0.12,
        -0.12,0.12,
        1,
        _p.accent
    );

    sc_visual_line(
        _x,_y,_length,_angle,
         0.12,-0.11,
         0.12,0.11,
        1,
        _p.accent
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}