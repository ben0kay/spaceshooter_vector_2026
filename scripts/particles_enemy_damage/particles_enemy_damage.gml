/// @description Registers shared low-hull enemy particle types.
function sc_particles_register_enemy_damage()
{
    var _smoke = sc_particles_type_create();

    if (!part_type_exists(_smoke))
    {
        show_debug_message("ENEMY DAMAGE PARTICLE ERROR - smoke creation failed");
        return false;
    }

    part_type_sprite(_smoke, s_smoke_puff, false, false, true);
    part_type_size(_smoke, 0.3, 0.55, 0.018, 0.03);
    part_type_colour2(_smoke, c_white, c_gray);
    part_type_alpha3(_smoke, 0.7, 0.48, 0);
    part_type_speed(_smoke, 0.2, 0.8, -0.015, 0);
    part_type_direction(_smoke, 0, 359, 0, 0);
    part_type_orientation(_smoke, 0, 359, 0, 2, false);
    part_type_life(_smoke, 28, 46);
    part_type_blend(_smoke, false);

    return sc_particles_group_register("enemy_damage", {
        smoke: _smoke
    });
}

/// @description Emits one faction-coloured smoke plume.
function sc_particles_enemy_damage_smoke_emit(_x, _y, _scale, _severity, _fx)
{
    var _types = sc_particles_group_get("enemy_damage");
    if (!is_struct(_types)) return false;

    var _config = global.config.visual.enemy_damage;
    var _size = _scale * lerp(_config.size_min, _config.size_max, _severity);

    part_type_colour2(_types.smoke, _fx.colour_light, _fx.colour_dark);
    part_type_size(_types.smoke, _size * 0.72, _size, _config.growth * _scale, _config.size_wiggle);
    part_type_alpha3(_types.smoke, lerp(0.48, 0.82, _severity), lerp(0.32, 0.58, _severity), 0);
    part_type_speed(_types.smoke, _config.speed_min, _config.speed_max, _config.speed_reduce, 0);
    part_type_life(_types.smoke,
        round(lerp(_config.life_min, _config.life_min_severe, _severity)),
        round(lerp(_config.life_max, _config.life_max_severe, _severity))
    );

    part_particles_create(global.particles.impact_system, _x, _y, _types.smoke, 1);
    return true;
}