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
		|| !sc_particles_register_simulant()
		|| !sc_particles_register_shard()
		|| !sc_particles_register_shockwave()
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