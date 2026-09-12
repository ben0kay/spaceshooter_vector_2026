/*
SIMULANT ORB

A medium Simulant energy-orb projectile with a soft animated plasma body
and a wispy runtime particle wake.

The projectile owns:
- its baked orb visuals
- its impact particles
- its generic projectile-trail particle family

Weapons can later own:
- speed
- life
- scale
- homing/guidance
- damage
*/

/// @description Registers the reusable Simulant orb projectile.
function sc_projectile_register_simulant_orb()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: {
            key: "projectile_simulant_orb",
            name: "Simulant Orb"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 8
        },

        visual: {
            radius: 10,
            length: 20,
            palette: _palette,

            draw_script: sc_projectile_simulant_orb_draw,
            impact_script: sc_projectile_simulant_orb_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_simulant_orb_particles_register,

            particle_trail: {
                group: "trail_simulant_orb",
                interval: 1,
                amount: 2,
                rear_scale: 0.34,
                spread: 22,
                size_min: 0.12,
                size_max: 0.26,
                size_growth: 0.006,
                size_wiggle: 0.045
            },

            trail: {
                enabled: true,
                length: 46,
                width: 3.2,
                glow_width: 11,
                alpha: 0.76,
                glow_alpha: 0.24
            },

            bake: {
                canvas_size: 96,
                frames: 8,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Simulant orb impact and wispy trail particles.
function sc_projectile_simulant_orb_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    if (!sc_particles_projectile_impact_register(
        "impact_simulant_orb",
        _palette,
        {
            scale: 1.3,
            spark_amount: 12,
            fragment_amount: 6,
            spark_spread: 160,
            speed_min: 2.2,
            speed_max: 5.8
        }
    )) return false;

    return sc_particles_projectile_trail_register(
        "trail_simulant_orb",
        {
            sprite: s_particle_smokey_wisp_001,

            colour_start: _palette.core,
            colour_middle: _palette.energy,
            colour_end: _palette.glow,

            alpha_start: 0.52,
            alpha_middle: 0.22,

            speed_min: 0.25,
            speed_max: 0.82,
            speed_reduce: -0.01,

            life_min: 18,
            life_max: 32,

            rotation_speed: 1.8,
            blend_additive: true
        }
    );
}

/// @description Emits the Simulant orb impact.
function sc_projectile_simulant_orb_impact(_x, _y, _direction, _target, _scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_simulant_orb",
        _x,
        _y,
        _direction,
        _scale
    );
}

/// @description Draws one animated Simulant orb frame for baking.
function sc_projectile_simulant_orb_draw(_x, _y, _angle, _visual, _frame, _frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.88 + sin(_phase) * 0.12;
    var _flicker = 0.9 + sin(_phase * 2 + 0.6) * 0.1;
    var _rotation = _angle + (_frame / _frame_count) * 360;

    // ==================================================
    // OUTER ADDITIVE AURA
    // ==================================================
    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.glow);
    draw_set_alpha(0.13);
    draw_circle(_x, _y, _r * 2.25 * _pulse, false);

    draw_set_colour(_p.accent);
    draw_set_alpha(0.22);
    draw_circle(_x, _y, _r * 1.65 * _pulse, false);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.42);
    draw_circle(_x, _y, _r * 1.18 * _flicker, false);

    // ==================================================
    // REAR WISPY LOBES
    // ==================================================
    for (var _i = 0; _i < 5; _i++)
    {
        var _offset = (_i - 2) * 14;
        var _curve = sin(_phase * 1.7 + _i * 0.9) * 12;
        var _dir_1 = 180 + _offset;
        var _dir_2 = 180 + _offset + _curve;
        var _dir_3 = 180 + _offset + _curve * 1.45;

        var _inner_len = _r * (0.35 + 0.03 * sin(_phase + _i));
        var _mid_len = _r * (0.9 + 0.06 * sin(_phase * 1.3 + _i));
        var _outer_len = _r * (1.55 + 0.09 * sin(_phase * 0.8 + _i));

        var _x1 = _x + lengthdir_x(_inner_len, _dir_1);
        var _y1 = _y + lengthdir_y(_inner_len, _dir_1);
        var _x2 = _x + lengthdir_x(_mid_len, _dir_2);
        var _y2 = _y + lengthdir_y(_mid_len, _dir_2);
        var _x3 = _x + lengthdir_x(_outer_len, _dir_3);
        var _y3 = _y + lengthdir_y(_outer_len, _dir_3);

        draw_set_alpha(0.12);
        draw_set_colour(_p.glow);
        draw_line_width(_x1, _y1, _x2, _y2, _r * 0.42);
        draw_line_width(_x2, _y2, _x3, _y3, _r * 0.24);

        draw_set_alpha(0.34);
        draw_set_colour((_i mod 2) == 0 ? _p.energy : _p.accent);
        draw_line_width(_x1, _y1, _x2, _y2, _r * 0.18);
        draw_line_width(_x2, _y2, _x3, _y3, _r * 0.09);
    }

    // ==================================================
    // BLOBBY OUTER ENERGY SHELL
    // ==================================================
    draw_set_alpha(0.62);
    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _r * 0.98 * _pulse, false);

    draw_set_alpha(0.82);
    draw_set_colour(_p.accent);
    draw_circle(_x, _y, _r * 0.74 * _flicker, false);

    // Rotating blobby surface nodes.
    for (var _j = 0; _j < 4; _j++)
    {
        var _blob_dir = _rotation + _j * 90 + sin(_phase + _j) * 9;
        var _blob_dist = _r * (0.38 + 0.04 * sin(_phase * 1.6 + _j));
        var _blob_size = _r * (0.17 + 0.035 * sin(_phase * 1.4 + _j * 0.7));

        draw_set_alpha(0.4);
        draw_set_colour((_j mod 2) == 0 ? _p.energy : _p.accent);
        draw_circle(
            _x + lengthdir_x(_blob_dist, _blob_dir),
            _y + lengthdir_y(_blob_dist, _blob_dir),
            _blob_size,
            false
        );
    }

    // ==================================================
    // HOT CORE
    // ==================================================
    draw_set_alpha(0.92);
    draw_set_colour(_p.energy);
    draw_circle(_x, _y, _r * 0.46 * _pulse, false);

    draw_set_alpha(1);
    draw_set_colour(_p.core);
    draw_circle(_x, _y, _r * 0.22 * _pulse, false);

    // Small inner rotating sparks.
    for (var _k = 0; _k < 3; _k++)
    {
        var _spark_dir = -_rotation * 1.15 + _k * 120;
        var _spark_dist = _r * 0.28;
        var _sx = _x + lengthdir_x(_spark_dist, _spark_dir);
        var _sy = _y + lengthdir_y(_spark_dist, _spark_dir);

        draw_set_alpha(0.95);
        draw_set_colour(_p.core);
        draw_circle(_sx, _sy, max(1.2, _r * 0.06), false);

        draw_set_alpha(0.45);
        draw_set_colour(_p.energy);
        draw_line_width(_x, _y, _sx, _sy, 1);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}