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
                shard_amount: 2,

                rear_scale_min: 0.32,
                rear_scale_max: 0.8,
                side_spread: 9,

                shard_size_min: 0.055,
                shard_size_max: 0.095,

                flame_size_min: 0.09,
                flame_size_max: 0.15,
                flame_side_spread: 5
            },

            trail: {
                enabled: true,
                length: 42,
                width: 1.8,
                glow_width: 7,
                alpha: 0.68,
                glow_alpha: 0.11
            },

            bake: {
                canvas_size: 96,
                frames: 4,
                frame_speed: 2
            }
        }
    });
}

/// @description Registers shard fragments and faint purple broad-flame wake particles.
function sc_projectile_simulant_shard_particles_register()
{
    var _p = sc_faction_palette_get(Faction.SIMULANT);

    if (!sc_particles_projectile_impact_register(
        "impact_simulant_shard",
        _p,
        {
            scale: 0.95,
            spark_amount: 7,
            fragment_amount: 5,
            spark_spread: 85,
            speed_min: 2.2,
            speed_max: 5.2
        }
    )) return false;

    var _shard = sc_particles_type_create();
    var _flame = sc_particles_type_create();

    if (!part_type_exists(_shard) || !part_type_exists(_flame))
        return false;

    // Small bright data fragments.
    part_type_sprite(_shard,s_particle_shard,false,false,false);
    part_type_colour3(_shard,_p.core,_p.energy,_p.glow);
    part_type_alpha3(_shard,0.95,0.5,0);
    part_type_speed(_shard,0.25,0.75,-0.015,0);
    part_type_direction(_shard,0,359,0,0);
    part_type_orientation(_shard,180,180,0,0,true);
    part_type_life(_shard,11,18);
    part_type_blend(_shard,true);

    // Faint cloudy energy body underneath the data fragments.
    part_type_sprite(_flame,s_broad_flame_body_white,false,false,false);
    part_type_colour3(_flame,_p.energy,_p.accent,_p.glow);
    part_type_alpha3(_flame,0.28,0.14,0);
    part_type_speed(_flame,0.15,0.5,-0.012,0);
    part_type_direction(_flame,0,359,0,0);
    part_type_orientation(_flame,180,180,0,0,true);
    part_type_life(_flame,12,20);
    part_type_blend(_flame,true);

    return sc_particles_group_register("trail_simulant_shard",{
        particle: _shard,
        flame: _flame
    });
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

/// @description Draws one predominantly purple faceted Simulant data shard.
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

    // Soft purple outer aura.
    gpu_set_blendmode(bm_add);
    draw_set_colour(_p.glow);
    draw_set_alpha(0.26);

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

    // Main filled purple diamond.
    var _body_front_x = _x+lengthdir_x(_r*1.2,_angle);
    var _body_front_y = _y+lengthdir_y(_r*1.2,_angle);
    var _body_rear_x = _x+lengthdir_x(-_r*0.76,_angle);
    var _body_rear_y = _y+lengthdir_y(-_r*0.76,_angle);
    var _body_left_x = _x+lengthdir_x(_r*0.65,_angle+90);
    var _body_left_y = _y+lengthdir_y(_r*0.65,_angle+90);
    var _body_right_x = _x+lengthdir_x(_r*0.65,_angle-90);
    var _body_right_y = _y+lengthdir_y(_r*0.65,_angle-90);

    draw_set_alpha(1);
    draw_set_colour(_p.accent);

    draw_triangle(
        _body_front_x,_body_front_y,
        _body_left_x,_body_left_y,
        _body_rear_x,_body_rear_y,
        false
    );

    draw_set_colour(_p.energy);

    draw_triangle(
        _body_front_x,_body_front_y,
        _body_rear_x,_body_rear_y,
        _body_right_x,_body_right_y,
        false
    );

    // Darker interior gives the diamond some depth.
    var _inner_front_x = _x+lengthdir_x(_r*0.86,_angle);
    var _inner_front_y = _y+lengthdir_y(_r*0.86,_angle);
    var _inner_rear_x = _x+lengthdir_x(-_r*0.48,_angle);
    var _inner_rear_y = _y+lengthdir_y(-_r*0.48,_angle);
    var _inner_left_x = _x+lengthdir_x(_r*0.34,_angle+90);
    var _inner_left_y = _y+lengthdir_y(_r*0.34,_angle+90);
    var _inner_right_x = _x+lengthdir_x(_r*0.34,_angle-90);
    var _inner_right_y = _y+lengthdir_y(_r*0.34,_angle-90);

    draw_set_colour(_p.hull_dark);

    draw_triangle(
        _inner_front_x,_inner_front_y,
        _inner_left_x,_inner_left_y,
        _inner_rear_x,_inner_rear_y,
        false
    );

    draw_set_colour(_p.accent);

    draw_triangle(
        _inner_front_x,_inner_front_y,
        _inner_rear_x,_inner_rear_y,
        _inner_right_x,_inner_right_y,
        false
    );

    // Purple lattice instead of a white outline.
    gpu_set_blendmode(bm_add);
    draw_set_colour(_p.energy);
    draw_set_alpha(0.88);

    draw_line_width(_body_front_x,_body_front_y,_body_left_x,_body_left_y,1.5);
    draw_line_width(_body_left_x,_body_left_y,_body_rear_x,_body_rear_y,1.5);
    draw_line_width(_body_rear_x,_body_rear_y,_body_right_x,_body_right_y,1.5);
    draw_line_width(_body_right_x,_body_right_y,_body_front_x,_body_front_y,1.5);

    draw_line_width(_body_left_x,_body_left_y,_inner_front_x,_inner_front_y,1.1);
    draw_line_width(_body_right_x,_body_right_y,_inner_front_x,_inner_front_y,1.1);
    draw_line_width(_body_left_x,_body_left_y,_inner_rear_x,_inner_rear_y,1.1);
    draw_line_width(_body_right_x,_body_right_y,_inner_rear_x,_inner_rear_y,1.1);

    // Only the tiny reactor point approaches white.
    draw_set_colour(_p.core);
    draw_set_alpha(0.9);
    draw_circle(_x,_y,max(1.2,_r*0.09*_pulse),false);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}

