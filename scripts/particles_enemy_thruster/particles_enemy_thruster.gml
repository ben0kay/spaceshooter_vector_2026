/// @description Registers the global particle family shared by every enemy thruster.
function sc_particles_register_enemy_thrust()
{
    var _trail = sc_particles_type_create();
    var _ignition = sc_particles_type_create();

    if (!part_type_exists(_trail) || !part_type_exists(_ignition))
    {
        show_debug_message("ENEMY THRUST PARTICLE ERROR - type creation failed");
        return false;
    }

    part_type_sprite(_trail, s_blur, false, false, false);
    part_type_size(_trail, 0.12, 0.24, -0.004, 0.03);
    part_type_colour3(_trail, c_white, c_white, c_white);
    part_type_alpha3(_trail, 0.9, 0.6, 0);
    part_type_speed(_trail, 0.8, 2.2, -0.03, 0);
    part_type_direction(_trail, 172, 188, 0, 0);
    part_type_life(_trail, 14, 24);
    part_type_blend(_trail, true);

    part_type_sprite(_ignition, s_ring, false, false, false);
    part_type_size(_ignition, 0.2, 0.28, 0.055, 0);
    part_type_colour2(_ignition, c_white, c_white);
    part_type_alpha2(_ignition, 1, 0);
    part_type_speed(_ignition, 0, 0, 0, 0);
    part_type_life(_ignition, 10, 14);
    part_type_blend(_ignition, true);

    return sc_particles_group_register("enemy_thrust", {
        trail: _trail,
        ignition: _ignition
    });
}

/// @description Calculates shared enemy-thruster width and length factors.
function sc_particles_enemy_thrust_scale(_power, _mount_scale, _ship_radius, _mass, _length_config)
{
    var _config = global.config.visual.enemy_thrust;
    var _radius_factor = clamp(_ship_radius / _config.radius_reference, _config.radius_factor_min, _config.radius_factor_max);
    var _mass_factor = clamp(_mass, _config.mass_min, _config.mass_max);

    return {
        width: _mount_scale * lerp(_config.width_base, _radius_factor, _config.width_radius_mix),
        length: _mount_scale * (_length_config.length_base + _mass_factor * _length_config.mass_weight)
            * lerp(_length_config.power_min, _length_config.power_max, _power),
        mass: _mass_factor
    };
}

/// @description Emits a faction-coloured ignition burst scaled by radius, mass and mount size.
function sc_particles_enemy_thrust_ignition(_x, _y, _direction, _power, _mount_scale, _ship_radius, _mass, _palette)
{
    var _types = sc_particles_group_get("enemy_thrust");
    var _config = global.config.visual.enemy_thrust.ignition;
    var _scale = sc_particles_enemy_thrust_scale(_power, _mount_scale, _ship_radius, _mass, _config);
    var _width = _scale.width;
    var _length = _scale.length;
    var _trail_count = clamp(ceil(_width * _config.trail_count_scale), _config.trail_count_min, _config.trail_count_max);

    part_type_colour2(_types.ignition, _palette.core, _palette.energy);
    part_type_size(_types.ignition, _config.ring_size_min * _width, _config.ring_size_max * _width, _config.ring_growth * _width, 0);
    part_type_life(_types.ignition,
        round(_config.life_min_base + _scale.mass * _config.life_min_mass),
        round(_config.life_max_base + _scale.mass * _config.life_max_mass)
    );
    part_particles_create(global.particles.system, _x, _y, _types.ignition, 1);

    part_type_colour3(_types.trail, _palette.core, _palette.energy, _palette.glow);
    part_type_direction(_types.trail, _direction - _config.trail_spread, _direction + _config.trail_spread, 0, 0);
    part_type_size(_types.trail, _config.trail_size_min * _width, _config.trail_size_max * _width,
        _config.trail_shrink, _config.trail_growth * _width);
    part_type_speed(_types.trail, _config.trail_speed_min * _length, _config.trail_speed_max * _length,
        _config.trail_speed_reduce, 0);
    part_type_life(_types.trail,
        round(_config.trail_life_min_base + _config.trail_life_min_length * _length),
        round(_config.trail_life_max_base + _config.trail_life_max_length * _length)
    );
    part_particles_create(global.particles.system, _x, _y, _types.trail, _trail_count);
    return true;
}

/// @description Emits continuous faction-coloured exhaust scaled by radius, mass and movement power.
function sc_particles_enemy_thrust_emit(_x, _y, _direction, _power, _mount_scale, _ship_radius, _mass, _palette)
{
    var _types = sc_particles_group_get("enemy_thrust");
    var _config = global.config.visual.enemy_thrust.trail;
    var _scale = sc_particles_enemy_thrust_scale(_power, _mount_scale, _ship_radius, _mass, _config);
    var _width = _scale.width;
    var _length = _scale.length;
    var _side_offset = random_range(-_config.side_spread, _config.side_spread) * _width;
    var _emit_x = _x + lengthdir_x(_side_offset, _direction + 90);
    var _emit_y = _y + lengthdir_y(_side_offset, _direction + 90);
    var _count = _width >= _config.wide_threshold ? _config.count_wide : _config.count_normal;

    part_type_colour3(_types.trail, _palette.core, _palette.energy, _palette.glow);
    part_type_direction(_types.trail, _direction - _config.direction_spread, _direction + _config.direction_spread, 0, 0);
    part_type_size(_types.trail, _config.size_min * _width,
        (_config.size_max_base + _config.size_max_power * _power) * _width,
        _config.shrink, _config.growth * _width);
    part_type_speed(_types.trail, _config.speed_min * _length, _config.speed_max * _length, _config.speed_reduce, 0);
    part_type_life(_types.trail,
        round(_config.life_min_base + _config.life_min_length * _length),
        round(_config.life_max_base + _config.life_max_length * _length)
    );
    part_particles_create(global.particles.system, _emit_x, _emit_y, _types.trail, _count);
    return true;
}