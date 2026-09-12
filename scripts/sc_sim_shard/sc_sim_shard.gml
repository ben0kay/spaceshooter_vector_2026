/*
SIMULANT SHARD

A fast Simulant crystal-bolt projectile.

Visual language:
- sharp glowing diamond shard body
- long violet glow tail behind it
- runtime shard particles using s_particle_shard

The projectile owns:
- baked body visuals
- impact particles
- runtime particle trail family

Weapons can later own:
- speed
- life
- scale
- damage
- spread / burst logic
*/

/// @description Registers the reusable Simulant shard projectile.
function sc_projectile_register_simulant_shard()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    return sc_projectile_register({
        identity: {
            key: "projectile_simulant_shard",
            name: "Simulant Shard"
        },

        projectile_motion: ProjectileMotion.STANDARD,
        projectile_class: ProjectileClass.REGULAR,

        collision: {
            radius: 6
        },

        visual: {
            radius: 8,
            length: 28,
            palette: _palette,

            draw_script: sc_projectile_simulant_shard_draw,
            impact_script: sc_projectile_simulant_shard_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_simulant_shard_particles_register,

            particle_trail: {
                group: "trail_simulant_shard",
                interval: 2,
                amount: 1,
                rear_scale: 0.42,
                spread: 10,
                size_min: 0.10,
                size_max: 0.18,
                size_growth: 0.002,
                size_wiggle: 0.03
            },

            trail: {
                enabled: true,
                length: 58,
                width: 2.4,
                glow_width: 11,
                alpha: 0.9,
                glow_alpha: 0.26
            },

            bake: {
                canvas_size: 96,
                frames: 8,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Simulant shard impact and runtime shard trail particles.
function sc_projectile_simulant_shard_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    if (!sc_particles_projectile_impact_register(
        "impact_simulant_shard",
        _palette,
        {
            scale: 1.08,
            spark_amount: 10,
            fragment_amount: 8,
            spark_spread: 95,
            speed_min: 2.6,
            speed_max: 6.2
        }
    )) return false;

    return sc_particles_projectile_trail_register(
        "trail_simulant_shard",
        {
            sprite: s_particle_shard,

            colour_start: _palette.core,
            colour_middle: _palette.accent,
            colour_end: _palette.glow,

            alpha_start: 0.82,
            alpha_middle: 0.28,

            speed_min: 0.12,
            speed_max: 0.55,
            speed_reduce: -0.008,

            life_min: 12,
            life_max: 20,

            rotation_speed: 2.6,
            blend_additive: true
        }
    );
}

/// @description Emits the Simulant shard impact.
function sc_projectile_simulant_shard_impact(_x,_y,_direction,_target,_scale)
{
    return sc_particles_projectile_impact_emit(
        "impact_simulant_shard",
        _x,
        _y,
        _direction,
        _scale
    );
}

/// @description Draws one animated Simulant shard frame for baking.
function sc_projectile_simulant_shard_draw(_x,_y,_angle,_visual,_frame,_frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _phase = (_frame / _frame_count) * pi * 2;
    var _pulse = 0.92 + sin(_phase) * 0.08;
    var _flicker = 0.92 + sin(_phase * 2 + 0.6) * 0.08;

    var _px = function(_f,_s)
    {
        return _x + lengthdir_x(_f, _angle) + lengthdir_x(_s, _angle + 90);
    };

    var _py = function(_f,_s)
    {
        return _y + lengthdir_y(_f, _angle) + lengthdir_y(_s, _angle + 90);
    };

    var _draw_diamond = function(_front,_rear,_half,_colour,_alpha)
    {
        draw_set_colour(_colour);
        draw_set_alpha(_alpha);

        draw_triangle(
            _px(_front,0), _py(_front,0),
            _px(0,_half), _py(0,_half),
            _px(_rear,0), _py(_rear,0),
            false
        );

        draw_triangle(
            _px(_front,0), _py(_front,0),
            _px(_rear,0), _py(_rear,0),
            _px(0,-_half), _py(0,-_half),
            false
        );
    };

    // ==================================================
    // ADDITIVE REAR GLOW / TAIL
    // ==================================================
    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.glow);
    draw_set_alpha(0.10);
    draw_line_width(
        _px(-_r * 2.8,0), _py(-_r * 2.8,0),
        _px(_r * 0.28,0), _py(_r * 0.28,0),
        _r * 0.95
    );

    draw_set_colour(_p.accent);
    draw_set_alpha(0.18);
    draw_line_width(
        _px(-_r * 2.1,0), _py(-_r * 2.1,0),
        _px(_r * 0.22,0), _py(_r * 0.22,0),
        _r * 0.52
    );

    draw_set_colour(_p.energy);
    draw_set_alpha(0.34);
    draw_line_width(
        _px(-_r * 1.55,0), _py(-_r * 1.55,0),
        _px(_r * 0.16,0), _py(_r * 0.16,0),
        _r * 0.24
    );

    // Soft tail bloom pockets.
    draw_set_colour(_p.glow);
    draw_set_alpha(0.08);
    draw_circle(_px(-_r * 1.65,0), _py(-_r * 1.65,0), _r * 0.72 * _pulse, false);

    draw_set_colour(_p.accent);
    draw_set_alpha(0.12);
    draw_circle(_px(-_r * 0.95,0), _py(-_r * 0.95,0), _r * 0.48 * _flicker, false);

    // Outer aura shard.
    _draw_diamond(_r * 1.45, -_r * 0.95, _r * 0.52, _p.glow, 0.16);
    _draw_diamond(_r * 1.24, -_r * 0.78, _r * 0.38, _p.accent, 0.22);

    gpu_set_blendmode(bm_normal);

    // ==================================================
    // MAIN SHARD BODY
    // ==================================================
    _draw_diamond(_r * 1.05, -_r * 0.66, _r * 0.34, _p.hull_light, 1);
    _draw_diamond(_r * 0.82, -_r * 0.44, _r * 0.21, _p.energy, 0.95);
    _draw_diamond(_r * 0.56, -_r * 0.18, _r * 0.11, _p.core, 0.92);

    // Crisp centre spine.
    draw_set_colour(_p.core);
    draw_set_alpha(0.95);
    draw_line_width(
        _px(-_r * 0.42,0), _py(-_r * 0.42,0),
        _px(_r * 0.88,0), _py(_r * 0.88,0),
        1.6
    );

    // Side glints.
    draw_set_colour(_p.accent);
    draw_set_alpha(0.7);
    draw_line_width(
        _px(0.06,_r * 0.18), _py(0.06,_r * 0.18),
        _px(_r * 0.48,0), _py(_r * 0.48,0),
        1.2
    );

    draw_line_width(
        _px(0.06,-_r * 0.18), _py(0.06,-_r * 0.18),
        _px(_r * 0.48,0), _py(_r * 0.48,0),
        1.2
    );

    // Forward hot tip.
    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.3);
    draw_circle(_px(_r * 0.98,0), _py(_r * 0.98,0), _r * 0.24, false);

    draw_set_colour(_p.core);
    draw_set_alpha(0.95);
    draw_circle(_px(_r * 0.98,0), _py(_r * 0.98,0), max(1.2, _r * 0.07), false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}