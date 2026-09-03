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

/// @description Emits a faction-coloured ignition burst scaled by ship radius, visual mass and mount size.
function sc_particles_enemy_thrust_ignition(_x, _y, _direction, _power, _mount_scale, _ship_radius, _visual_mass, _palette)
{
    var _types = sc_particles_group_get("enemy_thrust");
    var _size_factor = clamp(_ship_radius / 52, 0.65, 2.5);
    var _mass_factor = clamp(_visual_mass, 0.5, 3);
    var _width = _mount_scale * lerp(0.8, _size_factor, 0.72);
    var _length = _mount_scale * (0.7 + _mass_factor * 0.45) * lerp(0.8, 1.3, _power);
    var _trail_count = clamp(ceil(_width * 4), 3, 8);

    part_type_colour2(_types.ignition, _palette.core, _palette.energy);
    part_type_size(_types.ignition, 0.22 * _width, 0.34 * _width, 0.065 * _width, 0);
    part_type_life(_types.ignition, round(10 + _mass_factor * 2), round(14 + _mass_factor * 3));
    part_particles_create(global.particles.system, _x, _y, _types.ignition, 1);

    part_type_colour3(_types.trail, _palette.core, _palette.energy, _palette.glow);
    part_type_direction(_types.trail, _direction - 20, _direction + 20, 0, 0);
    part_type_size(_types.trail, 0.14 * _width, 0.3 * _width, -0.005, 0.035 * _width);
    part_type_speed(_types.trail, 1.2 * _length, 3.2 * _length, -0.04, 0);
    part_type_life(_types.trail, round(10 + 4 * _length), round(16 + 7 * _length));
    part_particles_create(global.particles.system, _x, _y, _types.trail, _trail_count);
    return true;
}

/// @description Emits continuous faction-coloured exhaust; radius controls width while mass and speed control length.
function sc_particles_enemy_thrust_emit(_x, _y, _direction, _power, _mount_scale, _ship_radius, _visual_mass, _palette)
{
    var _types = sc_particles_group_get("enemy_thrust");
    var _size_factor = clamp(_ship_radius / 52, 0.65, 2.5);
    var _mass_factor = clamp(_visual_mass, 0.5, 3);
    var _width = _mount_scale * lerp(0.8, _size_factor, 0.72);
    var _length = _mount_scale * (0.65 + _mass_factor * 0.42) * lerp(0.55, 1.75, _power);
    var _side_offset = random_range(-2.5, 2.5) * _width;
    var _emit_x = _x + lengthdir_x(_side_offset, _direction + 90);
    var _emit_y = _y + lengthdir_y(_side_offset, _direction + 90);
    var _count = _width >= 1.25 ? 2 : 1;

    part_type_colour3(_types.trail, _palette.core, _palette.energy, _palette.glow);
    part_type_direction(_types.trail, _direction - 7, _direction + 7, 0, 0);
    part_type_size(_types.trail, 0.1 * _width, (0.15 + 0.1 * _power) * _width, -0.004, 0.018 * _width);
    part_type_speed(_types.trail, 0.8 * _length, 2.3 * _length, -0.025, 0);
    part_type_life(_types.trail, round(11 + 4 * _length), round(17 + 7 * _length));
    part_particles_create(global.particles.system, _emit_x, _emit_y, _types.trail, _count);
    return true;
}