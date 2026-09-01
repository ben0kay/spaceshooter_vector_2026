/// @description Registers all shared Simulant particle types.
function sc_particles_register_simulant()
{
    var _palette =
        sc_faction_palette_get(Faction.SIMULANT);

    if (!is_struct(_palette))
    {
        show_debug_message(
            "SIMULANT PARTICLE ERROR - palette missing"
        );

        return false;
    }

    var _trail = sc_particles_type_create();
    var _ignition = sc_particles_type_create();

    if (
        !part_type_exists(_trail)
        || !part_type_exists(_ignition)
    )
    {
        show_debug_message(
            "SIMULANT PARTICLE ERROR - type creation failed"
        );

        return false;
    }

    // Detached violet engine energy.
    part_type_sprite(
        _trail,
        s_blur,
        false,
        false,
        false
    );

    part_type_size(
        _trail,
        0.12,
        0.24,
        -0.004,
        0.03
    );

    part_type_colour3(
        _trail,
        _palette.core,
        _palette.energy,
        _palette.glow
    );

    part_type_alpha3(
        _trail,
        0.85,
        0.55,
        0
    );

    part_type_speed(
        _trail,
        0.8,
        2.2,
        -0.03,
        0.12
    );

    part_type_direction(
        _trail,
        172,
        188,
        0,
        0
    );

    part_type_life(
        _trail,
        14,
        24
    );

    part_type_blend(
        _trail,
        true
    );

    // Expanding ignition pulse.
    part_type_sprite(
        _ignition,
        s_ring,
        false,
        false,
        false
    );

    part_type_size(
        _ignition,
        0.2,
        0.28,
        0.055,
        0
    );

    part_type_colour2(
        _ignition,
        _palette.core,
        _palette.energy
    );

    part_type_alpha2(
        _ignition,
        0.9,
        0
    );

    part_type_speed(
        _ignition,
        0,
        0,
        0,
        0
    );

    part_type_life(
        _ignition,
        10,
        14
    );

    part_type_blend(
        _ignition,
        true
    );

    return sc_particles_group_register(
        "simulant",
        {
            trail: _trail,
            ignition: _ignition
        }
    );
}

/// @description Emits one Simulant engine ignition burst.
function sc_particles_simulant_ignition(
    _x,
    _y,
    _direction,
    _scale
)
{
    var _types =
        sc_particles_group_get("simulant");

    if (!is_struct(_types))
        return false;

    part_type_size(
        _types.ignition,
        0.2 * _scale,
        0.28 * _scale,
        0.055 * _scale,
        0
    );

    part_particles_create(
        global.particles.system,
        _x,
        _y,
        _types.ignition,
        1
    );

    part_type_direction(
        _types.trail,
        _direction - 22,
        _direction + 22,
        0,
        0
    );

    part_type_size(
        _types.trail,
        0.16 * _scale,
        0.3 * _scale,
        -0.005,
        0.04
    );

    part_particles_create(
        global.particles.system,
        _x,
        _y,
        _types.trail,
        5
    );

    return true;
}

/// @description Emits one low-cost Simulant thrust particle.
function sc_particles_simulant_thrust(
    _x,
    _y,
    _direction,
    _power,
    _scale
)
{
    var _types =
        sc_particles_group_get("simulant");

    if (!is_struct(_types))
        return false;

    part_type_direction(
        _types.trail,
        _direction - 8,
        _direction + 8,
        0,
        0
    );

    part_type_size(
        _types.trail,
        0.1 * _scale,
        (0.14 + 0.1 * _power) * _scale,
        -0.004,
        0.02
    );

    part_particles_create(
        global.particles.system,
        _x,
        _y,
        _types.trail,
        1
    );

    return true;
}