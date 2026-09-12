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

    // ==================================================
    // LONG REAR GLOW TAIL
    // ==================================================
    gpu_set_blendmode(bm_add);

    draw_set_colour(_p.glow);
    draw_set_alpha(0.1);

    draw_line_width(
        _x + lengthdir_x(-_r * 2.8, _angle),
        _y + lengthdir_y(-_r * 2.8, _angle),
        _x + lengthdir_x(_r * 0.28, _angle),
        _y + lengthdir_y(_r * 0.28, _angle),
        _r * 0.95
    );

    draw_set_colour(_p.accent);
    draw_set_alpha(0.18);

    draw_line_width(
        _x + lengthdir_x(-_r * 2.1, _angle),
        _y + lengthdir_y(-_r * 2.1, _angle),
        _x + lengthdir_x(_r * 0.22, _angle),
        _y + lengthdir_y(_r * 0.22, _angle),
        _r * 0.52
    );

    draw_set_colour(_p.energy);
    draw_set_alpha(0.34);

    draw_line_width(
        _x + lengthdir_x(-_r * 1.55, _angle),
        _y + lengthdir_y(-_r * 1.55, _angle),
        _x + lengthdir_x(_r * 0.16, _angle),
        _y + lengthdir_y(_r * 0.16, _angle),
        _r * 0.24
    );

    // Soft glow pockets behind shard.
    draw_set_colour(_p.glow);
    draw_set_alpha(0.08);

    draw_circle(
        _x + lengthdir_x(-_r * 1.65, _angle),
        _y + lengthdir_y(-_r * 1.65, _angle),
        _r * 0.72 * _pulse,
        false
    );

    draw_set_colour(_p.accent);
    draw_set_alpha(0.12);

    draw_circle(
        _x + lengthdir_x(-_r * 0.95, _angle),
        _y + lengthdir_y(-_r * 0.95, _angle),
        _r * 0.48 * _flicker,
        false
    );

    // ==================================================
    // OUTER ENERGY DIAMOND
    // ==================================================
    var _front_x = _x + lengthdir_x(_r * 1.45, _angle);
    var _front_y = _y + lengthdir_y(_r * 1.45, _angle);

    var _rear_x = _x + lengthdir_x(-_r * 0.95, _angle);
    var _rear_y = _y + lengthdir_y(-_r * 0.95, _angle);

    var _left_x = _x + lengthdir_x(_r * 0.52, _angle + 90);
    var _left_y = _y + lengthdir_y(_r * 0.52, _angle + 90);

    var _right_x = _x + lengthdir_x(_r * 0.52, _angle - 90);
    var _right_y = _y + lengthdir_y(_r * 0.52, _angle - 90);

    draw_set_colour(_p.glow);
    draw_set_alpha(0.16);

    draw_triangle(
        _front_x,_front_y,
        _left_x,_left_y,
        _rear_x,_rear_y,
        false
    );

    draw_triangle(
        _front_x,_front_y,
        _rear_x,_rear_y,
        _right_x,_right_y,
        false
    );

    // ==================================================
    // MID ENERGY DIAMOND
    // ==================================================
    _front_x = _x + lengthdir_x(_r * 1.24, _angle);
    _front_y = _y + lengthdir_y(_r * 1.24, _angle);

    _rear_x = _x + lengthdir_x(-_r * 0.78, _angle);
    _rear_y = _y + lengthdir_y(-_r * 0.78, _angle);

    _left_x = _x + lengthdir_x(_r * 0.38, _angle + 90);
    _left_y = _y + lengthdir_y(_r * 0.38, _angle + 90);

    _right_x = _x + lengthdir_x(_r * 0.38, _angle - 90);
    _right_y = _y + lengthdir_y(_r * 0.38, _angle - 90);

    draw_set_colour(_p.accent);
    draw_set_alpha(0.22);

    draw_triangle(
        _front_x,_front_y,
        _left_x,_left_y,
        _rear_x,_rear_y,
        false
    );

    draw_triangle(
        _front_x,_front_y,
        _rear_x,_rear_y,
        _right_x,_right_y,
        false
    );

    gpu_set_blendmode(bm_normal);

    // ==================================================
    // MAIN CRYSTAL BODY
    // ==================================================
    _front_x = _x + lengthdir_x(_r * 1.05, _angle);
    _front_y = _y + lengthdir_y(_r * 1.05, _angle);

    _rear_x = _x + lengthdir_x(-_r * 0.66, _angle);
    _rear_y = _y + lengthdir_y(-_r * 0.66, _angle);

    _left_x = _x + lengthdir_x(_r * 0.34, _angle + 90);
    _left_y = _y + lengthdir_y(_r * 0.34, _angle + 90);

    _right_x = _x + lengthdir_x(_r * 0.34, _angle - 90);
    _right_y = _y + lengthdir_y(_r * 0.34, _angle - 90);

    draw_set_colour(_p.hull_light);
    draw_set_alpha(1);

    draw_triangle(
        _front_x,_front_y,
        _left_x,_left_y,
        _rear_x,_rear_y,
        false
    );

    draw_triangle(
        _front_x,_front_y,
        _rear_x,_rear_y,
        _right_x,_right_y,
        false
    );

    // ==================================================
    // INNER ENERGY CORE
    // ==================================================
    _front_x = _x + lengthdir_x(_r * 0.82, _angle);
    _front_y = _y + lengthdir_y(_r * 0.82, _angle);

    _rear_x = _x + lengthdir_x(-_r * 0.44, _angle);
    _rear_y = _y + lengthdir_y(-_r * 0.44, _angle);

    _left_x = _x + lengthdir_x(_r * 0.21, _angle + 90);
    _left_y = _y + lengthdir_y(_r * 0.21, _angle + 90);

    _right_x = _x + lengthdir_x(_r * 0.21, _angle - 90);
    _right_y = _y + lengthdir_y(_r * 0.21, _angle - 90);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.95);

    draw_triangle(
        _front_x,_front_y,
        _left_x,_left_y,
        _rear_x,_rear_y,
        false
    );

    draw_triangle(
        _front_x,_front_y,
        _rear_x,_rear_y,
        _right_x,_right_y,
        false
    );

    // ==================================================
    // HOT INNER SHARD
    // ==================================================
    _front_x = _x + lengthdir_x(_r * 0.56, _angle);
    _front_y = _y + lengthdir_y(_r * 0.56, _angle);

    _rear_x = _x + lengthdir_x(-_r * 0.18, _angle);
    _rear_y = _y + lengthdir_y(-_r * 0.18, _angle);

    _left_x = _x + lengthdir_x(_r * 0.11, _angle + 90);
    _left_y = _y + lengthdir_y(_r * 0.11, _angle + 90);

    _right_x = _x + lengthdir_x(_r * 0.11, _angle - 90);
    _right_y = _y + lengthdir_y(_r * 0.11, _angle - 90);

    draw_set_colour(_p.core);
    draw_set_alpha(0.92);

    draw_triangle(
        _front_x,_front_y,
        _left_x,_left_y,
        _rear_x,_rear_y,
        false
    );

    draw_triangle(
        _front_x,_front_y,
        _rear_x,_rear_y,
        _right_x,_right_y,
        false
    );

    // ==================================================
    // CRYSTAL SPINE
    // ==================================================
    draw_set_colour(_p.core);
    draw_set_alpha(0.95);

    draw_line_width(
        _x + lengthdir_x(-_r * 0.42, _angle),
        _y + lengthdir_y(-_r * 0.42, _angle),
        _x + lengthdir_x(_r * 0.88, _angle),
        _y + lengthdir_y(_r * 0.88, _angle),
        1.6
    );

    // ==================================================
    // FORWARD TIP GLOW
    // ==================================================
    gpu_set_blendmode(bm_add);

    var _tip_x = _x + lengthdir_x(_r * 0.98, _angle);
    var _tip_y = _y + lengthdir_y(_r * 0.98, _angle);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.3);
    draw_circle(_tip_x,_tip_y,_r * 0.24,false);

    draw_set_colour(_p.core);
    draw_set_alpha(0.95);
    draw_circle(_tip_x,_tip_y,max(1.2,_r * 0.07),false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}