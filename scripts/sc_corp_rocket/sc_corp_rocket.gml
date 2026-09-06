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
                    draw_script: sc_attack_area_corporation_rocket_explosion_draw,

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
            draw_script: sc_projectile_corporation_rocket_draw,
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
    });
}

/// @description Registers Corporation rocket impact and energized trail particles.
function sc_projectile_corporation_rocket_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.CORPORATION);

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
        _x,
        _y,
        _direction,
        _scale
    );
}

/// @description Draws one clean manufactured Corporation naval rocket.
function sc_projectile_corporation_rocket_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _length = _visual.length;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.86 + sin(_phase) * 0.14;
    var _flame = 0.88 + sin(_phase + 0.8) * 0.12;

    var _engine_x = sc_visual_x(
        _x, _length, _angle,
        -0.52, 0
    );

    var _engine_y = sc_visual_y(
        _y, _length, _angle,
        -0.52, 0
    );

    var _flame_x = sc_visual_x(
        _x, _length, _angle,
        -0.83 - 0.08 * _flame, 0
    );

    var _flame_y = sc_visual_y(
        _y, _length, _angle,
        -0.83 - 0.08 * _flame, 0
    );

    gpu_set_blendmode(bm_add);

    draw_set_alpha(0.2);
    draw_set_colour(_p.glow);
    draw_line_width(
        _engine_x, _engine_y,
        _flame_x, _flame_y,
        _r * 1.15
    );

    draw_set_alpha(0.68);
    draw_set_colour(_p.energy);
    draw_line_width(
        _engine_x, _engine_y,
        _flame_x, _flame_y,
        _r * 0.5
    );

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_line_width(
        _engine_x, _engine_y,
        lerp(_engine_x, _flame_x, 0.55),
        lerp(_engine_y, _flame_y, 0.55),
        max(1, _r * 0.18)
    );

    gpu_set_blendmode(bm_normal);

    // Dark rear stabilizers.
    for (var _side = -1; _side <= 1; _side += 2)
    {
        sc_visual_triangle(
            _x, _y, _length, _angle,
            -0.16, 0.16 * _side,
            -0.48, 0.18 * _side,
            -0.42, 0.36 * _side,
            _p.outline, false
        );

        sc_visual_triangle(
            _x, _y, _length, _angle,
            -0.2, 0.16 * _side,
            -0.44, 0.18 * _side,
            -0.4, 0.31 * _side,
            _p.hull_mid, false
        );

        sc_visual_line(
            _x, _y, _length, _angle,
            -0.21, 0.18 * _side,
            -0.4, 0.29 * _side,
            1.5, _p.accent
        );
    }

    // Main dark silhouette.
    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.52, -0.19,
         0.27, -0.19,
         0.62,  0,
        -0.52,  0.19,
        _p.outline
    );

    // Manufactured silver body.
    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.47, -0.15,
         0.25, -0.15,
         0.55,  0,
        -0.47,  0.15,
        _p.hull_light
    );

    // Gunmetal underside.
    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.4, -0.09,
         0.31, -0.09,
         0.48,  0,
        -0.4,  0.09,
        _p.hull_dark
    );

    // Raised forward armour.
    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.02, -0.13,
         0.3, -0.11,
         0.51,  0,
        -0.02,  0,
        _p.metal
    );

    sc_visual_quad(
        _x, _y, _length, _angle,
        -0.02, 0,
         0.51, 0,
         0.3, 0.11,
        -0.02, 0.13,
        _p.hull_mid
    );

    // Royal-blue central guidance rail.
    gpu_set_blendmode(bm_add);

    sc_visual_line(
        _x, _y, _length, _angle,
        -0.39, 0,
         0.39, 0,
        max(2, _r * 0.28),
        _p.glow
    );

    draw_set_alpha(0.78 * _pulse);

    sc_visual_line(
        _x, _y, _length, _angle,
        -0.35, 0,
         0.42, 0,
        max(1, _r * 0.13),
        _p.energy
    );

    draw_set_alpha(1);

    sc_visual_circle(
        _x, _y, _length, _angle,
        0.46, 0,
        0.055 * _pulse,
        _p.core, false
    );

    gpu_set_blendmode(bm_normal);

    // Engine collar and identification bands.
    sc_visual_line(
        _x, _y, _length, _angle,
        -0.43, -0.15,
        -0.43,  0.15,
        2,
        _p.metal
    );

    sc_visual_line(
        _x, _y, _length, _angle,
        -0.18, -0.15,
        -0.18,  0.15,
        1.5,
        _p.accent
    );

    sc_visual_line(
        _x, _y, _length, _angle,
         0.13, -0.13,
         0.13,  0.13,
        1.5,
        _p.accent
    );

    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Draws one precise Corporation rocket detonation.
function sc_attack_area_corporation_rocket_explosion_draw(_area, _data)
{
    var _p = _data.visual.palette;
    var _life_ratio = _data.runtime.life / _data.behaviour.duration;
    var _progress = 1 - _life_ratio;
    var _radius = _data.geometry.radius
        * sin(_progress * pi * 0.72);

    var _alpha = clamp(_life_ratio * 1.55, 0, 1);
    var _flash = clamp(1 - _progress * 3.5, 0, 1);
    var _pulse = 0.92 + sin(GAME_TICK * 0.7) * 0.08;
    var _angle = _data.direction;

    gpu_set_blendmode(bm_add);

    // Tight controlled blue energy bloom.
    draw_set_alpha(_alpha * 0.12);
    draw_set_colour(_p.glow);
    draw_circle(
        _area.x,
        _area.y,
        _radius * 1.18,
        false
    );

    draw_set_alpha(_alpha * 0.24);
    draw_set_colour(_p.accent);
    draw_circle(
        _area.x,
        _area.y,
        _radius * 0.82,
        false
    );

    // Precise concentric detonation rings.
    draw_set_alpha(_alpha * 0.92);
    draw_set_colour(_p.energy);
    draw_circle(
        _area.x,
        _area.y,
        _radius,
        true
    );

    draw_set_alpha(_alpha * 0.68);
    draw_set_colour(_p.core);
    draw_circle(
        _area.x,
        _area.y,
        _radius * 0.68 * _pulse,
        true
    );

    draw_set_alpha(_alpha * 0.5);
    draw_set_colour(_p.accent);
    draw_circle(
        _area.x,
        _area.y,
        _radius * 0.42,
        true
    );

    // Eight short manufactured radial energy lines.
    for (var _i = 0; _i < 8; _i++)
    {
        var _direction = _angle + _i * 45;
        var _inner = _radius * 0.48;
        var _outer = _radius * (
            (_i mod 2) == 0
                ? 0.9
                : 0.76
        );

        draw_set_alpha(_alpha * 0.72);
        draw_set_colour(
            (_i mod 2) == 0
                ? _p.core
                : _p.energy
        );

        draw_line_width(
            _area.x + lengthdir_x(_inner, _direction),
            _area.y + lengthdir_y(_inner, _direction),
            _area.x + lengthdir_x(_outer, _direction),
            _area.y + lengthdir_y(_outer, _direction),
            (_i mod 2) == 0 ? 3 : 2
        );
    }

    // Immediate blue-white central flash.
    draw_set_alpha(max(_flash, _alpha * 0.74));
    draw_set_colour(_p.core);
    draw_circle(
        _area.x,
        _area.y,
        max(3, _radius * 0.22),
        false
    );

    draw_set_alpha(_flash * 0.9);
    draw_set_colour(c_white);
    draw_circle(
        _area.x,
        _area.y,
        max(2, _radius * 0.1),
        false
    );

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}