/// @description Registers the generic faction-tinted attack-charge particle.
function sc_particles_register_attack_telegraph()
{
    var _charge = sc_particles_type_create();

    if (!part_type_exists(_charge))
    {
        show_debug_message("ATTACK TELEGRAPH PARTICLE ERROR - type creation failed");
        return false;
    }

    part_type_sprite(_charge, s_blur, false, false, false);
    part_type_size(_charge, 0.035, 0.075, -0.002, 0.008);
    part_type_alpha3(_charge, 0.9, 0.6, 0);
    part_type_speed(_charge, 0.4, 1.15, -0.04, 0);
    part_type_direction(_charge, 0, 359, 0, 0);
    part_type_life(_charge, 14, 24);
    part_type_blend(_charge, true);

    return sc_particles_group_register("attack_telegraph", { charge: _charge });
}

/// @description Emits generic charge particles tinted from the attacking faction.
function sc_particles_attack_telegraph_emit(_enemy, _attack, _transform, _progress, _palette, _config)
{
    var _particles = sc_particles_group_get("attack_telegraph");
    if (!is_struct(_particles)) return;

    var _radius = _enemy.enemy.visual.radius * _config.scale;
    var _spawn_radius = lerp(_radius * 0.34, _radius * 0.08, _progress);
    var _angle = random(360);
    var _x = _transform.x + lengthdir_x(_spawn_radius, _angle);
    var _y = _transform.y + lengthdir_y(_spawn_radius, _angle);
    var _direction = point_direction(_x, _y, _transform.x, _transform.y);

    part_type_colour3(_particles.charge, _palette.core, _palette.energy, _palette.glow);
    part_type_direction(_particles.charge, _direction - 10, _direction + 10, 0, 0);
    part_particles_create(global.particles.impact_system, _x, _y, _particles.charge, _progress > 0.7 ? 2 : 1);
}