/// @description Emits aligned data shards over a faint cloudy purple flame wake.
function sc_projectile_simulant_shard_trail_emit(_projectile,_data)
{
    var _config = _data.visual.particle_trail;

    if (((GAME_TICK+real(_projectile.id)) mod _config.interval) != 0)
        return true;

    if (!sc_optimization_circle_visible(
        _projectile.x,_projectile.y,
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
        _config.shard_size_min*_scale,
        _config.shard_size_max*_scale,
        -0.0015*_scale,
        0
    );

    for (var _i = 0; _i < _config.shard_amount; _i++)
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

    // Broader flame stays closer to the centre of the wake.
    var _flame_rear = _data.visual.length*random_range(0.28,0.58)*_scale;
    var _flame_side = random_range(
        -_config.flame_side_spread,
        _config.flame_side_spread
    )*_scale;

    var _flame_x = _projectile.x
        - lengthdir_x(_flame_rear,_direction)
        + lengthdir_x(_flame_side,_direction+90);

    var _flame_y = _projectile.y
        - lengthdir_y(_flame_rear,_direction)
        + lengthdir_y(_flame_side,_direction+90);

    part_type_direction(
        _types.flame,
        _trail_direction-8,
        _trail_direction+8,
        0,0
    );

    part_type_size(
        _types.flame,
        _config.flame_size_min*_scale,
        _config.flame_size_max*_scale,
        0.002*_scale,
        0.006
    );

    part_particles_create(
        global.particles.system,
        _flame_x,_flame_y,
        _types.flame,
        1
    );

    return true;
}