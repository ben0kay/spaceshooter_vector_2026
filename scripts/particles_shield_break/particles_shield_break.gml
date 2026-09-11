/// @description Registers soft shield motes and outward energy streaks.
function sc_particles_register_shield_break()
{
    var _blur = sc_particles_type_create();
    var _streak = sc_particles_type_create();
    if (!part_type_exists(_blur) || !part_type_exists(_streak)) return false;

    var _config = global.config.visual.shield.break_effect.particles;

    part_type_sprite(_blur, s_blur, false, false, false);
    part_type_size(_blur, _config.blur.size_min, _config.blur.size_max, _config.blur.growth, 0);
    part_type_alpha3(_blur, 0.7, 0.3, 0);
    part_type_speed(_blur, _config.blur.speed_min, _config.blur.speed_max, -0.025, 0);
    part_type_direction(_blur, 0, 359, 0, 0);
    part_type_orientation(_blur, 0, 359, 0, 3, false);
    part_type_life(_blur, _config.blur.life_min, _config.blur.life_max);
    part_type_blend(_blur, true);

    part_type_sprite(_streak, s_broad_flame_body_white, false, false, false);
    part_type_size(_streak, _config.streak.size_min, _config.streak.size_max, _config.streak.growth, 0);
    part_type_scale(_streak, _config.streak.length_scale, _config.streak.width_scale);
    part_type_alpha3(_streak, 0.8, 0.5, 0);
    part_type_speed(_streak, _config.streak.speed_min, _config.streak.speed_max, _config.streak.speed_reduction, 0);
    part_type_direction(_streak, 0, 359, 0, 0);
    part_type_orientation(_streak, -7, 7, 0, 2, true);
    part_type_life(_streak, _config.streak.life_min, _config.streak.life_max);
    part_type_blend(_streak, true);

    return sc_particles_group_register("shield_break", {
        blur: _blur,
        streak: _streak
    });
}

/// @description Emits shield-coloured blurs and directional streaks around an elliptical shield.
function sc_particles_shield_break_emit(_x, _y, _angle, _sprite, _palette)
{
    var _types = sc_particles_group_get("shield_break");
    if (!is_struct(_types)) return false;

    var _config = global.config.visual.shield.break_effect.particles;
    var _width = sprite_get_width(_sprite);
    var _height = sprite_get_height(_sprite);
    var _radius_x = _width * 0.47;
    var _radius_y = _height * 0.47;
    var _diameter = max(_width, _height);
    var _amount = clamp(round(_diameter / _config.spacing), _config.amount_min, _config.amount_max);
    var _size_ratio = _diameter / _config.size_reference;
    var _size_scale = clamp(power(_size_ratio, 1.25), 0.32, 2);

    part_type_colour3(_types.blur, _palette.core, _palette.energy, _palette.glow);
    part_type_colour3(_types.streak, _palette.core, _palette.energy, _palette.glow);

    part_type_size(
        _types.blur,
        _config.blur.size_min * _size_scale,
        _config.blur.size_max * _size_scale,
        _config.blur.growth * _size_scale,
        0
    );

    part_type_size(
        _types.streak,
        _config.streak.size_min * _size_scale,
        _config.streak.size_max * _size_scale,
        _config.streak.growth * _size_scale,
        0
    );

    for (var _i = 0; _i < _amount; ++_i)
    {
        var _perimeter_angle = (_i / _amount) * 360 + random_range(-6, 6);
        var _local_x = lengthdir_x(_radius_x, _perimeter_angle);
        var _local_y = lengthdir_y(_radius_y, _perimeter_angle);
        var _particle_x = _x + lengthdir_x(_local_x, _angle) + lengthdir_x(_local_y, _angle + 90);
        var _particle_y = _y + lengthdir_y(_local_x, _angle) + lengthdir_y(_local_y, _angle + 90);
        var _direction = point_direction(_x, _y, _particle_x, _particle_y);

        part_type_direction(
            _types.blur,
            _direction - _config.direction_spread,
            _direction + _config.direction_spread,
            0,
            0
        );

        part_particles_create(
            global.particles.impact_system,
            _particle_x,
            _particle_y,
            _types.blur,
            1
        );

        if (random(1) < _config.streak.chance)
        {
            part_type_direction(
                _types.streak,
                _direction - _config.direction_spread * 0.45,
                _direction + _config.direction_spread * 0.45,
                0,
                0
            );

            part_particles_create(
                global.particles.impact_system,
                _particle_x,
                _particle_y,
                _types.streak,
                1
            );
        }
    }

    return true;
}