/// @description Registers one reusable configurable projectile-trail particle family.
function sc_particles_projectile_trail_register(_key, _config)
{
    var _particle = sc_particles_type_create();

    if (!part_type_exists(_particle))
    {
        show_debug_message(
            "PROJECTILE TRAIL PARTICLE ERROR - creation failed: "
            + _key
        );

        return false;
    }

    part_type_sprite(
        _particle,
        _config.sprite,
        false,
        false,
        false
    );

    part_type_colour3(
        _particle,
        _config.colour_start,
        _config.colour_middle,
        _config.colour_end
    );

    part_type_alpha3(
        _particle,
        _config.alpha_start,
        _config.alpha_middle,
        0
    );

    part_type_speed(
        _particle,
        _config.speed_min,
        _config.speed_max,
        _config.speed_reduce,
        0
    );

    part_type_direction(
        _particle,
        0,
        359,
        0,
        0
    );

    part_type_orientation(
        _particle,
        0,
        359,
        0,
        _config.rotation_speed,
        false
    );

    part_type_life(
        _particle,
        _config.life_min,
        _config.life_max
    );

    part_type_blend(
        _particle,
        _config.blend_additive
    );

    return sc_particles_group_register(_key, {
        particle: _particle
    });
}

/// @description Emits one configurable particle trail behind a projectile.
function sc_projectile_particle_trail_emit(_projectile, _data)
{
    var _config = _data.visual.particle_trail;

    if (((GAME_TICK + real(_projectile.id)) mod _config.interval) != 0)
        return true;

    if (!sc_optimization_circle_visible(
        _projectile.x,
        _projectile.y,
        _data.visual.length * _data.scale,
        96
    ))
        return true;

    var _types = sc_particles_group_get(_config.group);
    if (!is_struct(_types)) return false;

    var _scale = _data.scale;
    var _direction = _data.direction;
    var _rear_distance = _data.visual.length
        * _config.rear_scale
        * _scale;

    var _x = _projectile.x
        - lengthdir_x(_rear_distance, _direction);

    var _y = _projectile.y
        - lengthdir_y(_rear_distance, _direction);

    var _trail_direction = _direction + 180;

    part_type_direction(
        _types.particle,
        _trail_direction - _config.spread,
        _trail_direction + _config.spread,
        0,
        0
    );

    part_type_size(
        _types.particle,
        _config.size_min * _scale,
        _config.size_max * _scale,
        _config.size_growth * _scale,
        _config.size_wiggle
    );

    part_particles_create(
        global.particles.system,
        _x,
        _y,
        _types.particle,
        _config.amount
    );

    return true;
}