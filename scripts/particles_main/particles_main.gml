/// @description Creates the shared background and foreground particle systems.
function sc_particles_init()
{
    var _system = part_system_create();
    var _impact_system = part_system_create();

    if (!part_system_exists(_system) || !part_system_exists(_impact_system))
    {
        if (part_system_exists(_system)) part_system_destroy(_system);
        if (part_system_exists(_impact_system)) part_system_destroy(_impact_system);
        show_debug_message("PARTICLE SYSTEM ERROR - creation failed");
        return false;
    }

    global.particles = { system: _system, impact_system: _impact_system, groups: {}, owned_types: [] };

    part_system_depth(_system, 10);
    part_system_depth(_impact_system, -10);

    if (!sc_particles_register_attack_telegraph()
    || !sc_particles_register_enemy_thrust()
    || !sc_particles_register_enemy_damage()
    || !sc_particles_register_corporation_thrust()
    || !sc_particles_register_simulant()
    || !sc_particles_register_shard()
    || !sc_particles_register_shockwave()
    || !sc_particles_register_beam_impact()
	|| !sc_particles_resource_pickup_register()
    || !sc_particles_register_projectile_content()
    || !sc_particles_register_weapon_content())
    {
        sc_particles_destroy();
        return false;
    }

    // Register additional particle families here.
    show_debug_message("PARTICLE SYSTEMS INITIALIZED");
    return true;
}

/// @description Registers reusable palette-driven beam contact particles.
function sc_particles_register_beam_impact()
{
    var _spark = sc_particles_type_create();
    var _mote = sc_particles_type_create();

    if (!part_type_exists(_spark) || !part_type_exists(_mote))
        return false;

    part_type_sprite(_spark, s_particle_trail_white_beam, false, false, false);
    part_type_size(_spark, 0.045, 0.1, -0.003, 0.012);
    part_type_scale(_spark, 1, 0.38);
    part_type_alpha3(_spark, 1, 0.72, 0);
    part_type_speed(_spark, 1.2, 3.8, -0.07, 0);
    part_type_direction(_spark, 0, 359, 0, 0);
    part_type_orientation(_spark, -10, 10, 0, 4, true);
    part_type_life(_spark, 9, 17);
    part_type_blend(_spark, true);

    part_type_sprite(_mote, s_blur, false, false, false);
    part_type_size(_mote, 0.05, 0.11, 0.002, 0.015);
    part_type_alpha3(_mote, 0.9, 0.5, 0);
    part_type_speed(_mote, 0.35, 1.4, -0.025, 0);
    part_type_direction(_mote, 0, 359, 0, 0);
    part_type_life(_mote, 13, 24);
    part_type_blend(_mote, true);

    return sc_particles_group_register("beam_impact", {
        spark: _spark,
        mote: _mote
    });
}

/// @description Emits faction-coloured particles from one beam's visual endpoint.
function sc_particles_beam_impact_emit(_area, _data)
{
    var _runtime = _data.runtime;
    var _impact = _data.visual.impact;
    if (!_runtime.impact_active || !_impact.particles_enabled) return false;
    if ((GAME_TICK + real(_area.id)) mod max(1, round(_impact.particle_interval)) != 0) return false;

    var _x = _area.x + lengthdir_x(_runtime.visual_length, _data.direction);
    var _y = _area.y + lengthdir_y(_runtime.visual_length, _data.direction);

    if (!sc_optimization_circle_visible(_x, _y, 64, 32))
        return false;

    var _particles = sc_particles_group_get("beam_impact");
    if (!is_struct(_particles)) return false;

    var _palette = _data.visual.palette;
    var _direction = _data.direction + 180 + random_range(-65, 65);

    part_type_colour3(_particles.spark, _palette.core, _palette.energy, _palette.glow);
    part_type_colour3(_particles.mote, _palette.core, _palette.energy, _palette.glow);

    part_type_direction(_particles.spark, _direction - 20, _direction + 20, 0, 0);
    part_type_direction(_particles.mote, _direction - 50, _direction + 50, 0, 0);

    part_particles_create(
        global.particles.impact_system,
        _x, _y,
        _particles.spark,
        irandom_range(1, 2)
    );

    part_particles_create(
        global.particles.impact_system,
        _x, _y,
        _particles.mote,
        1
    );

    return true;
}

/// @description Registers particle callbacks supplied by projectile definitions.
function sc_particles_register_projectile_content()
{
    var _keys = variable_struct_get_names(global.data.projectiles);

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _data = variable_struct_get(global.data.projectiles, _keys[_i]);
        var _visual = _data.visual;

        if (!variable_struct_exists(_visual, "particles_register_script")) continue;
        if (!_visual.particles_register_script()) return false;
    }

    return true;
}

/// @description Registers particle callbacks supplied by weapon definitions.
function sc_particles_register_weapon_content()
{
    var _keys = variable_struct_get_names(global.data.weapons);

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        var _weapon = variable_struct_get(
            global.data.weapons,
            _keys[_i]
        );

        var _delivery = _weapon.delivery;
        var _visual;

        switch (_delivery.type)
        {
            case AttackDelivery.AREA:
                _visual = _delivery.area.visual;
            break;

            case AttackDelivery.BEAM:
                _visual = _delivery.beam.visual;
            break;

            case AttackDelivery.DEPLOYABLE:
                _visual = _delivery.visual;
            break;

            default:
                continue;
        }

        if (!variable_struct_exists(
            _visual,
            "particles_register_script"
        ))
            continue;

        if (!_visual.particles_register_script())
            return false;
    }

    return true;
}

/// @description Creates and tracks one owned particle type.
function sc_particles_type_create()
{
    var _type = part_type_create();

    if (!part_type_exists(_type))
        return -1;

    var _owned_types = global.particles.owned_types;
    array_push(_owned_types, _type);
    global.particles.owned_types = _owned_types;

    return _type;
}

/// @description Registers one named particle family.
function sc_particles_group_register(_key, _data)
{
    if (variable_struct_exists(global.particles.groups, _key))
    {
        show_debug_message("PARTICLE GROUP ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.particles.groups, _key, _data);
    return true;
}

/// @description Returns one registered particle family.
function sc_particles_group_get(_key)
{
    if (!variable_global_exists("particles") || !is_struct(global.particles))
        return undefined;

    if (!variable_struct_exists(global.particles.groups, _key))
        return undefined;

    return variable_struct_get(global.particles.groups, _key);
}

/// @description Destroys every owned particle type and particle system.
function sc_particles_destroy()
{
    if (!variable_global_exists("particles") || !is_struct(global.particles))
        return;

    var _owned_types = global.particles.owned_types;

    for (var _i = 0; _i < array_length(_owned_types); _i++)
    {
        var _type = _owned_types[_i];

        if (part_type_exists(_type))
            part_type_destroy(_type);
    }

    var _system = global.particles.system;
    var _impact_system = global.particles.impact_system;

    if (part_system_exists(_system)) part_system_destroy(_system);
    if (part_system_exists(_impact_system)) part_system_destroy(_impact_system);

    global.particles = undefined;
    show_debug_message("PARTICLE SYSTEMS DESTROYED");
}