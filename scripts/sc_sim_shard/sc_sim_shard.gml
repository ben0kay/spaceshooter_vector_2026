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
            radius: 7
        },

        visual: {
            radius: 10,
            length: 30,
            palette: _palette,

            draw_script: sc_projectile_simulant_shard_draw,
            impact_script: sc_projectile_simulant_shard_impact,
            trail_script: sc_projectile_particle_trail_emit,
            particles_register_script: sc_projectile_simulant_shard_particles_register,

            particle_trail: {
                group: "trail_simulant_shard",
                interval: 3,
                amount: 1,
                rear_scale: 0.38,
                spread: 0,
                size_min: 0.035,
                size_max: 0.065,
                size_growth: -0.001,
                size_wiggle: 0
            },

            trail: {
                enabled: true,
                length: 48,
                width: 2.2,
                glow_width: 9,
                alpha: 0.84,
                glow_alpha: 0.2
            },

            bake: {
                canvas_size: 96,
                frames: 4,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the Simulant shard impact and direction-locked shard trail.
function sc_projectile_simulant_shard_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    if (!sc_particles_projectile_impact_register(
        "impact_simulant_shard",
        _palette,
        {
            scale: 0.9,
            spark_amount: 6,
            fragment_amount: 4,
            spark_spread: 80,
            speed_min: 2.2,
            speed_max: 5
        }
    )) return false;

    return sc_particles_projectile_trail_register(
        "trail_simulant_shard",
        {
            sprite: s_particle_shard,

            colour_start: _palette.core,
            colour_middle: _palette.accent,
            colour_end: _palette.glow,

            alpha_start: 0.72,
            alpha_middle: 0.24,

            speed_min: 0.15,
            speed_max: 0.45,
            speed_reduce: -0.01,

            life_min: 8,
            life_max: 13,

            direction_locked: true,

            // Particles travel backwards, so 180 faces them forwards.
            orientation_offset: 180,
            rotation_speed: 0,
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

/// @description Draws one clear animated Simulant diamond shard for baking.
function sc_projectile_simulant_shard_draw(_x,_y,_angle,_visual,_frame,_frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _phase = (_frame/_frame_count)*pi*2;
    var _pulse = 0.94+sin(_phase)*0.06;

    // Broad outer glow diamond.
    var _front_x = _x+lengthdir_x(_r*1.45,_angle);
    var _front_y = _y+lengthdir_y(_r*1.45,_angle);
    var _rear_x = _x+lengthdir_x(-_r*0.95,_angle);
    var _rear_y = _y+lengthdir_y(-_r*0.95,_angle);
    var _left_x = _x+lengthdir_x(_r*0.72*_pulse,_angle+90);
    var _left_y = _y+lengthdir_y(_r*0.72*_pulse,_angle+90);
    var _right_x = _x+lengthdir_x(_r*0.72*_pulse,_angle-90);
    var _right_y = _y+lengthdir_y(_r*0.72*_pulse,_angle-90);

    gpu_set_blendmode(bm_add);
    draw_set_colour(_p.glow);
    draw_set_alpha(0.24);

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

    // Solid main crystal.
    _front_x = _x+lengthdir_x(_r*1.22,_angle);
    _front_y = _y+lengthdir_y(_r*1.22,_angle);
    _rear_x = _x+lengthdir_x(-_r*0.78,_angle);
    _rear_y = _y+lengthdir_y(-_r*0.78,_angle);
    _left_x = _x+lengthdir_x(_r*0.55,_angle+90);
    _left_y = _y+lengthdir_y(_r*0.55,_angle+90);
    _right_x = _x+lengthdir_x(_r*0.55,_angle-90);
    _right_y = _y+lengthdir_y(_r*0.55,_angle-90);

    draw_set_alpha(1);
    draw_set_colour(_p.hull_light);

    draw_triangle(
        _front_x,_front_y,
        _left_x,_left_y,
        _rear_x,_rear_y,
        false
    );

    draw_set_colour(_p.accent);

    draw_triangle(
        _front_x,_front_y,
        _rear_x,_rear_y,
        _right_x,_right_y,
        false
    );

    // Smaller bright inner diamond.
    _front_x = _x+lengthdir_x(_r*0.87,_angle);
    _front_y = _y+lengthdir_y(_r*0.87,_angle);
    _rear_x = _x+lengthdir_x(-_r*0.48,_angle);
    _rear_y = _y+lengthdir_y(-_r*0.48,_angle);
    _left_x = _x+lengthdir_x(_r*0.27,_angle+90);
    _left_y = _y+lengthdir_y(_r*0.27,_angle+90);
    _right_x = _x+lengthdir_x(_r*0.27,_angle-90);
    _right_y = _y+lengthdir_y(_r*0.27,_angle-90);

    gpu_set_blendmode(bm_add);
    draw_set_colour(_p.energy);
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

    // Bright central crystal spine.
    draw_set_colour(_p.core);
    draw_set_alpha(1);

    draw_line_width(
        _x+lengthdir_x(-_r*0.4,_angle),
        _y+lengthdir_y(-_r*0.4,_angle),
        _x+lengthdir_x(_r*0.98,_angle),
        _y+lengthdir_y(_r*0.98,_angle),
        2
    );

    draw_circle(
        _x+lengthdir_x(_r*0.12,_angle),
        _y+lengthdir_y(_r*0.12,_angle),
        _r*0.12*_pulse,
        false
    );

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}