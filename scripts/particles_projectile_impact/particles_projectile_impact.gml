/// @description Registers one reusable projectile-impact particle family.
function sc_particles_projectile_impact_register(_key, _palette, _config)
{
    var _flash = sc_particles_type_create();
    var _ring = sc_particles_type_create();
    var _spark = sc_particles_type_create();

    if (!part_type_exists(_flash) || !part_type_exists(_ring) || !part_type_exists(_spark))
    {
        show_debug_message("PROJECTILE IMPACT PARTICLE ERROR - type creation failed: " + _key);
        return false;
    }

    part_type_sprite(_flash, s_blur, false, false, false);
    part_type_size(_flash, 0.24, 0.34, 0.06, 0);
    part_type_colour3(_flash, _palette.core, _palette.energy, _palette.glow);
    part_type_alpha3(_flash, 1, 0.7, 0);
    part_type_speed(_flash, 0, 0, 0, 0);
    part_type_life(_flash, 6, 9);
    part_type_blend(_flash, true);

    part_type_sprite(_ring, s_ring, false, false, false);
    part_type_size(_ring, 0.14, 0.2, 0.07, 0);
    part_type_colour2(_ring, _palette.core, _palette.energy);
    part_type_alpha2(_ring, 0.95, 0);
    part_type_speed(_ring, 0, 0, 0, 0);
    part_type_life(_ring, 8, 12);
    part_type_blend(_ring, true);

    part_type_sprite(_spark, s_blur, false, false, false);
    part_type_size(_spark, 0.045, 0.09, -0.003, 0.015);
    part_type_colour3(_spark, _palette.core, _palette.energy, _palette.glow);
    part_type_alpha3(_spark, 1, 0.7, 0);
    part_type_speed(_spark, _config.speed_min, _config.speed_max, -0.08, 0.1);
    part_type_direction(_spark, 0, 360, 0, 0);
    part_type_orientation(_spark, 0, 0, 0, 0, true);
    part_type_life(_spark, 8, 15);
    part_type_blend(_spark, true);

    return sc_particles_group_register(_key, {
        flash: _flash,
        ring: _ring,
        spark: _spark,
        config: _config
    });
}

/// @description Emits one projectile-impact burst scaled by its launched projectile.
function sc_particles_projectile_impact_emit(_key, _x, _y, _direction, _projectile_scale = 1)
{
    var _types = sc_particles_group_get(_key);
    if (!is_struct(_types)) return false;

    var _config = _types.config;
    var _system = global.particles.impact_system;
    var _scale = _config.scale * max(0.1, _projectile_scale);
    var _speed_scale = sqrt(max(0.1, _projectile_scale));
    var _reverse = _direction + 180;

    part_type_size(_types.flash, 0.24 * _scale, 0.34 * _scale, 0.06 * _scale, 0);
    part_type_size(_types.ring, 0.14 * _scale, 0.2 * _scale, 0.07 * _scale, 0);

    part_particles_create(_system, _x, _y, _types.flash, 2);
    part_particles_create(_system, _x, _y, _types.ring, 1);

    part_type_size(_types.spark, 0.045 * _scale, 0.09 * _scale, -0.003 * _scale, 0.015);
    part_type_direction(_types.spark, _reverse - _config.spark_spread, _reverse + _config.spark_spread, 0, 0);
    part_type_speed(_types.spark, _config.speed_min * _speed_scale, _config.speed_max * _speed_scale, -0.08, 0.1);
    part_particles_create(_system, _x, _y, _types.spark, _config.spark_amount);

    part_type_direction(_types.spark, 0, 359, 0, 0);
    part_type_speed(_types.spark, _config.speed_min * 0.45 * _speed_scale, _config.speed_max * 0.65 * _speed_scale, -0.06, 0.08);
    part_particles_create(_system, _x, _y, _types.spark, _config.fragment_amount);

    return true;
}