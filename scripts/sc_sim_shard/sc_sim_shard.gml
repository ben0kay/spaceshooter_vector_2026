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

/// @description Registers the reusable Simulant data-shard projectile.
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
            radius: 8
        },

        visual: {
            radius: 12,
            length: 32,
            palette: _palette,

            draw_script: sc_projectile_simulant_shard_draw,
            impact_script: sc_projectile_simulant_shard_impact,
            trail_script: sc_projectile_simulant_shard_trail_emit,
            particles_register_script: sc_projectile_simulant_shard_particles_register,

            particle_trail: {
                group: "trail_simulant_shard",
                interval: 2,
                amount: 2,

                rear_scale_min: 0.32,
                rear_scale_max: 0.8,
                side_spread: 9,

                size_min: 0.055,
                size_max: 0.095,
                size_growth: -0.0015,
                size_wiggle: 0
            },

            // Narrow foundation beneath the visible data fragments.
            trail: {
                enabled: true,
                length: 42,
                width: 1.8,
                glow_width: 7,
                alpha: 0.72,
                glow_alpha: 0.13
            },

            bake: {
                canvas_size: 96,
                frames: 4,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers the shard impact and bright direction-locked data fragments.
function sc_projectile_simulant_shard_particles_register()
{
    var _palette = sc_faction_palette_get(Faction.SIMULANT);

    if (!sc_particles_projectile_impact_register(
        "impact_simulant_shard",
        _palette,
        {
            scale: 0.95,
            spark_amount: 7,
            fragment_amount: 5,
            spark_spread: 85,
            speed_min: 2.2,
            speed_max: 5.2
        }
    )) return false;

    return sc_particles_projectile_trail_register(
        "trail_simulant_shard",
        {
            sprite: s_particle_shard,

            colour_start: _palette.core,
            colour_middle: _palette.energy,
            colour_end: _palette.glow,

            alpha_start: 0.95,
            alpha_middle: 0.5,

            speed_min: 0.25,
            speed_max: 0.75,
            speed_reduce: -0.015,

            life_min: 11,
            life_max: 18,

            direction_locked: true,

            // Particle movement is backward; 180 keeps its diamond facing forward.
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

/// @description Draws one wide layered Simulant data shard for baking.
function sc_projectile_simulant_shard_draw(_x,_y,_angle,_visual,_frame,_frame_count)
{
    var _p = _visual.palette;
    var _r = _visual.radius;
    var _phase = (_frame/_frame_count)*pi*2;
    var _pulse = 0.95+sin(_phase)*0.05;

    var _front_x = _x+lengthdir_x(_r*1.34,_angle);
    var _front_y = _y+lengthdir_y(_r*1.34,_angle);
    var _rear_x = _x+lengthdir_x(-_r*0.92,_angle);
    var _rear_y = _y+lengthdir_y(-_r*0.92,_angle);
    var _left_x = _x+lengthdir_x(_r*0.82*_pulse,_angle+90);
    var _left_y = _y+lengthdir_y(_r*0.82*_pulse,_angle+90);
    var _right_x = _x+lengthdir_x(_r*0.82*_pulse,_angle-90);
    var _right_y = _y+lengthdir_y(_r*0.82*_pulse,_angle-90);

    // Wide soft outer diamond.
    gpu_set_blendmode(bm_add);
    draw_set_colour(_p.glow);
    draw_set_alpha(0.3);

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

    // Brighter middle diamond.
    var _mid_front_x = _x+lengthdir_x(_r*1.17,_angle);
    var _mid_front_y = _y+lengthdir_y(_r*1.17,_angle);
    var _mid_rear_x = _x+lengthdir_x(-_r*0.75,_angle);
    var _mid_rear_y = _y+lengthdir_y(-_r*0.75,_angle);
    var _mid_left_x = _x+lengthdir_x(_r*0.63,_angle+90);
    var _mid_left_y = _y+lengthdir_y(_r*0.63,_angle+90);
    var _mid_right_x = _x+lengthdir_x(_r*0.63,_angle-90);
    var _mid_right_y = _y+lengthdir_y(_r*0.63,_angle-90);

    draw_set_colour(_p.accent);
    draw_set_alpha(0.58);

    draw_triangle(
        _mid_front_x,_mid_front_y,
        _mid_left_x,_mid_left_y,
        _mid_rear_x,_mid_rear_y,
        false
    );

    draw_triangle(
        _mid_front_x,_mid_front_y,
        _mid_rear_x,_mid_rear_y,
        _mid_right_x,_mid_right_y,
        false
    );

    gpu_set_blendmode(bm_normal);

    // Solid inner crystal.
    var _core_front_x = _x+lengthdir_x(_r*0.95,_angle);
    var _core_front_y = _y+lengthdir_y(_r*0.95,_angle);
    var _core_rear_x = _x+lengthdir_x(-_r*0.54,_angle);
    var _core_rear_y = _y+lengthdir_y(-_r*0.54,_angle);
    var _core_left_x = _x+lengthdir_x(_r*0.42,_angle+90);
    var _core_left_y = _y+lengthdir_y(_r*0.42,_angle+90);
    var _core_right_x = _x+lengthdir_x(_r*0.42,_angle-90);
    var _core_right_y = _y+lengthdir_y(_r*0.42,_angle-90);

    draw_set_alpha(1);
    draw_set_colour(_p.hull_light);

    draw_triangle(
        _core_front_x,_core_front_y,
        _core_left_x,_core_left_y,
        _core_rear_x,_core_rear_y,
        false
    );

    draw_set_colour(_p.energy);

    draw_triangle(
        _core_front_x,_core_front_y,
        _core_rear_x,_core_rear_y,
        _core_right_x,_core_right_y,
        false
    );

    // Bright diamond lattice like the reference.
    gpu_set_blendmode(bm_add);
    draw_set_colour(_p.core);
    draw_set_alpha(0.95);

    draw_line_width(
        _front_x,_front_y,
        _left_x,_left_y,
        1.5
    );

    draw_line_width(
        _left_x,_left_y,
        _rear_x,_rear_y,
        1.5
    );

    draw_line_width(
        _rear_x,_rear_y,
        _right_x,_right_y,
        1.5
    );

    draw_line_width(
        _right_x,_right_y,
        _front_x,_front_y,
        1.5
    );

    // Internal faceted connections.
    draw_line_width(
        _left_x,_left_y,
        _core_front_x,_core_front_y,
        1.2
    );

    draw_line_width(
        _right_x,_right_y,
        _core_front_x,_core_front_y,
        1.2
    );

    draw_line_width(
        _left_x,_left_y,
        _core_rear_x,_core_rear_y,
        1.2
    );

    draw_line_width(
        _right_x,_right_y,
        _core_rear_x,_core_rear_y,
        1.2
    );

    // Central data eye.
    draw_set_colour(c_white);
    draw_set_alpha(1);
    draw_circle(_x,_y,max(1.5,_r*0.11*_pulse),false);

    draw_set_colour(_p.energy);
    draw_set_alpha(0.8);
    draw_circle(_x,_y,_r*0.25*_pulse,true);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Emits visible data shards around, rather than directly beneath, the trail.
function sc_projectile_simulant_shard_trail_emit(_projectile,_data)
{
    var _config = _data.visual.particle_trail;

    if (((GAME_TICK+real(_projectile.id)) mod _config.interval) != 0)
        return true;

    if (!sc_optimization_circle_visible(
        _projectile.x,
        _projectile.y,
        _data.visual.length*_data.scale,
        96
    )) return true;

    var _types = sc_particles_group_get(_config.group);
    if (!is_struct(_types)) return false;

    var _scale = _data.scale;
    var _direction = _data.direction;
    var _trail_direction = _direction+180;

    part_type_direction(
        _types.particle,
        _trail_direction-5,
        _trail_direction+5,
        0,0
    );

    part_type_size(
        _types.particle,
        _config.size_min*_scale,
        _config.size_max*_scale,
        _config.size_growth*_scale,
        _config.size_wiggle
    );

    for (var _i = 0; _i < _config.amount; _i++)
    {
        var _rear = _data.visual.length*random_range(
            _config.rear_scale_min,
            _config.rear_scale_max
        )*_scale;

        var _side = random_range(
            -_config.side_spread,
            _config.side_spread
        )*_scale;

        var _x = _projectile.x
            - lengthdir_x(_rear,_direction)
            + lengthdir_x(_side,_direction+90);

        var _y = _projectile.y
            - lengthdir_y(_rear,_direction)
            + lengthdir_y(_side,_direction+90);

        part_particles_create(
            global.particles.system,
            _x,_y,
            _types.particle,
            1
        );
    }

    return true;
}